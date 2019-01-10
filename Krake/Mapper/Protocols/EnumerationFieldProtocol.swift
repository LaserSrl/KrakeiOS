//
//  EnumerationFieldProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol EnumerationFieldProtocol: KeyValueCodingProtocol
{
    var value: String? {get}
}
