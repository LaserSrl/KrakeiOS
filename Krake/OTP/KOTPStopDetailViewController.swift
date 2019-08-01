//
//  KOTPStopDetailViewController.swift
//  Krake
//
//  Created by Marco Zanino on 12/04/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import UIKit
import MBProgressHUD
import MapKit

public struct KOTPPatternStep {
    let id: String
    let destination: String
}

public class KOTPStopDetailViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    @IBOutlet weak var busImageView: UIImageView!
    @IBOutlet weak var arrivalImageView: UIImageView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Imposto il tint color dell'immagine.
        busImageView.tintColor = KTheme.current.color(.tint)
        arrivalImageView.tintColor = KTheme.current.color(.tint)
        arrivalImageView.image = UIImage(otpNamed: "durata")?.withRenderingMode(.alwaysTemplate)
        arrivalImageView.isHidden = true
    }

}

open class KOTPStopDetailViewController: KOTPBasePublicTransportListMapViewController<KBusLine> {

    
    public static var lineName: (_ line: KBusLine) -> String = { (line) -> String in
        let lastStop = !line.lastStop ? "" : "(Last stop)".localizedString()
        return String(format: "Linea %@ verso %@ %@".localizedString(),
               line.lineNumber, line.destination,lastStop)
    }
    
    
    public var sourceStop: KOTPStopItem?

    private var selectedLine: KBusLine? = nil
    private var lineOverlay: MKPolyline? = nil

    private lazy var sourceRegex: NSRegularExpression? = try? NSRegularExpression(
        pattern: "^([\\s\\S]+) to ([\\s\\S]+) from ([\\s\\S]+)$",
        options: .caseInsensitive)
    private lazy var destinationRegex: NSRegularExpression? = try? NSRegularExpression(
        pattern: "^([\\s\\S]+) to ([\\s\\S]+)$" ,
        options: .caseInsensitive)
    private lazy var calendar = Calendar(identifier: .gregorian)
    
    public override var items: [KBusLine]? {
        didSet {
            // Verifico se sono presenti nuove linee.
            if items?.isEmpty ?? true {
                // Nascondo la table view.
                hideTableView(animated: true)
            } else {
                if tableViewContainer.bounds.height < minimumTableViewContainerHeight || minimumTableViewContainerHeight == 0 {
                // Disabilito lo scroll della table view.
                tableView.isScrollEnabled = false
                // Aggiorno l'altezza della table view di modo che la prima
                // cella sia visibile.
                resetTableViewVisibility(animated: true)
                }
            }
            tableView.reloadData()
        }
    }

    private var intermediateStops: [KOTPStopItem]? {
        didSet {
            // Verifico se vi sono delle annotation da rimuovere dalla
            // mappa.
            if !(oldValue?.isEmpty ?? true) {
                mapView.removeAnnotations(oldValue!)
            }
            // Verifico che vi siano nuove fermate da mostrare all'utente.
            if let intermediateStops = intermediateStops {
                mapView.addAnnotations(intermediateStops)
                // Centro la mappa sui punti appena aggiunti.
                mapView.centerMap()
            }
        }
    }

    private var loadingTask: OMLoadDataTask? = nil
    private var timerForRefresh: Timer? = nil
    private var routes: [KOTPRoute]? = nil

    // MARK: - View controller lifecycle

    deinit {
        if loadingTask != nil {
            loadingTask?.cancel()
            loadingTask = nil
        }
        timerForRefresh?.invalidate()
        timerForRefresh = nil
        KLog("RELEASED")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Imposto il titolo sulla base della fermata di partenza.
        title = sourceStop?.name
        // Preparo la mappa.
        mapView.showsUserLocation = true
        if let sourceStop = sourceStop {
            mapView.addAnnotation(sourceStop)
            mapView.selectAnnotation(sourceStop, animated: false)
            mapView.centerMap()
        }
        // Aggiorno l'altezza che si presuppone abbiano le celle della table view.
        tableView.estimatedRowHeight = 60
        // Nascondo la table view finché non verranno scaricate le previsioni
        // per la fermata selezionata.
        hideTableView(animated: false)
        // Scarico le previsioni per la fermata corrente.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTimes))
        let secondForRefresh = KInfoPlist.OTP.secondForStopTimesRefresh
        if secondForRefresh > 0 {
            timerForRefresh = Timer.scheduledTimer(withTimeInterval: secondForRefresh, repeats: true, block: { [weak self](timer) in
                self?.loadTimes()
            })
        }

        minimumTableViewContainerHeight = 120
        
        KOpenTripPlannerLoader.shared.retrieveRoutesInfos(with: { [weak self](routes) in
            self?.routes = routes
            self?.loadTimes()
        })
        
        KOTPLocationManager.shared.completion = { [weak self](identifier) in
            guard let strongSelf = self else { return }
            for annotation in strongSelf.mapView.annotations where (annotation as? KOTPStopItem)?.originalId == identifier
            {
                strongSelf.mapView.removeAnnotation(annotation)
                strongSelf.mapView.addAnnotation(annotation)
            }
        }
    }

