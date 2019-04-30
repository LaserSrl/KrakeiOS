//
//  MKMapView.swift
//  Pods
//
//  Created by Patrick on 26/07/16.
//
//

import Foundation
import MapKit
import Cluster

public extension MKMapView{
    
    fileprivate func addAnnotationInRect(_ annotation: MKAnnotation, _ flyTo: MKMapRect) -> MKMapRect {
        let annotationPoint = KMapPointForCoordinate(annotation.coordinate)
        #if swift(>=4.2)
        let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
        let isNull = flyTo.isNull
        #else
        let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
        let isNull = MKMapRectIsNull(flyTo)
        #endif
        if isNull {
            return pointRect
        }
        else {
            #if swift(>=4.2)
            return flyTo.union(pointRect)
            #else
            return MKMapRectUnion(flyTo, pointRect)
            #endif
        }
    }

    /**
     Metodo per centrare lo zoom della mappa sugli overlay e le annotation in essa presenti.
     */
    
    
    func centerMap(defaultArea: MKMapRect = KMapRectNull){
        var flyTo = KMapRectNull
        for annotation in annotations{
            if !(annotation is MKUserLocation) {

                if let cluster = annotation as? ClusterAnnotation {
                    for annotation in cluster.annotations {
                        flyTo = addAnnotationInRect(annotation, flyTo)
                    }
                }
                else {
                    flyTo = addAnnotationInRect(annotation, flyTo)
                }
            }
        }
        for overlay in overlays{
            if !(overlay is MKTileOverlay){
                #if swift(>=4.2)
                let isNull = flyTo.isNull
                #else
                let isNull = MKMapRectIsNull(flyTo)
                #endif
                if isNull{
                    flyTo = overlay.boundingMapRect
                }else{
                    #if swift(>=4.2)
                    flyTo = flyTo.union(overlay.boundingMapRect)
                    #else
                    flyTo = MKMapRectUnion(flyTo, overlay.boundingMapRect)
                    #endif
                }
            }
        }
        #if swift(>=4.2)
        let isNull = flyTo.isNull
        #else
        let isNull = MKMapRectIsNull(flyTo)
        #endif
        if isNull
        {
            flyTo = defaultArea
        }
        let padding = min(bounds.width, bounds.height)/4
        if flyTo.size.width == 0.1 {
            #if swift(>=4.2)
            let point = MKMapRect(x: flyTo.origin.x - 1000, y: flyTo.origin.y - 1000, width: 2000, height: 2000)
            #else
            let point = MKMapRectMake(flyTo.origin.x - 1000, flyTo.origin.y - 1000, 2000, 2000)
            #endif
            setVisibleMapRect(point, edgePadding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding), animated: true)
        }else{
            setVisibleMapRect(flyTo, edgePadding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding), animated: true)
        }
    }
    
    func addOSMCopyright(){
        var webView = viewWithTag(10011) as? KWebView
        if webView == nil {
            webView = KWebView(frame: .zero)
            webView!.tag = 10011
            webView!.translatesAutoresizingMaskIntoConstraints = false
            webView!.isOpaque = false
            webView!.backgroundColor = UIColor.clear
            addSubview(webView!)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(48)-[wv]-|", options: .directionLeftToRight, metrics: nil, views: ["wv" : webView!]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[wv(35)]-|", options: .directionLeftToRight, metrics: nil, views: ["wv" : webView!]))
        }
        webView!.loadHTMLString(KInfoPlist.Location.osmCopyright)
    }
    
    func dequeueReusableAnnotationViewWithAnnotation(_ annotation: MKAnnotation, forcedColor: UIColor? = nil) -> MKAnnotationView?{
        var identifier = "StandardPin"
        if let elem = annotation as? AnnotationProtocol {
            identifier = elem.annotationIdentifier() + (forcedColor?.description ?? "")
        }
        return dequeueReusableAnnotationView(withIdentifier: identifier)
    }
}
