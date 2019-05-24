//
//  KInfoPlist+Login.swift
//  Krake
//
//  Created by Patrick on 20/09/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

extension KInfoPlist
{
    @objc open class Login: NSObject
    {
        @objc public static let canUserRegisterWithKrake: Bool =
            {
                let canUserRegisterWithKrake = KLoginManager.shared.delegate?.canUserRegisterWithKrake ?? Bundle.loginAndRegistrationKrakeSettings()["CanUserRegisterWithKrake"]?.boolValue ?? true
                return canUserRegisterWithKrake
        }()
        
        @objc public static let canUserRecoverPassword: Bool =
            {
                let canUserRecoverPassword = KLoginManager.shared.delegate?.canUserRecoverPassword ?? Bundle.loginAndRegistrationKrakeSettings()["CanUserRecoverPassword"]?.boolValue ?? true
                return canUserRecoverPassword
        }()
        
        @objc public static let canUserLoginWithKrake: Bool =
            {
                let canUserLoginWithKrake = KLoginManager.shared.delegate?.canUserLoginWithKrake ?? Bundle.loginAndRegistrationKrakeSettings()["CanUserLoginWithKrake"]?.boolValue ?? true
                return canUserLoginWithKrake
        }()
        
        public static let canUserLogout: Bool =
        {
            let canUserLogout = KLoginManager.shared.delegate?.canUserLogout ?? Bundle.loginAndRegistrationKrakeSettings()["CanUserLogout"]?.boolValue ?? true
            return canUserLogout
        }()
        
        @objc public static let canUserRecoverPasswordWithSMS: Bool =
            {
                let canUserRecoverPasswordWithSMS = KLoginManager.shared.delegate?.canUserRecoverPasswordWithSMS ?? Bundle.loginAndRegistrationKrakeSettings()["CanUserRecoverPasswordWithSMS"]?.boolValue ?? true
                return canUserRecoverPasswordWithSMS
        }()
        
        @objc public static let userHaveToRegisterWithSMS: Bool =
            {
                let userHaveToRegisterWithSMS = KLoginManager.shared.delegate?.userHaveToRegisterWithSMS ?? Bundle.loginAndRegistrationKrakeSettings()["UserHaveToRegisterWithSMS"]?.boolValue ?? false
                return userHaveToRegisterWithSMS
        }()
        
        @objc public static let canUserCancelLogin: Bool =
            {
                let canUserCancelLogin = KLoginManager.shared.delegate?.canUserCancelLogin ?? true
                return canUserCancelLogin
        }()
    }
}
