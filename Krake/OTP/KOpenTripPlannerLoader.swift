//
//  KOpenTripPlannerLinePathLoader.swift
//  Krake
//
//  Created by Marco Zanino on 03/05/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import Polyline
import EVReflection

public class KOpenTripPlannerLoader: KOTPLoader {
    
    public static var shared = KOpenTripPlannerLoader()

    private var geometryTask: KDataTask? = nil
    private var routesInfo: KDataTask? = nil
    private var stopTimes: KDataTask? = nil
    private var stopsPattern: KDataTask? = nil
    private var stopsInRoutePattern: KDataTask? = nil
    private var otpItemStopTime: KDataTask? = nil
    private var allStops: KDataTask? = nil
    private var routesCached: [KOTPRoute]?
    
    private func manager() -> KNetworkManager
    {
        return KNetworkManager(baseURL: KInfoPlist.OTP.path, auth: false)
    }
    
    public func retrievePathPoints(for line: KBusLine, with completion: @escaping (KBusLine, MKPolyline?) -> Void)
    {
        geometryTask?.cancel()
        geometryTask = manager().request(String(format: "index/patterns/%@/geometry",line.patternId),
                                       method:.get,
                    parameters: nil,
                    successCallback: { (task, result) in

                        if let result = result as? [String: Any] , let geometry = result["points"] as? String {

                            completion(line,Polyline(encodedPolyline: geometry).mkPolyline)

                        }
                        else {
                            completion(line,nil)
                        }
                        self.geometryTask = nil
        }) { (task, error) in
            completion(line,nil)
            self.geometryTask = nil
        }
    }
    
    public func retrieveRoutesInfos(with completion: @escaping ([KOTPRoute]?) -> Void)
    {
        if routesCached != nil {
            completion(routesCached)
            return
        }
        routesInfo?.cancel()
        routesInfo = manager().request("index/routes",
                                     method: .get,
                        parameters: nil,
                        successCallback: { (task, result) in
                            
                            if let result = result as? [NSDictionary]
                            {
                                let routes = [KOTPRoute](dictionaryArray: result)
                                self.routesCached = routes
                                completion(routes)
                            }
                            else {
                                completion(nil)
                            }
                            self.routesInfo = nil
        }) { (task, error) in
            completion(nil)
            self.routesInfo = nil
        }
        
    }
    
    public func retrieveStopTimes(for stopId: String!, with completion: @escaping ([KOTPStopTimes]?) -> Void)
    {
        stopTimes?.cancel()
        stopTimes = manager().request("index/stops/" + stopId + "/stoptimes",
                                    method: .get,
                                    parameters: nil,
                                    query: [URLQueryItem(name: "detail", value:"long"), URLQueryItem(name: "refs", value: "true")],
                                 successCallback: { (task, result) in
                                    
                                    if let result = result as? [NSDictionary]
                                    {
                                        let stopTimes = [KOTPStopTimes](dictionaryArray: result)
                                        completion(stopTimes)
                                    }
                                    else {
                                        completion(nil)
                                    }
                                    self.stopTimes = nil
        }) { (task, error) in
            completion(nil)
            self.stopTimes = nil
        }
        
    }
    
    public func retrieveStops(for line: KBusLine, with completion: @escaping ([KOTPStop]?) -> Void)
    {
        stopsPattern?.cancel()
        stopsPattern = manager().request("index/patterns/" + line.patternId + "/stops",
                                       method: .get,
                                       query: [URLQueryItem(name: "detail", value: "long"), URLQueryItem(name: "refs", value: "true")],
                                successCallback: { (task, result) in
                                    
                                    if let result = result as? [NSDictionary]
                                    {
                                        let stops = [KOTPStop](dictionaryArray: result)
                                        completion(stops)
                                    }
                                    else {
                                        completion(nil)
                                    }
                                    self.stopsPattern = nil
        }) { (task, error) in
            completion(nil)
            self.stopsPattern = nil
        }
        
    }

    public func retrieveStops(for route: KOTPRoute, with completion: @escaping ([KOTPStop]?) -> Void) {
        stopsInRoutePattern?.cancel()

        stopsInRoutePattern = manager().request("index/routes/" + route.id + "/stops",
                                           method: .get,
                                           query: [URLQueryItem(name: "detail", value: "long"), URLQueryItem(name: "refs", value: "true")],
                                           successCallback: { (task, result) in

                                            if let result = result as? [NSDictionary]
                                            {
                                                let stops = [KOTPStop](dictionaryArray: result)
                                                completion(stops)
                                            }
                                            else {
                                                completion(nil)
                                            }
                                            self.stopsInRoutePattern = nil
        }) { (task, error) in
            completion(nil)
            self.stopsInRoutePattern = nil
        }
    }

    public func retrieveTimes(for stop: KOTPStopItem,
                       route: KOTPRoute,
                       date: Date,
                       with completion: @escaping ([KOTPTimes]?) -> Void) {
        otpItemStopTime?.cancel()

        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMdd"
        let path = String(format: "index/stops/%@/stoptimes/%@",stop.originalId ?? "", formatter.string(from: date))
        otpItemStopTime = manager().request(path,
                                           method: .get,
                                           successCallback: { (task, result) in

                                            if let result = result as? [NSDictionary]
                                            {
                                                var stops = [KOTPStopTimes](dictionaryArray: result)

                                                stops = stops.filter({ (stop) -> Bool in
                                                    if let parts = stop.patternId?.components(separatedBy: ":") {
                                                        let routeParts = route.id.components(separatedBy: ":")

                                                        let maxIndex = min(parts.count, routeParts.count)

                                                        for index in 0 ..< maxIndex {
                                                            if parts[index] != routeParts[index] {
                                                                return false
                                                            }
                                                        }

                                                        return true
                                                    }
                                                    return false
                                                })

                                                stops = Array(Set(stops))

                                                let times = stops.map({ (stop: KOTPStopTimes) -> [KOTPTimes] in
                                                    return stop.timesST ?? []
                                                })

                                                let allTimes = times.flatMap{$0}.filter({ $0.realtimeState != "CANCELED"})

                                                completion(allTimes.sorted(by: {
                                                    return $0.scheduledDeparture?.intValue ?? 0 < $1.scheduledDeparture?.intValue ?? 0
                                                }))
                                            }
                                            else {
                                                completion(nil)
                                            }
                                            self.otpItemStopTime = nil
        }) { (task, error) in
            completion(nil)
            self.otpItemStopTime = nil
        }
    }
    
    public func retrieveAllStops(search text: String, with completion: @escaping ([KOTPStop]?) -> Void) {
        allStops?.cancel()
        if let text = text.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            allStops = manager().request("geocode",
                                    method: .get,
                                    query: [URLQueryItem(name: "autocomplete", value: "true"),
                                    URLQueryItem(name: "corners", value: "false"),
                                    URLQueryItem(name: "stops", value: "true"),
                                    URLQueryItem(name: "query", value: text)],
                                    successCallback: { (task, result) in
                                    
                                    if let result = result as? [NSDictionary]
                                    {
                                        let stops = [KOTPStop](dictionaryArray: result)
                                        completion(stops)
                                    }
                                    else {
                                        completion(nil)
                                    }
                                    self.allStops = nil
            }) { (task, error) in
                completion(nil)
                self.allStops = nil
            }
        }
        else
        {
            completion(nil)
            self.allStops = nil
        }
    }
}
