//
//  KExtendedMapView.swift
//  Krake
//
//  Created by joel on 26/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import UIKit
import MapKit
import Cluster
import Kml_swift

extension UIBarButtonItem {
    
    var frame: CGRect? {
        guard let view = self.value(forKey: "view") as? UIView else {
            return nil
        }
        return view.frame
    }
    
}

public typealias OpenMapCompletionBlock = (MKAnnotation?, UIViewController?) -> Void

open class KExtendedMapView: MKMapView {

    /// Default Block per l'apertura dell'annotation
    public static var defaultOpenAnnotation: OpenMapCompletionBlock? = {(annotation, fromViewController) -> Void in
        MKMapItem.openInMaps(annotation)
    }

    open weak var extendedDelegate: KExtendedMapViewDelegate?

    fileprivate weak var toolbar: UIToolbar?
    
    fileprivate lazy var expandMapButton : UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(krakeNamed: "zoom_out_map"), style: .plain, target: self, action: #selector(KExtendedMapView.expandMap))
    }()
    
    fileprivate lazy var collapseMapButton : UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(KExtendedMapView.collapseMap))
    }()
    
    fileprivate lazy var showUserLocationButton : MKUserTrackingBarButtonItem = {
        let button = MKUserTrackingBarButtonItem(mapView: self)
        button.tintColor = KTheme.current.color(.textTint)
        return button
    }()
    
    fileprivate lazy var changeMapTypeButton : UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(krakeNamed:"OCsatellite"), style: .plain, target: self, action: #selector(KExtendedMapView.changeMapType))
        button.tintColor = KTheme.current.color(.textTint)
        return button
    }()

    open var directionPolyline : MKPolyline?
    public static let DirectionPolylineTitle = "Points"
    fileprivate lazy var locationManager = KLocationManager()
    fileprivate lazy var supportDelegate : KExtendedMapViewDelegateSupport = KExtendedMapViewDelegateSupport(mapView: self)


    @IBInspectable var hideToolBar : Bool = false{
        didSet{
            toolbar?.isHidden = hideToolBar
        }
    }
    @IBInspectable open var canExpandMap : Bool = false
    @IBInspectable open var expandedMap : Bool = false {
        didSet {
            checkUserLocation()
        }
    }
    
    fileprivate func checkUserLocation()
    {
        if expandedMap {
            
            let status = CLLocationManager.authorizationStatus()
            if  status == .notDetermined && containingViewController()?.isViewLoaded ?? false{
                locationManager.requestAuthorization(completion: {[weak self] (manager, status) in
                    
                    self?.showsUserLocation = (status == .authorizedWhenInUse || status == .authorizedAlways)
                    
                    self?.updateToolbarButtons()
                    
                })
            }
            
            self.showsUserLocation = status == .authorizedWhenInUse || status == .authorizedAlways
        }
        self.updateToolbarButtons()
    }

    open override func awakeFromNib () {
        super.awakeFromNib()
        loadMapView()
        //TODO: verificare
        checkUserLocation()
    }

    public required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)

    }

    override init(frame: CGRect) {

        super.init(frame: frame)
        loadMapView()
    }

    fileprivate func loadMapView()
    {
        if(toolbar == nil) {
            expandMapButton.imageInsets = UIEdgeInsets(top: 0,left: -14,bottom: 0,right: 0)
            self.delegate = supportDelegate
            let newToolbar = UIToolbar(frame: CGRect(x: 0, y: 16, width: 44, height: 44))
            newToolbar.isHidden = hideToolBar
            newToolbar.isUserInteractionEnabled = true
            KTheme.current.applyTheme(toToolbar: newToolbar, style: .default)
            self.addSubview(newToolbar)
            toolbar = newToolbar

            updateMapTypeButtonImage()
            updateToolbarButtons()

            if KInfoPlist.Location.useOSMMap
            {
                let tile = MKTileOverlay(urlTemplate: KInfoPlist.Location.osmPath)
                tile.canReplaceMapContent = false
                #if swift(>=4.2)
                addOverlay(tile, level: .aboveLabels)
                #else
                add(tile, level: .aboveLabels)
                #endif
                addOSMCopyright()
            }
        }
    }

    open override func removeFromSuperview()
    {
        toolbar?.items = nil
        toolbar?.removeFromSuperview()
        self.showsUserLocation = false
        showUserLocationButton.mapView = nil
        collapseMapButton.target = nil
        expandMapButton.target = nil
        changeMapTypeButton.target = nil
        toolbar = nil
        extendedDelegate = nil
        
        super.removeFromSuperview()
    }

    @objc public func expandMap()
    {
        self.extendedDelegate?.showFullScreen(self)
    }

    @objc public func collapseMap()
    {
        self.extendedDelegate?.close(self)
    }

    func updateToolbarButtons() {
        if let toolbar = toolbar
        {
            var items = [UIBarButtonItem]()
            var width: CGFloat = 6.0
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            if canExpandMap
            {
                let button: UIBarButtonItem = expandedMap ? collapseMapButton : expandMapButton
                width = width + (button.frame?.width ?? 44.0) + 6.0
                items.append(button)
                items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            }
            if(expandedMap)
            {
                if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse
                {
                    width = width + (showUserLocationButton.frame?.width ?? 44.0) + 6.0
                    items.append(showUserLocationButton)
                    items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
                }

                if !KInfoPlist.Location.useOSMMap
                {
                    width = width + (changeMapTypeButton.frame?.width ?? 44.0) + 6.0
                    items.append(changeMapTypeButton)
                    items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
                }
            }
            toolbar.setItems(items, animated: true)
            let toolbarFrame = toolbar.frame
            toolbar.frame = CGRect(x: toolbarFrame.origin.x, y: toolbarFrame.origin.y, width: 25.0 * CGFloat(items.count), height: toolbarFrame.height)
        }
    }

    @objc func changeMapType() {
        if mapType != .satellite {
            mapType = .satellite
        } else {
            mapType = .standard
        }

        updateMapTypeButtonImage()
    }

    fileprivate func updateMapTypeButtonImage() {
        let imageName : String
        #if swift(>=4.0)
            switch self.mapType {
            case .standard:
                imageName = "OCsatellite"
            case .satellite:
                imageName = "OCstreet"
            case .hybrid:
                imageName = "OCstreet"
            case .satelliteFlyover:
                imageName = "OCsatellite"
            case .hybridFlyover:
                imageName = "OCstreet"
            case .mutedStandard:
                imageName = "OCsatellite"
            default:
                imageName = "OCsatellite"
            }
        #else
            switch self.mapType {
            case .standard:
                imageName = "OCsatellite"
            case .satellite:
                imageName = "OCstreet"
            case .hybrid:
                imageName = "OCstreet"
            case .satelliteFlyover:
                imageName = "OCsatellite"
            case .hybridFlyover:
                imageName = "OCstreet"
            }
        #endif
        changeMapTypeButton.image = UIImage(krakeNamed: imageName)?.withRenderingMode(.alwaysTemplate)
    }


    open func findDirection(_ from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        #if swift(>=4.2)
        let request = MKDirections.Request()
        #else
        let request = MKDirectionsRequest()
        #endif
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to, addressDictionary: nil))
        request.transportType = .automobile

        MKDirections(request: request).calculate {[weak self] (response, error) in
            if let route = response?.routes.first, let sSelf = self {
                sSelf.directionPolyline = route.polyline
                sSelf.directionPolyline?.title = KExtendedMapView.DirectionPolylineTitle
                #if swift(>=4.2)
                sSelf.addOverlay(route.polyline)
                #else
                sSelf.add(route.polyline)
                #endif
                sSelf.centerMap()
                sSelf.updateToolbarButtons()
            }
        }
    }


}


