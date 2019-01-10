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
    public var topPanelFontColor: UIColor? = nil
    public var topPanelBackgroundColor: UIColor? = nil
    public var bottomPanelBackgroundColor: UIColor? = nil
    public var mainPanelBackgroundColor: UIColor? = nil
    public var selectorPanelBackgroundColor: UIColor? = nil
    
    public var topPanelTitle: String? = nil
    public var buttonTitleDone: String = "Done".localizedString()
    public var buttonTitleCancel: String = "Cancel".localizedString()
    public var labelTextRangeTo: String = "To-date".localizedString()
    
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
