//
//  KUserProfiler.swift
//  Krake
//
//  Created by Patrick on 01/02/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import UIKit

public class KUserTracking: NSObject{
    
    public static let shared: KUserTracking = KUserTracking()
    
    private var timer: Timer?
    private var task: KDataTask?
    private var idsToSend: [String]{
        didSet{
            UserDefaults.standard.setValue(idsToSend, forKey: "TrackingIdsToSend")
            UserDefaults.standard.synchronize()
        }
    }
    
    override init() {
        idsToSend = UserDefaults.standard.stringArray(forKey: "TrackingIdsToSend") ?? [String]()
        super.init()
        timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(sendToKrake), userInfo: nil, repeats: true)
        sendToKrake()
    }
    
    
    public func log(object item: ManagedMappedContentItem){
        log(objects: [item])
    }
    
    public func log(objects items: [ManagedMappedContentItem]){
        if KLoginManager.shared.isKrakeLogged{
            for item in items{
                idsToSend.append(item.identifier.stringValue)
            }
        }
    }
    
    @objc func sendToKrake(){
        if task == nil && KLoginManager.shared.isKrakeLogged && idsToSend.count > 0{
            let idsSending = idsToSend
            let params = ["ID" : idsSending]
            idsToSend = [String]()

            task = KNetworkManager.defaultManager(true).request(KAPIConstants.tracking + "/PostIds",
                                                                method: .post,
                                                                parameters: params,
                                                                query: [],
                                                                successCallback: { (task, responseParams) in
                                                                    if let kResponse = KrakeResponse(object: responseParams){
                                                                        if kResponse.success{
                                                                            KLog("Log inviato correttamente \n\nDATA:\n%@", (kResponse.data?.description ?? ""))
                                                                        }else{
                                                                            self.idsToSend.append(contentsOf: idsSending)
                                                                            KLog(type: .error, kResponse.message)
                                                                        }
                                                                    }else{
                                                                        self.idsToSend.append(contentsOf: idsSending)
                                                                        KLog(type: .error, "No object in a response")
                                                                    }
                                                                    self.task = nil
            }, failureCallback: { (task, error) in
                self.idsToSend.append(contentsOf: idsSending)
                KLog(type: .error, error.localizedDescription)
                self.task = nil
            })
        }
    }
    
}
