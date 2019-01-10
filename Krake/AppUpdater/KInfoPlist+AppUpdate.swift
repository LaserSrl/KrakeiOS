//
//  KInfoPlist+AppUpdate.swift
//  Krake
//
//  Created by Patrick on 31/08/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

extension KInfoPlist
{
    public static let appUpdateUrlPath: String? = {
        return Bundle.krakeSettings()["AppUpdatePlistPath"] as? String
    }()
}
