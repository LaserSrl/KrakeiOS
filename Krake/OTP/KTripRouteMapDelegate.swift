//
//  KTripRouteMapDelegate.swift
//  Krake
//
//  Created by joel on 05/05/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import MapKit

class KTripRouteMapDelegate: NSObject, MKMapViewDelegate {

    weak var resultMapView: MKMapView!
    var route: KRoute! {
        didSet{
            showRouteOnMap()
        }
    }

    func showRouteOnMap()
    {
        let overlays = resultMapView.overlays

        overlays.forEach { (overlay) in
            if !(overlay is MKTileOverlay) {
                resultMapView.removeOverlay(overlay)
            }
        }

        let from = route.steps.first!.from
        from.pinName = KTripTheme.shared.pinName(.from)
        resultMapView.addAnnotation(from)

        let to = route.steps.last!.to
        to.pinName = KTripTheme.shared.pinName(.to)
        resultMapView.addAnnotation(to)

        for step in route.steps {
            resultMapView.addOverlay(step.polyline)
        }

        resultMapView.centerMap()
    }

    //Map view delegate
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is MKUserLocation {
            return nil
        }
        if annotation is AnnotationProtocol {
            var pinView = mapView.dequeueReusableAnnotationViewWithAnnotation(annotation)
            if pinView == nil {
                pinView = KAnnotationView(annotation: annotation)
            }
            return pinView
        } else {
            return nil
        }
    }

    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline
        {
            let renderer = MKPolylineRenderer(polyline: polyline)

            for step in route.steps {
                if step.polyline == polyline {
                    renderer.strokeColor = step.stepColor()
                }
            }

            renderer.lineWidth = 4.0;
            return renderer
        }

        return MKPolylineRenderer()
    }
}
