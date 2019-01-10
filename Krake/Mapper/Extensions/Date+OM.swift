//
//  NSDate+OM.swift
//  Pods
//
//  Created by Patrick on 03/09/16.
//
//

import Foundation
import NTPKit

extension Date{
    
    fileprivate static let server = NTPServer(hostname: "ntp1.inrim.it")
    
    public static func networkTime() -> Date{
        do{
            let date = try server.date()
            return date
        }catch let error{
            KLog(type: .error, "NTP %@", error.localizedDescription)
        }
        return Date()
    }
    
    public static func networkTimeSync() {
        do{
            try server.sync()
        }catch let error{
            KLog(type: .error, "NTP %@", error.localizedDescription)
        }
    }

    public func isToday() -> Bool
    {
        let caledar = NSCalendar.current

        let day = caledar.dateComponents([.day, .month, .year], from: self)
        let today = caledar.dateComponents([.day,.month, .year], from: Date())

        return day == today
    }
}
