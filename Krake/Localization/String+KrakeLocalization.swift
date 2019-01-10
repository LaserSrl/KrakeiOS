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
    
    public func bundleLocalizedString() -> String{
        let bundle = Bundle(for: KrakeLocalization.self)
        return bundle.localizedString(forKey: self, value: nil, table: "OCLocalizable")
    }
    
    /// Localize string by checking in app localizable.strings if is not present check on bundle OCLocalizable.strings
    ///
    /// - Returns: translated string
    public func localizedString() -> String {
        return Bundle.main.localizedString(forKey: self, value: bundleLocalizedString(), table: nil)
    }
}
