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
        
        ignoredParams.append(KParametersKeys.displayAlias)
        ignoredParams.append(KParametersKeys.page)
        ignoredParams.append(KParametersKeys.pageSize)
        ignoredParams.append(KParametersKeys.itemsFieldsFilter)
        ignoredParams.append(KParametersKeys.showPrivacy)
        ignoredParams.append(KParametersKeys.realFormat)
        ignoredParams.append(KParametersKeys.complexBehaviour)
        ignoredParams.append(KParametersKeys.noCache)
        ignoredParams.append(KParametersKeys.deepLevel)
        ignoredParams.append(KParametersKeys.aroundMeLatitude)
        ignoredParams.append(KParametersKeys.aroundMeLongitude)
        ignoredParams.append(KParametersKeys.aroundMeRadius)
        ignoredParams.append(KParametersKeys.lang)
    }
    
    open func displayCacheNameWithDisplayAlias(_ displayAlias: String, parameters: [String : AnyObject]) -> String
    {
        var name = displayAlias
        
        if displayAlias != KCommonDisplayAlias.userInfo {
            var keys = [String]()
            keys.append(contentsOf: parameters.keys)
            keys.sort()

            for key in keys {
                if ignoredParams.firstIndex(of: key) == nil {
                    name = name.appendingFormat("%@:%@", key , parameters[key]!.description)
                }
            }
        }

        return name;

    }
    
    open func isCacheValid(_ cache: DisplayPathCache, newRequestParameters parameters: [String : AnyObject]) -> Bool{
        var cacheValidity = defaultCacheValidity;
        if let displayAlias = parameters[KParametersKeys.displayAlias] as? String, let validity = cacheValidityForDisplayAlias[displayAlias]{
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
