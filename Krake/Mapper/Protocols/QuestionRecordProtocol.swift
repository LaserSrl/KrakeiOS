//
//  QuestionRecordProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public enum QuestionType: String {
    case SingleChoice
    case MultiChoice
    case OpenAnswer
    case Unknown
}

public enum AnswerType: String {
    case Datetime
    case Date
    case Url
    case Email
    case None
}

public protocol QuestionRecordProtocol: KeyValueCodingProtocol
{
    var identifier: NSNumber! { get }
    var isRequired: NSNumber? { get }
    var position: NSNumber? { get }
    var published: NSNumber? { get }
    var questionnairePartRecord_Id: NSNumber? { get }
    var question: String? { get }
    var answerType: String? { get }
    var questionType: String? { get }
    var conditionType: String? { get }
    var answers: NSOrderedSet? { get }
    var section: String? { get }
    var images: [Int]? {get}
}

extension QuestionRecordProtocol {
    
    public var questionTypeEnum: QuestionType {
        get{
            return QuestionType(rawValue: questionType ?? "") ?? .Unknown
        }
    }
    
    public var answerTypeEnum: AnswerType {
        get{
            return AnswerType(rawValue: answerType ?? "") ?? .None
        }
    }
    
    public var section: String? { get {return nil} set {} }
    
    public var images: [Int]?{
        get{
            if let imageString = value(forKey: "allFiles") as? NSString {
                var arrayImages = [Int]()
                for elem in imageString.components(separatedBy: ","){
                    if let intElem = Int(elem){
                        arrayImages.append(intElem)
                    }
                }
                return arrayImages
            }
            return nil
        }
    }
    
}
