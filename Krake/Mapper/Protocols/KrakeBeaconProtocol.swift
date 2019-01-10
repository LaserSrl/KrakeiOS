//
//  KrakeBeaconProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol KrakeBeaconProtocol: KeyValueCodingProtocol {
    var minorValue : NSNumber? {get}
    var majorValue : NSNumber? {get}
    var uUIDValue : String? {get}
    var titlePartTitle: String? {get}
    var testodellaNotificaValue: String? {get}
    
    func urlReference() -> FieldExternalProtocol?
    
    func termPart() -> TermPartProtocol?
}

extension KrakeBeaconProtocol
{
    public func urlReference()-> FieldExternalProtocol?
    {
        return value(forKey: "url") as? FieldExternalProtocol
    }
    
    public func termPart() -> TermPartProtocol?
    {
        return nil
    }
}

