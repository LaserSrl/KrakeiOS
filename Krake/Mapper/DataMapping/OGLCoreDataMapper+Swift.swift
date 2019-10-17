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
        let networkManager = KNetworkManager.defaultManager(loadDataTask.loginRequired)
        networkManager.requestSerializer = .http
        networkManager.responseSerializer = .json

        let request = KRequest()
        request.path = loadDataTask.command
        request.method = .get
        request.parameters = loadDataTask.parameters

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
