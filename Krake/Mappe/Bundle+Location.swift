//
//  Bundle+Location.swift
//  Krake
//
//  Created by Patrick on 30/08/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

extension Bundle
{
    public static func mapInfoKrakeSettings() -> [String : AnyObject]{
        return krakeSettings()["MapInfos"] as! [String : AnyObject]
    }
}
