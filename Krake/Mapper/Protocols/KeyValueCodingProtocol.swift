//
//  KeyValueCodingProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

@objc public protocol KeyValueCodingProtocol: NSObjectProtocol
{
    func value(forKey key: String) -> Any?
    
}
