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

    open func covert(calendarInfo info: CalendarInfo, to event: EKEvent) {
        event.title = info.title
        event.location = info.location;
        let fromDate : Date! = info.fromDate;
        event.isAllDay = abs(fromDate.timeIntervalSince(info.toDate))>=(60*60*24)
        event.startDate = fromDate;
        event.endDate = info.toDate
        if info.toDate.timeIntervalSince(fromDate) == 0 {
            event.isAllDay = true
        }
        event.notes = info.abstract
        event.url = info.url
    }

    open func presentAddToCalendar(_ info : CalendarInfo,  nav : UIViewController? = UIApplication.shared.delegate?.window??.rootViewController){
        let store = EKEventStore()
        store.requestAccess(to: EKEntityType.event, completion: { [weak self](granted : Bool, error : Optional<Error>!) -> Void in
            let event = EKEvent(eventStore: store)

            event.calendar = store.defaultCalendarForNewEvents
            self?.covert(calendarInfo: info, to: event)
            DispatchQueue.main.async(execute: {
                let eventVC = EKEventEditViewController()
                if UIDevice.current.userInterfaceIdiom == .pad {
                    eventVC.modalPresentationStyle = .pageSheet
                }
                eventVC.event = event
                eventVC.eventStore = store
                self?.infoCal = info
                eventVC.editViewDelegate = self
                 KTheme.current.applyTheme(toNavigationBar: eventVC.navigationBar, style: .default)
                nav?.present(eventVC, animated: true, completion: nil)
            })
        })
    }
    
    
    open func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
        
        if action == EKEventEditViewAction.saved {
            do{
                try controller.eventStore.save(controller.event!, span: EKSpan.thisEvent, commit: true)
                KMessageManager.showMessage(KLocalization.Calendar.eventAdded, type: .success)
            }catch {
                KMessageManager.showMessage((error as NSError).localizedDescription, type: .error)
            }
        }
    }
}
