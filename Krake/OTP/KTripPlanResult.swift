//
//  KTripPlanResult.swift
//  Krake
//
//  Created by joel on 13/04/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import MapKit
import EVReflection

public class KTripPlanResult {

    public let request: KTripPlanRequest
    public var routes: [KRoute]

    public init(_ requestParams: KTripPlanRequest) {
        request = requestParams
        routes = [KRoute]()
    }
}

public enum  KVehicleType: String {
    case tram = "TRAM"
    case subway = "SUBWAY"
    case metroRail = "METRO_RAIL"
    case rail = "RAIL"
    case bus = "BUS"
    case ferry = "FERRY"
    case transit = "TRANSIT"
    case other = "OTHER"
}

public enum KManeuver: String {
    case depart = "DEPART"
    case right = "RIGHT"
    case hardRight = "HARD_RIGHT"
    case circleCounterClockwise = "CIRCLE_COUNTERCLOCKWISE"
    case circleClockwise = "CIRCLE_CLOCKWISE"
    case keepGoing = "CONTINUE"
    case left = "LEFT"
    case hardLeft = "HARD_LEFT"
    case slightlyRight = "SLIGHTLY_RIGHT"
    case slightlyLeft = "SLIGHTLY_LEFT"
    case uturnRight = "UTURN_RIGHT"
    case uturnLeft = "UTURN_LEFT"
}

public class KRoute {
    public let startTime: Date
    public let endTime: Date
    public let duration: Double
    public let distance: Double
    public let walkDistance: Double

    public var steps: [KComplexStep] = [KComplexStep]()
    public let bounds: MKMapRect
    public let warnings: [String]?
    public let copyright: String?

    public init(startTime: Date,
         endTime: Date,
         duration: Double,
         distance: Double,
         walkDistance: Double,
         bounds: MKMapRect,
         warnings: [String]? = nil,
         copyright: String? = nil
) {
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.distance = distance
        self.walkDistance = walkDistance
        self.bounds = bounds
        self.warnings = warnings
        self.copyright = copyright
    }
}

public protocol KComplexStep {
    var travelMode: KTravelMode {get}
    var from: KPlaceResult {get}
    var to: KPlaceResult {get}
    var polyline: MKPolyline {get}
    var duration: Double {get}
    func stepColor() -> UIColor
}

public extension KComplexStep {
    func mapRect() -> MKMapRect {
        
        let fromRect = MKMapRect(origin: KMapPointForCoordinate(from.coordinate), size: MKMapSize(width: 0, height: 0))

        let toRect = MKMapRect(origin: KMapPointForCoordinate(to.coordinate), size: MKMapSize(width: 0, height: 0))
        
        #if swift(>=4.2)
        return fromRect.union(toRect)
        #else
        return MKMapRectUnion(fromRect, toRect)
        #endif
        
    }
}

public class KPlaceResult: NSObject, MKAnnotation, AnnotationProtocol {

    public let location: CLLocation
    public let name: String?
    public var pinName: String = "DefaultPin"

    public init(_ location: CLLocation, name: String? = nil) {
        self.location = location
        self.name = name
    }

    public var title: String? {
        get {
            return name
        }
    }

    public var coordinate: CLLocationCoordinate2D {
        get {
            return location.coordinate
        }
    }

    public func termIconIdentifier() -> String? {
        return nil
    }

    public func nameAnnotation() -> String {
        return pinName
    }

    public func imageInset() -> UIImage?{
        return UIImage(krakeNamed: nameAnnotation())
    }

    public var subtitle: String? {
        get {
            return nil
        }
    }
}

public class KSingleStep{
    public let travelMode: KTravelMode
    public let from: KPlaceResult
    public let to: KPlaceResult?
    public let duration: Double
    public let distance: Double
    public let polyline: String?
    public let instruction: NSAttributedString
    public let maneuver: KManeuver

    public init(travelMode: KTravelMode,
         from: KPlaceResult,
         to:KPlaceResult? = nil,
         duration: Double = 0,
         distance: Double,
         polyline: String? = nil,
         instruction: NSAttributedString,
         maneuver:KManeuver) {
        self.travelMode = travelMode
        self.maneuver = maneuver
        self.from = from
        self.to = to
        self.duration = duration
        self.distance = distance
        self.polyline = polyline
        self.instruction = instruction
    }
}


public class KStepGroup: NSObject, KComplexStep
{
    public let travelMode: KTravelMode
    public let from: KPlaceResult
    public let to: KPlaceResult
    public let duration: Double
    public let distance: Double
    public let polyline: MKPolyline
    public let instruction: NSAttributedString

    public var steps = [KSingleStep]()

    public init(travelMode: KTravelMode,
         from: KPlaceResult,
         to: KPlaceResult,
         duration: Double,
         distance: Double,
         polyline: MKPolyline,
        instruction: NSAttributedString) {
        self.travelMode = travelMode
        self.from = from
        self.to = to
        self.duration = duration
        self.distance = distance
        self.polyline = polyline
        self.instruction = instruction
    }

    public func stepColor() -> UIColor {
        return  KTripTheme.shared.colorFor(travelMode: travelMode)
    }

}

