//
//  KInfoPlist+Google.swift
//  Krake
//
//  Created by Patrick on 30/08/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

extension KInfoPlist
{
    
    open class Google: NSObject
    {
        public static let clientID: String = {
            return Bundle.googleServicePlist()!["CLIENT_ID"] as! String
        }()
        
        public static let serverClientID: String = {
            return Bundle.googleServicePlist()!["SERVER_CLIENT_ID"] as! String
        }()
    }
    
}
