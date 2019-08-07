//
//  KOTPStopsViewController.swift
//  Pods
//
//  Created by Patrick on 27/06/16.
//
//
import UIKit
import Foundation
import MBProgressHUD
import MapKit

public typealias KOTPSearchRadius = UInt

open class KOTPStopsViewController: KOTPBasePublicTransportListMapViewController<KOTPStopItem>, KSearchPlaceDelegate, UITextFieldDelegate {

    @IBOutlet weak var sourceAddressTextField: UITextField!
    @IBOutlet weak var labelSlider: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchRadiusSlider: UISlider!
    @IBOutlet weak var searchViewHiddenBottom: NSLayoutConstraint!
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var stopSearch: UITextField!
    @IBOutlet weak var stopSearchStack: UIStackView!
    @IBOutlet weak var locationSearchStack: UIStackView!
    
    public static var defaultLocation: CLLocation?
    public static var defaultArea: MKCoordinateRegion! = KSearchPlaceViewController.prefferedRegion

    public static func stopsSearchController(enableStopSearch: Bool = false) -> KOTPStopsViewController
    {
        let bundle = Bundle(url: Bundle(for: KTripPlannerSearchController.self).url(forResource: "OTP", withExtension: "bundle")!)
        let storyboard = UIStoryboard(name: "OCOTPStoryboard", bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "KOTPStopsViewController") as! KOTPStopsViewController
        vc.enableStopSearch = enableStopSearch
        return vc
    }
    fileprivate var enableStopSearch: Bool = false
    fileprivate var prevRadius: UInt = 0
    fileprivate var fromLocation: MKPlacemark?{
        didSet {
            if let fromLocation = fromLocation, fromLocation.coordinate.latitude != 0 && fromLocation.coordinate.longitude != 0{
                prevRadius = 0
                for ann in mapView.annotations{
                    if ann is UserSelectedPoint{
                        mapView.removeAnnotation(ann)
                    }
                }
                let selectedLocation = CLLocation(
                    latitude: fromLocation.coordinate.latitude,
                    longitude: fromLocation.coordinate.longitude)
                CLGeocoder().reverseGeocodeLocation(selectedLocation) { (placemarks, error) in
                    if let placemark = placemarks?.first,
                        let name = placemark.name {

                        self.sourceAddressTextField.text = name
                    }
                }
                let plac = UserSelectedPoint(placemark: fromLocation)
                mapView.addAnnotation(plac)
                centerMap()
                searchStops(around: selectedLocation,
                            with: UInt(searchRadiusSlider.value/10)*10)
            }
        }
    }
    fileprivate var isUserCustomLocation: Bool = false
    fileprivate var circleOverlay: MKCircle?
    public override var items: [KOTPStopItem]? {
        didSet {
            // Rimuovo le vecchie annotations dalla mappa, se presenti.
            if let oldItems = oldValue, !oldItems.isEmpty {
                mapView.removeAnnotations(oldItems)
            }
            // Verifico se sono presenti nuove annotations. In caso positivo, le
            // mostro su mappa, altrimenti mostro un messaggio di errore all'utente.
            if items?.isEmpty ?? true {
                
            } else {
                mapView.addAnnotations(items!)
                // Imposto lo stato delle view utilizzando la trait collection
                // legata alla main view.
                manageViewState(for: view.bounds.size)
            }
            prepareTableViewForFirstUsage(using: items, animated: true)
            tableView.reloadData()
        }
    }
    private lazy var placeholderImage: UIImage? = {
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
                let toDraw = UIEdgeInsetsInsetRect(drawingRect, edgeInset)
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
    private lazy var searchInitializer: KOTPStopsSearchInitializer = KOTPBaseStopsSearchInitializer()

    deinit {
        searchViewHiddenBottom = nil
    }

    // MARK: - View controller lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        isTableViewPanningDisabled =
            view.traitCollection.verticalSizeClass == .compact

        isUserCustomLocation = false
        title = "PUBLIC_TRANSPORT".localizedString()
        sourceAddressTextField.placeholder = "FROM".localizedString()
        KTheme.current.applyTheme(toLabel: labelSlider, style: .subtitle)
        let initialSearchRadius =
            KOTPPreferences.retrieveSearchRadius(fallbackValue: 150)
        searchRadiusSlider.value = Float(initialSearchRadius)
        labelSlider.text = String(format: "%d m", initialSearchRadius)
        let item = UIButton(type: .system)
        item.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        item.setImage(UIImage(krakeNamed: "pin_pos"), for: .normal)
        item.tintColor = KTheme.current.color(.tint)
        item.addTarget(self,
                       action: #selector(KOTPStopsViewController.refreshUserPosition),
                       for: .touchUpInside)
        sourceAddressTextField.leftView = item
        sourceAddressTextField.leftViewMode = .always
        let button = UIBarButtonItem(image: UIImage(otpNamed: "arrow_up"),
                                     style: .done,
                                     target: self,
                                     action: #selector(KOTPStopsViewController.changeSearchViewVisibility))
        navigationItem.rightBarButtonItem = button
        let longTap = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(KOTPStopsViewController.longTapMapPosition(_:)))
        mapView.addGestureRecognizer(longTap)

        hideTableView(animated: false)
        if enableStopSearch {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
            searchView.addGestureRecognizer(tapGesture)
            
            let imv = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
            imv.image = UIImage(otpNamed: "bus_stop")?.withRenderingMode(.alwaysTemplate)
            imv.contentMode = .center
            stopSearch.leftViewMode = .always
            stopSearch.leftView = imv
            stopSearch.tintColor = KTheme.current.color(.tint)
            stopSearch.placeholder = "Nome della fermata".localizedString()
            stopSearch.clearButtonMode = .whileEditing
            stopSearch.delegate = self
        }else{
            segmented.removeFromSuperview()
        }
        setupSearch()
        
        searchView.clipsToBounds = false
        searchView.layer.shadowColor = UIColor.black.cgColor
        searchView.layer.shadowRadius = 5.0
        searchView.layer.shadowOpacity = 0.2
        searchView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        segmented.setTitle("LOCATION".localizedString(), forSegmentAt: 0)
        segmented.setTitle("STOP".localizedString(), forSegmentAt: 1)
    }
    
