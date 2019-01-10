//
//  File.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol GameProtocol: KeyValueCodingProtocol {
    
    var identifier: NSNumber! { get }
    var titlePartTitle: String? { get }
    var galleryMediaParts: NSOrderedSet? { get }
    var questionariContentItems: NSOrderedSet? { get }
    var autoroutePartDisplayAlias: String? { get }
    var gamePartReference: GamePartProtocol? {get}
    var activityPartReference: ActivityPartProtocol? {get}
}

extension GameProtocol{
    
    public var gamePartReference: GamePartProtocol? {
        get{
            return value(forKey: "gamePart") as? GamePartProtocol
        }
    }
    
    public var activityPartReference: ActivityPartProtocol? {
        get{
            return value(forKey: "activityPart") as? ActivityPartProtocol
        }
    }
    
}
