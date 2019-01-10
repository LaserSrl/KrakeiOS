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
        if let color = dateTimeSelector.mainPanelBackgroundColor
        {
            optionMainPanelBackgroundColor = color
        }
        if let color = dateTimeSelector.bottomPanelBackgroundColor
        {
            optionBottomPanelBackgroundColor = color
        }
        if let color = dateTimeSelector.topPanelFontColor
        {
            optionTopPanelFontColor = color
        }
        if let color = dateTimeSelector.topPanelBackgroundColor
        {
            optionTopPanelBackgroundColor = color
        }
        if let color = dateTimeSelector.selectorPanelBackgroundColor
        {
            optionSelectorPanelBackgroundColor = color
        }
        optionButtonTitleDone = dateTimeSelector.buttonTitleDone
        optionButtonTitleCancel = dateTimeSelector.buttonTitleCancel
        optionTopPanelTitle = dateTimeSelector.topPanelTitle
        optionLabelTextRangeTo = dateTimeSelector.labelTextRangeTo
    }
}
