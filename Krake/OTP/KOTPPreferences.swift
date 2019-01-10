//
//  KOTPPreferences.swift
//  Krake
//
//  Created by Marco Zanino on 12/04/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation

public class KOTPPreferences {

    private static var searchRadiusPreferenceKey = "seach_radius"

    public static func retrieveSearchRadius(fallbackValue defaultValue: KOTPSearchRadius) -> KOTPSearchRadius {
		let storedValue =  UserDefaults
            .standard
            .integer(forKey: searchRadiusPreferenceKey)
        // Verifico che il valore restituito sia valido.
        if storedValue != 0 {
            return UInt(storedValue)
        } else {
			// Aggiorno il valore salvato con il default, di modo che la prossima
            // volta venga prelevato un valore valido.
            updateStoredSearchRadius(with: defaultValue)
            // Restituisco il valore di default.
            return defaultValue
        }
    }

    public static func updateStoredSearchRadius(with value: KOTPSearchRadius) {
        UserDefaults
            .standard
            .set(value, forKey: searchRadiusPreferenceKey)
    }

}
