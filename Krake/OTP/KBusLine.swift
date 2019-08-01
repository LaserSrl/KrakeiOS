//
//  Linea.swift
//  Krake
//
//  Created by Marco Zanino on 14/04/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation

open class KBusLine: Hashable {

    public let lineNumber: String
    public let destination: String
    public let scheduledArrival: Date
    public let realtimeArrival: Date?
    public let patternId: String
    public let tripId: String
    public let routeInfo: KOTPRoute?
    public let lastStop: Bool

    public init(lineNumber: String,
                destination: String,
                scheduledArrival: Date,
                realtimeArrival: Date? = nil,
         patternId: String,
         tripId: String,
         routeInfo: KOTPRoute?,
         lastStop: Bool = false) {
        self.lineNumber = lineNumber
        self.destination = destination
        self.scheduledArrival = scheduledArrival
        self.realtimeArrival = realtimeArrival
        self.patternId = patternId
        self.tripId = tripId
        self.routeInfo = routeInfo
        self.lastStop = lastStop
    }

    public static func == (lhs: KBusLine, rhs: KBusLine) -> Bool {
        return lhs.lineNumber == rhs.lineNumber &&
        lhs.destination == rhs.destination &&
        lhs.scheduledArrival == rhs.scheduledArrival &&
        lhs.patternId == rhs.patternId &&
        lhs.tripId == rhs.tripId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.lineNumber)
        hasher.combine( self.destination)
        hasher.combine( self.scheduledArrival)
        hasher.combine( self.patternId)
        hasher.combine( self.tripId)
    }
}
