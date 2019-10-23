//
//  URLConfigurationCookies.swift
//  Krake
//
//  Created by joel on 17/10/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import UIKit

public enum CookieType: String {
    case Auth = ".ASPXAUTH"
    case Policy = "PoliciesAnswers"
    case UserReaction = "userCookie"
    case OldAuth = "OCCookies"
}

class URLConfigurationCookies {
    private var authCookie: HTTPCookie? = nil
    private var policyCookie: HTTPCookie? = nil
    private var userReactionCookie: HTTPCookie? = nil

    static public let shared: URLConfigurationCookies = URLConfigurationCookies()

    public let configuration: URLSessionConfiguration

    private init() {

        configuration = URLSessionConfiguration.default.copy() as! URLSessionConfiguration
        configuration.httpShouldSetCookies = false
        loadCookiesFromPref()

        configuration.checkAndAddStoredCookie(authCookie)
        configuration.checkAndAddStoredCookie(policyCookie)
        configuration.checkAndAddStoredCookie(userReactionCookie)
    }


    private func loadCookiesFromPref(){

        //TODO: aggiornamento versione 11.0 da rimuovere 11.1
        if let old = UserDefaults.standard.object(forKey: CookieType.OldAuth.rawValue) as? Data {
            UserDefaults.standard.set(old, forKey: CookieType.Auth.rawValue)
            UserDefaults.standard.removeObject(forKey: CookieType.OldAuth.rawValue)
        }

        if let data = UserDefaults.standard.object(forKey: CookieType.Auth.rawValue) as? Data{
            let object = NSKeyedUnarchiver.unarchiveObject(with: data)
            if let objects = object as? NSArray{
                authCookie = objects.firstObject as? HTTPCookie
            }
            else {
                authCookie = object as? HTTPCookie
            }
            if !(authCookie?.isValidCookie() ?? true){
                removeAuthCookie()
            }
        }

        if let data = UserDefaults.standard.object(forKey: CookieType.Policy.rawValue) as? Data{
            let object = NSKeyedUnarchiver.unarchiveObject(with: data)
            if let objects = object as? NSArray{
                policyCookie = objects.firstObject as? HTTPCookie
            }
            else{
                policyCookie = object as? HTTPCookie
            }
            if !(policyCookie?.isValidCookie() ?? true){
                removePoliciesCookie()
            }

        }

        if let data = UserDefaults.standard.object(forKey: CookieType.UserReaction.rawValue) as? Data{
            let object = NSKeyedUnarchiver.unarchiveObject(with: data)
            if let objects = object as? NSArray{
                userReactionCookie = objects.firstObject as? HTTPCookie
            }
            else{
                userReactionCookie = object as? HTTPCookie
            }
            if !(userReactionCookie?.isValidCookie() ?? true){
                removeUserReactionCookie()
            }
        }
    }

    public func removeAuthCookie(){
        authCookie = nil
        removeCookie(.Auth)
    }

    public func removePoliciesCookie(){
        policyCookie = nil
        removeCookie(.Policy)
    }

    public func removeUserReactionCookie(){
        userReactionCookie = nil
        removeCookie(.UserReaction)
    }

    private func removeCookie(_ type:CookieType) {

        if let cookies = configuration.httpCookieStorage?.cookies?.filter({$0.name == type.rawValue}) {
            for cookie in cookies {
                configuration.httpCookieStorage?.deleteCookie(cookie)
            }
        }

        UserDefaults.standard.set(nil, forKey: type.rawValue)
        UserDefaults.standard.synchronize()
    }

    public func isValidAuthCookie() -> Bool {
        return authCookie != nil
    }

    func cookiesFor(request urlRequest: URLRequest, authenticated: Bool) -> KRequestCookies{
        var cookies = configuration.httpCookieStorage?.cookies(for: urlRequest.url!)
        var authCookie: HTTPCookie? = nil
        if !authenticated  {
            cookies = cookies?.filter({$0.name != CookieType.Auth.rawValue})
        }
        else {
            authCookie = cookies?.filter({$0.name == CookieType.Auth.rawValue}).first
        }

        return KRequestCookies(cookies: cookies ?? [HTTPCookie](),
                               authCookie: authCookie)
    }

    public func parse(cookies: [HTTPCookie]){
        if cookies.count > 0{
            for cookie in cookies {
                let data = NSKeyedArchiver.archivedData(withRootObject: cookie)
                switch cookie.name {
                case CookieType.Auth.rawValue:
                    authCookie = cookie
                    if !cookie.isSessionOnly {
                        UserDefaults.standard.set(data, forKey: CookieType.Auth.rawValue)
                    }
                case CookieType.Policy.rawValue:
                    policyCookie = cookie
                    UserDefaults.standard.set(data, forKey: CookieType.Policy.rawValue)
                case CookieType.UserReaction.rawValue:
                    userReactionCookie = cookie
                    UserDefaults.standard.set(data, forKey: CookieType.UserReaction.rawValue)
                default:
                    break
                }
            }
            UserDefaults.standard.synchronize()
        }
    }
}

public struct KRequestCookies {
    let cookies: [HTTPCookie]
    let authCookie: HTTPCookie?
}

extension URLSessionConfiguration {

    fileprivate func checkAndAddStoredCookie(_ cookie: HTTPCookie?) {
        if let cookie = cookie {
            if httpCookieStorage?.cookies?.filter({ (loopCookie) -> Bool in
                loopCookie.name == cookie.name
            }).first == nil {
                httpCookieStorage?.setCookie(cookie)
                NSLog("Setup: Cookie %@ aggiunto", cookie.name)
            }
            else {
                NSLog("Setup: Cookie %@ trovato", cookie.name)
            }
        }
    }
}
