//
//  KOTPStopItem.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation
import MapKit

public protocol KOTPStopItem : KeyValueCodingProtocol, MKAnnotation {
    var identifier: NSNumber! {get}
    var dist: NSNumber? {get}
    var originalId: String? {get}
    var name: String? {get}
    var lon: NSNumber? {get}
    var lat: NSNumber? {get}
}

extension KOTPStopItem {
    
    public var coordinate: CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: lat!.doubleValue, longitude: lon!.doubleValue)
    }
    
    public var title: String?{
        return name
    }
    
    public var subtitle: String?{
        return nil
    }
}
