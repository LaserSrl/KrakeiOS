//
//  KTitleLabel.swift
//  Krake
//
//  Created by Marco Zanino on 01/03/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import UIKit

open class KTitleLabel: UILabel, KDetailViewProtocol {

    public weak var detailPresenter: KDetailPresenter?
    public var detailObject: AnyObject? {
        didSet {
            text = (detailObject as? ContentItem)?.titlePartTitle
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
		KTheme.current.applyTheme(toLabel: self, style: .title)

        numberOfLines = 2
    }

}
