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

}

class URLConfigurationCookies {

    static public let shared: URLConfigurationCookies = URLConfigurationCookies()

    public let configuration: URLSessionConfiguration

    private init() {

        configuration = URLSessionConfiguration.default.copy() as! URLSessionConfiguration
        configuration.httpShouldSetCookies = false
        //TODO: aggiornamento versione 11.0 da rimuovere 11.1
        if let old = UserDefaults.standard.object(forKey: "OCCookies") as? Data {
            UserDefaults.standard.set(old, forKey: CookieType.Auth.rawValue)
            UserDefaults.standard.removeObject(forKey: "OCCookies")
            UserDefaults.standard.synchronize()
        }

        loadSavedCookies(.Auth)
        loadSavedCookies(.Policy)
        loadSavedCookies(.UserReaction)
    }


    private func loadSavedCookies(_ type:CookieType) {
        var cookie: HTTPCookie? = nil
        if let data = UserDefaults.standard.object(forKey: type.rawValue) as? Data {
            let object = NSKeyedUnarchiver.unarchiveObject(with: data)
            if let objects = object as? NSArray{
                cookie = objects.firstObject as? HTTPCookie
            }
            else {
                cookie = object as? HTTPCookie
            }
            
            if !(cookie?.isValidCookie() ?? true){
                removeCookie(type)
            }
        }
        
        configuration.checkAndAddStoredCookie(cookie)
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

        let cookies = configuration.httpCookieStorage?.cookies
        let authCookie: HTTPCookie? = cookies?.filter({$0.name == CookieType.Auth.rawValue}).first

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
                if let type = CookieType.init(rawValue: cookie.name) {
                    if !cookie.isSessionOnly {
                        let data = NSKeyedArchiver.archivedData(withRootObject: cookie)
                        UserDefaults.standard.set(data, forKey: type.rawValue)
                    }
                    configuration.checkAndAddStoredCookie(cookie)
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

/*
 Internal use only to delete the preferences
 */
extension URLConfigurationCookies {

    public func removeAuthCookie(){
        removeCookie(.Auth)
    }

    public func removePoliciesCookie(){
        removeCookie(.Policy)
    }

    public func removeUserReactionCookie(){
        removeCookie(.UserReaction)
    }
}

extension URLSessionConfiguration {

    fileprivate func checkAndAddStoredCookie(_ cookie: HTTPCookie?) {
        if let cookie = cookie {
            if httpCookieStorage?.cookies?.filter({ (loopCookie) -> Bool in
                if let cookieDate = cookie.expiresDate, let loopCookieDate = loopCookie.expiresDate {
                    return loopCookie.name == cookie.name && loopCookie.domain == cookie.domain && cookieDate < loopCookieDate
                }
                return loopCookie.name == cookie.name && loopCookie.domain == cookie.domain
            }).first == nil {
                httpCookieStorage?.setCookie(cookie)
                KLog(String(format:"Setup: Cookie %@ aggiunto", cookie.name))
            }
            else {
                KLog(String(format:"Setup: Cookie %@ trovato", cookie.name))
            }
        }
    }
}
