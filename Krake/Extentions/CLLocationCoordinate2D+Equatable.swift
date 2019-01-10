//
//  CLLocationCoordinate2D.swift
//  Krake
//
//  Created by Patrick on 19/05/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D: Equatable {
    static public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && rhs.longitude == lhs.longitude
    }
    
}
