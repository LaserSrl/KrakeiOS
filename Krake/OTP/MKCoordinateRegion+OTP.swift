//
//  MKCoordinateRegion+OTP.swift
//  Krake
//
//  Created by Marco Zanino on 13/04/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

extension MKCoordinateRegion {

    public func contains(point: CLLocationCoordinate2D) -> Bool {
        return
            cos((center.latitude - point.latitude) * .pi/180.0) > cos(span.latitudeDelta/2.0 * .pi/180.0) &&
                cos((center.longitude - point.longitude) * .pi/180.0) > cos(span.longitudeDelta/2.0 * .pi/180.0)
    }
    
}
