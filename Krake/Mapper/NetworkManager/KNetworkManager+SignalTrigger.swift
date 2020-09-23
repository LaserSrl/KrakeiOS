//
//  KSignalTriggerManager.swift
//  Krake
//
//  Created by Patrick Negretto on 10/07/2020.
//  Copyright © 2020 Laser Srl. All rights reserved.
//

import Foundation
import Alamofire

//MARK: Signal Trigger
extension KNetworkManager {
    
    public static func trigger(_ auth: Bool = false, checkHeaderResponse: Bool = false) -> KNetworkManager{
        let manager = KNetworkManager(baseURL: KInfoPlist.KrakePlist.path,
                                      auth: auth,
                                      checkHeaderResponse: checkHeaderResponse,
                                      requestSerializer: .http,
                                      responseSerializer: .json)
        return manager
    }
    
    public func post(signalName: String,
                     contentId: String,
                     params: KParamaters? = nil,
                     query: [URLQueryItem] = [],
                     success: ((KDataTask, Any?) -> Void)?,
                     failure: ((KDataTask?, Error) -> Void)?) -> KDataTask?{
        var tmpParams = params ?? KParamaters()
        tmpParams[KParametersKeys.lang] = KConstants.currentLanguage
        tmpParams["Name"] = signalName
        tmpParams["ContentId"] = contentId
        var tmpQuery = query
        tmpQuery.append(URLQueryItem(name: KParametersKeys.lang, value: KConstants.currentLanguage))
        return request(KAPIConstants.signal, method: .post, parameters: tmpParams, query: tmpQuery, successCallback: success, failureCallback: failure)
    }
    
}
