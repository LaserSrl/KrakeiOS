//
//  PatternProtocol.swift
//  OrchardGen
//
//  Created by joel on 15/05/17.
//  Copyright © 2017 Dream Team. All rights reserved.
//

import Foundation

public protocol PatternProtocol {

    var patternId: String? { get }
    var descriptionText: String? { get }
    var stopTimesList: NSOrderedSet? { get }

}