public class KTransitStep: NSObject, KComplexStep
{
    public let vehicle: KVehicleType
    public let headsign: String?
    public let from: KPlaceResult
    public let to: KPlaceResult
    public let polyline: MKPolyline
    public let startTime: Date
    public let endTime: Date
    public let duration: Double
    public let line: KTransitLine

    public let travelMode: KTravelMode = .transit

    public init(vehicle: KVehicleType,
                headsign: String? = nil,
                from: KPlaceResult,
                to: KPlaceResult,
                polyline: MKPolyline,
                startTime: Date,
                endTime: Date,
                duration: Double,
                line: KTransitLine
                ) {
        self.vehicle = vehicle
        self.headsign = headsign
        self.from = from
        self.to = to
        self.polyline = polyline
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.line = line
    }

    public func stepColor() -> UIColor {
        if let color = line.color {
            return color
        }

        return KTripTheme.shared.colorFor(vehicle: vehicle)
    }
}

public class KTransitLine {
    let name: String
    let shortName: String
    let lineIcon: MediaPartProtocol?
    let color: UIColor?

    public init(name: String,
         shortName: String,
         lineIcon: MediaPartProtocol? = nil,
         color: UIColor? = nil) {
        self.name = name
        self.shortName = shortName
        self.lineIcon = lineIcon
        self.color = color
    }
}

public class KOTPRoute: EVObject
{
    public var id: String!
    public var shortName: String!
    public var longName: String!
    public var mode: KVehicleType!
    public var color: UIColor!
    public var agencyName: String!
    
    public override func setValue(_ value: Any?, forKey key: String) {
        switch key{
        case "mode":
            mode = KVehicleType(rawValue: value as! String) ?? KVehicleType.other
        case "color":
            color = UIColor(hexString: value as! String)
        default:
            super.setValue(value, forKey: key)
        }
    }
}

public class KOTPStopTimes: EVObject, PatternProtocol
{
    public var patternST: KOTPPattern?
    public var timesST: [KOTPTimes]?
    
    public var patternId: String?{
        get{
            return patternST?.id
        }
    }
    
    public var descriptionText: String?{
        get{
            return patternST?.desc
        }
    }
    
    public var stopTimesList: NSOrderedSet?{
        get{
            return timesST != nil ? NSOrderedSet(array: timesST!) : nil
        }
    }
    
    public override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "pattern"{
            patternST = KOTPPattern(dictionary: value as! NSDictionary)
        } else if key == "times"{
            timesST = [KOTPTimes](dictionaryArray: value as! [NSDictionary])
        }
    }
    override public var hash: Int{
        return patternId.hashValue
    }

    static func ==(lhs: KOTPStopTimes, rhs: KOTPStopTimes) -> Bool {
        return lhs.patternId == rhs.patternId
    }
}

public class KOTPPattern: EVObject
{
    public var id: String?
    public var desc: String?
}

public class KOTPTimes: EVObject, StopTimeProtocol
{


    public var identifier: NSNumber!{
        get{
            return NSNumber(value: 0)
        }
    }
    
    public var stopId: String?
    public var stopIndex: NSNumber?
    public var stopCount: NSNumber?
    public var scheduledArrival: NSNumber?
    public var scheduledDeparture: NSNumber?
    public var realtimeArrival: NSNumber?
    public var realtimeDeparture: NSNumber?
    public var arrivalDelay: NSNumber?
    public var departureDelay: NSNumber?
    public var timepoint: Bool = false
    public var realtime: Bool = false
    public var realtimeState: String?
    public var serviceDay: NSNumber?
    public var tripId: String?
    public var headsign: String?
    public var lastStop: Bool {
        get {
            let lastStop: Bool
            if let index = stopIndex?.intValue ,
                let count = stopCount?.intValue {
                lastStop = index == count - 1
            }
            else {
                lastStop = false
            }
            return lastStop
        }
    }
}

public class KOTPStop: EVObject, KOTPStopItem, AnnotationProtocol
{
    public var originalId: String?{
        get{
            return id?.replacingOccurrences(of: "_", with: ":")
        }
    }
    
    public var identifier: NSNumber!{
        get{
            return NSNumber(value: 0)
        }
    }
    
    public var dist: NSNumber?{
        get{
            return nil
        }
    }
    
    public var code: String?
    public var id: String?
    public var lat: NSNumber?
    public var lon: NSNumber?
    public var name: String?

    public func nameAnnotation() -> String {
        return KTripTheme.shared.annotationName(for: self)
    }

    public func color() -> UIColor {
        return KTripTheme.shared.color(for: self)
    }
    
    @objc public var coordinate: CLLocationCoordinate2D{
        get{
            return CLLocationCoordinate2D(latitude: lat!.doubleValue, longitude: lon!.doubleValue)
        }
    }
    
    public var title: String?{
        return name
    }
    
    public var subtitle: String?{
        return nil
    }

    public func termIconIdentifier() -> String? {
        return nil
    }
    
    public override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "description"
        {
            name = (value as? String)?.replacingOccurrences(of: "stop ", with: "")
        }else if key == "lng"
        {
            lon = value as? NSNumber
        }
        
        
    }
}
