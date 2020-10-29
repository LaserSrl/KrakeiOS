//
//  KDurationFormatter.swift
//  Krake
//
//  Created by joel on 08/05/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import UIKit

public class KDurationFormatter: Formatter {


    public func string(from duration: Double) -> String {

        var minutes = Int(duration / 60)

        let hours = minutes / 60

        minutes = minutes % 60

        var format = ""

        if  hours > 0{
            format.append(String(hours))
            format.append(KLocalization.Date.hour)
        }

        if  minutes > 0{
            if !format.isEmpty {
                format.append(" ")
            }
            format.append(String(format: "%d %@", minutes, KLocalization.Date.minute))
        }

        return format

    }
}
