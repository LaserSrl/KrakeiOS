//
//  NSBundle+OM.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

extension Bundle{
    
    public static func krakeSettings() -> [String : AnyObject]{
        return Bundle.main.object(forInfoDictionaryKey: "Krake") as! [String : AnyObject]
    }
    
    public static func reviewRequestKrakeSettings() -> [String : AnyObject]?{
        return krakeSettings()["ReviewRequest"] as? [String : AnyObject]
    }
    
    public static func loginAndRegistrationKrakeSettings() -> [String : AnyObject]{
        return krakeSettings()["LoginAndRegistration"] as! [String : AnyObject]
    }
    
}
