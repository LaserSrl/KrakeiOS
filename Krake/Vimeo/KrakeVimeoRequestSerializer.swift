//
//  KrakeVimeoRequestSerializer.swift
//  Krake
//
//  Created by Marco Zanino on 12/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import AFNetworking

class KrakeVimeoRequestSerializer: AFHTTPRequestSerializer {
    
    override init() {
        super.init()
        
        // Adding POST method into the set of methods that require parameters into
        // query string and not into HTTP body.
        var methodsWithEncodingParamsInURI = httpMethodsEncodingParametersInURI
        methodsWithEncodingParamsInURI.insert("POST")
        httpMethodsEncodingParametersInURI = methodsWithEncodingParamsInURI
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
