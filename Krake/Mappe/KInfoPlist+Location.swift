//
//  KInfoPlist+Location.swift
//  Krake
//
//  Created by Patrick on 30/08/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

extension KInfoPlist
{
    open class Location: NSObject
    {
        public static let useOSMMap: Bool =
        {
            return Bundle.mapInfoKrakeSettings()["UseOSMMap"]?.boolValue ?? false
        }()
        
        public static let openExternalNav: Bool =
        {
            return Bundle.mapInfoKrakeSettings()["OpenExternalNav"]?.boolValue ?? true
        }()
        
        public static let enableNavigationOnPin: Bool =
        {
            return Bundle.mapInfoKrakeSettings()["EnableNavigationOnPins"]?.boolValue ?? true
        }()
        
        public static let openOTP: Bool =
        {
            return Bundle.mapInfoKrakeSettings()["OpenOTP"]?.boolValue ?? false
        }()
        
        public static let useTurnByTurnInApp: Bool =
        {
            return Bundle.mapInfoKrakeSettings()["UseTurnByTurnInApp"]?.boolValue ?? false
        }()
        
        public static let showMarkerFromKML: Bool =
        {
            return Bundle.mapInfoKrakeSettings()["ShowMarkerFromKML"]?.boolValue ?? false
        }()
        
        public static let osmPath: String =
        {
            return Bundle.mapInfoKrakeSettings()["OSMPath"] as? String ?? "http://a.tile.openstreetmap.org/{z}/{x}/{y}.png"
        }()
        
        public static let osmCopyright: String =
        {
            return Bundle.mapInfoKrakeSettings()["OSMCopyright"] as? String ?? "<div style=\"font-size:10pt;text-align:right;\">© <a href=\"http://www.openstreetmap.org/copyright\">OpenStreetMap</a> contributors</div>"
        }()
    }
}
