//
//  KVehicleAnnotation.swift
//  Krake
//
//  Created by Patrick on 20/05/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import Foundation
import MapKit

public class KVehicleAnnotation: MKPointAnnotation, AnnotationProtocol {
    
    let line: KBusLine!
    
    required init(_ line: KBusLine!) {
        self.line = line
        super.init()
    }
    
    public func annotationIdentifier() -> String{
        return nameAnnotation() + (color().description)
    }
    
    public func termIconIdentifier() -> String? {
        return nil
    }
    
    public func boxedText() -> String? {
        return nil
    }
    
    public func color() -> UIColor {
        return KTheme.current.color(.alternate)
    }
    
    public func nameAnnotation() -> String {
        return "vehicle"
    }
    
    public func imageInset() -> UIImage? {
        if let mode = line.routeInfo?.mode{
            return KTripTheme.shared.imageFor(vehicleType: mode)
        }
        return KOTPAssets.pinBus.image
    }
    
    override public func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
}
