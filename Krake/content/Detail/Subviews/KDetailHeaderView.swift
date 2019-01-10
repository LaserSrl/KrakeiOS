//
//  KDetailHeaderView.swift
//  Krake
//
//  Created by Marco Zanino on 01/03/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import UIKit

public extension UILayoutPriority{
    
    #if swift(>=4.0)
    public static func priority(_ value: Float) -> UILayoutPriority{
    return UILayoutPriority(rawValue: value)
    }
    #else
    public static func priority(_ value: Float) -> Float{
        return value
    }
    #endif
}

open class KDetailHeaderView: UIView, KDetailViewProtocol {

    public weak var detailPresenter: KDetailPresenter? {
        didSet {
            categoryImageView?.detailPresenter = detailPresenter
            titleLabel?.detailPresenter = detailPresenter
            categorySubtitleLabel?.detailPresenter = detailPresenter
            mapButton?.detailPresenter = detailPresenter
        }
    }
    public var detailObject: AnyObject? {
        didSet {
            categoryImageView?.detailObject = detailObject
            titleLabel?.detailObject = detailObject
            categorySubtitleLabel?.detailObject = detailObject
            mapButton?.detailObject = detailObject
        }
    }

    public private(set) weak var categoryImageView: KCategoryImageView?
    public private(set) weak var titleLabel: KTitleLabel?
    public private(set) weak var categorySubtitleLabel: KCategoryLabel?
    public private(set) weak var mapButton: KMapPlainButton?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        // Aggiunta dei margini di default della view.
        layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		// Creazione della stack view che conterrà tutte le subview.
        let mainStackView = UIStackView(frame: .zero)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.alignment = .center
        mainStackView.distribution = .fill
        mainStackView.axis = .horizontal
        mainStackView.spacing = 8.0
        // Aggiunta della stack view al layout.
        addSubview(mainStackView)
        // Aggiunta dei constraints per la stack view.
        addConstraints(
        	NSLayoutConstraint.constraints(
                withVisualFormat: "|-[sv]-|",
                options: .directionLeftToRight,
                metrics: nil,
                views: ["sv" : mainStackView]))
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[sv]-|",
                options: .directionLeftToRight,
                metrics: nil,
                views: ["sv" : mainStackView]))
        // Aggiunta dell'immagine della categoria.
        let categoryImageView = prepareCategoryImageView()
        categoryImageView.addConstraints([
        	categoryImageView.heightAnchor.constraint(equalTo: categoryImageView.widthAnchor),
        	categoryImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 60)
            ])
        categoryImageView
            .setContentCompressionResistancePriority(UILayoutPriority.priority(1000), for: .horizontal)
        categoryImageView
            .setContentHuggingPriority(UILayoutPriority.priority(251), for: .horizontal)
        mainStackView.addArrangedSubview(categoryImageView)
        self.categoryImageView = categoryImageView
		// Aggiunta delle label di titolo e descrizione della categoria.
        let titleLabel = prepareTitleLabel()
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority.priority(1000),
                                                           for: .vertical)
        self.titleLabel = titleLabel
        let categoryLabel = prepareCategorySubtitle()
        categoryLabel.setContentCompressionResistancePriority(UILayoutPriority.priority(1000),
                                                              for: .vertical)
        let categoryLabelHeight = categoryLabel.heightAnchor.constraint(equalToConstant: 20)
        categoryLabelHeight.priority = UILayoutPriority.priority(999)
        categoryLabel.addConstraint(categoryLabelHeight)
        categorySubtitleLabel = categoryLabel
        // Creazione del container di titolo e descrizione categoria.
		let titleSubtitleContainerView = UIStackView(arrangedSubviews: [titleLabel, categoryLabel])
		titleSubtitleContainerView.axis = .vertical
        titleSubtitleContainerView.alignment = .leading
        titleSubtitleContainerView.distribution = .fill
        titleSubtitleContainerView.spacing = 4.0
        titleSubtitleContainerView
            .setContentCompressionResistancePriority(UILayoutPriority.priority(1000), for: .horizontal)
        titleSubtitleContainerView
            .setContentHuggingPriority(UILayoutPriority.priority(250), for: .horizontal)
        mainStackView.addArrangedSubview(titleSubtitleContainerView)
        // Aggiunta del pulsante per la visualizzazione della mappa.
        let mapViewButton = prepareMapButton()
        mapViewButton
            .setContentCompressionResistancePriority(UILayoutPriority.priority(1000), for: .horizontal)
        mapViewButton
            .setContentHuggingPriority(UILayoutPriority.priority(251), for: .horizontal)
        mapViewButton.addConstraints([
            mapViewButton.widthAnchor.constraint(equalTo: mapViewButton.heightAnchor),
            mapViewButton.heightAnchor.constraint(lessThanOrEqualToConstant: 60)
            ])
        mainStackView.addArrangedSubview(mapViewButton)
        mapButton = mapViewButton
        KTheme.current.applyTheme(toView: self, style: .detailHeaderView)
    }

    open func prepareCategoryImageView() -> KCategoryImageView {
        let categoryImageView = KCategoryImageView()
        categoryImageView.translatesAutoresizingMaskIntoConstraints = false
        return categoryImageView
    }

    open func prepareTitleLabel() -> KTitleLabel {
        let titleLabel = KTitleLabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        return titleLabel
    }

    open func prepareCategorySubtitle() -> KCategoryLabel {
        let categoryLabel = KCategoryLabel()
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return categoryLabel
    }

    open func prepareMapButton() -> KMapPlainButton {
        let mapViewButton = KMapPlainButton(type: .system)
        mapViewButton.translatesAutoresizingMaskIntoConstraints = false
        mapViewButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        mapViewButton.alignImageAndTitleVertically()
        return mapViewButton
    }

}
