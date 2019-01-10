//
//  KOTPStopsSearchInitializer.swift
//  Krake
//
//  Created by Marco Zanino on 12/04/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import CoreLocation

public typealias KOTPStopSearchInitializerCompletion = (CLLocation?, String?) -> Void

public protocol KOTPStopsSearchInitializer {
    func coordinatesForSearchInitialization(with completion: @escaping KOTPStopSearchInitializerCompletion)
}

public class KOTPBaseStopsSearchInitializer: KOTPStopsSearchInitializer {

    private static var userLocationValidityInfoKey = "OTPUserLocationSecondsValidity"

    private lazy var locationManager: KLocationManager = {
        let locationManager = KLocationManager()
        locationManager.distanceFilter = 0
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        return locationManager
    }()

    private let userLocationValidity: TimeInterval

    init() {
        let userLocationValidity = Bundle
            .main
            .object(
                forInfoDictionaryKey: KOTPBaseStopsSearchInitializer.userLocationValidityInfoKey) as? NSNumber
        self.userLocationValidity = userLocationValidity?.doubleValue ?? 5.0 * 60
    }

    public func coordinatesForSearchInitialization(with completion: @escaping KOTPStopSearchInitializerCompletion) {
        // Verifico se si hanno i permessi necessari per accedere alla posizione
        // dell'utente.
        let currentLocationAuthorization = CLLocationManager.authorizationStatus()
        if currentLocationAuthorization == .authorizedWhenInUse || currentLocationAuthorization == .authorizedAlways {
            // Verifico se è presente una posizione dell'utente valida.
            // La posizione viene considerata valida se è stata presa non più
            // di cinque minuti da adesso.
            if let lastLocation = locationManager.location, -1.0 * lastLocation.timestamp.timeIntervalSinceNow <= userLocationValidity {
                if shouldNotifyCaller(about: lastLocation) {
                    completion(lastLocation, "LAMIAPOS".localizedString())
                } else {
                    completion(nil, nil)
                }
            } else {
                // Non è presente alcuna posizione in memoria, ne richiedo una
                // nuova.
                locationManager.requestStartUpdatedLocation() { [weak self] (manager, location) in
                    guard let strongSelf = self,
                        let location = location else {
                        completion(nil, nil)
                        return
                    }
                    // Fermo ogni altro location update.
                    manager.stopUpdatingLocation()
                    if strongSelf.shouldNotifyCaller(about: location) {
                        // Notifico il richiedente della nuova location.
                        completion(location, "LAMIAPOS".localizedString())
                    } else {
                        completion(nil, nil)
                    }
                }
            }
        } else {
            completion(nil, nil)
        }
    }

    private func shouldNotifyCaller(about position: CLLocation) -> Bool {
        guard let boundingRegion = KSearchPlaceViewController.prefferedRegion else { return true }
		return boundingRegion.contains(point: position.coordinate)
    }
    
}
