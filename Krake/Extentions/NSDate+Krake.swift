//
//  NSDate.swift
//  Pods
//
//  Created by Patrick on 26/07/16.
//
//

import Foundation

public extension Date {
    
    func stringFromDateTo(otherDate date: Date?) -> String{
        var text: String
        let parsedDates = self.getReadableDate(otherDate: date)
        
        if parsedDates.time2 == nil && parsedDates.time3 == nil {
            text = String(format: "on".localizedString(), parsedDates.time1)
        } else if parsedDates.time2 != nil && parsedDates.time3 == nil {
            text = String(format: "fromToDate".localizedString(), parsedDates.time1, parsedDates.time2!)
        } else {
            text = "\(parsedDates.time1) - "
                .appendingFormat("fromToHour".localizedString(), parsedDates.time2!, parsedDates.time3!)
        }
        if !text.isEmpty {
            var result = text
            result.replaceSubrange(text.startIndex...text.startIndex, with: String(text[text.startIndex]).uppercased())
            return result
        }
        return text
    }
    
    func getReadableDate(otherDate date: Date?) -> (time1: String, time2: String?, time3: String?) {
        let dFormatter = DateFormatter()
        if date == nil || self.timeIntervalSince(date!) == 0 {
            dFormatter.dateStyle = .full
            return (dFormatter.string(from: self), nil, nil)
        } else {
            if (Calendar.current as NSCalendar).components(.year, from: self).year != (Calendar.current as NSCalendar).components(.year, from: date!).year {
                dFormatter.dateStyle = .long
                return (dFormatter.string(from: self), dFormatter.string(from: date!), nil)
            } else if (Calendar.current as NSCalendar).compare(self, to: date!, toUnitGranularity: .month) != .orderedSame {
                let daFormatter = DateFormatter()
                daFormatter.dateFormat = "dd MMMM"
                dFormatter.dateStyle = .long
                return (daFormatter.string(from: self), dFormatter.string(from: date!), nil)
            }else if (Calendar.current as NSCalendar).compare(self, to: date!, toUnitGranularity: .day) != .orderedSame {
                let daFormatter = DateFormatter()
                daFormatter.dateFormat = "dd"
                dFormatter.dateStyle = .long
                return (daFormatter.string(from: self), dFormatter.string(from: date!), nil)
            }else{
                dFormatter.dateStyle = .full
                let tFormatter = DateFormatter()
                tFormatter.timeStyle = .short
                return (dFormatter.string(from: self), tFormatter.string(from: self), tFormatter.string(from: date!))
            }
        }
    }
    
}
