//
//  KBusTracker.swift
//  Krake
//
//  Created by Patrick on 18/05/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import Foundation
import MapKit

public typealias KBusTrackerComlpetion = (CLLocationCoordinate2D?) -> Void

public protocol KBusTrackerLoader
{
    func getVehiclePostion(for line: BusLine, with busTracker: KBusTracker, completion: KBusTrackerComlpetion?)
}

public class KBusTracker: NSObject
{
    public static var busTrackerLoader: KBusTrackerLoader?
    private let line: BusLine
    private var completion: KBusTrackerComlpetion?
    private var timer: Timer? = nil
    private let timeInterval = 3.0
    
    required init?(line: BusLine) {
        self.line = line
        super.init()
    }
    
    deinit {
        stopTrack()
        KLog("RELEASED")
    }
    
    public func startTrack(completion: @escaping KBusTrackerComlpetion)
    {
        self.completion = completion
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { [weak self](timer) in
            self?.getVehiclePosition()
        })
        getVehiclePosition()
    }
    
    public func isTracking() -> Bool
    {
        return completion != nil
    }
    
    public func stopTrack()
    {
        completion = nil
        timer?.invalidate()
        timer = nil
    }
    
    private func getVehiclePosition()
    {
        KBusTracker.busTrackerLoader?.getVehiclePostion(for: line, with: self, completion: completion)
    }
}

public class KVehicleAnnotation: MKPointAnnotation, AnnotationProtocol {
    
    let line: BusLine!
    
    required init(_ line: BusLine!) {
        self.line = line
        super.init()
    }
    
    public func annotationIdentifier() -> String{
        return nameAnnotation() + (color().description)
    }
    
    public func termIconIdentifier() -> String? {
        return nil
    }
    
    public func boxedText() -> String? {
        return nil
    }
    
    public func color() -> UIColor {
        return KTheme.current.color(.alternate)
    }
    
    public func nameAnnotation() -> String {
        return "vehicle"
    }
    
    public func imageInset() -> UIImage? {
        if let mode = line.routeInfo?.mode{
            return KTripTheme.shared.imageFor(vehicleType: mode)
        }
        return UIImage(otpNamed: "pin_bus")
    }
    
    override public func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
}
