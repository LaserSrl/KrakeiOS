//
//  AFHTTPSessionManager.swift
//  Pods
//
//  Created by Patrick on 22/07/16.
//
//

import Foundation
import AFNetworking

extension AFHTTPSessionManager{
    
    @objc public convenience init(baseURL url: URL?, auth: Bool) {
        self.init(baseURL: url, sessionConfiguration:URLSessionConfiguration.krakeSessionConfiguration(auth: auth))
    }
    
}
