//
//  String+OM.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public extension String{
    
    /// Localize string by checking only in app localizable.strings
    ///
    /// - Returns: translated string
    func appLocalizedString(_ value: String? = nil) -> String {
        return Bundle.main.localizedString(forKey: self, value: value, table: nil)
    }
}
