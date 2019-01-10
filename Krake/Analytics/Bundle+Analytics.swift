//
//  Bundle+Analytics.swift
//  Krake
//
//  Created by Patrick on 31/08/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

extension Bundle{
 
    public static func analyticsKrakeSettings() -> [String : AnyObject]?{
        return krakeSettings()["Analytics"] as? [String : AnyObject]
    }
    
}
