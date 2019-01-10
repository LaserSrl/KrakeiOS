//
//  Twitter+Krake.swift
//
//
//  Created by Patrick on 23/08/16.
//  Copyright © 2016-2018 Laser Srl. All rights reserved.
//

import Foundation
import TwitterKit
import SwiftyJSON

public typealias DownloadTweetsBlock = (_ completed: Bool,_ tweets: [TWTRTweet]?, _ error: Error?) -> Void

@objc public enum KTWTRTweetViewStyle: NSInteger{
    case Light
    case Dark
};

extension KInfoPlist
{
    open class Twitter: NSObject
    {
        public static let consumerKey: String = {
            let fabric = JSON(Bundle.main.object(forInfoDictionaryKey: "Fabric")!)
            let kits = fabric["Kits"].array!
            for kit in kits{
                if kit["KitName"].string == "Twitter" {
                    return kit["KitInfo"].dictionary!["consumerKey"]!.string!
                }
            }
            assertionFailure("Manca la Key di Twitter")
            return ""
        }()
        
        public static let consumerSecret: String = {
            let fabric = JSON(Bundle.main.object(forInfoDictionaryKey: "Fabric")!)
            let kits = fabric["Kits"].array!
            for kit in kits{
                if kit["KitName"].string == "Twitter" {
                    return kit["KitInfo"].dictionary!["consumerSecret"]!.string!
                }
            }
            assertionFailure("Manca il Secret di Twitter")
            return ""
        }()
    }
}

//MARK: - Twitter extension
extension TWTRTwitter{
    /*
        Call this before do anything
     */
    public func start(){
        TWTRTwitter.sharedInstance().start(withConsumerKey: KInfoPlist.Twitter.consumerKey, consumerSecret: KInfoPlist.Twitter.consumerSecret)
    }
}