    @objc func endEditing(){
        view.endEditing(true)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsCore.shared?.log(itemList:"Public Transport", parameters: nil)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if KOTPLocationManager.shared.monitoredRegions.count>0
        {
            let barButton = UIBarButtonItem(image: UIImage(krakeNamed: "remove_alarm"), style: .plain, target: self, action: #selector(stopMonitoring))
            navigationItem.leftBarButtonItem = barButton
        }else{
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    @objc func stopMonitoring(){
        let alert = UIAlertController(title: KInfoPlist.appName, message: "OTP_DISABLE_ALL_STOPS_NOTIFICATION_?".localizedString(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Si".localizedString(), style: .default, handler: { (action) in
            KOTPLocationManager.shared.stopMonitoringRegions()
            self.navigationItem.leftBarButtonItem = nil
        }))
        alert.addAction(UIAlertAction(title: "No".localizedString(), style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        manageViewState(for: size)

        super.viewWillTransition(to: size, with: coordinator)
    }

    func centerMap() {
        let raggio = Double(searchRadiusSlider.value)
        let delta: Double = ((((raggio - 10.0) * 299.0 / 990.0) + 1.0) / 10000) + 0.0001
        if let fromLocation = fromLocation{
            let mapRegion = MKCoordinateRegion(center: fromLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
            mapView.setRegion(mapRegion, animated: true)
            if circleOverlay != nil{
                #if swift(>=4.2)
                mapView.removeOverlay(circleOverlay!)
                #else
                mapView.remove(circleOverlay!)
                #endif
            }
            circleOverlay = MKCircle(center: fromLocation.coordinate, radius: raggio)
            #if swift(>=4.2)
            mapView.addOverlay(circleOverlay!)
            #else
            mapView.add(circleOverlay!)
            #endif
        }
    }

    @objc func refreshUserPosition(){
        isUserCustomLocation = false
        fromLocation = MKPlacemark(coordinate: mapView.userLocation.coordinate, addressDictionary: nil)
        sourceAddressTextField.text = "LAMIAPOS".localizedString()
    }

    open func setupSearch() {
        searchInitializer.coordinatesForSearchInitialization() { [weak self] (initialSearchLocation, suggestedDescription) in
            guard let strongSelf = self, strongSelf.fromLocation == nil else {
                return
            }

            if let initialSearchLocation = initialSearchLocation, KOTPStopsViewController.defaultArea.contains(point: initialSearchLocation.coordinate) {
                // Nascondo la barra di ricerca.
                strongSelf.hideSearchView()
                // Aggiungo la descrizione del punto di ricerca nel text field.
                strongSelf.sourceAddressTextField.text = suggestedDescription
                // Aggiorno il centro della ricerca.
                strongSelf.fromLocation = MKPlacemark(
                    coordinate: initialSearchLocation.coordinate,
                    addressDictionary: nil)
                // Avvio la ricerca delle fermate sulla base della posizione iniziale.
                strongSelf.searchStops(
                    around: initialSearchLocation,
                    with: UInt(strongSelf.searchRadiusSlider.value/10)*10)
            } else if let defaultSearchLocation = KOTPStopsViewController.defaultLocation {
                // Aggiorno il centro della ricerca.
                strongSelf.fromLocation = MKPlacemark(
                    coordinate: defaultSearchLocation.coordinate,
                    addressDictionary: nil)
                // Avvio la ricerca delle fermate sulla base della posizione iniziale.
                strongSelf.searchStops(
                    around: defaultSearchLocation,
                    with: UInt(strongSelf.searchRadiusSlider.value/10)*10)
            }
        }
    }

    private func manageViewState(for size: CGSize) {
        let isLandscapeOrientation = !(UIDevice.current.userInterfaceIdiom == .pad) && size.width > size.height
        isTableViewPanningDisabled = isLandscapeOrientation
        tableViewPanGestureRecognizer.isEnabled = !isLandscapeOrientation
        tableView.isScrollEnabled = isLandscapeOrientation
    }

    override func tableViewContainerAvailableFrame() -> CGRect {
        return CGRect(
            origin: CGPoint(x: 0,
                            y: searchView.frame.maxY),
            size: CGSize(
                width: view.bounds.width,
                height: view.bounds.height - searchView.frame.maxY))
    }

    // MARK: - UI actions

    @IBAction func openSearchTableView(_ sender: AnyObject){
        isUserCustomLocation = true
        let vc = KSearchPlaceViewController.getViewController()
        vc.searchField = sender as? UITextField
        vc.delegate = self
        vc.modalPresentationStyle = .formSheet
        navigationController?.present(vc, animated: true, completion: nil)
    }

    @IBAction func valueDidChange(_ sender: AnyObject){
        // Aggiorno la label che indica il raggio di ricerca selezionato.
        labelSlider.text = String(format: "%d m", UInt(searchRadiusSlider.value/10)*10)
        centerMap()
    }

    @IBAction func userDidEndTouch(_ sender: AnyObject){
        let selectedSearchRadius = UInt(searchRadiusSlider.value/10)*10
        // Aggiorno il raggio di ricerca salvato su file system.
        KOTPPreferences.updateStoredSearchRadius(with: selectedSearchRadius)

        if let fromLocation = fromLocation {
            searchStops(
                around: CLLocation(latitude: fromLocation.coordinate.latitude, longitude:  fromLocation.coordinate.longitude),
                with: selectedSearchRadius)
        }
    }

    func searchStops(around center: CLLocation, with searchRadius: KOTPSearchRadius) {
        if searchRadius != prevRadius {
            // Nascondo la table view per evitare i flash di aggiornamento celle
            // e per resettare lo scroll.
            hideTableView(animated: true)
            // Aggiorno il valore dell'ultimo raggio di ricerca selezionato.
            prevRadius = searchRadius

            MBProgressHUD.showAdded(to: view, animated: true)
            let extras = KRequestParameters.parameters(
                userLocation: center,
                radius: prevRadius)
            OGLCoreDataMapper.sharedInstance()
                .loadData(withDisplayAlias: "otp/otpstops",
                          extras: extras) { [weak self] (parsedObject, error, completed) in

                            guard let strongSelf = self, completed else { return }

                            if let parsedObject = parsedObject {
                                let cache = OGLCoreDataMapper
                                    .sharedInstance()
                                    .displayPathCache(from: parsedObject)
                                let newStops = cache.cacheItems.array as? [KOTPStopItem]

                                strongSelf.items = newStops
                            } else {
                                strongSelf.items = nil
                            }
                            if strongSelf.items?.isEmpty ?? true {
                                KMessageManager.showMessage("CAN_NOT_FIND_STOPS".localizedString(), type: .message)
                            }
                            MBProgressHUD.hide(for: strongSelf.view,
                                               animated: true)
            }
        }
    }

    @objc dynamic func changeSearchViewVisibility() {
        if self.searchViewHiddenBottom.isActive {
            showSearchView()
        } else {
            hideSearchView()
        }
    }

    private func hideSearchView() {
        // Verifico che la search view non sia già nascosta.
        guard !self.searchViewHiddenBottom.isActive else { return }
        // Sostituisco l'icona del pulsante che viene utilizzato per modificare
        // la visibilità della search view.
        navigationItem.rightBarButtonItem?.image = UIImage(krakeNamed: "search")
        // Modifico la visibilità della search view animatamente.
        UIView.animate(withDuration: 0.2,
                       animations: {
                        self.searchViewHiddenBottom.isActive = true
                        // Verifico se la table view era precedentemente attaccata alla
                        // search view.
                        if let tableViewContainerTop = self.tableViewContainerTop, tableViewContainerTop.constant == self.minimumTableViewTopDistanceFromParent {
                            tableViewContainerTop.constant = 0
                        }
                        self.view.layoutIfNeeded()
        }) { (_) in
            self.minimumTableViewTopDistanceFromParent = 0
        }
    }

    private func showSearchView() {
        // Verifico che la search view non sia visibile.
        guard self.searchViewHiddenBottom.isActive else { return }
        // Sostituisco l'icona del pulsante che viene utilizzato per modificare
        // la visibilità della search view.
        navigationItem.rightBarButtonItem?.image = UIImage(otpNamed: "arrow_up")
        // Modifico la visibilità della search view animatamente.
        let searchViewHeight = searchView.bounds.height
        UIView.animate(withDuration: 0.2,
                       animations: {
                        self.searchViewHiddenBottom.isActive = false
                        // Verifico se la table view aveva raggiunto la massima
                        // espansione consentita.
                        if let tableViewContainerTop = self.tableViewContainerTop, tableViewContainerTop.constant == 0 {
                            tableViewContainerTop.constant = searchViewHeight
                        }
                        self.view.layoutIfNeeded()
        }) { (_) in
            self.minimumTableViewTopDistanceFromParent = searchViewHeight
        }
    }

    //MARK: - KExtendedMapViewDelegate

    @objc(mapView:didUpdateUserLocation:)
    open func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard fromLocation == nil else { return }

        if (userLocation.location?.horizontalAccuracy ?? 0.0) > 0.0 &&
            (userLocation.location?.horizontalAccuracy ?? 0.0) < 500.0 &&
            !isUserCustomLocation {

            fromLocation = MKPlacemark(coordinate: mapView.userLocation.coordinate, addressDictionary: nil)
            isUserCustomLocation = true
        }
    }

    open override func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            if !(annotation is UserSelectedPoint){
                mapView.showAnnotations([annotation], animated: true)
            }
        }
    }

    open override func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotationView = super.mapView(mapView, viewFor: annotation) {
            if annotation is UserSelectedPoint{
                annotationView.isDraggable = true
                annotationView.canShowCallout = false
            } else {
                annotationView.addButtonDetail()
            }
            return annotationView
        }
        return nil
    }

    @objc(mapView:rendererForOverlay:)
    open func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleView = MKCircleRenderer(overlay: overlay)
        circleView.strokeColor = KTheme.current.color(.alternate)
        circleView.fillColor = circleView.strokeColor?.withAlphaComponent(0.1)
        circleView.lineWidth = 2.0
        return circleView
    }

