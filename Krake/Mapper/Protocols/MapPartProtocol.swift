//
//  MapPartProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol MapPartProtocol: KeyValueCodingProtocol
{
    var latitude: NSNumber {get}
    var longitude: NSNumber {get}
    var location: CLLocation? {get}
    var mapSourceFileMediaParts: NSOrderedSet? {get}
    var locationAddress: String? {get}
    var locationInfo: String? {get}
    
    func isValid() -> Bool
}

public extension  MapPartProtocol {
    func isValid() -> Bool {
        if let loc = location {
            return loc.coordinate.latitude != 0.0 && loc.coordinate.longitude != 0.0
        }
        return false
    }
}
