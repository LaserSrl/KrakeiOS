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

public class KBusTracker: NSObject
{
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
    }
    
    public func startTrack(completion: @escaping KBusTrackerComlpetion)
    {
        self.completion = completion
        getVehiclePosition()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { [weak self](timer) in
            self?.getVehiclePosition()
        })
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
        let manager = AFHTTPSessionManager(baseURL: URL(string: "http://bigosoluzions.url/"))
        manager.get("tripId="+(line.routeInfo?.id ?? ""), parameters: nil, progress: nil, success: { (task, object) in
            self.completion?(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        }) { (task, error) in
            KLog(error.localizedDescription)
        }
    }
    
    
    
}

public class KVehicleAnnotation: MKPointAnnotation, AnnotationProtocol {
    
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
        return UIImage(otpNamed: "pin_bus")
    }
    
    override public func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
}
