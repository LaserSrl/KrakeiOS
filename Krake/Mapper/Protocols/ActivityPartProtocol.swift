//
//  ActivityPartProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol ActivityPartProtocol: KeyValueCodingProtocol
{
    var allDay: NSNumber? {get}
    var repeatValue: NSNumber? {get}
    var repeatEnd: NSNumber? {get}
    var repeatType: String? {get}
    var repeatDetails: String? {get}
    var dateTimeStart: Date? { get }
    var dateTimeEnd: Date? { get }
}