class KExtendedMapViewDelegateSupport: NSObject, MKMapViewDelegate, ClusterManagerDelegate {

    weak var mapView : KExtendedMapView!
    init(mapView map: KExtendedMapView!) {
        mapView = map
    }
    //MARK: - MKMap Cluster Delegate

    func shouldClusterAnnotation(_ annotation: MKAnnotation) -> Bool {
        return !(annotation is MKUserLocation)
    }

    //MARK: - MKMap View Delegate

    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        if mode == .none{
            mapView.centerMap()
        }
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if self.mapView.extendedDelegate?.responds(to: #selector(MKMapViewDelegate.mapView(_:didUpdate:))) ?? false {
            self.mapView.extendedDelegate!.mapView!(mapView, didUpdate: userLocation)
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if self.mapView.extendedDelegate?.responds(to: #selector(MKMapViewDelegate.mapView(_:didSelect:))) ?? false {
            self.mapView.extendedDelegate!.mapView!(mapView, didSelect: view)
        }
        else {

            for overlay in mapView.overlays {
                if !overlay.isKind(of: MKTileOverlay.self) && overlay.title ?? "" != KExtendedMapView.DirectionPolylineTitle {
                    #if swift(>=4.2)
                    mapView.removeOverlay(overlay)
                    #else
                    mapView.remove(overlay)
                    #endif
                }
            }

            if let det = view.annotation as? ContentItemWithMapPart, let mapPart = det.mapPartReference() {
                for loopItem in mapPart.mapSourceFileMediaParts ?? NSOrderedSet() {

                    let media = loopItem as? MediaPartProtocol

                    if media?.mediaUrl?.hasSuffix("kml") ?? false {

                        let completeUrl = KInfoPlist.KrakePlist.path.appendingPathComponent(media?.mediaUrl?.removingPercentEncoding ?? "")

                        KMLDocument.parse(url: completeUrl, callback: { (kml) in
                            self.mapView?.addOverlays(kml.overlays)

                            if KInfoPlist.Location.showMarkerFromKML {
                                self.mapView?.addAnnotations(kml.annotations)
                            }
                        })
                    }
                }

            }

        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay as? MKTileOverlay)?.urlTemplate ?? "" == KInfoPlist.Location.osmPath {
            return MKTileOverlayRenderer(tileOverlay: overlay as! MKTileOverlay)
        }

        if let kml = overlay as? KMLOverlay {
            return kml.renderer()
        }

        if overlay.title ?? "" == KExtendedMapView.DirectionPolylineTitle {

            let polyline = MKPolylineRenderer(overlay: overlay)

            KTheme.current.applyTheme(toPolyline: polyline, style: .directions)

            return polyline
        }


        return self.mapView.extendedDelegate?.mapView!(mapView, rendererFor: overlay) ?? MKOverlayRenderer(overlay: overlay)

    }


    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }

        if self.mapView.extendedDelegate != nil {
            return self.mapView.extendedDelegate!.mapView!(mapView, viewFor: annotation)
        }
        else {
            if let pinView = mapView.dequeueReusableAnnotationViewWithAnnotation(annotation) {
                return pinView;
            }
            else {
                return KAnnotationView(annotation: annotation)
            }
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let fromViewController = mapView.containingViewController(),
            !(self.mapView?.extendedDelegate?.extendedMapView(self.mapView!, annotationView: view, calloutAccessoryControlTapped: control, fromViewController: fromViewController) ?? false) {
            if control.tag == KAnnotationView.CalloutNavigationButtonTag
            {
                KExtendedMapView.defaultOpenAnnotation?(view.annotation, fromViewController)
            }
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if self.mapView.extendedDelegate?.responds(to: #selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:))) ?? false {
            self.mapView.extendedDelegate!.mapView!(mapView, regionDidChangeAnimated: animated)
        }
    }
}

public protocol KExtendedMapViewDelegate : MKMapViewDelegate {
    func showFullScreen(_ map: KExtendedMapView)

    func close(_ map: KExtendedMapView)

    func extendedMapView(_ mapView: KExtendedMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl, fromViewController: UIViewController) -> Bool
}

extension KExtendedMapViewDelegate {
    public func showFullScreen(_ map: KExtendedMapView) {

    }

    public func close(_ map: KExtendedMapView) {

    }
}
