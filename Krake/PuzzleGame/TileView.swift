//
//  TileView.swift
//  Krake
//
//  Created by Marco Zanino on 15/03/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import UIKit

public class TileView: UIView {

    public var coordinates: Coordinates

    public weak var imageView: UIImageView!
    public weak var numberLabel: UILabel!
    private weak var tileHiderImageView: UIImageView?

    public init(coordinates: Coordinates) {
        self.coordinates = coordinates
        super.init(frame: .zero)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
		// Creazione della UIImageView che verrà utilizzata per mostrare
        // l'immagine del tile.
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Creazione della label che rappresenterà il numero del tile.
        let numberLabel = UILabel(frame: .zero)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
		numberLabel.backgroundColor = KTheme.current.color(.tint)
        numberLabel.textColor = KTheme.current.color(.textTint)
        numberLabel.textAlignment = .center
        // Aggiungo entrambe le view come subviews.
        addSubview(imageView)
        addSubview(numberLabel)
        // Imposto i constraints per le subviews.
        let viewRefs = [ "iv" : imageView ]
        addConstraints([
			NSLayoutConstraint.constraints(
                withVisualFormat: "|-0-[iv]-0-|",
                options: .directionLeftToRight,
                metrics: nil,
                views: viewRefs),
			NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[iv]-0-|",
                options: .directionLeftToRight,
                metrics: nil,
                views: viewRefs)
            ].flatMap { $0 })
        numberLabel.addConstraints([
			numberLabel.heightAnchor.constraint(equalToConstant: 20),
			numberLabel.widthAnchor.constraint(equalTo: numberLabel.heightAnchor)
            ])
        addConstraints([
			numberLabel.topAnchor.constraint(equalTo: topAnchor, constant: 1),
			numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1)
            ])
		// Salvo le reference alle view generate.
        self.imageView = imageView
        self.numberLabel = numberLabel
    }

    public func hideImageView() {
        guard tileHiderImageView == nil else {
            return
        }
        let hiderImageView = UIImageView()
        hiderImageView.translatesAutoresizingMaskIntoConstraints = false
        hiderImageView.backgroundColor = .clear
        addSubview(hiderImageView)
        let viewRefs = [ "iv" : hiderImageView ]
        addConstraints([
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-0-[iv]-0-|",
                options: .directionLeftToRight,
                metrics: nil,
                views: viewRefs),
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[iv]-0-|",
                options: .directionLeftToRight,
                metrics: nil,
                views: viewRefs)
            ].flatMap { $0 })
        imageView.alpha = 0
		tileHiderImageView = hiderImageView
    }

    public func showImageView() {

    }

}
