//
//  Linea.swift
//  Krake
//
//  Created by Marco Zanino on 14/04/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation

open class KBusLine {

    public let lineNumber: String
    public let destination: String
    public let scheduledArrival: Date
    public let patternId: String
    public let tripId: String
    public let routeInfo: KOTPRoute?

    public init(lineNumber: String,
                destination: String,
         scheduledArrival: Date,
         patternId: String,
         tripId: String,
         routeInfo: KOTPRoute?) {
        self.lineNumber = lineNumber
        self.destination = destination
        self.scheduledArrival = scheduledArrival
        self.patternId = patternId
        self.tripId = tripId
        self.routeInfo = routeInfo
    }
}
