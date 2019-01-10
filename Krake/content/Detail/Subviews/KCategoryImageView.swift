//
//  KCategoryImageView.swift
//  Krake
//
//  Created by Marco Zanino on 01/03/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import UIKit

open class KCategoryImageView: UIImageView, KDetailViewProtocol {

    public weak var detailPresenter: KDetailPresenter?
    public var detailObject: AnyObject? {
        didSet {
            if let termIcon = ((detailObject as? ContentItemWithCategories)?
                .categoriaTerms?
                .firstObject as? TermPartProtocol)?
                .iconMediaParts?
                .firstObject {

                setImage(
                    media: termIcon,
                    placeholderImage: KTheme.current.placeholder(.category),
                    options: KMediaImageLoadOptions(
                        size: CGSize(width: 300, height: 300),
                        mode: .Pan,
                        alignement: .MiddleCenter),
                    completed: nil)

                hiddenAnimated = false
            } else {
                hiddenAnimated = true
            }
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        KTheme.current.applyTheme(toImageView: self, style: .termPart)
    }

}
