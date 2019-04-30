//
//  UIViewController+OM.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController{
    
    @objc func presentPolicyViewController(policyEndPoint: String? = nil, policyTitle: String? = nil, policyText: String? = nil, largeMargin: Bool = false){
        let vc = PolicyViewController(policyEndPoint: policyEndPoint, policyTitle: policyTitle, policyText: policyText, largeMargin: largeMargin)
        let nav = UINavigationController(rootViewController: vc)
        KTheme.current.applyTheme(toNavigationBar: nav.navigationBar, style: .default)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true, completion: nil)
    }
    
}
