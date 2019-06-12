//
//  KTripPlanRequest.swift
//  Krake
//
//  Created by joel on 13/04/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import MapKit

public class KTripPlanRequest: Equatable {

    public var to: MKAnnotation? = nil
    public var from: MKAnnotation? = nil

    public var selectedTravelMode: KTravelMode = .transit
    public var datePlanChoice: KDatePlanChoice = .departure
    public var dateSelectedForPlan: Date = Date()
    public var maxWalkDistance: Int = 0

    public func isValid() -> Bool
    {
        return from?.isPlacemarkValid() ?? false && to?.isPlacemarkValid() ?? false
    }

    func needUserLocation() -> Bool {

        if let loc = from, loc.isUserLocation(), !loc.isPlacemarkValid() {
            return true
        }

        if let loc = to, loc.isUserLocation(), !loc.isPlacemarkValid() {
            return true
        }
        return false
    }

    public init() {

    }

    static public func ==(lhs: KTripPlanRequest, rhs: KTripPlanRequest) -> Bool {

        return lhs.selectedTravelMode == rhs.selectedTravelMode &&
        lhs.datePlanChoice == rhs.datePlanChoice &&
        lhs.to?.coordinate == rhs.to?.coordinate &&
        lhs.from?.coordinate == rhs.from?.coordinate
    }
}

public enum KTravelMode: String {
    case car = "CAR"
    case transit = "TRANSIT"
    case walk = "WALK"
    case bicycle = "BICYCLE"
}

public enum KDatePlanChoice: Int {
    case departure
    case arrival
}
