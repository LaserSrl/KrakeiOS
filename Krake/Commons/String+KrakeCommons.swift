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
    public func appLocalizedString() -> String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }
}
