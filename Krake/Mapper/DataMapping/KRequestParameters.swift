//
//  KRequestParameters.swift
//  OrchardGen
//
//  Created by joel on 27/09/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation
import CoreLocation

open class KRequestParameters: NSObject {

    /// Parametri per richiedere i subTerm di una Taxonomyo TermPart e non i suoi contenuti.
    ///
    /// - returns: paramettri da spedire
    public static func parametersToLoadCategorySubTerms() -> [String: Any] {
        return [REQUEST_RESULT_TARGET : "SubTerms"]
    }

    /// Richiesta normale di una projection
    ///
    /// - parameter page:         pagina corrente numerate da 1 ad N
    /// - parameter pageSize:     dimensione della pagina
    /// - parameter fieldsFilter: filtri seperati da virgola per prelevare solo alcuni campi da orchard
    ///
    /// - returns: paramettri da spedire
    public static func parameters(currentPage page: UInt, pageSize: UInt, fieldsFilter: String? = nil) -> [String: Any] {
        var parameters : [String : Any] = [REQUEST_PAGE_KEY: page, REQUEST_PAGE_SIZE_KEY: pageSize]

        if fieldsFilter != nil {
            parameters[REQUEST_ITEMS_FIELDS_FILTER] = fieldsFilter!
        }

        return parameters
    }

    /// Around Me
    ///
    /// - parameter location:     posizione dell'utente
    /// - parameter radius:       raggio in chilometri
    /// - parameter page:         pagina corrente numerate da 1 ad N
    /// - parameter pageSize:     dimensione della pagina
    /// - parameter fieldsFilter: filtri seperati da virgola per prelevare solo alcuni campi da orchard
    ///
    /// - returns: parametri per la ricerca around me
    public static func parameters(userLocation location: CLLocation, radius: UInt, page: UInt = 1, pageSize: UInt = 9999, fieldsFilter: String? = nil) -> [String: Any] {
        var parameters : [String : Any] = [REQUEST_AROUND_ME_RADIUS: radius, REQUEST_AROUND_ME_LATITUDE : location.coordinate.latitude, REQUEST_AROUND_ME_LONGITUDE : location.coordinate.longitude, REQUEST_PAGE_KEY: page, REQUEST_PAGE_SIZE_KEY: pageSize]

        if fieldsFilter != nil {
            parameters[REQUEST_ITEMS_FIELDS_FILTER] = fieldsFilter!
        }

        return parameters
    }


    /// Richiesta per visualizzare la privacy, senza considerla un caso speciale
    ///
    /// - returns: parametri della richiesta
    public static func parametersShowPrivacy() -> [String: Any] {
        return [REQUEST_SHOW_PRIVACY: true]
    }


    /// Richiesta per evitare la cache lato orchard
    ///
    /// - returns: parametri per la richiesta
    public static func parametersNoCache() -> [String: Any] {
        return [REQUEST_NO_CACHE: String(format: "%f", Date().timeIntervalSinceReferenceDate)]
    }
    
}

