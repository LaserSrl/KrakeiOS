//
//  SwitchField.swift
//  Pods
//
//  Created by Marco Zanino on 05/08/16.
//
//

import UIKit

class SwitchField: NSObject, SingleValueFieldItem, UISwitchWithLabelDelegate {
    var key: String
    var coreDataKeyPath: String?
    var placeholder: String?
    var required: Bool
    var view: UIView? {
        return switchWithLabel
    }
    
    var visibleOnly: Bool = false{
        didSet{
            switchWithLabel.switchView?.isEnabled = !visibleOnly
        }
    }
    
    fileprivate lazy var switchWithLabel: UISwitchWithLabel = {
        let view = UISwitchWithLabel(labelText: self.placeholder!)
        view.delegate = self
        return view
    }()
    
    weak var delegate: FieldItemDelegate?
    
    fileprivate var switchChanged: Bool = false
    
    init(key: String, placeholder: String, required: Bool) {
        self.key = key
        self.required = required
        self.placeholder = placeholder
    }
    
    /**
     Change the switch status based on the argument received.
     
     - parameter value: can be a Bool or a NSNumber, other types will not
     be considered.
     */
    func setInitialValue(_ value: Any?) {
        var checked: Bool? = nil
        if value is Bool {
            checked = value as? Bool
        } else if value is NSNumber {
            checked = (value as! NSNumber).boolValue
        }
        
        if checked != nil {
            switchWithLabel.switchView?.setOn(checked!, animated: true)
        }
    }
    
    /**
     The current value based on switch state.
     
     - returns: Bool that indicates the switch state.
     */
    func currentValue() -> Any? {
        return switchWithLabel.switchView?.isOn
    }
    
    func jsonValue(fromValue value: Any?) -> Any? {
        return value as? NSNumber
    }
    
    func isValueChanged(_ oldValue: Any?) -> Bool {
        if oldValue == nil {
            return switchChanged
        } else {
            if let oldSwitchState = oldValue as? Bool {
                return oldSwitchState != (currentValue() as! Bool)
            }
            return false
        }
    }
    
    // MARK: - Switch delegate
    
    func switchChanged(_ switchView: UISwitch, isChecked: Bool) {
        switchChanged = true
        
        delegate?.valueChanged(isChecked, forField: self)
    }
    
    

}
