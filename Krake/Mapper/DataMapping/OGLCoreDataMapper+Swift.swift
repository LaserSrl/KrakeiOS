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

        /* TODO:ALAMO controllare dopo aggiornamento gestione cookie
              if (loadDataTask.parameters[REQUEST_NO_CACHE]) {
                  [localSessionManager.session.configuration addCacheHeaders:loadDataTask.parameters[REQUEST_NO_CACHE]];
              }else{
                  [localSessionManager.session.configuration removeCacheHeaders];
              }*/

        _ = networkManager.request(loadDataTask.command,
                               method: .get,
                               parameters: loadDataTask.parameters,
                               query: [],
                               successCallback: { (task, responseObject) in
                                self.importAndSave(inCoreData: responseObject!,
                                                   parameters: loadDataTask.parameters,
                                                   loadDataTask: loadDataTask)
        }) { (task, error) in
            loadDataTask.loadingFailed(task, withError: error)
            if (error as NSError).code != -999 {
                DispatchQueue.main.async {
                    loadDataTask.completionBlock(nil,error,true)
                }
            }
        }
    }
}
