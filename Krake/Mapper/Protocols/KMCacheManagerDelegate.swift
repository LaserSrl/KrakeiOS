//
//  KMCacheManagerDelegate.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

@objc public protocol KMCacheManagerDelegate : NSObjectProtocol {
    
    func displayCacheNameWithDisplayAlias(_ displayAlias: String, parameters: [String : AnyObject]) -> String
    
    func isCacheValid(_ cache: DisplayPathCache, newRequestParameters parameters: [String : AnyObject]) -> Bool
}
