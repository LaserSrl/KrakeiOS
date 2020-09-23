//
//  OGLCoreDataMapper+Swift.swift
//  Krake
//
//  Created by joel on 11/10/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import UIKit

extension OGLCoreDataMapper {
    @objc public func startDataLoading(task loadDataTask:OMLoadDataTask) {
        let networkManager = KNetworkManager.default(loadDataTask.loginRequired, false, .http, .json)

        let request = KRequest()
        request.path = loadDataTask.command
        request.method = .get

        for key in loadDataTask.parameters.keys {
            var string: String? = nil
            if let value = loadDataTask.parameters[key] {
                if let sValue = value as? String {
                    string = sValue
                }
                else if let nValue = value as? NSNumber {
                    string = nValue.description
                }
                else if let dValue = value as? Double {
                    string = String(format:"%f",dValue)
                }
                else if let fValue = value as? Float {
                    string = String(format:"%f",fValue)
                }
                else if let iValue = value as? Int {
                    string = String(format:"%d",iValue)
                }
                else if let bValue = value as? Bool {
                    string = bValue ? "true" : "false"
                }
                else if let oValue = value as? NSObject {
                    string = oValue.description
                }
                else {
                }

                if let string = string {
                    request
                        .queryParameters
                        .append(URLQueryItem(name: key, value: string))
                }
            }
        }

        if let cacheTime = loadDataTask.parameters[REQUEST_NO_CACHE] as? String {
            request.headers["Cache-Control"] = "no-cache"
            request.headers["cache-request-time"] = cacheTime
        }

        _ = networkManager.request(request,
                               successCallback: { (task, responseObject) in
                                                       self.importAndSave(inCoreData: responseObject!,
                                                                          parameters: loadDataTask.parameters,
                                                                          loadDataTask: loadDataTask)
                               },
                               failureCallback: { (task, error) in
                                   loadDataTask.loadingFailed(task, withError: error)
                                   if (error as NSError).code != -999 {
                                       DispatchQueue.main.async {
                                           loadDataTask.completionBlock(nil,error,true)
                                       }
                                   }
                               })
    }
}
