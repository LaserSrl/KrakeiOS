//
//  NilCoalescing+StringDefault.swift
//  Krake
//
//  Created by Marco Zanino on 26/04/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation

infix operator ???: NilCoalescingPrecedence
/**
 Utility function that has the same target of the nil-coalescing operator, except
 that returns always a `String`.
 This is usefull for debugging, when a default description for nil value could be
 usefull.

 - Parameters:
   - optional: The object asked for its description.
 It is the left operand of the infix operator `???`.
   - defaultValue: The autoclosure used to return a default `String` when the
 object is nil. It is the right operand of the infix operator `???`.
 - Returns: If `optional` is not nil, its description, otherwise `defaultValue`.
*/
public func ???<T>(optional: T?, defaultValue: @autoclosure () -> String) -> String {
    return optional.map { String(describing: $0) } ?? defaultValue()
}

