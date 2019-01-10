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
public class KOpenTripPlannerLinePathLoader: KLinePathLoader {

    private var connection: URLSessionDataTask?

    public func retrievePathPoints(for line: BusLine, with completion: @escaping (BusLine, MKPolyline?) -> Void) {

        let manager = KNetworkManager(baseURL: KInfoPlist.OTP.path)

        connection?.cancel()
        connection = manager.get(String(format: "index/patterns/%@/geometry",line.patternId),
                    parameters: nil,
                    progress: nil,
                    success: { (task, result) in

                        if let result = result as? [String: Any] , let geometry = result["points"] as? String {

                            completion(line,Polyline(encodedPolyline: geometry).mkPolyline)

                        }
                        else {
                            completion(line,nil)
                        }
                        self.connection = nil

        }) { (task, error) in
            completion(line,nil)
            self.connection = nil
        }


    }

}
