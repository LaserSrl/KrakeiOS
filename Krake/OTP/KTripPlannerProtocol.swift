//
//  KTripPlannerProtocol.swift
//  Krake
//
//  Created by joel on 02/05/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation

public protocol KTripPlannerProtocol {
    func planTrip(request: KTripPlanRequest, callback: @escaping ((KTripPlanRequest,KTripPlanResult?,Error?) -> ()))

    func isPlanning() -> Bool

    func cancel()
}
