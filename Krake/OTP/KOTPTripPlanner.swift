//
//  KOTPTripPlanner.swift
//  Krake
//
//  Created by joel on 02/05/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import MapKit
import Polyline
import SwiftyJSON

public class KOTPTripPlanner: KTripPlannerProtocol
{
    static private let uselessStreetNames = ["road","path","sidewalk","platform","underpass","service road","bike path","ramp","steps","footbridge","parking aisle"]

    private var planDataTask : KDataTask? = nil

    public init() {

    }

    public func planTrip(request: KTripPlanRequest, callback: @escaping ((KTripPlanRequest,KTripPlanResult?, Error?) -> ()))
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateString = dateFormatter.string(from: request.dateSelectedForPlan)

        dateFormatter.dateFormat = "hh:mma"
        let timeString = dateFormatter.string(from: request.dateSelectedForPlan)

        let manager = KNetworkManager.otp()        

        var params : [String: String] = ["fromPlace": request.from!.otpRequestFormat(),
                                         "toPlace": request.to!.otpRequestFormat(),
                                         "date":dateString,
                                         "time":timeString,
                                         "mode":request.selectedTravelMode.otpFormat(),
                                         "arriveBy": request.datePlanChoice == .departure ? "false": "true"]
        if request.maxWalkDistance > 0 {
            params["maxWalkDistance"] = String(format: "%d", request.maxWalkDistance)
        }

        planDataTask?.cancel()
        
