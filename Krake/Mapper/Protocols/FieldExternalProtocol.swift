//
//  FieldExternalProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol FieldExternalProtocol: KeyValueCodingProtocol {
    var httpDataTypeCode: String? {get}
    var httpVerb: String? {get}
    var httpDataType: String? {get}
    var contentUrl: String? {get}
}