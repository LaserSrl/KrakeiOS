//
//  VimeoStreamingProvider.swift
//  Krake
//
//  Created by Patrick on 01/09/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import CryptoSwift

open class VimeoStreamingProvider: KStreamingProvider {

    // Empty public constructor for initializer accessibility.
    public init() {}

    public var name: String {
        return "VIMEO"
    }

    public func retrieveVideoURL(from videoString: String) -> String? {
        guard videoString.count > 24 else {
            // The string length is minor than the minimum and so it does not
            // contain the IV.
            return nil
        }
		// Finding the start index of the content to parse to get the URL
        // of the video.
        let videoStringStartIndex: String.Index = {
            let startIndex = videoString.startIndex
			// Searching for the '|' character because the string returned by
            // the WS should be constructed as "STREAMING_PROVIDER_DESCRIPTION|ENCRYPTED_VIDEO_URL".
            if let pipeIndex = videoString.range(of: "|") {
                return videoString.index(startIndex,
                                         offsetBy: videoString.distance(from: startIndex,
                                                                        to: pipeIndex.upperBound))
            }
            return startIndex
        }()
		// Getting the initialization vector and the encrypted URL from the
        // video string.
        if let iv = String(videoString[videoStringStartIndex..<videoString.index(videoStringStartIndex, offsetBy: 24)]).decodeBase64(),
            let encryptedURL = String(videoString[videoString.index(videoStringStartIndex, offsetBy: 24)..<videoString.endIndex]).decodeBase64(),
            let xsrf = KInfoPlist.KrakePlist.encriptionKey {
			// Constructing the decryption key to use for AES starting from
            // the XSRF token.
            var xsrfMod = [UInt8]()
            var startIndex = xsrf.startIndex
            let endIndex = xsrf.endIndex
            while startIndex !=  endIndex {
                let loopIndex = xsrf.index(startIndex, offsetBy: 2)
                let part = String(xsrf[startIndex..<loopIndex])
                xsrfMod.append(UInt8(strtol(part, nil, 16)))
                startIndex = loopIndex
            }
			// Decrypting the received URL.
            let decryptedData = try? encryptedURL.decrypt(cipher: AES(key: xsrfMod,
                                                                      blockMode: CBC(iv: iv),
                                                                      padding: .pkcs7))
			// Creating the string using the decrypted data, if any.
            if let decryptedData = decryptedData,
                let stringURL = String(bytes: decryptedData, encoding: String.Encoding.utf8) , stringURL.validateUrl() {
                return stringURL
            }
        }
        return nil
    }
    
}
