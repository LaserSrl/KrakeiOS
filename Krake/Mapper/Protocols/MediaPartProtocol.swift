//
//  MediaPartProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol MediaPartProtocol: KeyValueCodingProtocol
{
    var mimeType: String? {get}
    var alternateText: String? {get}
    var fileName: String? {get}
    var title: String? {get}
    var folderPath: String? {get}
    var logicalType: String? {get}
    var caption: String? {get}
    var mediaUrl: String? {get}
    var identifier: NSNumber? {get}
}
