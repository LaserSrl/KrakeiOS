//
//  WWCalendarTimeSelector+Krake.swift
//  Krake
//
//  Created by Patrick on 30/05/18.
//

import Foundation
import LaserCalendarTimeSelector

extension WWCalendarTimeSelector
{
    public func configureSelector(from dateTimeSelector: KDateTimeSelector)
    {
        optionMultipleSelectionGrouping = .linkedBalls
        optionButtonShowCancel = true
        
        optionTintColor = dateTimeSelector.tintColor
        
        if let color = dateTimeSelector.topPanelBackgroundColor
        {
            optionTopPanelBackgroundColor = color
        }
        if let color = dateTimeSelector.topPanelFontColor
        {
            optionTopPanelFontColor = color
        }
        
        if let color = dateTimeSelector.selectorPanelBackgroundColor
        {
            optionSelectorPanelBackgroundColor = color
        }
        if let color = dateTimeSelector.selectorPanelFontColor
        {
            optionSelectorPanelFontColorDate = color.withAlphaComponent(0.5)
            optionSelectorPanelFontColorTime = color.withAlphaComponent(0.5)
            optionSelectorPanelFontColorYear = color.withAlphaComponent(0.5)
            optionSelectorPanelFontColorMonth = color.withAlphaComponent(0.5)
            optionSelectorPanelFontColorDateHighlight = color
            optionSelectorPanelFontColorTimeHighlight = color
            optionSelectorPanelFontColorYearHighlight = color
            optionSelectorPanelFontColorMonthHighlight = color
            optionSelectorPanelFontColorMultipleSelection = color.withAlphaComponent(0.5)
            optionSelectorPanelFontColorMultipleSelectionHighlight = color
        }
        
        if let color = dateTimeSelector.mainPanelBackgroundColor
        {
            optionMainPanelBackgroundColor = color
        }
        if let color = dateTimeSelector.mainPanelFontColor
        {
            optionCalendarFontColorMonth = color
            optionCalendarFontColorDays = color
            optionCalendarFontColorToday = color
            optionCalendarFontColorPastDates = color.withAlphaComponent(0.8)
            optionCalendarFontColorFutureDates = color.withAlphaComponent(0.8)
        }
        if let color = dateTimeSelector.mainPanelHighlightBackgroundColor
        {
            optionCalendarBackgroundColorTodayHighlight = color
            optionCalendarBackgroundColorPastDatesHighlight = color
            optionCalendarBackgroundColorFutureDatesHighlight = color
        }
        if let color = dateTimeSelector.mainPanelHighlightFontColor
        {
            optionCalendarFontColorTodayHighlight = color
            optionCalendarFontColorPastDatesHighlight = color
            optionCalendarFontColorFutureDatesHighlight = color
        }
        
        if let color = dateTimeSelector.bottomPanelBackgroundColor
        {
            optionBottomPanelBackgroundColor = color
        }
        if let color = dateTimeSelector.bottomPanelDoneFontColor
        {
            optionButtonFontColorDone = color
            optionButtonFontColorDoneHighlight = color.withAlphaComponent(0.25)
        }
        if let color = dateTimeSelector.bottomPanelCancelFontColor
        {
            optionButtonFontColorCancel = color
            optionButtonFontColorCancelHighlight = color.withAlphaComponent(0.25)
        }
        
        optionButtonTitleDone = dateTimeSelector.buttonTitleDone
        optionButtonTitleCancel = dateTimeSelector.buttonTitleCancel
        optionTopPanelTitle = dateTimeSelector.topPanelTitle
        optionLabelTextRangeTo = dateTimeSelector.labelTextRangeTo
    }
}