    open override func mapView(_ mapView: MKMapView,
                               annotationView view: MKAnnotationView,
                               calloutAccessoryControlTapped control: UIControl) {
        if !(view.annotation is UserSelectedPoint) {
            switch control.tag {
            case KAnnotationView.CalloutNavigationButtonTag:
                KExtendedMapView.defaultOpenAnnotation?(view.annotation, self)
            case KAnnotationView.CalloutDetailButtonTag:
                guard let stop = view.annotation as? KOTPStopItem else {
                    return
                }
                openDetail(for: stop)
            default: break
            }
        }
    }

    open override func extendedMapView(_ mapView: KExtendedMapView,
                                       annotationView view: MKAnnotationView,
                                       calloutAccessoryControlTapped control: UIControl,
                                       fromViewController: UIViewController) -> Bool {
        return true
    }

    @objc(mapView:annotationView:didChangeDragState:fromOldState:)
    open func mapView(_ mapView: MKMapView,
                      annotationView view: MKAnnotationView,
                      didChange newState: KAnnotationViewDragState,
                      fromOldState oldState: KAnnotationViewDragState) {
        switch newState {
        case .starting:
            isUserCustomLocation = true
            view.dragState = .dragging
        case .ending, .canceling:
            if let ann = view.annotation {
                fromLocation = MKPlacemark(coordinate: ann.coordinate,
                                           addressDictionary: nil)
            }
            view.dragState = KAnnotationViewDragState.none
        default:break
        }
    }

