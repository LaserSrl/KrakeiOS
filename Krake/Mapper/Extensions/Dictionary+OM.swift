//
//  Dictionary+OM.swift
//  Pods
//
//  Created by Patrick on 27/09/16.
//
//

import Foundation

extension Dictionary {
    
    public mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
