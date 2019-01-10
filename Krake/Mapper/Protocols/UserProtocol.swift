//
//  UserProtocol.swift
//  Krake
//
//  Created by joel on 02/08/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation

public protocol UserProtocol {
    var galleryMediaParts: NSOrderedSet? {get}
    var name: String? {get}
    var surname: String? {get}
}
