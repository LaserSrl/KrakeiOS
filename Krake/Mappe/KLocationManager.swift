//
//  KLocationManager.swift
//  Krake
//
//  Created by joel on 29/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import CoreLocation

public typealias LocationAuthBlock = (KLocationManager, CLAuthorizationStatus, CLAccuracyAuthorization?) -> Void
public typealias LocationUpdateBlock = (KLocationManager, CLLocation?) -> Void

public enum WantAccurateLocationFor{
    case discoverAddress
    case custom(value: String)
    
    public var rawValue: String {
        get{
            switch self {
                case let .custom(value):
                    return value
                default:
                    return String(describing: self)
            }
        }
    }
}

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
    
    public func request(authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse, completion: @escaping LocationAuthBlock)
    {
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined || ( status == .authorizedWhenInUse && authorizationStatus == .authorizedAlways ) {
            authBlock = completion
            if !(authorizationStatus == .authorizedAlways)
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
                    if #available(iOS 14.0, *) {
                        completion(self, status, accuracyAuthorization)
                    } else {
                        completion(self, status, nil)
                    }
                }
            }
        }
        else {
            if #available(iOS 14.0, *) {
                completion(self, status, accuracyAuthorization)
            } else {
                completion(self, status, nil)
            }
        }
    }
    
    @available(iOS 14.0, *)
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authBlock?(self, manager.authorizationStatus, manager.accuracyAuthorization)
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authBlock?(self, status, nil)
    }
    
    
    /// This method request at user the update location
    /// - Parameters:
    ///   - wantAccurateLocationFor: default is nil and on iOS 14 not requested the CLAccuracyAuthorization.fullAccuracy. If setted
    ///   - completion: will called with the first available location, location can be nil if did fail with error
    public func requestStartUpdatedLocation(wantAccurateLocationFor: WantAccurateLocationFor? = nil,
                                            completion: @escaping LocationUpdateBlock) {
        locationUpdateBlock = completion
        if #available(iOS 14.0, *) {
            if accuracyAuthorization == CLAccuracyAuthorization.reducedAccuracy,
               let accurateLocation = wantAccurateLocationFor {
                requestTemporaryFullAccuracyAuthorization(withPurposeKey: accurateLocation.rawValue, completion: { [weak self] error in
                    self?.startUpdatingLocation()
                    if let error = error {
                        KLog(type: .warning, "\(error.localizedDescription) probably is not present the value and key '\(accurateLocation.rawValue)' on InfoPlist in dictionary's key  'NSLocationTemporaryUsageDescriptionDictionary'")
                    }
                })
            } else {
                self.startUpdatingLocation()
            }
        } else {
            self.startUpdatingLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationUpdateBlock?(self, locations.first)
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationUpdateBlock?(self, nil)
    }
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        locationUpdateBlock?(self, nil)
    }
}
