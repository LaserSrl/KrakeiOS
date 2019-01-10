//
//  ContentItemWithUserPolicyAnswersRecord.swift
//  Krake
//
//  Created by Patrick on 29/09/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation

public protocol ContentItemWithUserPolicyAnswersRecord : KeyValueCodingProtocol {
    var userPolicyPartUserPolicyAnswers: NSOrderedSet? {get}
}
