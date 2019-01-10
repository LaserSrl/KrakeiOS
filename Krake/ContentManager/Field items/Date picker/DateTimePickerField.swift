//
//  DatePickerField.swift
//  Krake
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import UIKit
import LaserCalendarTimeSelector

/// DateTimePickerField is a SingleValue Field Item 
open class DateTimePickerField: NSObject, SingleValueFieldItem, WWCalendarTimeSelectorProtocol {
    public static let DefaultRemoteDateFormat: String = "yyyy-MM-dd'T'HH:mm:ss"
    public static let DefaultVisualDateFormat: String = "dd/MM/yyyy"
    public static let DefaultVisualDateTimeFormat: String = "dd/MM/yyyy HH:mm"

    open var key: String
    open var coreDataKeyPath: String?
    open var placeholder: String?
    open var required: Bool
    public var dateTimeSelectorTheme: KDateTimeSelector! = KTheme.dateTimeSelector
    public let disableFutureSelection: Bool
    public let disableHistorySelection: Bool
    public let showTime: Bool
    
    open var view: UIView? {
        return dateView
    }
    
    public var visibleOnly: Bool = false{
        didSet{
            dateView.openCalendarButton.isEnabled = !visibleOnly
        }
    }
    
    fileprivate lazy var dateView: TakeInfoDateView = {
        let view = TakeInfoDateView()
        view.descriptionLabel.text = self.fieldTitle + (self.required ? " *" : "")
        view.dateLabel.text = self.placeholder
        view.openCalendarButton
            .addTarget(self,
                       action: #selector(DateTimePickerField.openCalendar),
                       for: .touchUpInside)
        KTheme.current.applyTheme(toButton: view.openCalendarButton, style: .default)
        return view
    }()
    
    weak open var delegate: FieldItemDelegate?
    
    fileprivate let fieldTitle: String
    
    // MARK: - Date string formats
    
    fileprivate let remoteDateFormat: String
    fileprivate let visualDateFormat: String
    fileprivate var dateSelected : Date? = Date()
    
    // MARK: - Date formatters

    lazy var remoteDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.remoteDateFormat
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()

    lazy var visualDateFormatter: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = self.visualDateFormat
                return dateFormatter
            }()

    
    // MARK: - Date picker controller
    
    lazy var datePickerViewController: WWCalendarTimeSelector = {
        let dp = WWCalendarTimeSelector.instantiate()
        dp.delegate = self
        dp.configureSelector(from: dateTimeSelectorTheme)
        let options: WWCalendarTimeSelectorEnabledDateRange = disableHistorySelection ? WWCalendarTimeSelectorEnabledDateRange.future : disableFutureSelection ? WWCalendarTimeSelectorEnabledDateRange.past : WWCalendarTimeSelectorEnabledDateRange()
        dp.optionRangeOfEnabledDates = options
        dp.optionStyles.showTime(showTime)
        dp.optionSelectionType = .single
        return dp
    }()
    
    // MARK: - Initializers
    
    init(key: String,
         required: Bool,
         descriptionText: String,
         remoteDateFormat: String = DefaultRemoteDateFormat,
         visualDateFormat: String = DefaultVisualDateFormat,
         disableHistorySelection: Bool = true,
         disableFutureSelection: Bool = false,
         showTime: Bool = false) {
        
        self.key = key
        self.required = required
        self.fieldTitle = descriptionText
        self.remoteDateFormat = remoteDateFormat
        self.visualDateFormat = (showTime && visualDateFormat == DateTimePickerField.DefaultVisualDateFormat) ? DateTimePickerField.DefaultVisualDateTimeFormat : visualDateFormat
        self.disableFutureSelection = disableFutureSelection
        self.disableHistorySelection = disableHistorySelection
        self.showTime = showTime
    }
    
    // MARK: - Field item implementation
    
    open func setInitialValue(_ value: Any?) {

        if let dateString = value as? String {
            // Creating the date from the received value.
            if var
                storedDate = remoteDateFormatter.date(from: dateString) {
                if Calendar.current.component(.year, from: storedDate) < 1900
                {
                    storedDate = Date() // Orchard sends 0001-12-01, iOS translates as 0002-01-01 so it is not a valid start date
                }
                dateSelected = storedDate

            } else {
                KLog(type: .warning, "Cannot generate a valid date starting from the string %@. " +
                    "The view related to the field with key %@ will not be restored.", dateString, key)
            }
        } else if let date = value as? Date {
            dateSelected = date
        }
        
        if let dateSelected = dateSelected {
            dateView.dateLabel.text = visualDateFormatter.string(from: dateSelected)
            datePickerViewController.optionCurrentDate = dateSelected
        }
    }

    open func currentValue() -> Any?
    {
        if let dateSelected = dateSelected
        {
            return remoteDateFormatter.string(from: dateSelected)
        }
        return nil
    }
    
    open func jsonValue(fromValue value: Any?) -> Any?
    {
        if value == nil
        {
            return nil
        }
        else
        {
            if value is NSDate
            {
                return remoteDateFormatter.string(from: value as! Date) as AnyObject?
            }
            else if value is String
            {
                return value
            }
            return nil
        }
    }
    
    open func isValueChanged(_ oldValue: Any?) -> Bool
    {
        let currentDateString = currentValue() as? String
        if oldValue == nil
        {
            return currentDateString != nil
        }
        else
        {
            if let oldString = oldValue as? String
            {
                if currentDateString != nil
                {
                    return oldString != currentDateString
                }
            }
            return false
        }
    }
    
    // MARK: - Calendar presentation
    
    @objc func openCalendar()
    {
        let presentingViewController: UIViewController?
        if delegate is UIViewController
        {
            presentingViewController = delegate as? UIViewController
        }
        else
        {
            presentingViewController = UIApplication.shared.keyWindow?.rootViewController
        }
        
        presentingViewController?.view.endEditing(true)
        presentingViewController?.present(datePickerViewController, animated: true, completion: nil)
    }
    
    // MARK: - Date picker delegate
    public func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date)
    {
        dateSelected = !showTime ? date.beginningOfDay.addingTimeInterval(60*60*12) : date //FIXME: Added 12 hour to fix orchard timezone
        if let dateSelected = dateSelected
        {
            delegate?.valueChanged(remoteDateFormatter.string(from: dateSelected) as AnyObject?, forField: self)
            dateView.dateLabel.text = visualDateFormatter.string(from: dateSelected)
        }
    }
    
    public func WWCalendarTimeSelectorCancel(_ selector: WWCalendarTimeSelector, date: Date) {
        if !required {
            dateSelected = nil
            dateView.dateLabel.text = nil
            delegate?.valueChanged(nil, forField: self)
        }
    }
    
}
