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

    public override func awakeFromNib() {
        super.awakeFromNib()
        // Imposto il tint color dell'immagine.
        busImageView.tintColor = .tint
    }

}

open class KOTPStopDetailViewController: KOTPBasePublicTransportListMapViewController<BusLine> {

    public var sourceStop: KOTPStopItem?

    private var selectedLine: BusLine? = nil
    private var lineOverlay: MKPolyline? = nil

    private lazy var sourceRegex: NSRegularExpression? = try? NSRegularExpression(
        pattern: "^([\\s\\S]+) to ([\\s\\S]+) from ([\\s\\S]+)$",
        options: .caseInsensitive)
    private lazy var destinationRegex: NSRegularExpression? = try? NSRegularExpression(
        pattern: "^([\\s\\S]+) to ([\\s\\S]+)$" ,
        options: .caseInsensitive)
    private lazy var calendar = Calendar(identifier: .gregorian)
    
    public override var items: [BusLine]? {
        didSet {
            // Verifico se sono presenti nuove linee.
            if items?.isEmpty ?? true {
                // Nascondo la table view.
                hideTableView(animated: true)
            } else {
                // Disabilito lo scroll della table view.
                tableView.isScrollEnabled = false
                // Aggiorno l'altezza della table view di modo che la prima
                // cella sia visibile.
                resetTableViewVisibility(animated: true)
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
        if let secondForRefresh = KInfoPlist.OTP.secondForStopTimesRefresh {
            timerForRefresh = Timer.scheduledTimer(withTimeInterval: secondForRefresh.doubleValue, repeats: true, block: { [weak self](timer) in
                self?.loadTimes()
            })
        }
        
        KOpenTripPlannerLoader.shared.retrieveRoutesInfos(with: { [weak self](routes) in
            self?.routes = routes
            self?.loadTimes()
        })
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
        let arrivalTimeSeconds = line.scheduledArrival.timeIntervalSinceNow
        let arrivalTimeDescription: String
        if arrivalTimeSeconds > 0 && arrivalTimeSeconds < 60 * 60 {
            arrivalTimeDescription =
                String(format: "%0.f minuti", arrivalTimeSeconds / 60)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            arrivalTimeDescription =
                String(format: "ore %@", dateFormatter.string(from: line.scheduledArrival))
        }
        // Customizzo la cella sulla base delle informazioni ricevute.
        cell.titleLabel.text = String(format: "Linea %@ verso %@",
                                      line.lineNumber, line.destination)
        cell.arrivalLabel.text = arrivalTimeDescription
        
        cell.busImageView.image = KTripTheme.shared.imageFor(vehicleType: line.routeInfo?.mode ?? .other).withRenderingMode(.alwaysTemplate)
        cell.busImageView.backgroundColor = line.routeInfo?.color ?? UIColor.tint
        cell.busImageView.tintColor = UIColor.white
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Imposto l'altezza della table view come al primo accesso.
        resetTableViewVisibility(animated: true)
        // Carico gli stops per l'item selezionato.
        loadStops(for: items![indexPath.row])
        if let sourceStop = sourceStop{
            mapView.removeAnnotation(sourceStop)
            mapView.addAnnotation(sourceStop)
        }
    }

    // MARK: - Map view delegate

    public final override func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Corpo della funzione vuoto, per evitare lo zoom sulla MKAnnotation
        // selezionata.
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
        let color: UIColor? = isSourceStopAnnotation(annotation) ? pinColor : .lightGray
        let pinView =
            mapView.dequeueReusableAnnotationViewWithAnnotation(annotation, forcedColor: color) ?? KAnnotationView(annotation: annotation, forcedColor: color)
        pinView.addNavigationButton()
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
        var hintableLines = [BusLine]()
        var numberOfLinesFromPattern = 0
        for pattern in patterns {
            if let step = self.step(from: pattern.descriptionText,
                                    formattingNumbersWith: numberFormatter),
                let stopTimes = pattern.stopTimesList?.array as? [StopTimeProtocol], !stopTimes.isEmpty {

                numberOfLinesFromPattern = 0
                for stopTime in stopTimes {
                    var stopArrival: NSNumber? = nil

                     if let realTime = stopTime.realtimeDeparture, realTime.intValue > 0 {
                        stopArrival = realTime
                    }
                    else {
                        stopArrival = stopTime.scheduledDeparture
                    }

                    if let stopTimeScheduledArrival = stopArrival,
                        let scheduledArrival = minutes(until: stopTimeScheduledArrival) {
                        let secondsUntilArrival = scheduledArrival.timeIntervalSinceNow
                        if secondsUntilArrival > 0 && secondsUntilArrival < 121 * 60 {
                            
                            let routeInfo = routes?.filter({ (route) -> Bool in
                                return pattern.patternId!.starts(with: route.id)
                            }).first
                            
                            let line = BusLine(lineNumber: step.id,
                                               destination: step.destination,
                                               scheduledArrival: scheduledArrival,
                                               patternId: pattern.patternId!,
                                               routeInfo: routeInfo)

                            hintableLines.append(line)
                            numberOfLinesFromPattern += 1
                        }
                    }
                }
            }
        }
        items = hintableLines.sorted(by: { $0.scheduledArrival < $1.scheduledArrival })
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

    private func loadStops(for line: BusLine) {
        mapView.removeOverlays(mapView.overlays)
        selectedLine = line
        MBProgressHUD.showAdded(to: view, animated: true)
        KOpenTripPlannerLoader.shared.retrieveStops(for: line.patternId, with: { [weak self](result) in
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
                }
            }
        })
    }

}
