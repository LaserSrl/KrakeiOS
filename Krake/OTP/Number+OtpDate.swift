//
//  Number+OtpDate.swift
//  Krake
//
//  Created by joel on 24/05/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import Foundation

extension NSNumber {

    static private let calendar = Calendar(identifier: .gregorian)

    func otpSecondsToDate() -> Date? {
        guard let today = NSNumber.calendar.date(
            from: NSNumber.calendar.dateComponents([.year, .month, .day], from: Date())) else {
                return nil
        }

        return Date(timeInterval: TimeInterval(intValue), since: today)
    }
}
