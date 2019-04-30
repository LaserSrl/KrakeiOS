//
//  UIResponder+Krake.swift
//  Krake
//
//  Created by Patrick on 28/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation


public extension UIResponder {
    fileprivate weak static var _currentFirstResponder: UIResponder? = nil
    
    class func currentFirstResponder() -> UIResponder? {
        UIResponder._currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return UIResponder._currentFirstResponder
    }
    
    @objc internal func findFirstResponder(_ sender: AnyObject) {
        UIResponder._currentFirstResponder = self
    }
}
