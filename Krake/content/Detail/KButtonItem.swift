//
//  ButtonItem.swift
//  Krake
//
//  Created by joel on 21/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation

public struct KButtonItem{
    public var mediaUrl: String?
    public var title: String
    public var image: UIImage?
    public weak var target: AnyObject?
    public var selector: Selector?
    public var showTitle: Bool
    
    public init(title _title: String,
                      image _image: UIImage? = nil,
                            mediaUrl _mediaUrl: String? = nil,
                                     target _target: AnyObject? = nil,
                                            selector _selector: Selector? = nil,
                                                     showTitle _showTitle: Bool = false){
        title = _title
        image = _image
        mediaUrl = _mediaUrl
        target = _target
        selector = _selector
        showTitle = _showTitle
    }
}

@available(*, deprecated: 1.0, renamed: "KButtonItem")
public struct ButtonItem{
    public var mediaUrl: String?
    public var title: String
    public var image: UIImage?
    public weak var target: AnyObject?
    public var selector: Selector?
    public var showTitle: Bool
    
    public init(title _title: String,
                image _image: UIImage? = nil,
                mediaUrl _mediaUrl: String? = nil,
                target _target: AnyObject? = nil,
                selector _selector: Selector? = nil,
                showTitle _showTitle: Bool = false){
        title = _title
        image = _image
        mediaUrl = _mediaUrl
        target = _target
        selector = _selector
        showTitle = _showTitle
    }
}
