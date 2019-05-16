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
import SwiftyJSON

public class KOpenTripPlannerLoader: KOTPLoader {

    private let manager = AFHTTPSessionManager(baseURL: KInfoPlist.OTP.path)

    private var geometryTask: URLSessionDataTask? = nil
    private var routesInfo: URLSessionDataTask? = nil
    
    public func retrievePathPoints(for line: BusLine, with completion: @escaping (BusLine, MKPolyline?) -> Void)
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
        routesInfo?.cancel()
        routesInfo = manager.get("index/routes",
                        parameters: nil,
                        progress: nil,
                        success: { (task, result) in
                            
                            if let result = result as? [[String : Any]],
                                let results = JSON(result).array
                            {
                                var routes = [KOTPRoute]()
                                for result in results{
                                    let route = KOTPRoute(parameter: result)
                                    routes.append(route)
                                }
                                
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

}

protocol JSONable {
    init?(parameter: JSON)
}

public class KOTPRoute: JSONable {
    let identifier :String!
    let shortName :String!
    let longName :String!
    let mode: KVehicleType!
    let color: UIColor!
    let agencyName :String!
    
    required init(parameter: JSON) {
        identifier = parameter["id"].stringValue
        shortName = parameter["shortName"].stringValue
        longName = parameter["longName"].stringValue
        mode = parameter["mode"].string != nil ? KVehicleType(rawValue: parameter["mode"].stringValue)! : KVehicleType.other
        color = parameter["color"].string != nil ? UIColor(hexString: parameter["color"].stringValue) : UIColor.tint
        agencyName = parameter["agencyName"].stringValue
    }
}
