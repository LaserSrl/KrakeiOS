//
//  ContentItemWithMapPart.swift
//  OrchardGen
//
//  Created by Patrick on 02/09/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation
import MapKit

public protocol ContentItemWithMapPart: ContentItem{
    
    func mapPartReference()-> MapPartProtocol?
    func otherAnnotations()-> [MKAnnotation]?
    
}

extension ContentItemWithMapPart{
    
    public func mapPartReference()-> MapPartProtocol? {
        return value(forKey: "mapPart") as? MapPartProtocol
    }
    
    
    public func otherAnnotations()-> [MKAnnotation]?{
        return nil
    }
    
}
