//
//  UserPolicyAnswersRecordProtocol.swift
//  Krake
//
//  Created by Patrick on 29/09/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation

public protocol UserPolicyAnswersRecordProtocol: KeyValueCodingProtocol {
    var identifier: NSNumber! {get}
    var answerDate: Date? {get}
    var accepted: NSNumber? {get}
    
    var policyTextInfoPartRecordIdentifier: NSNumber? {get}
    var policyTextInfoPartRecordUserHaveToAccept: NSNumber? {get}
    var policyTextInfoPartRecordPriority: NSNumber? {get}
    var policyTextInfoPartRecordPolicyType: String? {get}
}

