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

    private let manager = AFHTTPSessionManager(baseURL: KInfoPlist.OTP.path)

    private var geometryTask: URLSessionDataTask? = nil
    private var routesInfo: URLSessionDataTask? = nil
    private var stopTimes: URLSessionDataTask? = nil
    private var stopsPattern: URLSessionDataTask? = nil
    private var routesCached: [KOTPRoute]?
    
    public func retrievePathPoints(for line: KBusLine, with completion: @escaping (KBusLine, MKPolyline?) -> Void)
    {
        geometryTask?.cancel()
        geometryTask = manager.get(String(format: "index/patterns/%@/geometry",line.patternId),
                    parameters: nil,
                    progress: nil,
                    success: { (task, result) in

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
        routesInfo = manager.get("index/routes",
                        parameters: nil,
                        progress: nil,
                        success: { (task, result) in
                            
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
    
    public func retrieveStopTimes(for stopId: String! ,with completion: @escaping ([KOTPStopTimes]?) -> Void)
    {
        stopTimes?.cancel()
        stopTimes = manager.get("index/stops/" + stopId + "/stoptimes?detail=long&refs=true",
                                 parameters: nil,
                                 progress: nil,
                                 success: { (task, result) in
                                    
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
    
    public func retrieveStops(for line: KBusLine ,with completion: @escaping ([KOTPStop]?) -> Void)
    {
        stopsPattern?.cancel()
        stopsPattern = manager.get("index/patterns/" + line.patternId + "/stops?detail=long&refs=true",
                                parameters: nil,
                                progress: nil,
                                success: { (task, result) in
                                    
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

}