    @objc func longTapMapPosition( _ gesture : UITapGestureRecognizer){
        if gesture.state != KGestureRecognizerState.ended{
            return
        }
        let touchPoint = gesture.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        isUserCustomLocation = true
        fromLocation = MKPlacemark(coordinate: touchMapCoordinate, addressDictionary: nil)
    }

    //MARK: - OCSearchTableView DELEGATE

    open func searchPlace(_ tableView: UITableView, didSelect mapItem: MKMapItem, forTextField: UITextField?) {
        forTextField?.text = KSearchPlaceViewController.stringFromPlacemark(mapItem.placemark)

        if forTextField == sourceAddressTextField{
            fromLocation = mapItem.placemark
        }
    }

    // MARK: - Table view data source & delegate

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let stop = items![indexPath.row]
        let imageView = cell.viewWithTag(100) as? UIImageView
        let textLabel = cell.viewWithTag(101) as? UILabel
        textLabel?.text = stop.title!
        imageView?.image = (stop as? AnnotationProtocol)?.imageInset() ?? placeholderImage
        imageView?.tintColor = (stop as? AnnotationProtocol)?.color() ?? KTheme.current.color(.tint)
        cell.selectedBackgroundView = UIView()
        KTheme.current.applyTheme(toView: cell.selectedBackgroundView!, style: .selected)
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let stop = items![indexPath.row]
        openDetail(for: stop)
    }

    private func openDetail(for stop: KOTPStopItem) {
        if let detailsVC = storyboard?
            .instantiateViewController(withIdentifier: "KOTPStopDetailViewController") as? KOTPStopDetailViewController {
            detailsVC.sourceStop = stop
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }

    // MARK: - IBAction
    
    @IBAction fileprivate func changeSection()
    {
        if segmented.selectedSegmentIndex == 0
        {
            fromLocation = fromLocation != nil ? fromLocation : nil
            self.stopSearchStack.isHidden = true
            self.sourceAddressTextField.isHidden = false
            self.locationSearchStack.isHidden = false
        }else{
            searchStops()
            self.stopSearchStack.isHidden = false
            self.sourceAddressTextField.isHidden = true
            self.locationSearchStack.isHidden = true
        }
    }
    
    @IBAction fileprivate func searchStops()
    {
        view.endEditing(true)
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        guard let textToSearch = stopSearch.text, !textToSearch.isEmpty else {
            self.items = nil
            return
        }
        MBProgressHUD.showAdded(to: view, animated: true)
        KOpenTripPlannerLoader.shared.retrieveAllStops(search: textToSearch) { (stops) in
            self.items = stops
            self.mapView.centerMap()
            if self.items?.isEmpty ?? true {
                KMessageManager.showMessage("CAN_NOT_FIND_STOPS".localizedString(), type: .message)
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    // MARK: - Text Field data source & delegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchStops()
        return true
    }
}

class UserSelectedPoint: NSObject, MKAnnotation, AnnotationProtocol {

    func annotationIdentifier() -> String{
        return nameAnnotation() + (color().description)
    }

    func termIconIdentifier() -> String? {
        return nil
    }

    func boxedText() -> String? {
        return nil
    }

    var coordinate: CLLocationCoordinate2D
    var title: String?

    init(placemark: MKPlacemark) {
        coordinate = placemark.coordinate
        title = placemark.title
        super.init()
    }
    
    func color() -> UIColor {
        return KTheme.current.color(.userSelectablePin)
    }
    
    func nameAnnotation() -> String {
        return "pin_pos"
    }
    
    func imageInset() -> UIImage? {
        return UIImage(otpNamed: nameAnnotation())
    }
    
    override func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
}
