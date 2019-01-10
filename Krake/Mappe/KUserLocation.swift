//
//  KUserLocation.swift
//  Krake
//
//  Created by joel on 15/05/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import MapKit

public class KUserLocationPlacemark : MKPlacemark
{
    public override var title: String? {
        get {
            return "LAMIAPOS".localizedString()
        }
    }
}

extension MKAnnotation {
    func isUserLocation() -> Bool {
        return self is KUserLocationPlacemark
    }

    func isPlacemarkValid() -> Bool {
        if self is KUserLocationPlacemark {
            return !(coordinate == CLLocationCoordinate2D(latitude: 0, longitude: 0))
        }
        return true
    }
}
