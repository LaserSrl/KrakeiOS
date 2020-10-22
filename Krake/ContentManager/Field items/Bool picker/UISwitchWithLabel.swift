//
//  UISwitchWithLabel.swift
//  Krake
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation

protocol UISwitchWithLabelDelegate: NSObjectProtocol {
    func switchChanged(_ switchView: UISwitch, isChecked: Bool)
}

class UISwitchWithLabel: UIView {
    weak var switchView: UISwitch?
    weak var labelView: UILabel?
    weak var delegate: UISwitchWithLabelDelegate?
    
    init(labelText: String, defaultVal: Bool = false) {
        super.init(frame: CGRect.zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let switchView = UISwitch()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.isOn = defaultVal
        KTheme.current.applyTheme(toSwitch: switchView, style: .contentMofication)
        let event = UIControl.Event.valueChanged
        switchView.addTarget(self, action: #selector(UISwitchWithLabel.switchChanged(_:)), for: event)
        
        addSubview(switchView)
        
        let labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.numberOfLines = 0
        labelView.text = labelText
        
        addSubview(labelView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(8)-[label]-(8)-[switch(49)]-(8)-|", options: .directionLeftToRight, metrics: nil, views: ["label" : labelView, "switch" : switchView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[label]-(8)-|", options: .directionLeftToRight, metrics: nil, views: ["label" : labelView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=8)-[switch]-(>=8)-|", options: .directionLeftToRight, metrics: nil, views: ["switch" : switchView]))
        addConstraint(NSLayoutConstraint(item: switchView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        self.switchView = switchView
        self.labelView = labelView
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        if let delegate = delegate {
            delegate.switchChanged(sender, isChecked: sender.isOn)
        }
    }
    
    deinit {
        delegate = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
