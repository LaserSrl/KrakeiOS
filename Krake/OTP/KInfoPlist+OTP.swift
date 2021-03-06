//
//  KInfoPlist+OTP.swift
//  Krake
//
//  Created by Patrick on 30/08/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

extension KInfoPlist
{
    open class OTP: NSObject
    {
        public static let path: URL = {
            if let otpPath = Bundle.otpSettings()?["WSOTP"] as? String ?? Bundle.krakeSettings()["WSOTP"] as? String,
                let otpURL = URL(string: otpPath) {
                return otpURL
            }
            fatalError("Non è stato impostato alcuno URL per il server OTP, oppure lo URL impostato non è valido.")
            
        }()
        
        public static let secondForStopTimesRefresh: TimeInterval = {
            return (Bundle.otpSettings()?["SecondForStopTimesRefresh"] as? NSNumber)?.doubleValue ?? 0
        }()

        public static let busTrackerRefresh: NSNumber? = {
            return Bundle.otpSettings()?["BusTrackerRefresh"] as? NSNumber
        }()
        
        public static let stopRegionRadiusMeter: Double = {
            return (Bundle.otpSettings()?["StopRegionRadiusMeter"] as? NSNumber)?.doubleValue ?? 250.0
        }()
        
    }
    
}

extension Bundle{
    
    public static func otpSettings() -> [String : AnyObject]?{
        return Bundle.krakeSettings()["OTP"] as? [String : AnyObject]
    }
    
    
}
