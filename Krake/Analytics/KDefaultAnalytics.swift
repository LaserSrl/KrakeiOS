//
//  AppAnalytics.swift
//
//  Created by joel on 22/06/16.
//  Copyright © 2016 MyKrake. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import FirebaseCore

open class KDefaultAnalytics: NSObject, KAnalytics {
    
    public override init(){
        if KInfoPlist.Analytics.enabled {
            FirebaseApp.configure()
        }
        super.init()
        setUserInfoProperties()
    }
    
    @objc open func log(itemList itemCategory: String, parameters: [String : Any]? = nil) {
        if !KInfoPlist.Analytics.enabled
        {
            return
        }
        var params: [String : Any] = [AnalyticsParameterItemCategory : itemCategory]
        if (parameters != nil)
        {
            params.update(other: parameters!)
        }
        Analytics.logEvent(AnalyticsEventViewItemList, parameters: params as? [String : NSObject])
    }
    
    @objc open func log(event eventName: String, parameters: [String : Any]? = nil) {
        if !KInfoPlist.Analytics.enabled
        {
            return
        }
        Analytics.logEvent(eventName, parameters: parameters as? [String : NSObject])
    }
    
    @objc open func log(share socialActivity: String, contentType: String, itemId: String?, parameters: [String : Any]? = nil) {
        if !KInfoPlist.Analytics.enabled
        {
            return
        }
        var params : [String: Any] = [AnalyticsParameterContentType: contentType,
                                               "social": socialActivity]
        if itemId  != nil {
            params[AnalyticsParameterItemName] = itemId
        }
        if (parameters != nil)
        {
            params.update(other: parameters!)
        }
        Analytics.logEvent(AnalyticsEventShare, parameters: params as? [String : NSObject])
    }
    
    @objc open func log(selectContent contentType: String, itemId: NSNumber?, itemName: String?, parameters: [String : Any]? = nil) {
        if !KInfoPlist.Analytics.enabled
        {
            return
        }
        var params : [String: Any] = [AnalyticsParameterContentType: contentType]
        if itemId != nil {
            params[AnalyticsParameterItemID] = itemId
        }
        if itemName != nil {
            params[AnalyticsParameterItemName] = itemName
        }
        if parameters != nil
        {
            params.update(other: parameters!)
        }
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: params as? [String : NSObject])
    }
    
    //MARK: - USER INFO PARAMS
    
    @objc open func setProperty(_ property: String, forKey: String) {
        if !KInfoPlist.Analytics.enabled
        {
            return
        }
        Analytics.setUserProperty(property, forName: forKey)
    }
    
    //MARK: set default UserInfo properties
    @objc open func setUserInfoProperties()
    {
        if !KInfoPlist.Analytics.enabled
        {
            return
        }
        if KInfoPlist.Analytics.collectUserProperties && KLoginManager.shared.isKrakeLogged
        {
            if let userIdentifier = KLoginManager.shared.currentUser?.identifier{
                Analytics.setUserID(userIdentifier)
                Analytics.setUserProperty(userIdentifier, forName: "KrakeIdentifier")
            }
            if let contactIdentifier = KLoginManager.shared.currentUser?.contactIdentifier{
                Analytics.setUserProperty(contactIdentifier, forName: "KrakeContactIdentifier")
            }
            if let userRoles = KLoginManager.shared.currentUser?.roles{
                var stringRoles = ""
                for role in userRoles{
                    if !stringRoles.isEmpty{
                        stringRoles.append(", ")
                    }
                    stringRoles.append(role)
                }
                Analytics.setUserProperty(stringRoles, forName: "KrakeRoles")
            }
        }
    }
}

