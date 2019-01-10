//
//  Bundle+Google.swift
//  Krake
//
//  Created by Patrick on 30/08/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

extension Bundle
{
    
    public static func googleServicePlist() -> [String : AnyObject]?{
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let dic = NSDictionary(contentsOfFile: path){
            return dic as? [String : AnyObject]
        }
        return nil
    }
    
}
