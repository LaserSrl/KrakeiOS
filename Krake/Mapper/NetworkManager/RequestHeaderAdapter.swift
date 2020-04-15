//
//  RequestHeaderAdapter.swift
//  Krake
//
//  Created by joel on 16/10/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import UIKit
import Alamofire
import CryptoSwift

class RequestHeaderAdapter: RequestInterceptor {

    let authenticaed: Bool
    init(auth: Bool) {
        authenticaed = auth
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {

        var request = urlRequest
        request.setValue("lmnv", forHTTPHeaderField: "OutputFormat")
        if !KConstants.uuid.isEmpty
        {
            request.setValue(KConstants.uuid, forHTTPHeaderField: "x-UUID")
        }


        let cookiesToSend = URLConfigurationCookies.shared.cookiesFor(request: urlRequest, authenticated: authenticaed)

        let cookiesHeaders = HTTPCookie.requestHeaderFields(with: cookiesToSend.cookies)

        KLog(cookiesHeaders.description)
        for (key, value) in cookiesHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let authCookie = cookiesToSend.authCookie {
            request.setValue(authCookie.sha512() ?? "", forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        if let apiKeyInfo = generateApiKey() {
            request.setValue(apiKeyInfo.apiKey, forHTTPHeaderField: "ApiKey")
            request.setValue(apiKeyInfo.akiv, forHTTPHeaderField: "AKIV")
            if let apiChannel = apiKeyInfo.apiChannel {
                request.setValue(apiChannel, forHTTPHeaderField: "ApiChannel")
            }
        }
        completion(.success(request))
    }

    private func generateApiKey() -> ApiKeyInfo? {
        if let apikey = KInfoPlist.KrakePlist.apiKey, !apikey.isEmpty
        {
            let date = Date.networkTime()
            let timeStamp: TimeInterval = date.timeIntervalSince1970
            let key = String(format:"%@:%.f:%lu", apikey, timeStamp, arc4random())
            if let xsrf = KInfoPlist.KrakePlist.encriptionKey{
                var xsrfMod = [UInt8]()
                var startIndex = xsrf.startIndex
                let endIndex = xsrf.endIndex
                while startIndex !=  endIndex {
                    let loopIndex = xsrf.index(startIndex, offsetBy: 2)
                    let part = String(xsrf[startIndex ..< loopIndex])
                    xsrfMod.append(UInt8(strtol(part, nil, 16)))
                    startIndex = loopIndex
                }
                var input = [UInt8]()
                for char in key.utf8{
                    input.append(char)
                }
                let iv: [UInt8] = AES.randomIV(AES.blockSize)
                do {
                    let encrypted: [UInt8] = try AES(key: xsrfMod, blockMode: CBC(iv: iv), padding: .pkcs7).encrypt(input)
                    if let encryptedString = encrypted.toBase64(), let ivString = iv.toBase64(){
                        return (ApiKeyInfo(apiKey: encryptedString, akiv: ivString, apiChannel: KInfoPlist.KrakePlist.apiChannel))
                    }
                }
                catch {

                }
            }
        }

        return nil
    }
}

extension HTTPCookie {
    fileprivate func sha512() -> String?{

        if let salt = KInfoPlist.KrakePlist.encriptionKey
        {
            let saltData = salt.data(using: String.Encoding.utf8)
            let paramData = value.data(using: String.Encoding.utf8)
            let saltArray = Array(UnsafeBufferPointer(start: (saltData! as NSData).bytes.bindMemory(to: UInt8.self, capacity: saltData!.count), count: saltData!.count))
            let saltParam = Array(UnsafeBufferPointer(start: (paramData! as NSData).bytes.bindMemory(to: UInt8.self, capacity: paramData!.count), count: paramData!.count))
            let hash = try! HMAC(key: saltArray, variant: .sha512).authenticate(saltParam)
            let base64Hash = hash.toBase64()
            return base64Hash
        }
        return nil
    }
}
struct ApiKeyInfo {
    let apiKey: String
    let akiv: String
    let apiChannel: String?
}
