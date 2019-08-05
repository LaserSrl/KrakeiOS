//
//  KLocationManager.swift
//  Krake
//
//  Created by joel on 29/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import CoreLocation

public typealias LocationAuthBlock = (KLocationManager, CLAuthorizationStatus) -> Void
public typealias LocationUpdateBlock = (KLocationManager, CLLocation?) -> Void

open class KLocationManager : CLLocationManager, CLLocationManagerDelegate
{
    private var authBlock : LocationAuthBlock?
    private var locationUpdateBlock : LocationUpdateBlock?
    
    public override init()
    {
        super.init()
        self.desiredAccuracy = kCLLocationAccuracyBest
        self.distanceFilter = 25.0
        self.delegate = self
    }
    
    public func requestAuthorization(always: Bool = false, completion: @escaping LocationAuthBlock)
    {
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined || ( status == .authorizedWhenInUse && always ) {
            authBlock = completion
            if !always
            {
                self.requestWhenInUseAuthorization()
            }
            else
            {
                if !UserDefaults.standard.bool(forKey: "IsFirstTimeAlwaysAuthorizationRequested")
                {
                    self.requestAlwaysAuthorization()
                    UserDefaults.standard.set(true, forKey: "IsFirstTimeAlwaysAuthorizationRequested")
                }
                else
                {
                    completion(self, status)
                }
            }
        }
        else {
            completion(self, status)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authBlock?(self, status)
    }
    
    public func requestStartUpdatedLocation(completion: @escaping LocationUpdateBlock) {
        locationUpdateBlock = completion
        self.startUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locationUpdateBlock != nil {
            locationUpdateBlock!(self, locations.first)
        }
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if locationUpdateBlock != nil {
            locationUpdateBlock!(self, nil)
        }
    }
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        if locationUpdateBlock != nil {
            locationUpdateBlock!(self, nil)
        }
    }
}
