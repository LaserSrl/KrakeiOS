//
//  AnnotationProtocol.swift
//  Krake
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation
import MapKit

public protocol AnnotationProtocol: MKAnnotation, KeyValueCodingProtocol{
    func annotationIdentifier() -> String
    func nameAnnotation() -> String
    func color() -> UIColor
    func boxedText() -> String?
    func imageInset() -> UIImage?
    func termIconIdentifier() -> String?
}

extension AnnotationProtocol {
    
    public func annotationIdentifier() -> String{
        let boxedTextTmp = boxedText() ?? ""
        let termIconIdentifierTmp = termIconIdentifier() ?? ""
        return nameAnnotation() + boxedTextTmp + termIconIdentifierTmp + color().description
    }
    
    public func nameAnnotation() -> String{
        
        if let iconId = termIconIdentifier() {
            return "termicon_" + iconId
        } else {
            return value(forKey: "contentType") as? String ??  "DefaultPin"
        }
        
    }
    
    public func boxedText() -> String?{
        return nil
    }
    
    public func termIconIdentifier() -> String?{
        if let cats = value(forKey: "categoriaTerms") as? NSOrderedSet, let media = (cats.firstObject as? TermPartProtocol)?.iconMediaParts?.firstObject as? MediaPartProtocol{
            return (media.identifier ?? 0).stringValue
            
        }
        return nil
    }
    
    public func imageInset() -> UIImage?{
        return UIImage(named: nameAnnotation())
    }
    
    public func color() -> UIColor{
        return KTheme.current.color(.tint)
    }
}
