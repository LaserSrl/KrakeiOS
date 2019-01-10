//
//  KDetailViewControllerFactory.swift
//  Krake
//
//  Created by Patrick on 31/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation

/**
 Factory class that creates a view controller representing in detail an object;
 the view controller is created using the storyboard named *KDetail.storyboard*
 inside *Content* folder.
 
 - important:
 If you want to subclass this class, remember to update `KDetailViewControllerFactory.factory`
 to an instance of your own subclass.
*/
@objc(KDetailViewControllerFactory)
open class KDetailViewControllerFactory: NSObject {
    /// Instance of the `KDetailViewControllerFactory` used to generate
    /// the detail view controller.
    public static var factory: KDetailViewControllerFactory = KDetailViewControllerFactory()

    open func objc_newDetailViewController(_ endPoint: String?) -> UIViewController? {
        return newDetailViewController(endPoint: endPoint, extras: nil, detailDelegate: nil, analyticsExtras: nil)
    }

    /**
     Create a new view controller using the given parameters.
     
     - precondition: If the detail object is not `nil` it must conform to `ContentItem`
     protocol.
     
     - parameter detail: Object that has to be presented by the created view controller.
     - parameter endPoint: Endpoint used to load the information about the detail.
     - parameter loginRequired: il the detail must be called with login required
     - parameter extras: Dictionary containing the parameters that will be sent to the WS.
     - parameter detailDelegate: Object that acts as delegate of the view controller.
     - parameter analyticsExtras: Dictionary containing the parameters that will be sent to Analytics.
     
     - returns: A new instance of `UIViewController` prepared with the given
     parameters.
     */
    open func newDetailViewController(detailObject detail: AnyObject? = nil,
                                      endPoint: String? = nil,
                                      loginRequired: Bool = false,
                                      extras: [String: Any]? = nil,
                                      detailDelegate: KDetailPresenterDelegate? = nil,
                                      analyticsExtras: [String: Any]? = nil) -> UIViewController? {
        guard detail == nil || ((detail as? ContentItem) != nil) else {
            return nil
        }
        
        // Getting the detail view controller from the storyboard.
        let vc = KDetailViewController()
        // Setting the detail object and the endpoint on the created view
        // controller.
        vc.loginRequired = loginRequired
        vc.detailObject = detail
        vc.endPoint = endPoint
        vc.analyticsExtras = analyticsExtras
        // Updating the delegate of the view controller, if present.
        if detailDelegate != nil {
            vc.detailDelegate = detailDelegate
        }
        // Updating the entries of the view controller's extras using the given
        // dictionary, if present.
        if let extras = extras {
            for (key, value) in extras {
                vc.extraDictionary[key] = value
            }
        }
        return vc
    }
}
