//
//  QuestionnaireProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol QuestionnaireProtocol: KeyValueCodingProtocol{
    
    var titlePartTitle: String? { get }
    var bodyPartText: String? { get }
    var contentType: String? { get }
    var autoroutePartDisplayAlias: String? { get }
    var questionnairePartReference: QuestionnairePartProtocol? { get }
}

public extension QuestionnaireProtocol{
    var questionnairePartReference: QuestionnairePartProtocol? {
        get{
            return value(forKey: "questionnairePart") as? QuestionnairePartProtocol
        }
    }
}

