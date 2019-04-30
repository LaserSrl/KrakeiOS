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
        self.init(named: named, in: Bundle(for: KTripPlannerSearchController.self), compatibleWith: nil)
    }
}
