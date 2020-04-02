//
//  NSHTTPCookie+OM.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

extension HTTPCookie{
    
    public func isValidCookie() -> Bool{
        let orcws = KInfoPlist.KrakePlist.host
        if orcws.host != domain || (expiresDate != nil && expiresDate!.timeIntervalSinceNow.isLess(than: 0.0)) {
            return false
        }
        return true
    }
}
