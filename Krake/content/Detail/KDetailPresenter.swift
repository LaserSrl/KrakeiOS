//
//  KDetailPresenter.swift
//  Krake
//
//  Created by Patrick on 31/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import UIKit
import MapKit

/// Protocol implemented by classes that want to present in the UI detailed
/// information about an object.
public protocol KDetailPresenter: NSObjectProtocol {
    /// The object asked to be presented.
    var detailObject : AnyObject? { get set }
    /// The endpoint where information about the detail can be retrieved.
    /// Usually, this is the last path segment that will be appended to the base
    /// path.
    var endPoint : String? { get set }
    /// Dictionary containing extra parameters that will be sent to the WS.
    var extraDictionary: [String: Any] { get set }
    /// The object acting as delegate of the presenter.
    var detailDelegate: KDetailPresenterDelegate? { get set }
    
    var analyticsExtras : [String : Any]? { get set }

    var loginRequired: Bool {get set}
}

public protocol KDetailPresenterDelegate: NSObjectProtocol {
    func createAttachmentButtons(_ controller: UIViewController,
                                 element: AnyObject?) -> [KButtonItem]?
    func createSocialButtons(_ controller: UIViewController,
                             element: AnyObject?) -> [KButtonItem]?
    func detailMapView(_ mapView: KExtendedMapView,
                       annotationView view: MKAnnotationView,
                       calloutAccessoryControlTapped control: UIControl,
                       fromViewController: UIViewController) -> Bool
    func shareActivitiesFor(content: AnyObject!) -> [UIActivity]?

    func viewDidLoad(_ viewController: KDetailViewController)
    func viewWillDisappear(_ viewController: KDetailViewController)
    func viewDidAppear(_ viewController: KDetailViewController)
    func viewWillAppear(_ viewController: KDetailViewController)
}

open class KDetailPresenterDefaultDelegate : NSObject, KDetailPresenterDelegate {

    public let showTitles: Bool

    public init(showTitles titles: Bool = true) {
        showTitles = titles
    }
    
    open func createSocialButtons(_ controller: UIViewController, element: AnyObject?) -> [KButtonItem]? {
        if let element = element {
            var array = [KButtonItem]()
            if let shareElem = element as? ContentItemWithSocial {
                if let facebookValue = shareElem.facebookValue {
                    let media = KButtonItem(title: "Facebook",
                                           image: UIImage(krakeNamed:"facebook"),
                                           mediaUrl: facebookValue,
                                           showTitle: showTitles)
                    array.append(media)
                }
                if let twitterValue = shareElem.twitterValue {
                    let media = KButtonItem(title: "Twitter",
                                           image: UIImage(krakeNamed:"twitter"),
                                           mediaUrl:  twitterValue,
                                           showTitle: showTitles)
                    array.append(media)
                }
                if let pinterestValue = shareElem.pinterestValue {
                    let media = KButtonItem(title: "Pinterest",
                                           image: UIImage(krakeNamed:"pinterest"),
                                           mediaUrl: pinterestValue,
                                           showTitle: showTitles)
                    array.append(media)
                }
                if let instagramValue = shareElem.instagramValue {
                    let media = KButtonItem(title: "Instagram",
                                           image: UIImage(krakeNamed:"instagram"),
                                           mediaUrl: instagramValue,
                                           showTitle: showTitles)
                    array.append(media)
                }
            }
            if let shareElem = element as? ContentItemWithContacts {
                if let phoneNumber = shareElem.telefonoValue {
                    let media = KButtonItem(title: "Telefono".localizedString(),
                                           image: UIImage(krakeNamed:"phone"),
                                           mediaUrl: "telprompt:\(phoneNumber)",
                                           showTitle: showTitles)
                    array.append(media)
                }
                if let email = shareElem.eMailValue {
                    let media = KButtonItem(title: "E-Mail".localizedString(),
                                           image: UIImage(krakeNamed:"email"),
                                           mediaUrl: "mailto:\(email)",
                                           showTitle: showTitles)
                    array.append(media)
                }
                if let webSite = shareElem.sitoWebValue {
                    let media = KButtonItem(title: "Sito web".localizedString(),
                                           image: UIImage(krakeNamed:"web"),
                                           mediaUrl: webSite,
                                           showTitle: showTitles)
                    array.append(media)
                }
            }
            return array
        }
        return nil
    }
    
    open func createAttachmentButtons(_ controller: UIViewController, element: AnyObject?) -> [KButtonItem]? {
        return nil
    }
    
    open func shareActivitiesFor(content: AnyObject!) -> [UIActivity]? {
        return nil
    }
    
    open func viewWillDisappear(_ viewController: KDetailViewController){
        
    }
    
    open func viewDidAppear(_ viewController: KDetailViewController){
        
    }
    
    open func detailMapView(_ mapView: KExtendedMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl, fromViewController: UIViewController) -> Bool {
        return false
    }
}

extension KDetailPresenterDelegate {

    public func viewDidLoad(_ viewController: KDetailViewController) {

    }
    
    public func detailMapView(_ mapView: KExtendedMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl, fromViewController: UIViewController) -> Bool {
        return false
    }

    public func createAttachmentButtons(_ controller: UIViewController, element: AnyObject?) -> [KButtonItem]? {
        return nil
    }
    
    public func shareActivitiesFor(content: AnyObject!) -> [UIActivity]? {
        return nil
    }
    
    public func viewWillDisappear(_ viewController: KDetailViewController){
        
    }

    public func viewWillAppear(_ viewController: KDetailViewController)
    {

    }
    
    public func viewDidAppear(_ viewController: KDetailViewController)
    {
        
    }
}
