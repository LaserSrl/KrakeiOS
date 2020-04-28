//
//  KMAroundMeCacheManager.swift
//  OrchardGen
//
//  Created by joel on 08/06/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import UIKit
import CoreLocation

open class KMAroundMeCacheManager: NSObject , KMCacheManagerDelegate {
    
    let aroundMeDisplayRoutes: [String]
    let parentCacheManager: KMCacheManagerDelegate
    
    public init(aroundMeDisplayRoutes _aroundMeDisplayRoutes: [String], parentCacheManager _parentCacheManager: KMCacheManagerDelegate)
    {
        aroundMeDisplayRoutes = _aroundMeDisplayRoutes;
        parentCacheManager = _parentCacheManager;
        super.init()
    }
    
    open func displayCacheNameWithDisplayAlias(_ displayAlias: String, parameters: [String : AnyObject]) -> String {
        return parentCacheManager.displayCacheNameWithDisplayAlias(displayAlias, parameters: parameters)
    }
    
    open func isCacheValid(_ cache: DisplayPathCache, newRequestParameters parameters: [String : AnyObject]) -> Bool {
        
        var alias = cache.displayPath
        if let displayAlias = parameters[KParametersKeys.displayAlias] as? String
        {
            alias = displayAlias
        }
        
        if let alias = alias, aroundMeDisplayRoutes.firstIndex(of: alias) != nil {
            
            if let cacheParams = cache.extrasParameters{
                
                let cacheLocation = CLLocation(latitude: (cacheParams.value(forKey: REQUEST_AROUND_ME_LATITUDE) as! NSNumber).doubleValue,
                                               longitude: (cacheParams.value(forKey: REQUEST_AROUND_ME_LONGITUDE) as! NSNumber).doubleValue)
                
                let requestLocation = CLLocation(latitude: (parameters[REQUEST_AROUND_ME_LATITUDE] as! NSNumber).doubleValue, longitude: (parameters[REQUEST_AROUND_ME_LONGITUDE] as! NSNumber).doubleValue)
                
                let cacheRadius = (cacheParams[REQUEST_AROUND_ME_RADIUS] as! NSNumber).doubleValue
                
                let radius = (parameters[REQUEST_AROUND_ME_RADIUS] as! NSNumber).doubleValue

                if abs(radius-cacheRadius) > 1 || cacheLocation.distance(from: requestLocation) > radius/3
                {
                    return false
                }
                
            }
            
        }
        
        return parentCacheManager.isCacheValid(cache, newRequestParameters: parameters)
    }
}
