//
//  KInfoPlist.swift
//  Krake
//
//  Created by Patrick on 30/08/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

@objc open class KInfoPlist: NSObject
{
    @objc public static let appName: String = {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    }()
    
    public static let detailBodyStyle: String = {
        return Bundle.krakeSettings()["DetailBodyStyle"] as? String ?? "text-align:justify;"
    }()
    
    public static let defautCacheHour: NSNumber = {
       return Bundle.krakeSettings()["CacheHour"] as? NSNumber ?? 6
    }()
    
    @objc open class KrakePlist: NSObject
    {
        public static let host: URL = {
            if let urlString = Bundle.krakeSettings()["WSKrake"] as? String,
                let pathURL = URL(string: urlString)
            {
                return pathURL
            }
            else if let pref = UserDefaults.standard.string(forKey: "tenant_preference"),
                let urlDB = URL(string: pref),
                let baseURL = urlDB.baseURL
            {
                return baseURL
            }
            fatalError("NON E' STATO IMPOSTATO IL registerDefaultsFromSettingsBundle")
        }()
        
        @objc public static let path: URL = {
            let baseURL = KInfoPlist.KrakePlist.host
            if let subtenantName = KInfoPlist.KrakePlist.relativePath {
                return baseURL.appendingPathComponent(subtenantName)
            }
            return baseURL
        }()
        
        public static let relativePath: String? = {
            if let pref = UserDefaults.standard.string(forKey: "tenant_preference"),
                let urlDB = URL(string: pref){
                let pathComponents = urlDB.pathComponents
                let path = NSMutableString()
                for pathc in pathComponents{
                    if pathc != "/"{
                        path.appendFormat("%@/", pathc)
                    }
                }
                return path as String
            }
            return Bundle.krakeSettings()["BaseServices"] as? String
        }()
        
        public static let apiKey: String? = {
            return Bundle.krakeSettings()["ApiKey"] as? String
        }()
        
        public static let encriptionKey: String? = {
            return Bundle.krakeSettings()["EncriptionKey"] as? String
        }()
        
        public static let pushRegistrationOnDidFinishLaunchingWithOptions: Bool = {
            return Bundle.krakeSettings()["PushRegistrationOnDidFinishLaunchingWithOptions"] as? Bool ?? true
        }()
    
    }
    
    open class StoreReview: NSObject
    {
        public static let minimunRunCountReviewRequest: NSNumber = {
            return Bundle.reviewRequestKrakeSettings()?["MinimunRunCount"] as? NSNumber ?? NSNumber(value: 3)
        }()
        
        public static let canPromptReviewRequest: Bool = {
            return Bundle.reviewRequestKrakeSettings()?["CanPrompt"]?.boolValue ?? true
        }()
    }
    
    
}



