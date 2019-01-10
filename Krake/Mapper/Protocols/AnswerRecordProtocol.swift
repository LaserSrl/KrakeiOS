//
//  AnswerRecordProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol AnswerRecordProtocol: KeyValueCodingProtocol
{
    var identifier: NSNumber! { get }
    var questionRecord_Id: NSNumber? { get }
    var answer: String? { get }
    var correctResponse: NSNumber? { get }
    var published: NSNumber? { get }
    var position: NSNumber? { get }
    var images: [Int]? {get}
}

extension AnswerRecordProtocol {
    
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