        planDataTask = manager.request("plan",
                                       method: .get,
                                       parameters: params,
             successCallback: { (task, response) in
                if let response = response {
                let resultJson = JSON(response)

                    if resultJson["error"] == JSON.null
                    {
                        callback(request,self.parseTripPlan(request: request, response: resultJson["plan"]),nil)
                    }
                    else {
                        callback(request,nil, NSError(domain: "OTP", code: 1, userInfo: [NSLocalizedDescriptionKey:
                                                                                            KOTPLocalization.kotpLocalizable(resultJson["error"]["msg"].stringValue)]))
                    }
                }
                self.planDataTask = nil
        }) { (task, error) in
            callback(request,nil, NSError(domain: "OTP", code: 1, userInfo: [NSLocalizedDescriptionKey: KOTPLocalization.Error.generic]))
            self.planDataTask = nil
        }
    }

    public func isPlanning() -> Bool {
        return planDataTask != nil
    }

    public func cancel() {
        planDataTask?.cancel()
        planDataTask = nil
    }

    private func parseTripPlan(request: KTripPlanRequest, response: JSON) -> KTripPlanResult
    {
        let tripReturn = KTripPlanResult(request)

        let itineraries = response["itineraries"].arrayValue

        for itinerary in itineraries {
            tripReturn.routes.append(parseRoute(itineraryInfos: itinerary))
        }

        return tripReturn
    }

    private func parseRoute( itineraryInfos: JSON) -> KRoute
    {
        var steps = [KComplexStep]()

        let jSteps = itineraryInfos["legs"].arrayValue

        for info in jSteps {
            steps.append(parseLeg(infos: info))
        }

        let totalDistance = steps.reduce(0, { (total: Double, step) -> Double in
            if step is KStepGroup {
                return total + (step as! KStepGroup).distance
            }
            return 0
        })
        let bounds = steps.map {
            return (MKMapPoint($0.from.location.coordinate), MKMapPoint($0.from.location.coordinate))
            }.reduce([MKMapPoint]()) { (total, coordinates) -> [MKMapPoint] in
                var totals = total
                totals.append(coordinates.0)
                totals.append(coordinates.1)
                return totals
            }.map {
                return MKMapRect(origin: $0, size: MKMapSize(width: 0, height: 0))
            }.reduce(MKMapRect.null) {
                return $0.union($1)
        }
        let route = KRoute(startTime: parseDate(itineraryInfos["startTime"].doubleValue),
                           endTime: parseDate(itineraryInfos["endTime"].doubleValue),
                           duration: ((itineraryInfos["endTime"].doubleValue) - (itineraryInfos["startTime"].doubleValue))/1000,
                           distance: totalDistance,
            walkDistance: itineraryInfos["walkDistance"].doubleValue,
            bounds: bounds
        )

        route.steps = steps

        return route
    }

    private func parseLocation(result: JSON) -> KPlaceResult {

        let location = CLLocation(latitude: result["lat"].doubleValue, longitude: result["lon"].doubleValue)

        return KPlaceResult(location, name: result["name"].string)
    }

    private func parseDate(_ otpTime: Double) -> Date
    {
        return Date(timeIntervalSince1970: otpTime / 1000)
    }


    private func parseLeg(infos: JSON) -> KComplexStep {

        let from = parseLocation(result: infos["from"])
        let to = parseLocation(result: infos["to"])
        let polyline = infos["legGeometry"]["points"].stringValue

        if (infos["transitLeg"].boolValue) {

            let colorString = infos["routeColor"].string

            let line = KTransitLine(name: infos["routeLongName"].stringValue,
                                    shortName: infos["routeShortName"].stringValue,
                                    lineIcon: nil,
                                    color: colorString != nil ? UIColor(hexString: colorString!) : nil)

            return KTransitStep(vehicle: KVehicleType(rawValue: infos["mode"].stringValue) ?? .other,
                                headsign: infos["headsign"].string,
                                from: from,
                                to: to,
                                polyline: Polyline(encodedPolyline: polyline).mkPolyline!,
                                startTime: parseDate(infos["startTime"].doubleValue),
                                endTime: parseDate(infos["endTime"].doubleValue),
                                duration: ((infos["endTime"].doubleValue) - (infos["startTime"].doubleValue))/1000,
                                line: line)
        } else {

            let travelMode = KTravelMode(rawValue: infos["mode"].stringValue)!
            let group = KStepGroup(travelMode: travelMode,
                       from: from,
                       to: to,
                       duration: infos["duration"].doubleValue,
                       distance: infos["distance"].doubleValue,
                       polyline:  Polyline(encodedPolyline: polyline).mkPolyline!,
                       instruction: NSAttributedString(string: "\(KOTPLocalization.kotpLocalizable("TravelMode.\(travelMode.rawValue)")) \(to.name!)"))

            let steps = infos["steps"].arrayValue

            for stepInfo in steps {
                group.steps.append(parseStep(infos: stepInfo,travelMode: travelMode))
            }

            return group
        }
    }


    private func parseStep(infos: JSON, travelMode: KTravelMode) -> KSingleStep {

        let maneuver = KManeuver(rawValue: infos["relativeDirection"].stringValue)!

        return KSingleStep(travelMode: travelMode,
                           from: parseLocation(result: infos),
                           distance: infos["distance"].doubleValue,
                           instruction: instruction(direction: maneuver, streetName: infos["streetName"].stringValue, exit: infos["exit"].string),
                           maneuver: maneuver)
    }

    private func instruction(direction: KManeuver, streetName: String, exit: String?) -> NSAttributedString {
        let directionDescription: String

        switch direction {
        case .circleClockwise, .circleCounterClockwise:
            directionDescription = KOTPLocalization.DirectionDescription.circle(exit ?? "")
        case .right:
            directionDescription = KOTPLocalization.DirectionDescription.right
        case .hardRight:
            directionDescription = KOTPLocalization.DirectionDescription.hardRight
        case .left:
            directionDescription = KOTPLocalization.DirectionDescription.left
        case .hardLeft:
            directionDescription = KOTPLocalization.DirectionDescription.hardLeft
        case .keepGoing:
            directionDescription = KOTPLocalization.DirectionDescription.continue
        case .depart:
            directionDescription = KOTPLocalization.DirectionDescription.depart
        case .slightlyLeft:
            directionDescription = KOTPLocalization.DirectionDescription.slightlyLeft
        case .slightlyRight:
            directionDescription = KOTPLocalization.DirectionDescription.slightlyRight
        case .uturnLeft:
            directionDescription = KOTPLocalization.DirectionDescription.uturn
        case .uturnRight:
            directionDescription = KOTPLocalization.DirectionDescription.uturn
        }

        let fontKey = NSAttributedString.Key.font
        
        if !KOTPTripPlanner.uselessStreetNames.contains(streetName.lowercased()) {
            
            let attributedString =  NSMutableAttributedString(string: String(format:"%@ %@ %@",directionDescription,KOTPLocalization.to,streetName),
                                                              attributes: [fontKey: KTripTheme.shared.fontFor(text: .instructionImportant)])

            let range = (attributedString.string as NSString).range(of: " \(KOTPLocalization.to) ")

            attributedString.addAttributes([fontKey: KTripTheme.shared.fontFor(text: .instruction)], range: range)

            return attributedString
        }
        else {
            return NSAttributedString(string: directionDescription, attributes: [fontKey: KTripTheme.shared.fontFor(text: .instructionImportant)])
        }
    }
}

extension MKAnnotation
{
    func otpRequestFormat() -> String
    {
        return String(format:"%f,%f", coordinate.latitude, coordinate.longitude)
    }
}

extension KTravelMode
{
    func otpFormat() -> String
    {
        switch self {
        case .car:
            return "CAR"
        case .bicycle:
            return "BICYCLE"
        case .transit:
            return "TRANSIT,WALK"
        case .walk:
            return "WALK"
        }
    }
}
