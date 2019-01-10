//
//  QuestionnairePartProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol QuestionnairePartProtocol: KeyValueCodingProtocol
{
    var useRecaptcha: NSNumber? { get }
    var mustAcceptTerms: NSNumber? { get }
    var questions: NSOrderedSet? { get }
}

extension QuestionnairePartProtocol{
    
}