    override func tableViewContainerAvailableFrame() -> CGRect {
        return
            CGRect(
                origin: CGPoint(
                    x: 0,
                    y: topLayoutGuide.length),
                size: CGSize(
                    width: view.bounds.width,
                    height: view.bounds.height - topLayoutGuide.length))
    }

    // MARK: - Table view data source & delegate

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! KOTPStopDetailViewCell
        let line = items![indexPath.row]
        // Sulla base dei secondi rimanenti prima che arrivi il prossimo bus,
        // imposto la descrizione del tempo di attesa previsto.
        let arrivalTimeSeconds = line.realtimeArrival?.timeIntervalSinceNow ?? line.scheduledArrival.timeIntervalSinceNow
        let arrivalTimeDescription: String
        if arrivalTimeSeconds <= 60 {
            arrivalTimeDescription = "in arrivo".localizedString()
        }
        else if arrivalTimeSeconds < 60 * 60 {
            arrivalTimeDescription =
                String(format: "%0.f minuti".localizedString(), arrivalTimeSeconds / 60)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            arrivalTimeDescription =
                String(format: "ore %@".localizedString(), dateFormatter.string(from: line.scheduledArrival))
        }
        // Customizzo la cella sulla base delle informazioni ricevute.
        cell.titleLabel.text = KOTPStopDetailViewController.lineName(line)
        cell.arrivalLabel.text = arrivalTimeDescription
        if line.realtimeArrival != nil{
            cell.arrivalLabel.textColor = KTheme.current.color(.tint)
            DispatchQueue.main.async {
                cell.arrivalImageView.isHidden = false
            }
        }else{
            cell.arrivalLabel.textColor = UIColor.darkGray
            DispatchQueue.main.async {
                cell.arrivalImageView.isHidden = true
            }
        }
        
        cell.busImageView.image = KTripTheme.shared.imageFor(vehicleType: line.routeInfo?.mode ?? .other).withRenderingMode(.alwaysTemplate)
        cell.busImageView.backgroundColor = line.routeInfo?.color ?? KTheme.current.color(.tint)
        cell.busImageView.tintColor = cell.busImageView.backgroundColor?.constrastTextColor()
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Imposto l'altezza della table view come al primo accesso.
        resetTableViewVisibility(animated: true, force: true)

        tableView.scrollToRow(at: indexPath, at: .top, animated: false)

