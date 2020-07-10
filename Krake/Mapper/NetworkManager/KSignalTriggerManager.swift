//
//  KSignalTriggerManager.swift
//  Krake
//
//  Created by Patrick Negretto on 10/07/2020.
//  Copyright © 2020 Laser Srl. All rights reserved.
//

import Foundation
import Alamofire

public class KSignalTriggerManager: KNetworkManager {
    
    public static func manager(_ auth: Bool = false, checkHeaderResponse: Bool = false) -> KSignalTriggerManager{
        let manager = KSignalTriggerManager(baseURL: KInfoPlist.KrakePlist.path, auth: auth)
        manager.requestSerializer = .http
        manager.responseSerializer = .json
        manager.checkHeaderResponse = checkHeaderResponse
        return manager
    }

    //MARK: Post Signal Trigger
    
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
