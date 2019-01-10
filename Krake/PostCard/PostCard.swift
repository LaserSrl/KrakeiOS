//
//  Collection.swift
//  Auto Moto Epoca
//
//  Created by Patrick on 11/09/15.
//  Copyright © 2015 Laser Group. All rights reserved.
//

import Foundation

public protocol PostCardProtocol: KeyValueCodingProtocol{
    var identifier: NSNumber! {get}
    var titlePartTitle: String? {get}
    var galleryMediaParts: NSOrderedSet? {get}
}

extension PostCardProtocol{
    
    public var titlePartTitle: String? {get{return nil}}
    public var galleryMediaParts: NSOrderedSet? {get{return nil}}
    
}

@objc(PostCards)
open class PostCards: NSObject{
    
    public static let sentPostCard = Notification.Name(rawValue: "SentPostCard")
    
    static public func postCardsViewController(_ endPoint: String, ratio: CGFloat = 1.0) -> UIViewController{
        let OCBundle = Bundle(for: PostCardCollectionViewController.self)
        let bundle = Bundle(url: OCBundle.url(forResource: "PostCard", withExtension: "bundle")!)
        let story = UIStoryboard(name: "PostCard", bundle: bundle)
        let vc = story.instantiateInitialViewController() as! PostCardCollectionViewController
        vc.endPoint = endPoint
        vc.ratio = ratio
        return vc
    }
}

extension UIViewController{
    
    public func present(postCardsViewController endPoint: String, ratio: CGFloat = 1.0){
        let vc = PostCards.postCardsViewController(endPoint, ratio: ratio)
        let nav = UINavigationController(rootViewController: vc)
        KTheme.current.applyTheme(toNavigationBar: nav.navigationBar, style: .default)
        nav.modalPresentationStyle = .formSheet
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(UIViewController.dismissViewController))
        present(nav, animated: true, completion: nil)
    }
}

extension UINavigationController{
    
    public func pushPostCardsViewController(_ endPoint: String, ratio: CGFloat = 1.0){
        let vc = PostCards.postCardsViewController(endPoint, ratio: ratio)
        pushViewController(vc, animated: true)
    }
}
