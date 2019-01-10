//
//  StoreKitManager.swift
//  Krake
//
//  Created by Patrick on 03/04/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation
import StoreKit

public class KStoreKitManager: NSObject
{
    public static let shared: KStoreKitManager = KStoreKitManager()
    
    fileprivate static let CountOpenAppReviewKey = "CountOpenAppReviewKey"
    fileprivate let isNumberOfRunMajorThanMinimunRequired: Bool = {
        let numberOfUses: Int = UserDefaults.standard.value(forKey: KStoreKitManager.CountOpenAppReviewKey) as? Int ?? 0
        return numberOfUses >= KInfoPlist.StoreReview.minimunRunCountReviewRequest.intValue
    }()
    
    /// Set true to enable prompt review request, by default check the field 'Krake.CanPrompt' into the info.plist
    public var canPromptReviewRequest = KInfoPlist.StoreReview.canPromptReviewRequest
    
    fileprivate override init() {
        super.init()
        let countOpen: Int = UserDefaults.standard.value(forKey: KStoreKitManager.CountOpenAppReviewKey) as? Int ?? 0
        UserDefaults.standard.set(countOpen+1, forKey: KStoreKitManager.CountOpenAppReviewKey)
        UserDefaults.standard.synchronize()
    }
    
    /// Check if is need to prompt the review request and if is true call promptReviewRequest()
    public func promptReviewRequestIfNeeded()
    {
        #if !(DEBUG)
        if canPromptReviewRequest && isNumberOfRunMajorThanMinimunRequired{
            promptReviewRequest()
        }
        #endif
    }
    
    /// Prompt the review request
    public func promptReviewRequest()
    {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            //TODO: - Gestire il caso in cui l'OS sia inferiore a 10.3
        }
    }
    
    //MARK: - Deprecated
    
    @available(*, deprecated: 1.0, renamed: "promptReviewRequestIfNeeded")
    public func requestReviewIfNeeded()
    {
        promptReviewRequestIfNeeded()
    }
}

//MARK: - Deprecated

@available(*, deprecated: 1.0, renamed: "KStoreKitManager")
public class StoreKitManager: KStoreKitManager{}
