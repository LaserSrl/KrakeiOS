//
//  KTripPlannerSearchController.swift
//  Krake
//
//  Created by joel on 02/05/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import UIKit
import DateTimePicker
import MapKit
import CoreLocation
import Segmentio

open class KTripPlannerSearchController : UIViewController,
    UITableViewDelegate,
    UITextFieldDelegate,
    KSearchPlaceDelegate {

    public static let openInAppTripPlanner : OpenMapCompletionBlock =
    {(annotation, fromViewController) -> Void in

        let request = KTripPlanRequest()
        request.to = annotation
        request.from = KUserLocationPlacemark(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), addressDictionary: nil)
        let vc = KTripPlannerSearchController.newSearchViewController(request)
        vc.title = "Trip Planning"
        if fromViewController?.navigationController != nil {
            fromViewController?.navigationController?.pushViewController(vc, animated: true)
        }else{
            let nav = UINavigationController(rootViewController: vc)
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: vc, action: #selector(UIViewController.dismissViewController))
            nav.modalPresentationStyle = .formSheet
            fromViewController?.present(nav, animated: true, completion: nil)
        }
    }


    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var searchContainer: UIView!

    @IBOutlet weak var travelModeSegmented: Segmentio!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTopContraint: NSLayoutConstraint!
    @IBOutlet weak var resultsView: UITableView!
    @IBOutlet weak var resultMapView: MKMapView!
    @IBOutlet weak var pickDateButton: UIButton!
    @IBOutlet weak var dateSelectionStackView: UIStackView!
    
    enum ListState {
        case hidden
        case contracted
        case allVisible
    }

    @IBOutlet weak var dateModeSelection: UISegmentedControl!
    enum ShowPlannedTripMode {
        case auto
        case showSingleTransitWithBackNavigation
    }

    public static func newSearchViewController(_ request : KTripPlanRequest? = nil,
                                               travelModes: [KTravelMode] = [.car, .transit, .walk, .bicycle]) -> KTripPlannerSearchController {
        let bundle = Bundle(url: Bundle(for: KTripPlannerSearchController.self).url(forResource: "OTP", withExtension: "bundle")!)
        let storyboard = UIStoryboard(name: "OCOTPStoryboard", bundle: bundle)

        let vc =  storyboard.instantiateInitialViewController() as! KTripPlannerSearchController

        if let request = request {
            vc.tripPlanRequest = request
        }
        vc.travelModes = travelModes
        return vc
    }

    public var travelModes: [KTravelMode] = [.car, .transit, .walk, .bicycle]
    public var tripPlanRequest = KTripPlanRequest() {
        didSet {
            if isViewLoaded {
                updateUiForTripRequest()
            }
        }
    }

    public var tripPlanner: KTripPlannerProtocol = KOTPTripPlanner()

    private var newListUIState: ListState = .hidden

    private var listUIState: ListState = .hidden

    private var previousYOffset: CGFloat = CGFloat.nan

    private var willDecelerate = false

    private var needToUpdateLayout = true

    private static let COLLAPSED_LIST_HEIGHT : CGFloat = 80

    private let routeMapDelegate = KTripRouteMapDelegate()

    private var currentCollectionDatasource: ResultTableDisplayer?

    private(set) var plannedTrip: KTripPlanResult?
    private var originalLeftButtonItem: UIBarButtonItem?
    
    #if swift(>=4.2)
    private let loadingProgressView: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)
    #else
    private let loadingProgressView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    #endif
    
    private let dateFormatter: DateFormatter = { let formatter = DateFormatter(); formatter.dateStyle = .short; formatter.timeStyle = .short; return formatter }()

    private let locationManager = KLocationManager()

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        fromTextField.placeholder = "FROM".localizedString()
        toTextField.placeholder = "TO".localizedString()

        originalLeftButtonItem = self.navigationItem.leftBarButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingProgressView)
        loadingProgressView.hidesWhenStopped = true

        resultMapView.delegate = routeMapDelegate
        routeMapDelegate.resultMapView = resultMapView

        let segmentTravelMode = travelModes.map { (mode) -> SegmentioItem in
            SegmentioItem(title: nil, image: KTripTheme.shared.imageFor(travelMode: mode).withRenderingMode(.alwaysTemplate))
        }

        travelModeSegmented.setup(content: segmentTravelMode,
                                  style: .onlyImage,
                                  options:  KTheme.travelModeSegmentOptions)

        travelModeSegmented.valueDidChange = { segmentio, segmentIndex in
            self.tripPlanRequest.selectedTravelMode = self.travelModes[segmentIndex]
            self.dateSelectionStackView.isHidden = self.tripPlanRequest.selectedTravelMode != .transit
            self.planTripIfValid()
        }

        travelModeSegmented.isHidden = travelModes.count <= 1
        
        dateModeSelection.setTitle("tripModePartenza".localizedString(), forSegmentAt: 0)
        dateModeSelection.setTitle("tripModeArrivo".localizedString(), forSegmentAt: 1)
        dateModeSelection.tintColor = KTheme.current.color(.tint)
        pickDateButton.tintColor = KTheme.current.color(.tint)
        pickDateButton.setImage(UIImage(otpNamed:"ic_plan_date"), for: .normal)

        locationManager.requestAuthorization { (manager, status) in
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                if !self.tripPlanRequest.isValid() && self.tripPlanRequest.needUserLocation() {
                    self.planTripIfValid()
                }
            }
        }

        resultsView.rowHeight = KTableViewAutomaticDimension
        resultsView.estimatedRowHeight = 80.0
        
        searchContainer.clipsToBounds = false
        searchContainer.layer.shadowColor = UIColor.black.cgColor
        searchContainer.layer.shadowRadius = 5.0
        searchContainer.layer.shadowOpacity = 0.2
        searchContainer.layer.shadowOffset = CGSize(width: 0, height: 2)

        updateUiForTripRequest()
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if needToUpdateLayout {
            needToUpdateLayout = false

            updateUIState(listUIState)
        }
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        needToUpdateLayout = true
    }

    private func isRunningInIPad() -> Bool {
        return view.traitCollection.horizontalSizeClass == .regular && view.traitCollection.verticalSizeClass == .regular
    }

    private func updateUiForTripRequest() {

        if let from = tripPlanRequest.from
        {
            fromTextField.text = from.title ?? ""
        }

        if let to = tripPlanRequest.to
        {
            if !(to.title??.isEmpty ?? true)
            {
                toTextField.text = to.title!
            }
            else
            {
                CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: to.coordinate.latitude, longitude: to.coordinate.longitude),
                                                    completionHandler: { (placemarks, error) in
                                                        if let placemark = placemarks?.first{
                                                            self.toTextField.text = placemark.name
                                                        }
                })
            }
        }
        travelModeSegmented.selectedSegmentioIndex = travelModes.index(of: tripPlanRequest.selectedTravelMode) ?? 0

        pickDateButton.setTitle(dateFormatter.string(from: tripPlanRequest.dateSelectedForPlan), for: .normal)

        dateSelectionStackView.isHidden = tripPlanRequest.selectedTravelMode != .transit

        dateModeSelection.selectedSegmentIndex = tripPlanRequest.datePlanChoice == .departure ? 0 : 1

        if self.tripPlanRequest.isValid()
        {
            planTripIfValid()
        }
    }

    //MARK: - Scroll delegate and constraint management
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isRunningInIPad() {
            handleScrolling(scrollView)
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        willDecelerate = decelerate
        if !isRunningInIPad() {
            self.handleScrollingEnd(scrollView)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        willDecelerate = false
    }

    private func handleScrolling(_ scrollView: UIScrollView) {

        if(!Double(previousYOffset).isNaN)
        {
            // 1 - Calculate the delta
            var deltaY = previousYOffset - scrollView.contentOffset.y

            let start = -scrollView.contentInset.top

            // 2 - Ignore any scrollOffset beyond the bounds
            if previousYOffset < start {

                if listUIState == .allVisible && !willDecelerate{

                    updateBeyhodBoundsConstraints(scrollView, deltaY: deltaY)

                    if searchContainer.bounds.height - searchTopContraint.constant > 15 {
                        newListUIState = .contracted
                    }
                    else {
                        newListUIState = .allVisible
                    }
                }

                deltaY = min(0, deltaY - (previousYOffset - start))
            }

            /* rounding to resolve a dumb issue with the contentOffset value
             CGFloat end = floorf(self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds) + self.scrollView.contentInset.bottom - 0.5f);
             if (self.previousYOffset > end && deltaY > 0)
             {
             deltaY = MAX(0, deltaY - self.previousYOffset + end);
             }
             */

            if fabs(Double(deltaY)) > .ulpOfOne && !willDecelerate {
                updateConstraintsWithScroll(scrollView, deltaY: deltaY)

                let topScrollMax = (view.bounds.height - topLayoutGuide.length) - KTripPlannerSearchController.COLLAPSED_LIST_HEIGHT

                let topConstantMaxDelta = topScrollMax - collectionViewTopConstraint.constant
                if topConstantMaxDelta < 10 {
                    newListUIState = .contracted
                }
                else {
                    newListUIState = .allVisible
                }
            }
        }

        previousYOffset = scrollView.contentOffset.y
    }

    private func updateConstraintsWithScroll(_ scrollView: UIScrollView, deltaY: CGFloat)
    {
        let constantDelta : CGFloat

        if deltaY < 0 {
            constantDelta = -min(abs(deltaY),collectionViewTopConstraint.constant)
        }
        else if (collectionViewTopConstraint.constant > 0){
            let topScrollMax = (view.bounds.height - topLayoutGuide.length) - KTripPlannerSearchController.COLLAPSED_LIST_HEIGHT

            let topConstantMaxDelta = topScrollMax - collectionViewTopConstraint.constant

            constantDelta = min(topConstantMaxDelta,deltaY)
        }
        else {
            constantDelta = 0
        }

        collectionViewTopConstraint.constant += constantDelta
        if constantDelta != 0 {
            scrollView.contentOffset.y = 0
        }
    }

    private func updateBeyhodBoundsConstraints(_ scrollView: UIScrollView, deltaY: CGFloat)
    {
        let searchMovement: CGFloat
        if deltaY > 0 {
            searchMovement =  max(-deltaY, self.searchTopContraint.constant)
        }
        else if abs(scrollView.contentOffset.y) < searchContainer.bounds.height {
            searchMovement = min(-deltaY, abs(searchContainer.bounds.height + searchTopContraint.constant ))
        }
        else {
            searchMovement = 0
        }
        self.searchTopContraint.constant = self.searchTopContraint.constant - searchMovement
    }

    private func handleScrollingEnd(_ scrollView: UIScrollView) {
        if newListUIState != listUIState {
            updateUIState(newListUIState)
        }
    }

    func updateUIState(_ newState:ListState)
    {
        if !isRunningInIPad() {
            let collectionTopConstant: CGFloat
            let searchTopConstant: CGFloat
            switch newState {
            case .contracted:
                searchTopConstant = 0
                collectionTopConstant = (view.bounds.height - topLayoutGuide.length) - KTripPlannerSearchController.COLLAPSED_LIST_HEIGHT
            case .hidden:
                searchTopConstant = 0
                collectionTopConstant = (view.bounds.height - topLayoutGuide.length)
            case .allVisible:
                collectionTopConstant = 0
                searchTopConstant = searchContainer.bounds.height
            }

            self.collectionViewTopConstraint.constant = collectionTopConstant
            self.searchTopContraint.constant = -searchTopConstant

            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
        listUIState = newState
    }

    @objc func showPlannedTripTransists()
    {
        if let plannedTrip = plannedTrip {
            showPlannedTrip(plannedTrip)
        }
    }

    //MARK: - Text Edit delegate

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        let searchvc = KSearchPlaceViewController.getViewController()
        searchvc.searchField = textField
        searchvc.delegate = self
        navigationController?.present(searchvc, animated: true, completion: nil)
    }

    public func searchPlace(_ tableView: UITableView, didSelect mapItem: MKMapItem, forTextField: UITextField?) {
        if forTextField == fromTextField {
            tripPlanRequest.from = mapItem.placemark
            fromTextField.text = mapItem.placemark.name
        }
        else if forTextField == toTextField {
            tripPlanRequest.to = mapItem.placemark
            toTextField.text = mapItem.placemark.name
        }
        planTripIfValid()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentCollectionDatasource?.tableView?(tableView, didSelectRowAt: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: Date planning

    @IBAction func showDatePicker()
    {
        let picker = DateTimePicker.create(minimumDate: min(tripPlanRequest.dateSelectedForPlan, Date()), maximumDate: nil)
        picker.selectedDate = tripPlanRequest.dateSelectedForPlan
        picker.show()

        KTripTheme.shared.applyTheme(toDateTimePicker: picker)

        picker.completionHandler = { date in
            self.tripPlanRequest.dateSelectedForPlan = date
            self.pickDateButton.setTitle(self.dateFormatter.string(from: date), for: .normal)
            self.planTripIfValid()
        }
    }

    @IBAction func changeDateMode(_ sender: UISegmentedControl)
    {
        tripPlanRequest.datePlanChoice = sender.selectedSegmentIndex == 0 ? .departure : .arrival
        planTripIfValid()
    }

    //MARK: - Trip Planning

    private func planTripIfValid()
    {
        if tripPlanRequest.isValid() {
            loadingProgressView.startAnimating()
            tripPlanner.planTrip(request: tripPlanRequest,
                                 callback: { [weak self](request, result, error) in

                                    if let sSelf = self {
                                        sSelf.loadingProgressView.stopAnimating()
                                        if request == sSelf.tripPlanRequest {
                                            if let result = result {
                                                sSelf.showPlannedTrip(result)
                                            }
                                            else if let error = error {
                                                sSelf.showError(error)
                                            }
                                        }
                                    }
            })
        }
        else if tripPlanRequest.needUserLocation() {
            locationManager.requestStartUpdatedLocation(completion: {[weak self] (manager, userLocation) in
                manager.stopUpdatingLocation()

                if let sSelf = self {
                if let location = userLocation {
                    if sSelf.tripPlanRequest.from?.isUserLocation() ?? false {
                        sSelf.tripPlanRequest.from = KUserLocationPlacemark(coordinate: location.coordinate, addressDictionary:nil)
                    }

                    if sSelf.tripPlanRequest.to?.isUserLocation() ?? false {
                        sSelf.tripPlanRequest.to = KUserLocationPlacemark(coordinate: location.coordinate, addressDictionary:nil)
                    }

                    sSelf.planTripIfValid()
                }
                }
            })
        }
    }

    private func showError(_ error: Error)
    {
        KMessageManager.showMessage(error.localizedDescription, type: .error)
    }

    func showPlannedTrip(_ plannedTrip: KTripPlanResult, mode: ShowPlannedTripMode = .auto, index: IndexPath? = nil)
    {
        let newListState: ListState
        self.plannedTrip = plannedTrip
        resultMapView.removeAnnotations(resultMapView.annotations)
        resultMapView.removeOverlays(resultMapView.overlays)

        if plannedTrip.routes.count == 1 || plannedTrip.request.selectedTravelMode != .transit || mode == .showSingleTransitWithBackNavigation {
            let route = index != nil ? plannedTrip.routes[index!.row] : plannedTrip.routes.first!
            routeMapDelegate.route = route

            if !route.steps.contains(where: {return $0 is KTransitStep }) {
                currentCollectionDatasource = SingleTripModeDatasource(with: route.steps.first as! KStepGroup)
            }
            else {
                currentCollectionDatasource = SingleTransitDatasource(with: route)
            }
            newListState = .contracted
        }
        else {
            currentCollectionDatasource = TransitsDatasource(with: plannedTrip.routes)
            newListState = .allVisible
        }
        currentCollectionDatasource?.searchController = self
        resultsView.dataSource = currentCollectionDatasource
        resultsView.reloadData()

        updateUIState(newListState)

        if (mode == .showSingleTransitWithBackNavigation && self.navigationItem.leftBarButtonItem == originalLeftButtonItem)
        {
            self.navigationItem.setLeftBarButton(UIBarButtonItem(image: UIImage(otpNamed:"ic_arrow_back"), style: .plain, target: self, action: #selector(showPlannedTripTransists)), animated: true)
        }
        else if self.navigationItem.leftBarButtonItem != originalLeftButtonItem {
            self.navigationItem.setLeftBarButton(originalLeftButtonItem, animated:  true)
        }
    }

    //MARK: - Map Zoom

    func zoomMap(onComplexStep complexStep: KComplexStep)
    {
        zoomMap(onRect: complexStep.mapRect())
    }

    func zoomMap(onStep step: KSingleStep)
    {
        zoomMap(onRect: MKMapRect(origin: KMapPointForCoordinate(step.from.coordinate), size: MKMapSize(width: 0, height: 0)))
    }

    private func zoomMap(onRect flyTo: MKMapRect)
    {
        let padding = min(resultMapView.bounds.width, resultMapView.bounds.height)/4
        if flyTo.size.width == 0.1 {
            #if swift(>=4.2)
            let point = MKMapRect(x: flyTo.origin.x - 1000, y: flyTo.origin.y - 1000, width: 2000, height: 2000)
            #else
            let point = MKMapRectMake(flyTo.origin.x - 1000, flyTo.origin.y - 1000, 2000, 2000)
            #endif
            resultMapView.setVisibleMapRect(point, edgePadding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding), animated: true)
            
        }else{
            resultMapView.setVisibleMapRect(flyTo, edgePadding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding), animated: true)
        }
    }

}
