//
//  KDateTimeSelector.swift
//  Krake
//
//  Created by Patrick on 30/05/18.
//

import Foundation

//MARK: - KDateTimeSelector

public struct KDateTimeSelector
{
    public var tintColor: UIColor
    
    /// Set font color for title area
    public var topPanelFontColor: UIColor? = nil
    /// Set background color for title area
    public var topPanelBackgroundColor: UIColor? = nil
    /// Set font color for header panel
    public var selectorPanelFontColor: UIColor? = nil
    /// Set background color for header panel
    public var selectorPanelBackgroundColor: UIColor? = nil
    /// Set font color for selected dates
    public var mainPanelHighlightFontColor: UIColor? = nil
    /// Set background color for selected dates
    public var mainPanelHighlightBackgroundColor: UIColor? = nil
    /// Set font color for date in calendar
    public var mainPanelFontColor: UIColor? = nil
    /// Set background color for calendar
    public var mainPanelBackgroundColor: UIColor? = nil
    /// Set font color for Done & Cancel button
    public var bottomPanelFontColor: UIColor? = nil
    {
        didSet{
            bottomPanelDoneFontColor = bottomPanelFontColor
            bottomPanelCancelFontColor = bottomPanelFontColor
        }
    }
    /// Set font color for Cancel button
    public var bottomPanelCancelFontColor: UIColor? = nil
    /// Set font color for Done button
    public var bottomPanelDoneFontColor: UIColor? = nil
    /// Set background color for Done & Cancel footer area
    public var bottomPanelBackgroundColor: UIColor? = nil
    
    public var topPanelTitle: String? = nil
    public var buttonTitleDone: String = KLocalization.Commons.done
    public var buttonTitleCancel: String = KLocalization.Commons.cancel
    public var labelTextRangeTo: String = KLocalization.Date.toDate
    
    public init(tintColor: UIColor = KTheme.current.color(.tint)) {
        self.tintColor = tintColor
    }
}

extension KTheme
{
    public static var dateTimeSelector: KDateTimeSelector = KDateTimeSelector()
}

//MARK: - KDatePickerSelection

public enum KDatePickerSelectionType: Int
{
    case single
    case multi
    case range
}
