//
//  TermPartProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol TermPartProtocol: KeyValueCodingProtocol
{
    var identifier: NSNumber! {get}
    var taxonomyId: NSNumber? {get}
    var count: NSNumber? {get}
    var autoroutePartDisplayAlias: String? {get}
    var weight: NSNumber? {get}
    var iconMediaParts: NSOrderedSet? {get}
    var name: String? {get}
    var fullPath: String? {get}
}

extension TermPartProtocol
{
    public func tipoUnivocoReference()-> EnumerationFieldProtocol? {
        return value(forKey: "tipoUnivoco") as? EnumerationFieldProtocol
    }
}
