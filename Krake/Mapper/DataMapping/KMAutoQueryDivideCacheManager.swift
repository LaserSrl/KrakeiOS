//
//  KMAutoQueryDivideCacheManager.swift
//  OrchardGen
//
//  Created by joel on 07/06/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import UIKit

open class KMAutoQueryDivideCacheManager: NSObject, KMCacheManagerDelegate {
    
    open var ignoredParams = [String]()
    
    open var cacheValidityForDisplayAlias = [String:Double]()
    
    fileprivate let defaultCacheValidity = 60 * 60 * KInfoPlist.defautCacheHour.doubleValue
    
    override public init() {
        super.init()
        
        ignoredParams.append(KParamsKey.displayAlias)
        ignoredParams.append(KParamsKey.page)
        ignoredParams.append(KParamsKey.pageSize)
        ignoredParams.append(KParamsKey.itemsFieldsFilter)
        ignoredParams.append(KParamsKey.showPrivacy)
        ignoredParams.append(KParamsKey.realFormat)
        ignoredParams.append(KParamsKey.complexBehaviour)
        ignoredParams.append(KParamsKey.noCache)
        ignoredParams.append(KParamsKey.deepLevel)
        ignoredParams.append(KParamsKey.aroundMeLatitude)
        ignoredParams.append(KParamsKey.aroundMeLongitude)
        ignoredParams.append(KParamsKey.aroundMeRadius)
        ignoredParams.append(KParamsKey.lang)
    }
    
    open func displayCacheNameWithDisplayAlias(_ displayAlias: String, parameters: [String : AnyObject]) -> String
    {
        var name = displayAlias
        
        if displayAlias != KCommonDisplayAlias.userInfo {
            var keys = [String]()
            keys.append(contentsOf: parameters.keys)
            keys.sort()

            for key in keys {
                if ignoredParams.index(of: key) == nil {
                    name = name.appendingFormat("%@:%@", key , parameters[key]!.description)
                }
            }
        }

        return name;

    }
    
    open func isCacheValid(_ cache: DisplayPathCache, newRequestParameters parameters: [String : AnyObject]) -> Bool{
        var cacheValidity = defaultCacheValidity;
        if let displayAlias = parameters[KParamsKey.displayAlias] as? String, let validity = cacheValidityForDisplayAlias[displayAlias]{
            cacheValidity =  validity
        }
        else if let validity = cacheValidityForDisplayAlias[cache.displayPath] {
            cacheValidity =  validity
        }
        else if PseudoPathCache.globalClasses.keys.contains(cache.displayPath){
            return true
        }
        return  abs(cache.date.timeIntervalSinceNow) < cacheValidity
    }
}
