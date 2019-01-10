//
//  StopTimeProtocol.swift
//  OrchardGen
//
//  Created by joel on 15/05/17.
//  Copyright © 2017 Dream Team. All rights reserved.
//

import Foundation

public protocol StopTimeProtocol {

    var identifier: NSNumber! { get }
    var realtimeArrival: NSNumber? { get }
    var departureDelay: NSNumber? { get }
    var timePoint: NSNumber? { get }
    var arrivalDelay: NSNumber? { get }
    var scheduledArrival: NSNumber? { get }
    var realtimeDeparture: NSNumber? { get }
    var scheduledDeparture: NSNumber? { get }
    
}
