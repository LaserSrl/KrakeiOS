//
//  ContentItem.swift
//  Pods
//
//  Created by joel on 30/01/17.
//
//

import Foundation

public protocol ContentItem : KeyValueCodingProtocol {
    var identifier: NSNumber! {get}
    var titlePartTitle: String? {get}
    var autoroutePartDisplayAlias: String? {get}
}
