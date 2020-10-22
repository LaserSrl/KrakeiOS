//
//  CLLocationValueTransformer.swift
//  Krake
//
//  Created by Patrick on 22/10/2020.
//

import Foundation
import CoreLocation

@available(iOS 12.0, *)
@objc(CLLocationValueTransformer)
final class CLLocationValueTransformer: NSSecureUnarchiveFromDataTransformer
{
    static let name = NSValueTransformerName(rawValue: String(describing: CLLocationValueTransformer.self))
    
    override static var allowedTopLevelClasses: [AnyClass] {
        return [CLLocation.self]
    }
    
    public static func register() {
        let transformer = CLLocationValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
