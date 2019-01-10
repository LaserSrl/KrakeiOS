//
//  KrakeResolutionAction.swift
//  Krake
//
//  Created by Patrick on 30/08/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

open class KResolutionAction: NSObject
{
    public static let userHaveToLogin: Int = 1000
    public static let userHaveToAcceptPolicy: Int = 3000
    public static let inProgress: Int = 4001
    public static let uploadNeverStarted: Int = 4002
    public static let finishingErrors: Int = 4003
    public static let retry: Int = 5001
}
