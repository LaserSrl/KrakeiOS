//
//  KMapPlainButton.swift
//  Pods
//
//  Created by Patrick on 14/09/16.
//
//

import Foundation
import UIKit
import MapKit
import KNSemiModalViewController_hons82

@IBDesignable
open class KMapPlainButton: UIButton, KExtendedMapViewDelegate, KDetailViewProtocol
{
    
    @IBInspectable public var showDetailButtonOnCallout: Bool = false
    
    public weak var detailPresenter: KDetailPresenter?
    public var detailObject: AnyObject?
    {
        didSet
        {
            if let object = detailObject as? ContentItemWithMapPart
            {
                loadData(object: object)
            }
        }
    }
    
    var fullScreenMapView : KExtendedMapView?
    
    deinit
    {
        if fullScreenMapView != nil
        {
            fullScreenMapView?.removeFromSuperview()
            fullScreenMapView = nil
        }
    }
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        setDefaultConfig()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setDefaultConfig()
    }
    
    public func loadData(object: ContentItemWithMapPart)
    {
        if object.mapPartReference()?.isValid() ?? false || (object.otherAnnotations()?.count ?? 0) > 0
        {
            hiddenAnimated = false
        }
        else
        {
            hiddenAnimated = true
        }
    }
    
    @objc public func openMapFullScreen()
    {
        if fullScreenMapView == nil
        {
            let mapView = KExtendedMapView()
            mapView.extendedDelegate = self
            fullScreenMapView = mapView
        }
        fullScreenMapView?.canExpandMap = true
        fullScreenMapView?.expandedMap = true
        fullScreenMapView?.showsUserLocation = false
        if let view = containingViewController()?.view
        {
            let height = view.bounds.height > view.bounds.width && UIDevice.current.userInterfaceIdiom == .phone ? view.bounds.height - 100 : view.bounds.height
            let width = view.bounds.width
            fullScreenMapView!.frame = CGRect(x: 0, y: 0, width: width, height: height)
            _ = showDataInMap(mapView: fullScreenMapView!)
            containingViewController()?.presentSemiView(fullScreenMapView, withOptions: ["KNSemiModalOptionParentScale" : 0.8, "KNSemiModalOptionDisableCancel" : true])
        }
    }
    
    private func showDataInMap(mapView: KExtendedMapView) -> Bool
    {
        if let object = detailObject as? ContentItemWithMapPart, let mappa = object.mapPartReference()
        {
            mapView.removeAnnotations(mapView.annotations)
            if mappa.location!.coordinate.latitude != 0.0 && mappa.location!.coordinate.longitude != 0.0
            {
                mapView.addAnnotations([object as! MKAnnotation] )
                if KInfoPlist.Location.useOSMMap
                {
                    mapView.addOSMCopyright()
                }
            }
        }
        if let object = detailObject as? ContentItemWithMapPart, let points = object.otherAnnotations()
        {
            for annotation in points
            {
                if annotation.coordinate.latitude != 0.0 && annotation.coordinate.longitude != 0.0
                {
                    mapView.addAnnotation(annotation)
                }
            }
        }
        if mapView.annotations.count > 0
        {
            mapView.selectAnnotation(mapView.annotations.first!, animated: false)
            mapView.centerMap()
        }
        return mapView.annotations.count > 0
    }
    
    private func setDefaultConfig()
    {
        isHidden = false
        addTarget(self, action: #selector(KMapPlainButton.openMapFullScreen), for: .touchUpInside)
        if image(for: .normal) == nil
        {
            setImage(KAssets.Images.oCmap.image, for: .normal)
        }
        if title(for: .normal)?.isEmpty ?? true
        {
            setTitle("Mappa".localizedString(), for: .normal)
        }
        KTheme.current.applyTheme(toButton: self, style: .map)
        isHidden = true
    }
    
    open override func prepareForInterfaceBuilder()
    {
        super.prepareForInterfaceBuilder()
        setImage(KAssets.Images.oCmap.image, for: .normal)
        setTitle("Mappa".localizedString(), for: .normal)
    }
    
    //MARK: - KExtendedMapView Delegate
    
    public func close(_ map: KExtendedMapView)
    {
        if fullScreenMapView != nil
        {
            containingViewController()?.dismissSemiModalView()
            fullScreenMapView = nil
        }
    }
    
    open func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        var pinView = mapView.dequeueReusableAnnotationViewWithAnnotation(annotation)
        if pinView == nil
        {
            pinView = KAnnotationView(annotation: annotation)
            pinView?.addNavigationButton()
            if showDetailButtonOnCallout
            {
                pinView?.addButtonDetail()
            }
        }
        return pinView
    }
    
    public func extendedMapView(_ mapView: KExtendedMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl, fromViewController: UIViewController) -> Bool
    {
        close(mapView)
        if let vc = containingViewController(),
            let response = detailPresenter?.detailDelegate?.detailMapView(mapView, annotationView: view, calloutAccessoryControlTapped: control, fromViewController: vc), response
        {
            return true
        }
        if control.tag == KAnnotationView.CalloutDetailButtonTag
        {
            containingViewController()?.navigationController?.pushDetailViewController(nil, detail: view.annotation as? ContentItem, extras: nil, detailDelegate: nil, analyticsExtras: nil)
            return true
        }
        return false
    }
    
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation)
    {
        if let kExtendedMapView = mapView as? KExtendedMapView,
            let object = detailObject as? ContentItemWithMapPart,
            let mapPart = object.mapPartReference(),
            object.mapPartReference()?.isValid() ?? false
        {
            if kExtendedMapView.directionPolyline == nil && KInfoPlist.Location.enableNavigationOnPin
            {
                kExtendedMapView.findDirection(userLocation.coordinate, to: mapPart.location!.coordinate)
            }
        }
    }
    
}
