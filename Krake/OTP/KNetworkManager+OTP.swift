//
//  KNetworkManager+OTP.swift
//  Krake
//
//  Created by Patrick on 23/09/2020.
//


extension KNetworkManager {
    
    
    public static func otp(_ auth: Bool = false, checkHeaderResponse: Bool = false) -> KNetworkManager{
        let manager = KNetworkManager(baseURL: KInfoPlist.OTP.path,
                                      auth: auth,
                                      checkHeaderResponse: checkHeaderResponse,
                                      requestSerializer: .http,
                                      responseSerializer: .json)
        return manager
    }
}
