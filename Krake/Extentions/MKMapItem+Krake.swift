//
//  MKAnnotation+Krake.swift
//  Krake
//
//  Created by Patrick on 31/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import MapKit

public extension MKMapItem{
    
    static func openInMaps(_ annotation: MKAnnotation?){
        if let annotation = annotation{
            let placemark = MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil)
            let item = MKMapItem(placemark: placemark)
            item.name = annotation.title ?? item.name
            item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
    }
}
