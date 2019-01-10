//
//  NSURL+Krake.swift
//  Krake
//
//  Created by Marco Zanino on 01/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation

public extension URL {
    
    public func resourceReachable() -> Bool {
        var checkResourceReachabilityError: NSError? = nil
        (self as NSURL).checkResourceIsReachableAndReturnError(&checkResourceReachabilityError)
        return checkResourceReachabilityError == nil
    }
    
}
