//
//  TakeInfoDateView.swift
//  Krake
//
//  Created by Marco Zanino on 05/08/16.
//
//

import UIKit

open class TakeInfoDateView: UIView {
    
    open var descriptionLabel: UILabel!
    open var dateLabel: UILabel!
    open var openCalendarButton: UIButton!
    
    public init() {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        commonInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /**
     Add subviews to this view.
     */
    fileprivate func commonInit() {
        // Creating the description label.
        descriptionLabel = UILabel(forAutoLayout: ())
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        descriptionLabel.textColor = UIColor.darkGray
        descriptionLabel.setContentHuggingPriority(UILayoutPriority.priority(251), for: .horizontal)
        descriptionLabel.setContentCompressionResistancePriority(UILayoutPriority.priority(1000), for: .horizontal)
        addSubview(descriptionLabel)
        // Creating the date label.
        dateLabel = UILabel(forAutoLayout: ())
        dateLabel.font = UIFont.systemFont(ofSize: 17.0)
        dateLabel.textColor = UIColor.darkGray
        dateLabel.textAlignment = .right
        dateLabel.setContentHuggingPriority(UILayoutPriority.priority(250), for: .horizontal)
        addSubview(dateLabel)
        // Creating the button that should be used to open the calendar.
        openCalendarButton = UIButton(type: .system)
        openCalendarButton.translatesAutoresizingMaskIntoConstraints = false
        openCalendarButton.setImage(UIImage(krakeNamed: "calendar"), for: .normal)
        openCalendarButton.setContentHuggingPriority(UILayoutPriority.priority(251), for: .horizontal)
        openCalendarButton.setContentCompressionResistancePriority(UILayoutPriority.priority(1000), for: .horizontal)
        addSubview(openCalendarButton)
        
        // Adding horizontal constraints.
        addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "|-0-[desc]-8-[date]-8-[b(buttonWidth)]-0-|",
                options: .directionLeftToRight,
                metrics: [ "buttonWidth" : 44.0 ],
                views: [ "desc" : descriptionLabel!, "date" : dateLabel!, "b" : openCalendarButton! ]))
        // Adding vertical constraints.
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[desc]-0-|",
            options: .directionLeftToRight,
            metrics: nil,
            views: [ "desc" : descriptionLabel! ]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[date]-0-|",
            options: .directionLeftToRight,
            metrics: nil,
            views: [ "date" : dateLabel! ]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[button]-0-|",
            options: .directionLeftToRight,
            metrics: nil,
            views: [ "button" : openCalendarButton! ]))
        // Adding aspect ratio constraint to button.
        openCalendarButton.addConstraint(
            NSLayoutConstraint(item: openCalendarButton!, attribute: .height,
                relatedBy: .equal,
                toItem: openCalendarButton, attribute: .width,
                multiplier: 1, constant: 0))
    }
    
}
