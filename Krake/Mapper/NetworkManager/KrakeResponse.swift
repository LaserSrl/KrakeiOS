//
//  KrakeResponse.swift
//  OrchardGen
//
//  Created by Patrick on 10/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public struct KrakeResponse{
    public var success: Bool
    public var message: String!
    public var errorCode: Int
    public var resolutionAction: Int
    public var data: [AnyHashable: Any]?
    
    public init?(object: Any?){
        if let oggetto = object as? [String : AnyObject] ,let tmpSuccess = oggetto["Success"] as? Bool ?? oggetto["success"] as? Bool{
            success = tmpSuccess
            message = oggetto["Message"] as? String ?? oggetto["message"] as? String ?? KLocalization.Error.genericError
            message = KLocalization.localizable(message)
            errorCode = oggetto["ErrorCode"] as? Int ?? 0
            if let resAction = oggetto["ResolutionAction"] as? Int{
                resolutionAction = resAction
            }else if message.contains("Invalid cookie."){
                //TODO: Eliminare questo check in versioni future dopo che lato web sia fixato nel modulo di fidelity
                resolutionAction = KResolutionAction.userHaveToLogin
            }else{
                resolutionAction = 0
            }
            data = oggetto["Data"] as? [AnyHashable : Any]
        }else{
            return nil
        }
        
    }
}
