//
//  OCDateFilterManager.swift
//  OrchardCore
//
//  Created by joel on 09/03/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import LaserCalendarTimeSelector

public struct KDateFilterOptions
{
    /// Use .default for a default struct settings, by default
    /// - stringDateFormat is dd/MM/yyyy
    /// - selectionType is .single
    /// - enableHistorySelection is false
    /// - enableFutureSelection is true
    /// - dateRangeFromDate is nil (if setted the enableHistorySelection and enableFutureSelection are not considered)
    /// - dateRangeToDate is nil (if setted the enableHistorySelection and enableFutureSelection are not considered)
    public static let `default` = KDateFilterOptions()
    
    public var stringDateFormat: String! = "yyyy/MM/dd"
    public var selectionType: KDatePickerSelectionType = .single
    public var dateRangeFromDate: Date? = nil
    public var dateRangeToDate: Date? = nil
    public var enableHistorySelection: Bool = false
    public var enableFutureSelection: Bool = true
    
    public var dateTimeSelector: KDateTimeSelector = KTheme.dateTimeSelector
    
    public init(stringDateFormat: String! = "yyyy/MM/dd",
         selectionType: KDatePickerSelectionType = .single,
         enableHistorySelection: Bool = false,
         enableFutureSelection: Bool = true,
         dateRangeFromDate: Date? = nil,
         dateRangeToDate: Date? = nil)
    {
        self.stringDateFormat = stringDateFormat
        self.selectionType = selectionType
        self.dateRangeFromDate = dateRangeFromDate
        self.dateRangeToDate = dateRangeToDate
        self.enableHistorySelection = enableHistorySelection
        self.enableFutureSelection = enableFutureSelection
    }
}

open class KDateFilterManager: NSObject, WWCalendarTimeSelectorProtocol {

    fileprivate let datePicker : WWCalendarTimeSelector
    open var selectedDates: [Date]! = [Date()]{
        didSet{
            dateButtonUpdate()
        }
    }
    weak var delegate: KDateFilterManagerDelegate?
    public let serviceDateFormatter : DateFormatter
    fileprivate let subtitleDateFormatter : DateFormatter
    fileprivate let subtitleShortDateFormatter : DateFormatter
    fileprivate var dateButton: UIButton?
    public let dateFilterOptions: KDateFilterOptions!
    
    init(delegate _delegate: KDateFilterManagerDelegate!,
         dateFilterOptions: KDateFilterOptions = KDateFilterOptions())
    {
        self.dateFilterOptions = dateFilterOptions
        datePicker = WWCalendarTimeSelector.instantiate()
        serviceDateFormatter = DateFormatter()
        serviceDateFormatter.dateFormat = dateFilterOptions.stringDateFormat
        subtitleDateFormatter = DateFormatter()
        subtitleDateFormatter.dateFormat = "dd MMM yy"
        subtitleShortDateFormatter = DateFormatter()
        subtitleShortDateFormatter.dateFormat = "dd MMM yy"
        super.init()
        delegate = _delegate

        datePicker.delegate = self
        
        let options = !dateFilterOptions.enableHistorySelection ? .future : !dateFilterOptions.enableFutureSelection ? .past : WWCalendarTimeSelectorEnabledDateRange()
        options.setStartDate(dateFilterOptions.dateRangeFromDate)
        options.setEndDate(dateFilterOptions.dateRangeToDate)
        datePicker.optionRangeOfEnabledDates = options
        datePicker.optionStyles.showTime(false)
        datePicker.optionSelectionType = WWCalendarTimeSelectorSelection(rawValue: dateFilterOptions.selectionType.rawValue) ?? .single
        
        datePicker.configureSelector(from: dateFilterOptions.dateTimeSelector)
    }
    
    func generateAndSaveDateTextOnButton(_ button: UIButton)
    {
        dateButton = button
        dateButtonUpdate()
    }

    func showDatePicker(_ controller: UIViewController)
    {
        datePicker.optionCurrentDateRange = WWCalendarTimeSelectorDateRange()
        if let fromDate = selectedDates.first
        {
            datePicker.optionCurrentDateRange.setStartDate(fromDate)
        }
        if let toDate = selectedDates.last
        {
            datePicker.optionCurrentDateRange.setEndDate(toDate)
        }
        controller.present(datePicker, animated: true, completion: nil)
    }

    public func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date)
    {
        selectedDates = [date]
        dateButtonUpdate()
        delegate?.dateFilterManager(self, selectedDates: selectedDates)
    }
    
    public func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, dates: [Date])
    {
        selectedDates = dates.sorted { (first: Date, second: Date) -> Bool in
            return first.timeIntervalSince(second) < 0.0
        }
        dateButtonUpdate()
        delegate?.dateFilterManager(self, selectedDates: selectedDates)
    }

    func dateButtonUpdate(){
        if abs(selectedDates.first!.timeIntervalSince(selectedDates.last!)) < 60 {
            dateButton?.setTitle(subtitleDateFormatter.string(from: selectedDates.first!), for: .normal)
        }else{
            dateButton?.setTitle(subtitleShortDateFormatter.string(from: selectedDates.first!) + "\n" + subtitleShortDateFormatter.string(from: selectedDates.last!), for: .normal)
        }
    }

}

public protocol KDateFilterManagerDelegate : NSObjectProtocol {
    func dateFilterManager(_ _manager: KDateFilterManager, selectedDates: [Date]);
}
