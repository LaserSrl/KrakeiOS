//
//  URLConfigurationCookies.swift
//  Krake
//
//  Created by joel on 17/10/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import UIKit

public enum CookieType: String {
    case Auth = "OCCookies"
    case Policy = "PoliciesAnswers"
    case UserReaction = "userCookie"
}

class URLConfigurationCookies {
    static var authCookie: HTTPCookie? = nil
    static var policyCookie: HTTPCookie? = nil
    static var userReactionCookie: HTTPCookie? = nil

    static public let shared: URLSessionConfiguration = {
        URLConfigurationCookies.loadCookiesFromPref()

        let configuration = URLSessionConfiguration.default.copy() as! URLSessionConfiguration
        configuration.httpShouldSetCookies = false

        configuration.checkAndAddStoredCookie(URLConfigurationCookies.authCookie)
        configuration.checkAndAddStoredCookie(URLConfigurationCookies.policyCookie)
        configuration.checkAndAddStoredCookie(URLConfigurationCookies.userReactionCookie)

        return configuration
    }()

    private static func loadCookiesFromPref(){
        if URLConfigurationCookies.authCookie == nil {
            if let data = UserDefaults.standard.object(forKey: CookieType.Auth.rawValue) as? Data{
                let object = NSKeyedUnarchiver.unarchiveObject(with: data)
                if let objects = object as? NSArray{
                    URLConfigurationCookies.authCookie = objects.firstObject as? HTTPCookie
                }else{
                    URLConfigurationCookies.authCookie = object as? HTTPCookie
                }
                if !(URLConfigurationCookies.authCookie?.isValidCookie() ?? true){
                    URLSessionConfiguration.removeAuthCookie()
                }
            }
        }
        if URLConfigurationCookies.policyCookie == nil {
            if let data = UserDefaults.standard.object(forKey: CookieType.Policy.rawValue) as? Data{
                let object = NSKeyedUnarchiver.unarchiveObject(with: data)
                if let objects = object as? NSArray{
                    URLConfigurationCookies.policyCookie = objects.firstObject as? HTTPCookie
                }else{
                    URLConfigurationCookies.policyCookie = object as? HTTPCookie
                }
                if !(URLConfigurationCookies.policyCookie?.isValidCookie() ?? true){
                    URLSessionConfiguration.removePoliciesCookie()
                }
            }
        }
        if URLConfigurationCookies.userReactionCookie == nil {
            if let data = UserDefaults.standard.object(forKey: CookieType.UserReaction.rawValue) as? Data{
                let object = NSKeyedUnarchiver.unarchiveObject(with: data)
                if let objects = object as? NSArray{
                    URLConfigurationCookies.userReactionCookie = objects.firstObject as? HTTPCookie
                }else{
                    URLConfigurationCookies.userReactionCookie = object as? HTTPCookie
                }
                if !(URLConfigurationCookies.userReactionCookie?.isValidCookie() ?? true){
                    URLSessionConfiguration.removeUserReactionCookie()
                }
            }
        }
    }
}

extension URLSessionConfiguration {

    fileprivate func checkAndAddStoredCookie(_ cookie: HTTPCookie?) {
        //if httpCookieStorage?.cookies
    }
}
