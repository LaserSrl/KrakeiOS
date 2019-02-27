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
        // Preparo la view che verrà impostata come background per identificare
        // la cella selezionata.
        let selectedStateView = UIView()
        KTheme.current.applyTheme(toView: selectedStateView, style: .selected)
        selectedBackgroundView = selectedStateView
    }

}

open class KOTPStopDetailViewController: KOTPBasePublicTransportListMapViewController<BusLine> {

    public var sourceStop: KOTPStopItem?

    public var patternGeometryLoader: KLinePathLoader? = KOpenTripPlannerLinePathLoader()

    private var selectedLine: BusLine? = nil

    private lazy var sourceRegex: NSRegularExpression? = try? NSRegularExpression(
        pattern: "^([\\s\\S]+) to ([\\s\\S]+) from ([\\s\\S]+)$",
        options: .caseInsensitive)
    private lazy var destinationRegex: NSRegularExpression? = try? NSRegularExpression(
        pattern: "^([\\s\\S]+) to ([\\s\\S]+)$" ,
        options: .caseInsensitive)
    private lazy var calendar = Calendar(identifier: .gregorian)
    private lazy var linesPlaceholderImage: UIImage? = {
        if let originalImage = UIImage(otpNamed: "bus_stop")?.imageTinted(UIColor.white) {
            let drawingRect = CGRect(origin: .zero, size: CGSize(width: 28, height: 28))
            UIGraphicsBeginImageContextWithOptions(drawingRect.size, false, 0)
            let image: UIImage?
            if let context = UIGraphicsGetCurrentContext() {
                context.setFillColor(UIColor.tint.cgColor)
                let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: 6)
                context.addPath(path.cgPath)
                context.fillPath()
                let edgeInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
                #if swift(>=4.2)
                let toDraw = drawingRect.inset(by: edgeInset)
                #else
                let toDraw =  UIEdgeInsetsInsetRect(drawingRect, edgeInset)
                #endif
                originalImage.draw(in: toDraw)
                image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            } else {
                image = originalImage
            }
            return image
        }
        return nil
    }()
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

    // MARK: - View controller lifecycle

    deinit {
        if loadingTask != nil {
            loadingTask?.cancel()
            loadingTask = nil
        }
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
        loadTimes()
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
        cell.busImageView.image = linesPlaceholderImage
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Imposto l'altezza della table view come al primo accesso.
        resetTableViewVisibility(animated: true)
        // Carico gli stops per l'item selezionato.
        loadStops(for: items![indexPath.row])
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
        polylineRenderer.strokeColor = KTripTheme.shared.colorFor(travelMode: .transit)
        return polylineRenderer
    }

    open override func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let color: UIColor? = isSourceStopAnnotation(annotation) ? nil : .lightGray
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

    private func loadTimes() {
        guard let sourceStop = sourceStop else { return }

        MBProgressHUD.showAdded(to: view, animated: true)
        var extras = KRequestParameters.parameters(currentPage: 1, pageSize: 9999)
        extras["id"] = sourceStop.originalId ?? NSNull()
        extras.update(other: KRequestParameters.parametersNoCache())
        loadingTask = OGLCoreDataMapper.sharedInstance()
            .loadData(withDisplayAlias: "otp/otp-stop-times",
                      extras: extras) { [weak self] (cacheId, error, hasCompleted) in
                        guard let strongSelf = self, hasCompleted else { return }

                        MBProgressHUD.hide(for: strongSelf.view, animated: true)
                        if let cacheId = cacheId {
                            let cache = OGLCoreDataMapper.sharedInstance().displayPathCache(from: cacheId)
                            if let patterns = cache.cacheItems.array as? [PatternProtocol], !patterns.isEmpty {
                                strongSelf.prepareLines(from: patterns)
                            } else {
                                // TODO: considerare se gestire il caso pattern vuoti.
                            }
                        } else if let error = error {
                            KMessageManager
                                .showMessage(ObjC: error.localizedDescription,
                                             type: .error,
                                             layout: .tabView,
                                             fromViewController: nil)
                        }
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
                            let line = BusLine(lineNumber: step.id,
                                               destination: step.destination,
                                               scheduledArrival: scheduledArrival,
                                               patternId: pattern.patternId!)

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
        MBProgressHUD.showAdded(to: view, animated: true)
        var extras = KRequestParameters.parametersNoCache()
        extras["patternid"] = line.patternId
        selectedLine = line
        loadingTask = OGLCoreDataMapper.sharedInstance()
            .loadData(withDisplayAlias: "otp/otpstopspattern",
                      extras: extras) { [weak self] (cacheId, error, hasCompleted) in
                        guard let strongSelf = self, hasCompleted else { return }

                        if let cacheId = cacheId {
                            let cache = OGLCoreDataMapper.sharedInstance().displayPathCache(from: cacheId)
                            if let stops = cache.cacheItems.array as? [KOTPStopItem], !stops.isEmpty {
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
                        }
                        if hasCompleted {
                            MBProgressHUD.hide(for: strongSelf.view, animated: true)
                        }
        }

        patternGeometryLoader?.retrievePathPoints(for: line, with: { [weak self](line, polyline) in

            if let sSelf = self, let polyline = polyline {
                if line.lineNumber == sSelf.selectedLine?.lineNumber {
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
