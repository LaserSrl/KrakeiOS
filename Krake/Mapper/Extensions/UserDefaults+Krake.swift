//
//  UserDefaults+Krake.swift
//  Krake
//
//  Created by Patrick on 30/08/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

@objc public enum OMStringConstantKey: Int {
    case userPhoneNumber
    case userName
    case userEmail
    case domain
    case pushDeviceToken
    case pushDeviceUUID
    case pushLanguage
    case pushURL
}

extension UserDefaults
{
    
    func stringFromKey(key: OMStringConstantKey) -> String
    {
        switch key {
        case .userPhoneNumber:
            return "User-PhoneNumber"
        case .userName:
            return "User-Name"
        case .domain:
            return "User-Domain"
        case .userEmail:
            return "User-Email"
        case .pushDeviceToken:
            return "SentTokenPrefKey"
        case .pushDeviceUUID:
            return "SentUUIDPrefKey"
        case .pushLanguage:
            return "SentLanguage"
        case .pushURL:
            return "SentURL"
        }
    }
    
    @objc open func setStringAndSync(_ value: String?, forConstantKey key: OMStringConstantKey) {
        setValue(value, forKey: stringFromKey(key: key))
        synchronize()
    }
    
    @objc open func string(forConstantKey key: OMStringConstantKey) -> String? {
        return value(forKey: stringFromKey(key: key)) as? String
    }
}
