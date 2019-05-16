//
//  Linea.swift
//  Krake
//
//  Created by Marco Zanino on 14/04/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation

open class BusLine {

    public let lineNumber: String
    public let destination: String
    public let scheduledArrival: Date
    public let patternId: String
    public let routeInfo: KOTPRoute?

    public init(lineNumber: String,
                destination: String,
         scheduledArrival: Date,
         patternId: String,
         routeInfo: KOTPRoute?) {
        self.lineNumber = lineNumber
        self.destination = destination
        self.scheduledArrival = scheduledArrival
        self.patternId = patternId
        self.routeInfo = routeInfo
    }
}
