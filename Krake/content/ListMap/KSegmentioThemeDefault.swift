//
//  DefaultSegmentioOptions.swift
//  Pods
//
//  Created by Patrick on 02/02/17.
//
//

import Foundation
import Segmentio

public protocol KSegmentioTheme: NSObjectProtocol
{
    var style : SegmentioStyle!{get}
    var segmentioOptions: SegmentioOptions!{get}
}

extension KTheme
{
    public static var segmentio: KSegmentioTheme = KSegmentioThemeDefault(.onlyLabel)
}

open class KSegmentioThemeDefault: NSObject, KSegmentioTheme
{
    
    public var style: SegmentioStyle!
    public var segmentioOptions: SegmentioOptions!

    public init(_ style: SegmentioStyle)
    {
        super.init()
        self.style = style
        segmentioOptions = createSegmentioOptions()
    }

    open func createSegmentioOptions() -> SegmentioOptions
    {
        return SegmentioOptions(
            backgroundColor: KTheme.current.color(.tint),
            segmentPosition: .dynamic,
            scrollEnabled: true,
            indicatorOptions: segmentioIndicatorOptions(),
            horizontalSeparatorOptions: segmentioHorizontalSeparatorOptions(),
            verticalSeparatorOptions: segmentioVerticalSeparatorOptions(),
            imageContentMode: KViewContentMode.scaleAspectFit,
            labelTextAlignment: .center,
            labelTextNumberOfLines: 0,
            segmentStates: segmentioStates(),
            animationDuration: 0.3
        )
    }
    
    open func segmentioStates() -> SegmentioStates
    {
        let font = UIFont.systemFont(ofSize: 13.0)
        return SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: font,
                titleTextColor: KTheme.current.color(.textTint)
            ),
            selectedState: SegmentioState(
                backgroundColor: KTheme.current.color(.textTint).withAlphaComponent(0.3),
                titleFont: font,
                titleTextColor: KTheme.current.color(.textTint)
            ),
            highlightedState: SegmentioState(
                backgroundColor: .clear,
                titleFont: font,
                titleTextColor: KTheme.current.color(.textTint)
            )
        )
    }
    
    open func segmentioIndicatorOptions() -> SegmentioIndicatorOptions
    {
        return SegmentioIndicatorOptions(
            type: .bottom,
            ratio: 1,
            height: 5,
            color: KTheme.current.color(.textTint)
        )
    }
    
    open func segmentioHorizontalSeparatorOptions() -> SegmentioHorizontalSeparatorOptions
    {
        return SegmentioHorizontalSeparatorOptions(
            type: .bottom,
            height: 1,
            color: KTheme.current.color(.textTint).withAlphaComponent(0.3)
        )
    }
    
    open func segmentioVerticalSeparatorOptions() -> SegmentioVerticalSeparatorOptions
    {
        return SegmentioVerticalSeparatorOptions(
            ratio: 1,
            color: KTheme.current.color(.textTint).withAlphaComponent(0.3)
        )
    }
}

//MARK: - Deprecated

@available(*, deprecated: 1.0, renamed: "KSegmentioTheme")
public protocol SegmentioTheme: KSegmentioTheme{}

@available(*, deprecated: 1.0, renamed: "KSegmentioThemeDefault")
open class DefaultSegmentioOptions: KSegmentioThemeDefault{}
