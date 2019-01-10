//
//  PaddingLabel.swift
//  Krake
//
//  Created by Patrick on 13/10/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import UIKit

open class KPaddingLabel: UILabel {
    
    @IBInspectable open var topInset: CGFloat = 5.0
    @IBInspectable open var bottomInset: CGFloat = 5.0
    @IBInspectable open var leftInset: CGFloat = 7.0
    @IBInspectable open var rightInset: CGFloat = 7.0
    
    override open func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        
        #if swift(>=4.2)
        super.drawText(in: rect.inset(by: insets))
        #else
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        #endif
    }
    
    override open var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
}

//MARK: - Deprecated
@available(*, deprecated: 1.0, renamed: "KPaddingLabel")
open class PaddingLabel: KPaddingLabel {}
