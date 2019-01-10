//
//  GamePartProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol GamePartProtocol: KeyValueCodingProtocol
{
    var rankingIOSIdentifier: String? { get }
    var myOrder: NSNumber? { get }
    var answerTime: NSNumber? { get }
    var answerPoint: NSNumber? { get }
    var questionsSortedRandomlyNumber: NSNumber? { get }
    #if swift(>=4.0)
    var gameDate: Date? { get }
    #else
    var gameDate: NSDate? { get }
    #endif
    var workflowfired: NSNumber? { get }
    var abstractText: String? { get }
    var randomResponse: NSNumber? { get }
    var state: NSNumber? { get }
    var gameType: String? { get }
}
