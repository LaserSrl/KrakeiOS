//
//  APIConstants.swift
//  Krake
//
//  Created by Patrick on 30/08/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

open class KAPIConstants: NSObject
{
    public static let mail = "Api/Laser.Orchard.ContactForm/EmailAPI"
    public static let contentExtension = "Api/Laser.Orchard.ContentExtension/ContentItem"
    public static let userStartupConfig = "Api/Laser.Orchard.StartupConfig/User"
    public static let policies = "Api/Laser.Orchard.Policy/PoliciesApi"
    public static let questionnairesGameRanking = "Api/Laser.Orchard.Questionnaires/GameRanking"
    public static let questionnairesResponse = "Api/Laser.Orchard.Questionnaires/QuestionnaireResponse"
    public static let signal = "Api/Laser.Orchard.WebServices/SignalApi"
    public static let tracking = "Api/Tracking"
    public static let nonceLogin = "Api/NonceLogin"
    
    public static let imageBasePath = "MediaExtensions/ImageUrl"
    @objc public static let wsBasePath = "Laser.Orchard.WebServices"
    public static let uploadFile = "Laser.Orchard.ContentExtension/UploadFile/PostFile"
    public static let userExtensions = "Laser.Orchard.UsersExtensions/AKUserActions"
    public static let policiesList = "Policies/List"
    public static let externalTokenLogon = "AKExternal/TokenLogon"
}
