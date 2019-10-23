//
//  OMSettings.swift
//  Pods
//
//  Created by Patrick on 26/07/16.
//
//

import Foundation

open class OMSettings: NSObject{
    
    fileprivate static var krakeBundle: Bool = false
    fileprivate static var _settingsKrakeBundle: [String : AnyObject]? = nil
    
    public static func settingsKrakeBundle() -> [String : AnyObject]?{
        if _settingsKrakeBundle != nil {
            return _settingsKrakeBundle
        }else{
            if !krakeBundle{
                krakeBundle = true
                if let settingsBundle: String = Bundle.main.path(forResource: "Settings", ofType: "bundle"){
                    _settingsKrakeBundle = NSDictionary(contentsOfFile: settingsBundle + "/KrakeSettings.plist") as? [String : AnyObject]
                    return _settingsKrakeBundle
                }
            }
        }
        return nil
    }
    
    public static func needToResetDataBase() -> Bool{
        if settingsKrakeBundle() != nil{
            let needToReset = UserDefaults.standard.bool(forKey: "resetdb_preference")
            if needToReset{
                UserDefaults.standard.set(false, forKey: "resetdb_preference")
                UserDefaults.standard.synchronize()
            }
            return needToReset
        }
        return false
    }
    
    public static func registerDefaultsSettings(){
        if let dic = settingsKrakeBundle(){
            if let preferences = dic["PreferenceSpecifiers"] as? [NSDictionary]{
                var defaultsToRegister = [String : Any]()
                for prefSpecification in preferences{
                    if let key = prefSpecification["Key"] as? String, let value = prefSpecification["DefaultValue"]{
                        defaultsToRegister[key] = value
                    }
                }
                UserDefaults.standard.register(defaults: defaultsToRegister)
            }
            if let value = Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String){
                UserDefaults.standard.set(value, forKey: "appIdentifier_preference")
            }
            if let value = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString"){
                UserDefaults.standard.set(value, forKey: "appVersion_preference")
            }
            if let value = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String){
                UserDefaults.standard.set(value, forKey: "buildVersion_preference")
            }
            if UserDefaults.standard.bool(forKey: "resetAuthCookie_preference"){
                KLoginManager.shared.userLogout()
                UserDefaults.standard.set(false, forKey: "resetAuthCookie_preference")
            }
            if UserDefaults.standard.bool(forKey: "resetPoliciesCookie_preference"){
                URLConfigurationCookies.shared.removePoliciesCookie()
                UserDefaults.standard.set(false, forKey: "resetPoliciesCookie_preference")
            }
            if UserDefaults.standard.bool(forKey: "resetReactionsCookie_preference"){
                URLConfigurationCookies.shared.removeUserReactionCookie()
                UserDefaults.standard.set(false, forKey: "resetReactionsCookie_preference")
            }
            UserDefaults.standard.setValue(String(format: "%.f ore", KInfoPlist.defautCacheHour.doubleValue), forKey: "cacheHour_preference")
            UserDefaults.standard.synchronize()
        }
        
    }
    
}
