//
//  ContentItemWithActivityPart.swift
//  OrchardGen
//
//  Created by Patrick on 02/09/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol ContentItemWithActivityPart: ContentItem{
    
    func activityPartReference()-> ActivityPartProtocol?

}

extension ContentItemWithActivityPart{
    
    public func activityPartReference()-> ActivityPartProtocol? {
        return value(forKey: "activityPart") as? ActivityPartProtocol
    }
}
