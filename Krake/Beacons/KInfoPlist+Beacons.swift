//
//  KInfoPlist+Beacons.swift
//  Krake
//
//  Created by Patrick on 30/08/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

extension KInfoPlist
{
    
    open class Beacon: NSObject
    {
        public static let beaconADSMaxNotificationInSameVisit: NSNumber =
        {
            return Bundle.main.object(forInfoDictionaryKey: "KBeaconADSMaxNotificationInSameVisit") as? NSNumber ?? 5.0
        }()
        
        public static let beaconDistanceToBeNearInMeter: NSNumber =
        {
            return Bundle.main.object(forInfoDictionaryKey: "KBeaconDistanceToBeNearInMeter") as? NSNumber ?? 4.0
        }()
        
        //TODO: check this never used
        public static let beaconNumberOfSamples:NSNumber =
        {
            return Bundle.main.object(forInfoDictionaryKey:  "KBeaconNumberOfSample") as? NSNumber ?? 0.0
        }()
        
        public static let beaconDistanceBetweenSuperBeaconAndOthers: NSNumber =
        {
            return Bundle.main.object(forInfoDictionaryKey: "KBeaconDistanceBetweenSuperBeaconAndOthers") as? NSNumber ?? 1.0
        }()
        
        public static let beaconMinimunTimeToBecomeSuperBeacon: NSNumber =
        {
            return Bundle.main.object(forInfoDictionaryKey: "KBeaconMinimunTimeToBecomeSuperBeacon") as? NSNumber ?? 22.0
        }()
        
        public static let beaconADSMinimumTimeToNotifySameBeacon: NSNumber =
        {
            return Bundle.main.object(forInfoDictionaryKey: "KBeaconADSMinimumTimeToNotifySameBeacon") as? NSNumber ?? 3600.0
        }()
        
    }
    
}
