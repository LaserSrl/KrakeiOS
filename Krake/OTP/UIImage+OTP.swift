//
//  UIImage.swift
//  Pods
//
//  Created by Patrick on 26/07/16.
//
//

import Foundation


public extension UIImage{
    
    convenience init?(otpNamed named: String){
        guard let bundlePath = Bundle(for: KTripPlannerSearchController.self).path(forResource: "OTP", ofType: "bundle") else { return nil }
        self.init(named: named, in: Bundle(path: bundlePath), compatibleWith: nil)
    }
}
