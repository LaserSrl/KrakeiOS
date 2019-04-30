//
//  UIButton+Krake.swift
//  Krake
//
//  Created by Patrick on 03/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import UIKit

public extension UIButton
{
    func alignImageAndTitleVertically(_ padding: CGFloat = 0.0) {
        if let iv = self.imageView,
            let lbl = self.titleLabel {

            lbl.sizeToFit()
            let imageSize = iv.image?.size ?? .zero
            let titleSize = lbl.bounds.size
            let totalHeight = imageSize.height + titleSize.height + padding
            
            self.contentEdgeInsets = UIEdgeInsets(top: titleSize.height, left: 0, bottom: titleSize.height, right: 0)
            self.imageEdgeInsets = UIEdgeInsets(
                top: -(totalHeight - imageSize.height),
                left: 0,
                bottom: 0,
                right: -titleSize.width
            )
            
            self.titleEdgeInsets = UIEdgeInsets(
                top: 0,
                left: -imageSize.width,
                bottom: -(totalHeight - titleSize.height),
                right: 0
            )
        }
    }
    
}
