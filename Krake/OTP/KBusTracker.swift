//
//  KBusTracker.swift
//  Krake
//
//  Created by Patrick on 18/05/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import Foundation
import MapKit

public protocol KBusTrackerLoader
{
    func currentVehiclePostion(for line: KBusLine,
                           with tracker: KBusTracker)
}

public class KBusTracker: NSObject
{
    public typealias Completion = (CLLocationCoordinate2D?) -> Void
    public static var loader: KBusTrackerLoader? = nil
    
    private let line: KBusLine
    private var callerCompletion: Completion?
    private var timer: Timer? = nil
    private let timeInterval: TimeInterval = KInfoPlist.OTP.busTrackerRefresh?.doubleValue ?? 0
    
    required init?(line: KBusLine) {
        if KBusTracker.loader == nil {
            return nil
        }
        self.line = line
        super.init()
    }
    
    deinit {
        stopTrack()
        KLog("RELEASED")
    }
    
    public func startTrack(completion: @escaping Completion)
    {
        self.callerCompletion = completion
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval > 0 ? timeInterval : 10, repeats: true, block: { [weak self](timer) in
            self?.getVehiclePosition()
        })
        getVehiclePosition()
    }
    
    public func isTracking() -> Bool
    {
        return callerCompletion != nil
    }
    
    public func stopTrack()
    {
        callerCompletion = nil
        timer?.invalidate()
        timer = nil
    }
    
    private func getVehiclePosition()
    {
        KBusTracker.loader?.currentVehiclePostion(for: line, with: self)
    }

    public func updatedPosition(loader: KBusTrackerLoader, coordinates: CLLocationCoordinate2D?, error: Error?)
    {
        callerCompletion?(coordinates)
    }
}

