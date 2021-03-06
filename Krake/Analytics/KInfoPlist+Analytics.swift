//
//  KInfoPlist+Analytics.swift
//  Krake
//
//  Created by Patrick on 30/08/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

extension KInfoPlist
{
    open class Analytics: NSObject
    {
        public static let enabled: Bool = {
            return Bundle.analyticsKrakeSettings()?["Enabled"]?.boolValue ?? Bundle.krakeSettings()["EnableAnalytics"]?.boolValue ?? false
        }()
        
        public static let collectUserProperties: Bool = {
            return Bundle.analyticsKrakeSettings()?["CollectUserProperties"]?.boolValue ?? false
        }()
    }
    
}
