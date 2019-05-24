//
//  KOTPLinePathLoader.swift
//  Krake
//
//  Created by Marco Zanino on 03/05/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

public protocol KOTPLoader
{
    func retrievePathPoints(for line: KBusLine, with completion: @escaping (KBusLine, MKPolyline?) -> Void)
    func retrieveRoutesInfos(with completion: @escaping ([KOTPRoute]?) -> Void)
    func retrieveStopTimes(for stopId: String! ,with completion: @escaping ([KOTPStopTimes]?) -> Void)
    func retrieveStops(for line: KBusLine ,with completion: @escaping ([KOTPStop]?) -> Void)
    func retrieveStops(for route: KOTPRoute ,with completion: @escaping ([KOTPStop]?) -> Void)
    func retrieveTimes(for stop: KOTPStopItem, route: KOTPRoute, date: Date, with completion: @escaping ([KOTPTimes]?) -> Void)
}
