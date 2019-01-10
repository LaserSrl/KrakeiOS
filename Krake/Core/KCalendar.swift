//
//  Calendar.swift
//  OrchardCore
//
//  Created by Patrick on 05/08/15.
//  Copyright (c) 2015 Laser Group srl. All rights reserved.
//

import Foundation
import EventKit
import EventKitUI

public struct CalendarInfo {
    public var title : String
    public var abstract : String?
    public var location : String?
    public var fromDate : Date
    public var toDate : Date
    public var url : URL?
    
    @available(*, deprecated, renamed: "init(title:abstract:location:url:fromDate:toDate:)")
    public init(title : String, abstract : String? = nil, subtitle : String? = nil, url : URL? = nil, fromDate : Date, toDate : Date)
    {
        self.init(title: title, abstract: abstract, location: subtitle, url: url, fromDate: fromDate, toDate: toDate)
    }
    
    public init(title : String, abstract : String? = nil, location : String? = nil, url : URL? = nil, fromDate : Date, toDate : Date)
    {
        self.title = title
        self.abstract = abstract
        self.location = location
        self.url = url
        self.fromDate = fromDate
        self.toDate = toDate
    }
}

open class KCalendar : NSObject, EKEventEditViewDelegate {
    
    var infoCal : CalendarInfo!
    
    open func presentAddToCalendar(_ info : CalendarInfo,  nav : UIViewController? = UIApplication.shared.delegate?.window??.rootViewController){
        let store = EKEventStore()
        store.requestAccess(to: EKEntityType.event, completion: { [weak self](granted : Bool, error : Optional<Error>!) -> Void in
            let event = EKEvent(eventStore: store)
            event.title = info.title
            event.location = info.location;
            var fromDate : Date! = info.fromDate;
            if abs(fromDate.timeIntervalSince(info.toDate))>=(60*60*24)
            {
                event.isAllDay = true
                let calendar = Calendar.current
                var completeComponents = (calendar as NSCalendar).components(NSCalendar.Unit(rawValue: (NSCalendar.Unit.day.rawValue|NSCalendar.Unit.month.rawValue|NSCalendar.Unit.year.rawValue)), from: Date())
                let timeComponents = (calendar as NSCalendar).components(NSCalendar.Unit(rawValue: (NSCalendar.Unit.hour.rawValue|NSCalendar.Unit.minute.rawValue)), from: info.fromDate)
                
                completeComponents.hour = timeComponents.hour;
                completeComponents.minute = timeComponents.minute;
                fromDate = calendar.date(from: completeComponents)
            }
            event.startDate = fromDate;
            event.endDate = info.toDate
            if info.toDate.timeIntervalSince(fromDate) == 0 {
                event.isAllDay = true
            }
            event.calendar = store.defaultCalendarForNewEvents
            event.notes = info.abstract
            event.url = info.url
            let eventVC = EKEventEditViewController()
            eventVC.event = event
            eventVC.eventStore = store
            self?.infoCal = info
            eventVC.editViewDelegate = self
            KTheme.current.applyTheme(toNavigationBar: eventVC.navigationBar, style: .default)
            DispatchQueue.main.async(execute: {
                nav?.present(eventVC, animated: true, completion: nil)
            })
        })
    }
    
    
    open func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
        
        if action == EKEventEditViewAction.saved {
            do{
                try controller.eventStore.save(controller.event!, span: EKSpan.thisEvent, commit: true)
                KMessageManager.showMessage("event_added".localizedString(), type: .success)
            }catch {
                KMessageManager.showMessage((error as NSError).localizedDescription, type: .error)
            }
        }
    }
}
