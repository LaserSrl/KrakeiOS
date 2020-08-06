//
//  KConstants+KrakeLocalization.swift
//  Krake
//
//  Created by Patrick on 06/08/2020.
//  Copyright © 2020 Laser Srl. All rights reserved.
//

import Foundation


extension KConstants {
    
    @objc public static let currentLanguage: String = {
        let lang = "LANGUAGE".localizedString()
        if lang == "LANGUAGE"{
            assertionFailure("DEVI CONFIGUARE LA KEY 'LANGUAGE' NEL LOCALIZABLE.STRINGS")
        }
        return lang
    }()
    
}
