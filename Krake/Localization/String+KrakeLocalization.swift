//
//  String+OM.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

fileprivate class KrakeLocalization: NSObject
{
    
}

public extension String{
    
    /// Localize string by checking only in bundle OCLocalizable.strings
    ///
    /// - Returns: translated string
    func bundleLocalizedString() -> String{
        let bundle = Bundle(url: Bundle.main.url(forResource: "Localization", withExtension: "bundle")!)!
        return bundle.localizedString(forKey: self, value: nil, table: "OCLocalizable")
    }
    
    /// Localize string by checking in app localizable.strings if is not present check in bundle OCLocalizable.strings
    ///
    /// - Returns: translated string
    func localizedString() -> String {
        return Bundle.main.localizedString(forKey: self, value: bundleLocalizedString(), table: nil)
    }
    
}
