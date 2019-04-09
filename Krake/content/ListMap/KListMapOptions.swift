//
//  KListMapOptions.swift
//  Krake
//
//  Created by Patrick on 22/05/18.
//

import Foundation
import MapKit

public struct KMapOptions
{
    /// Use .default for a default struct settings, by default
    /// - useCluser is true
    public static let `default` = KMapOptions()
    
    public var useCluster: Bool
    
    public var defaultCenterOfMap: MKMapRect = KMapRectNull
    
    public init(useCluster: Bool = true) {
        self.useCluster = useCluster
    }
}

public struct KListMapData
{
    public var endPoint: String? = nil
    public var loginRequired: Bool = false
    public var elements: NSOrderedSet? = nil
    public var elementsSortOrder: ((Any, Any) -> ComparisonResult)? = nil
    public var pageSize: UInt = 25
    public var extras: [String : Any] = [:]
    
    public init(endPoint: String? = nil,
                loginRequired: Bool = false,
                elements: NSOrderedSet? = nil,
                extras: [String : Any] = [:])
    {
        self.endPoint = endPoint
        self.loginRequired = loginRequired
        self.elements = elements
        self.extras = extras
    }
}

public struct KListMapOptions
{
    @available(*, deprecated, renamed: "data.endPoint")
    public var endPoint: String?
    {
        set
        {
            data.endPoint = newValue
        }
        get
        {
            return data.endPoint
        }
    }
    
    @available(*, deprecated, renamed: "data.loginRequired")
    public var loginRequired: Bool
    {
        set
        {
            data.loginRequired = newValue
        }
        get
        {
            return data.loginRequired
        }
    }
    
    @available(*, deprecated, message: "mapOptions = .default")
    public var isMapVisible: Bool
    {
        set
        {
            mapOptions = newValue == true && mapOptions == nil ?  KMapOptions.default : mapOptions
        }
        get
        {
            return mapOptions != nil
        }
    }
    
    @available(*, deprecated, renamed: "mapOptions.useCluster")
    public var useCluster: Bool
    {
        set
        {
            mapOptions = mapOptions == nil ?  KMapOptions.default : mapOptions
            mapOptions?.useCluster = newValue
        }
        get
        {
            return mapOptions?.useCluster ?? false
        }
    }
    
    @available(*, deprecated, message: "searchFilterOptions = .default")
    public var isSearchVisible: Bool
    {
        set
        {
            searchFilterOptions = newValue == true ?  KSearchFilterOptions.default : nil
        }
        get
        {
            return searchFilterOptions != nil
        }
    }
    
    @available(*, deprecated, message: "dateFilterOptions = .default")
    public var isCalendarVisible: Bool
    {
        set
        {
            dateFilterOptions = newValue == true && dateFilterOptions == nil ?  KDateFilterOptions.default : dateFilterOptions
        }
        get
        {
            return dateFilterOptions != nil
        }
    }
    
    @available(*, deprecated, renamed: "dateFilterOptions.stringDateFormat")
    public var stringDateFormat: String!
    {
        set
        {
            dateFilterOptions = dateFilterOptions ?? KDateFilterOptions.default
            dateFilterOptions?.stringDateFormat = newValue
        }
        get
        {
            return dateFilterOptions?.stringDateFormat ?? ""
        }
    }
    
    @available(*, deprecated, renamed: "dateFilterOptions.selectionType")
    public var selectionType: KDatePickerSelectionType!
    {
        set
        {
            dateFilterOptions = dateFilterOptions ?? KDateFilterOptions.default
            dateFilterOptions?.selectionType = newValue
        }
        get
        {
            return dateFilterOptions?.selectionType ?? .single
        }
    }
    
    public enum ToggleButtonPosition
    {
        case bottomLeading
        case bottomCenter
        case bottomTrailing
    }

    public var supplementaryHeaderView: UIView? = nil
    public var analyticsExtras: [String: Any]? = nil
    public var tabViewHeight: CGFloat! = 44.0
    
    public var listMapDelegate: KListMapDelegate? = KDefaultListMapDelegate()
    public var detailDelegate: KDetailPresenterDelegate? = nil
    
    public var data: KListMapData
    public var tabManagerOptions: KTabManagerOptions? = nil
    public var searchFilterOptions: KSearchFilterOptions? = nil
    public var dateFilterOptions: KDateFilterOptions? = nil
    public var mapOptions: KMapOptions? = nil
    
    public var toggleButtonPosition: ToggleButtonPosition = .bottomCenter
    
    @available(*, deprecated, renamed: "init(data:)")
    public init(endPoint: String? = nil,
                tabManagerOptions: KTabManagerOptions? = nil,
                loginRequired: Bool = false,
                elements: NSOrderedSet? = nil,
                extras: [String : Any]? = nil,
                listMapDelegate: KListMapDelegate? = KDefaultListMapDelegate(),
                isMapVisible: Bool = false,
                useCluster: Bool = true,
                isSearchVisible: Bool = true,
                filterableKeys: [String]! = ["titlePartTitle"],
                onlineSearch: Bool = false,
                isCalendarVisible: Bool = false,
                stringDateFormat: String? = "yyyy/MM/dd",
                selectionType: KDatePickerSelectionType = .single,
                tabViewHeight: CGFloat = 44.0,
                supplementaryHeaderView: UIView? = nil,
                detailDelegate: KDetailPresenterDelegate? = nil,
                elementsSortOrder: ((Any, Any) -> ComparisonResult)? = nil,
                analyticsExtras: [String: Any]? = nil)
    {
        
        var data = KListMapData(endPoint: endPoint, loginRequired: loginRequired, elements: elements, extras: extras ?? [:])
        data.elementsSortOrder = elementsSortOrder
        self.init(data: data)
        self.tabManagerOptions = tabManagerOptions
        self.mapOptions = isMapVisible ? KMapOptions(useCluster: useCluster) : nil
        self.searchFilterOptions = isSearchVisible ? KSearchFilterOptions(filterableKeys: filterableKeys, onlineSearch: onlineSearch) : nil
        self.dateFilterOptions = isCalendarVisible ? KDateFilterOptions(stringDateFormat: stringDateFormat, selectionType: selectionType) : nil
        self.listMapDelegate = listMapDelegate
        self.detailDelegate = detailDelegate
        self.supplementaryHeaderView = supplementaryHeaderView
        self.analyticsExtras = analyticsExtras
        self.tabViewHeight = tabViewHeight
    }
    
    public init(data: KListMapData!)
    {
        self.data = data
    }
    
}