        // Carico gli stops per l'item selezionato.
        loadStops(for: items![indexPath.row])
        if let sourceStop = sourceStop {
            mapView.removeAnnotation(sourceStop)
            mapView.addAnnotation(sourceStop)
        }
    }

    // MARK: - Map view delegate

    public final override func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Corpo della funzione vuoto, per evitare lo zoom sulla MKAnnotation
        // selezionata.
    }
    
    open override func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control.tag == 15, let otpitem = view.annotation as? KOTPStopItem {
            let identifier = (view.annotation as? KOTPStopItem)?.originalId
            let region = KOTPLocationManager.shared.monitoring(from: identifier)
            let message = region == nil ? "Vuoi abilitare la funzionalità di notifica quanto sei nei paraggi della fermata?" : "Vuoi disabilitare la notifica?"
            let alert = UIAlertController(title: "Notificami quando sto per arrivare", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Si", style: .default, handler: { (action) in
                if region != nil
                {
                    KOTPLocationManager.shared.stopMonitoring(region: region!)
                    (view.rightCalloutAccessoryView as? UIButton)?.isSelected = false
                }else{
                    KOTPLocationManager.shared.startMonitoring(regionFrom: otpitem, completion: { (success) in
                        (view.rightCalloutAccessoryView as? UIButton)?.isSelected = success
                    })
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }else{
            super.mapView(mapView, annotationView: view, calloutAccessoryControlTapped: control)
        }
    }

    @objc(mapView:rendererForOverlay:)
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.lineWidth = 3.0
        polylineRenderer.strokeColor = selectedLine?.routeInfo?.color ?? KTripTheme.shared.colorFor(travelMode: .transit)
        return polylineRenderer
    }

    open override func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let pinColor: UIColor? = selectedLine?.routeInfo?.color
        let color: UIColor? = isSourceStopAnnotation(annotation) || annotation is KVehicleAnnotation ? pinColor : .lightGray
        let scaleFactor: CGFloat = isSourceStopAnnotation(annotation) || annotation is KVehicleAnnotation ? 1.0 : 0.7
        let pinView =
            mapView.dequeueReusableAnnotationViewWithAnnotation(annotation, forcedColor: color) ?? KAnnotationView(annotation: annotation, forcedColor: color, scaleFactor: scaleFactor)
        if annotation is KVehicleAnnotation
        {
            pinView.canShowCallout = false
        }else{
            pinView.addNavigationButton()
            if !isSourceStopAnnotation(annotation) {
                if pinView.rightCalloutAccessoryView == nil {
                    let rightButton = UIButton(type: .custom)
                    rightButton.backgroundColor = KTheme.current.color(.tint)
                    rightButton.tintColor = KTheme.current.color(.textTint)
                    rightButton.frame = CGRect(x: 0, y: 0, width: 32, height: 56)
                    rightButton.imageEdgeInsets = UIEdgeInsets(top: 13, left: 2, bottom: 14, right: 2)
                    rightButton.setImage(UIImage(krakeNamed: "add_alarm")?.withRenderingMode(.alwaysTemplate), for: .normal)
                    rightButton.setImage(UIImage(krakeNamed: "remove_alarm")?.withRenderingMode(.alwaysTemplate), for: .selected)
                    rightButton.tag = 15
                    pinView.rightCalloutAccessoryView = rightButton
                }
                (pinView.rightCalloutAccessoryView as? UIButton)?.isSelected = KOTPLocationManager.shared.monitoring(from: (annotation as? KOTPStopItem)?.originalId) != nil
            }
        }
        
        return pinView
    }

    private func isSourceStopAnnotation(_ annotation: MKAnnotation) -> Bool {
        guard let sourceStop = sourceStop else { return false }

        let sourceStopCoordinate = sourceStop.coordinate
        let currentAnnotationCoordinate = annotation.coordinate

        return sourceStopCoordinate.latitude == currentAnnotationCoordinate.latitude &&
            sourceStopCoordinate.longitude == currentAnnotationCoordinate.longitude &&
            sourceStop.title! == annotation.title!
    }

    // MARK: - Lines loading

    @objc func refreshTimes() {
        if lineOverlay != nil {
            mapView.removeOverlay(lineOverlay!)
            lineOverlay = nil
        }
        intermediateStops = nil
        if vehicleAnnotation != nil {
            mapView.removeAnnotation(vehicleAnnotation)

            vehicleAnnotation = nil
        }
          busTracker?.stopTrack()

        loadTimes()
    }

    private func loadTimes() {
        guard let sourceStop = sourceStop else { return }
        MBProgressHUD.showAdded(to: view, animated: true)
        if let stopId = sourceStop.originalId
        {
            KOpenTripPlannerLoader.shared.retrieveStopTimes(for: stopId, with: { [weak self](result) in
                guard let strongSelf = self else { return }
                MBProgressHUD.hide(for: strongSelf.view, animated: true)
                if let patterns = result, !patterns.isEmpty {
                    strongSelf.prepareLines(from: patterns)
                }
            })
        }
    }

    private func prepareLines(from patterns: [PatternProtocol]) {
        let numberFormatter = NumberFormatter()
        var hintableLines = [KBusLine]()
        for pattern in patterns {
            if let step = self.step(from: pattern.descriptionText,
                                    formattingNumbersWith: numberFormatter),
                let stopTimes = pattern.stopTimesList?.array as? [StopTimeProtocol], !stopTimes.isEmpty {

                for stopTime in stopTimes {
                    

                    if let stopTimeScheduledArrival = stopTime.scheduledDeparture,
                        let scheduledArrival = stopTimeScheduledArrival.otpSecondsToDate() {
                        let secondsUntilArrival = scheduledArrival.timeIntervalSinceNow
                        if secondsUntilArrival > 0 && secondsUntilArrival < 121 * 60 {
                            var realtimeArrival: Date? = nil
                            if let realTime = stopTime.realtimeDeparture, realTime.intValue > 0, realTime.compare(stopTimeScheduledArrival) != .orderedSame {
                                realtimeArrival = realTime.otpSecondsToDate()
                            }
                            
                            let routeInfo = routes?.filter({ (route) -> Bool in
                                return pattern.patternId!.starts(with: route.id)
                            }).first

                            let line = KBusLine(lineNumber: step.id,
                                               destination: step.destination,
                                               scheduledArrival: scheduledArrival,
                                               realtimeArrival: realtimeArrival,
                                               patternId: pattern.patternId!,
                                               tripId: stopTime.tripId!,
                                               routeInfo: routeInfo,
                                               lastStop: stopTime.lastStop)

                            hintableLines.append(line)
                        }
                    }
                }
            }
        }

        items = Array(Set(hintableLines)).sorted(by: { $0.scheduledArrival < $1.scheduledArrival })
    }

    private func step(from stepDescription: String?, formattingNumbersWith numberFormatter: NumberFormatter) -> KOTPPatternStep? {
        guard let stepDescription = stepDescription,
            let sourceRegex = sourceRegex,
            let destinationRegex = destinationRegex else { return nil }
        // Recupero le informazioni dello step utilizzando due possibili
        // espressioni regolari.
        let regexSearchRange = NSMakeRange(0, stepDescription.count)
        var regexSearchResult = sourceRegex.firstMatch(
            in: stepDescription,
            options: [],
            range: regexSearchRange)
        if regexSearchResult == nil {
            regexSearchResult = destinationRegex.firstMatch(
                in: stepDescription,
                options: [],
                range: regexSearchRange)
        }
        if let regexSearchResult = regexSearchResult {
            let legacyStepDescription = stepDescription as NSString
            // Recupero l'id dello step dal risultato della ricerca.
            #if swift(>=4.0)
                let id = legacyStepDescription.substring(with: regexSearchResult.range(at: 1))
            var destination = legacyStepDescription.substring(with: regexSearchResult.range(at: 2))
            #else
                let id = legacyStepDescription.substring(with: regexSearchResult.rangeAt(1))
            var destination = legacyStepDescription.substring(with: regexSearchResult.rangeAt(2))
            #endif
            if let firstParentesisIndex = destination
                .range(of: "(", options: [.backwards])
            {
                destination = String(destination[..<firstParentesisIndex.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return KOTPPatternStep(id: id, destination: destination)
        }
        // Non è stato possibile recuperare le informazioni riguardanti lo
        // step utilizzando le espressioni regolari conosciute.
        return nil
    }

    private func minutes(until arrival: NSNumber) -> Date? {
        guard let today = calendar.date(
            from: calendar.dateComponents([.year, .month, .day], from: Date())) else {
                return nil
        }
        return Date(timeInterval: TimeInterval(arrival.intValue), since: today)
    }

    // MARK: - Stops loading

    private func loadStops(for line: KBusLine) {
        mapView.removeOverlays(mapView.overlays)
        selectedLine = line
        MBProgressHUD.showAdded(to: view, animated: true)
        KOpenTripPlannerLoader.shared.retrieveStops(for: line, with: { [weak self](result) in
            guard let strongSelf = self else { return }
            if let stops = result, !stops.isEmpty {
                var retrievedStops = [KOTPStopItem]()
                var isAddable = false
                for stop in stops {
                    if isAddable {
                        retrievedStops.append(stop)
                    }
                    if stop.originalId == strongSelf.sourceStop?.originalId {
                        isAddable = true
                    }
                }
                strongSelf.intermediateStops = retrievedStops
            }
            MBProgressHUD.hide(for: strongSelf.view, animated: true)
        })
        
        KOpenTripPlannerLoader.shared.retrievePathPoints(for: line, with: { [weak self](line, polyline) in
            
            if let sSelf = self, let polyline = polyline {
                
                if line.lineNumber == sSelf.selectedLine?.lineNumber {
                    sSelf.lineOverlay = polyline
                    #if swift(>=4.2)
                    sSelf.mapView.addOverlay(polyline)
                    #else
                    sSelf.mapView.add(polyline)
                    #endif
                    sSelf.mapView.centerMap()
                }
            }
        })
        
        if let vehicleAnnotation = vehicleAnnotation{
            mapView.removeAnnotation(vehicleAnnotation)
            self.vehicleAnnotation = nil
        }
        busTracker?.stopTrack()
        let bus = KBusTracker(line: line)
        busTracker = bus
        busTracker?.startTrack(completion: { [weak self](location) in
            if let location = location,
                location.latitude != 0,
                location.longitude != 0
            {
                if self?.vehicleAnnotation == nil
                {
                    let vehicleAnnotation = KVehicleAnnotation(line)
                    vehicleAnnotation.coordinate = location
                    self?.vehicleAnnotation = vehicleAnnotation
                    self?.mapView.addAnnotation(vehicleAnnotation)
                    self?.mapView.selectAnnotation(vehicleAnnotation, animated: true)
                }
                else
                {
                    UIView.animate(withDuration: 0.5, animations: {
                        self?.vehicleAnnotation.coordinate = location
                    })
                }
            }else{
                if let vehicleAnnotation = self?.vehicleAnnotation{
                    self?.mapView.removeAnnotation(vehicleAnnotation)
                    self?.vehicleAnnotation = nil
                }
            }
        })
    }
    
    var busTracker: KBusTracker?
    var vehicleAnnotation: KVehicleAnnotation!
    
}
