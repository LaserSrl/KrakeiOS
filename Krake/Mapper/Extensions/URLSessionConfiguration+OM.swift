//
//  NSURLSessionConfiguration+OM.swift
//  OrchardGen
//
//  Created by Patrick on 11/03/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation
import CryptoSwift


extension URLSessionConfiguration{
    fileprivate static var authCookie: HTTPCookie? = nil
    fileprivate static var policyCookie: HTTPCookie? = nil
    fileprivate static var userReactionCookie: HTTPCookie? = nil
    
    public static func krakeSessionConfiguration(auth: Bool) -> URLSessionConfiguration {
        loadCookiesFromPref()
        let krakeSessionConfiguration = URLSessionConfiguration.default.copy() as! URLSessionConfiguration
        krakeSessionConfiguration.configureSession(auth: auth)
        return krakeSessionConfiguration
    }
    
    @objc public static func removeAuthCookie(){
        URLSessionConfiguration.authCookie = nil
        UserDefaults.standard.set(nil, forKey: CookieType.Auth.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public static func removePoliciesCookie(){
        URLSessionConfiguration.policyCookie = nil
        UserDefaults.standard.set(nil, forKey: CookieType.Policy.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public static func removeUserReactionCookie(){
        URLSessionConfiguration.userReactionCookie = nil
        UserDefaults.standard.set(nil, forKey: CookieType.UserReaction.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    @objc public static func isValidAuthCookie() -> Bool{
        loadCookiesFromPref()
        return URLSessionConfiguration.authCookie != nil
    }
    
    public static func parse(cookies: [HTTPCookie]){
        if cookies.count > 0{
            for cookie in cookies {
                let data = NSKeyedArchiver.archivedData(withRootObject: cookie)
                switch cookie.name {
                case ".ASPXAUTH":
                    URLSessionConfiguration.authCookie = cookie
                    if !cookie.isSessionOnly {
                        UserDefaults.standard.set(data, forKey: CookieType.Auth.rawValue)
                    }
                case CookieType.Policy.rawValue:
                    URLSessionConfiguration.policyCookie = cookie
                    UserDefaults.standard.set(data, forKey: CookieType.Policy.rawValue)
                case CookieType.UserReaction.rawValue:
                    URLSessionConfiguration.userReactionCookie = cookie
                    UserDefaults.standard.set(data, forKey: CookieType.UserReaction.rawValue)
                default:
                    break
                }
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    static func loadCookiesFromPref(){
        if URLSessionConfiguration.authCookie == nil {
            if let data = UserDefaults.standard.object(forKey: CookieType.Auth.rawValue) as? Data{
                let object = NSKeyedUnarchiver.unarchiveObject(with: data)
                if let objects = object as? NSArray{
                    URLSessionConfiguration.authCookie = objects.firstObject as? HTTPCookie
                }else{
                    URLSessionConfiguration.authCookie = object as? HTTPCookie
                }
                if !(URLSessionConfiguration.authCookie?.isValidCookie() ?? true){
                    URLSessionConfiguration.removeAuthCookie()
                }
            }
        }
        if URLSessionConfiguration.policyCookie == nil {
            if let data = UserDefaults.standard.object(forKey: CookieType.Policy.rawValue) as? Data{
                let object = NSKeyedUnarchiver.unarchiveObject(with: data)
                if let objects = object as? NSArray{
                    URLSessionConfiguration.policyCookie = objects.firstObject as? HTTPCookie
                }else{
                    URLSessionConfiguration.policyCookie = object as? HTTPCookie
                }
                if !(URLSessionConfiguration.policyCookie?.isValidCookie() ?? true){
                    URLSessionConfiguration.removePoliciesCookie()
                }
            }
        }
        if URLSessionConfiguration.userReactionCookie == nil {
            if let data = UserDefaults.standard.object(forKey: CookieType.UserReaction.rawValue) as? Data{
                let object = NSKeyedUnarchiver.unarchiveObject(with: data)
                if let objects = object as? NSArray{
                    URLSessionConfiguration.userReactionCookie = objects.firstObject as? HTTPCookie
                }else{
                    URLSessionConfiguration.userReactionCookie = object as? HTTPCookie
                }
                if !(URLSessionConfiguration.userReactionCookie?.isValidCookie() ?? true){
                    URLSessionConfiguration.removeUserReactionCookie()
                }
            }
        }
    }
    
    public func configureSession(auth: Bool){
        let cookieStorage = httpCookieStorage
        httpAdditionalHeaders = nil
        if let cookie = URLSessionConfiguration.authCookie , auth {
            cookieStorage?.setCookie(cookie)
            addXSRFToken()
        }
        if let cookie = URLSessionConfiguration.policyCookie {
            cookieStorage?.setCookie(cookie)
        }
        if let cookie = URLSessionConfiguration.userReactionCookie {
            cookieStorage?.setCookie(cookie)
        }
        if !auth || URLSessionConfiguration.authCookie == nil {
            if let cookies = cookieStorage?.cookies{
                for cookie in cookies{
                    if cookie.name == ".ASPXAUTH"{
                        cookieStorage?.deleteCookie(cookie)
                    }
                }
            }
        }
    }
    
    public func addXSRFToken() {
        if let cookie = URLSessionConfiguration.authCookie, let hash = sha512(cookie.value){
            addAdditionalHeaders(["X-XSRF-TOKEN" : hash])
        }
    }
    
    public func addAdditionalHeaders(_ headers: [String : String]){
        if httpAdditionalHeaders == nil {
            httpAdditionalHeaders = headers
        }else{

            for (key, value) in headers {
                httpAdditionalHeaders?[key] = value
            }
        }
    }
    
    func sha512(_ string: String) -> String?{
        
        if let salt = KInfoPlist.KrakePlist.encriptionKey
        {
            let saltData = salt.data(using: String.Encoding.utf8)
            let paramData = string.data(using: String.Encoding.utf8)
            let saltArray = Array(UnsafeBufferPointer(start: (saltData! as NSData).bytes.bindMemory(to: UInt8.self, capacity: saltData!.count), count: saltData!.count))
            let saltParam = Array(UnsafeBufferPointer(start: (paramData! as NSData).bytes.bindMemory(to: UInt8.self, capacity: paramData!.count), count: paramData!.count))
            let hash = try! HMAC(key: saltArray, variant: .sha512).authenticate(saltParam)
            let base64Hash = hash.toBase64()
            return base64Hash
        }
        return nil
    }
    
}
