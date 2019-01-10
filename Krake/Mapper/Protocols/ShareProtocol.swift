//
//  ShareProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol ShareProtocol
{
    var sharedText: String? { get }
    var sharedLink: String? { get }
    var sharedImage: String? { get }
}
