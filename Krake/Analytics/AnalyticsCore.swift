//
//  AnalyticsCore.swift
//  Pods
//
//  Created by Patrick on 27/07/16.
//
//

import Foundation

/**
 Protocol that defines the functions that an analytics manager must expose to
 the components of the app.
 Each function is used to track a particular event on the associated analytics
 system.
 */
@objc public protocol KAnalytics: NSObjectProtocol {
    /**
     Track a content selection event.
     
     - parameters:
     - contentType: String describing the type of the selected content.
     - itemId: The identifier of the selected content.
     - itemName: The name of the selected content.
     - parameters: The dictionary of extra parameters
     */
    func log(selectContent contentType: String, itemId: NSNumber?, itemName: String?, parameters: [String : Any]?)
    /**
     Track a list displaying event.
     
     - parameters:
     - itemCategory: Description of the category of items displayed in the list.
     - `parameters`: Additional parameters to attach to the event.
     */
    func log(itemList itemCategory: String, parameters: [String : Any]?)
    /**
     Track a generic event.
     
     - parameters:
     - eventName: The name of the event.
     - `parameters`: Additional parameters to attach to the event.
     */
    func log(event eventName: String, parameters: [String : Any]?)
    /**
     Track a share event.
     
     - parameters:
     - socialActivity: Description of the shared information.
     - contentType: Description of the type of the shared content.
     - itemId: Description of the type of the shared content.
     - `parameters`: Additional parameters to attach to the event.
     */
    func log(share socialActivity: String, contentType: String, itemId: String?, parameters: [String : Any]?)
    
    // FIXME: Documentation missing.
    func setProperty(_ property: String, forKey: String)
    
    func setUserInfoProperties()
}

/**
 Object used to hold the reference to the analytics manager that will be used
 to track key user interactions with the app.
 
 - important: Remember to configure the reference `AnalyticsCore.shared` with
 your analytics manager.
 */
@objc open class AnalyticsCore: NSObject {
    @objc public static var shared: KAnalytics?
}
