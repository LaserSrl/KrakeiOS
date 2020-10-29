//
//  PolicyProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

@objc public protocol PolicyProtocol: KeyValueCodingProtocol
{
    var identifier: NSNumber! {get}
    var autoroutePartDisplayAlias: String? {get}
    var titlePartTitle: String? {get}
    var bodyPartText: String? {get}
    var contentType: String? {get}
    var bodyPartFormat: String? {get}
    
    var policyTextInfoPartUserHaveToAccept: NSNumber? {get}
    var policyTextInfoPartPriority: NSNumber? {get}
    var policyTextInfoPartPolicyType: String? {get}
    
}

extension PolicyProtocol {
    func policyTextInfoPartPolicyTypeImage() -> UIImage? {
        if let named = policyTextInfoPartPolicyType{
            return KImageAsset(name: named).image
        }
        return nil
    }
}
