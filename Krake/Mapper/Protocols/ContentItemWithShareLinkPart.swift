//
//  ContentItemWithShareLinkPart.swift
//  OrchardGen
//
//  Created by Patrick on 02/09/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol ContentItemWithShareLinkPart: ContentItem{
    
    func shareLinkPartReference()-> ShareProtocol?
    
}

extension ContentItemWithShareLinkPart{
    
    public func shareLinkPartReference() -> ShareProtocol?{
        return value(forKey: "shareLinkPart") as? ShareProtocol
    }
    
}
