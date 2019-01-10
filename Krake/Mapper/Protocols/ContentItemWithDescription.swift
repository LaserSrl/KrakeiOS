//
//  ContentItemWithDescription.swift
//  OrchardGen
//
//  Created by Patrick on 18/05/17.
//  Copyright © 2017 Dream Team. All rights reserved.
//

import Foundation

public protocol ContentItemWithDescription: ContentItem {
    func bodyPart() -> String?
}

public extension ContentItemWithDescription {
    func bodyPart() -> String?{
        return value(forKey: "bodyPartText") as? String
    }
}
