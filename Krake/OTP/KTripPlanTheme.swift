//
//  KTripPlanTheme.swift
//  Krake
//
//  Created by joel on 05/05/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import DateTimePicker

class KTripTheme {
    static var shared: KTripPlanTheme = KTripDefaultTheme()
}

public enum KTripText {
    case distance
    case mainInfo
    case instruction
    case instructionImportant
    case date
}

public enum KTripPinName {
    case from
    case to
}

public protocol KTripPlanTheme {

    func colorFor(travelMode mode: KTravelMode) -> UIColor
    func colorFor(vehicle: KVehicleType) ->  UIColor

    func applyTheme(toLabel label: UILabel, type: KTripText)
    func colorFor(text: KTripText) ->  UIColor
    func fontFor(text: KTripText) ->  UIFont

    func imageFor(travelMode mode: KTravelMode) -> UIImage
    func imageFor(vehicleType vehicle: KVehicleType) -> UIImage

    func imageFor(maneuver: KManeuver) -> UIImage

    func pinName(_ pin: KTripPinName) -> String

    func applyTheme(toDateTimePicker dateTimePicker: DateTimePicker)
}

open class KTripDefaultTheme: KTripPlanTheme {


    open func applyTheme(toLabel label: UILabel, type: KTripText)
    {
        label.font = KTripTheme.shared.fontFor(text: type)
        label.textColor = KTripTheme.shared.colorFor(text: type)
    }

    open func colorFor(travelMode mode: KTravelMode) -> UIColor
    {
        switch mode {
        case .bicycle:
            return UIColor(red: 0.417, green: 0.709, blue: 0.147, alpha: 1.0)

        case .car:
            return UIColor(red: 0.352, green: 0.678, blue: 0.865, alpha: 1.0)

        case .walk:
            return UIColor(red: 0.472, green: 0.311, blue: 0.171, alpha: 1.0)

        default:
            return KTheme.current.color(.tint)
        }
    }

    open func colorFor(vehicle: KVehicleType) -> UIColor
    {
        switch vehicle {
        case .bus:
            return UIColor(red: 0.043, green: 0.357, blue: 0.682, alpha: 1.0)

        case .tram:
            return UIColor(hexString:"#f7931e")
        case .subway:
            return UIColor.black
        default:
            return KTheme.current.color(.tint)
        }
    }

    open func imageFor(travelMode mode: KTravelMode) -> UIImage {

        let imageName: String
        
        switch mode {
        case .bicycle:
            imageName = "ic_directions_bike"

        case .car:
            imageName = "ic_directions_car"

        case .walk:
            imageName = "ic_directions_walk"

        case .transit:
            imageName = "ic_directions_transit"
        }

        let image = UIImage(otpNamed: imageName)!

        let size = image.size

        return image.resizableImage(withCapInsets: UIEdgeInsets(top: size.height - 1, left: 0, bottom: 0, right:0), resizingMode: .tile)
    }

    open func imageFor(maneuver: KManeuver) -> UIImage {

        let imageName: String
        switch maneuver {
        case .depart, .keepGoing:
            imageName = "continua_dritto"

        case .right, .hardRight:
            imageName = "destra_90"

        case .slightlyRight:
            imageName = "destra_45"

        case .circleClockwise, .circleCounterClockwise:
            imageName = "rotonda"

        case .left, .hardLeft:
            imageName = "sinistra_90"

        case .slightlyLeft:
            imageName = "sinistra_45"

        case .uturnRight:
            imageName = "inversione_u_dx"

        case .uturnLeft:
            imageName = "inversione_u_sx"
        }

        return UIImage(otpNamed: imageName)!.withRenderingMode(.alwaysTemplate)
    }

    open func colorFor(text: KTripText) ->  UIColor
    {
        switch text {
        case .distance:
            return UIColor.darkGray

        default:
            return UIColor.black
        }
    }

    open func fontFor(text: KTripText) ->  UIFont
    {
        switch text {
        case .instruction:
            return UIFont.systemFont(ofSize: 15)
        case .instructionImportant:
            return UIFont.boldSystemFont(ofSize: 15)

        case .mainInfo:
            return UIFont.preferredFont(forTextStyle: .headline)

        case .distance, .date:
            return UIFont.preferredFont(forTextStyle: .subheadline)
        }
    }

    open func imageFor(vehicleType vehicle: KVehicleType) -> UIImage
    {
        let imageName: String
        switch vehicle {
        case .subway:
            imageName = "pin_metro"
        case .tram:
            imageName = "pin_tram"
        case .bus:
            imageName = "pin_bus"
        default:
            imageName = "ic_directions_transit"
        }

        return UIImage(otpNamed: imageName)!.withRenderingMode(.alwaysTemplate)
    }

    open func pinName(_ pin: KTripPinName) -> String {
        switch pin {
        case .from:
            return "pin_partenza"
        default:
            return "pin_traguardo"
        }
    }

    open func applyTheme(toDateTimePicker dateTimePicker: DateTimePicker) {
        dateTimePicker.highlightColor = KTheme.current.color(.tint)
    }
}
