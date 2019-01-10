//
//  UINavigationController.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController{
    
    open func pushPolicyViewController(policyEndPoint: String? = nil, policyTitle: String? = nil, policyText: String? = nil, largeMargin: Bool = false){
        let vc = PolicyViewController(policyEndPoint: policyEndPoint, policyTitle: policyTitle, policyText: policyText, largeMargin: largeMargin)
        pushViewController(vc, animated: true)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle{
        return KTheme.current.statusBarStyle(.default)
    }
}
