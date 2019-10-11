//
//  KOTPRouterRectLoader.swift
//  Krake
//
//  Created by joel on 11/05/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import UIKit
import MapKit

public class KOTPRouterRectLoader: NSObject {

    public static func loadRouterBoundaries(_ callback: @escaping (MKCoordinateRegion?) -> Void ) {
        let manager = KNetworkManager(baseURL: KInfoPlist.OTP.path, auth: false)


        _ = manager.request("",
                            method:.get,
                            parameters: nil, successCallback: { (task, responseObject) in

            if let returnedInfos = responseObject as? [String: AnyObject] {
                if let coordinates = ((returnedInfos["polygon"] as? [String: AnyObject] )?["coordinates"] as? [[[Any]]])?[0]
                {
                    var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
                    var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)

                    for coordinate in coordinates {
                       let coordinate = CLLocationCoordinate2D(latitude: coordinate[1] as! CLLocationDegrees, longitude: coordinate[0] as! CLLocationDegrees)
                        topLeft.longitude = min(topLeft.longitude, coordinate.longitude)
                        topLeft.latitude = max(topLeft.latitude, coordinate.latitude)

                        bottomRight.longitude = max(bottomRight.longitude, coordinate.longitude)
                        bottomRight.latitude = min(bottomRight.latitude, coordinate.latitude)
                    }

                    var region = MKCoordinateRegion()
                    region.center.latitude = topLeft.latitude - (topLeft.latitude - bottomRight.latitude) * 0.5
                    region.center.longitude = topLeft.longitude + (bottomRight.longitude - topLeft.longitude) * 0.5
                    region.span.latitudeDelta = fabs(topLeft.latitude - bottomRight.latitude) * 1.1 // Add a little extra space on the sides
                    region.span.longitudeDelta = fabs(bottomRight.longitude - topLeft.longitude) * 1.1 // Add a little extra space on the sides

                    callback(region)
                }
            }

        }, failureCallback: nil)
    }
}
