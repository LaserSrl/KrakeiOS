//
//  TextField.swift
//  Pods
//
//  Created by Marco Zanino on 05/08/16.
//
//

import UIKit
import LaserFloatingTextField

public class AbstractTextField: NSObject, SingleValueFieldItem {
    
    public var key: String
    public var coreDataKeyPath: String?
    public var placeholder: String?
    public var required: Bool
    public var view: UIView? {
        return nil
    }
    public weak var delegate: FieldItemDelegate?
    
    public init(key: String, required: Bool) {
        self.key = key
        self.required = required
    }
    
    public func setInitialValue(_ value: Any?) {
        fatalError("This is only an abstract class. " +
            "You must use one of the default implementations or provide a custom subclass.")
    }
    
    public func currentValue() -> Any? {
        fatalError("This is only an abstract class. " +
            "You must use one of the default implementations or provide a custom subclass.")
    }
    
    public func jsonValue(fromValue value: Any?) -> Any? {
        if value == nil {
            return nil
        }
        
        if let numericValue = value as? NSNumber {
            return numericValue.stringValue
        }
        return value as? String as AnyObject?
    }
    
    public func isValueChanged(_ oldValue: Any?) -> Bool {
        let newValue = currentValue()
        if oldValue == nil {
            return newValue != nil
        } else {
            if let
                newValue = newValue as? String,
                let oldValue = oldValue as? String {
                
                return oldValue != newValue
            }
            return true
        }
    }
    
    public func isDataValid(params: NSMutableDictionary) throws {
        try isDataRequired(params: params)
    }
}

public class SinglelineTextField: AbstractTextField, UITextFieldDelegate {
    
    var validationType: EGFloatingTextFieldValidationType?
    
    override public var view: UIView? {
        return floatingTextField
    }
    
    public var visibleOnly: Bool = false{
        didSet{
            floatingTextField.isEnabled = !visibleOnly
        }
    }
    
    fileprivate lazy var floatingTextField: EGFloatingTextField = {
        let view = EGFloatingTextField()
        KTheme.current.applyTheme(toTextField: view, style: .contentManager)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.IBPlaceholder = self.placeholder
        view.canBeEmpty = !self.required
        if let validationType = self.validationType {
            view.validationType = validationType
        }
        return view
    }()
    
    /// Used to translate inserted text from String to NSNumber,
    /// if the validation type is number.
    fileprivate lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()
    
    init(key: String, required: Bool, validationType: EGFloatingTextFieldValidationType?) {
        self.validationType = validationType
        
        super.init(key: key, required: required)
    }
    
    // MARK: - FieldItem implementation
    
    override public func setInitialValue(_ value: Any?) {
        let text: String?
        if value is String {
            text = value as? String
        } else if value is NSNumber {
            text = String(describing: value as! NSNumber)
        } else {
            text = nil
        }
        
        if text != nil {
            floatingTextField.text = text
        }
    }
    
    public override func isDataValid(params: NSMutableDictionary) throws {
        try isDataRequired(params: params)
        
        //se sono qui è perchè ha già superato il check sul required
        //il dato c'è, ora controllo se è corretto
        
        let (isValidField, errorMessage) = floatingTextField.isValid()
        if !isValidField{
            throw FieldItemError.notValidData(errorMessage!.localizedString())
        }       
    }
    
    override public func currentValue() -> Any? {
        if let currentText = floatingTextField.text {
            if validationType == .Integer || validationType == .Decimal {
                return numberFormatter.number(from: currentText)
            }
            return currentText
        }
        return nil
    }
    
    override public func jsonValue(fromValue value: Any?) -> Any? {
        if validationType == .Integer || validationType == .Decimal {
            return value as? NSNumber
        }
        return super.jsonValue(fromValue: value)
    }
    
    override public func isValueChanged(_ oldValue: Any?) -> Bool {
        if let
            oldNumber = oldValue as? NSNumber,
            let currentText = floatingTextField.text,
            let currentNumber = numberFormatter.number(from: currentText) {
            
            return oldNumber != currentNumber
        }
        return super.isValueChanged(oldValue)
    }
    
    // MARK: - Text field delegate
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let insertedValue: AnyObject? = {
            if let insertedText = textField.text {
                if validationType == .Integer || validationType == .Decimal {
                    return numberFormatter.number(from: insertedText)
                }
                return insertedText as AnyObject?
            }
            return nil
        }()
        delegate?.valueChanged(insertedValue, forField: self)
    }
}

class MultilineTextField: AbstractTextField, UITextViewDelegate {
    
    fileprivate let numberOfLines: Int
    
    override var view: UIView? {
        return textView
    }
    
    var visibleOnly: Bool = true{
        didSet{
            textView.isEditable = !visibleOnly
        }
    }
    
    fileprivate lazy var textView: UITextView = {
        let view = UITextView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = self.placeholder
        view.textColor = UIColor.darkGray
        view.font = UIFont.systemFont(ofSize: 17.0)
        view.layer.borderColor = KTheme.current.color(.tint).cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 5.0
        view.addConstraint(
            NSLayoutConstraint(item: view, attribute: .height,
                relatedBy: .equal,
                toItem: nil, attribute: .height,
                multiplier: 1,
                constant: CGFloat(self.numberOfLines) * 25.0))
        return view
    }()
    
    init(key: String, required: Bool, numberOfLines: Int) {
        self.numberOfLines = numberOfLines
        super.init(key: key, required: required)
    }
    
    // MARK: - Field item implementation
    
    override func setInitialValue(_ value: Any?) {
        guard let text = value as? String else {
            return
        }
        
        textView.becomeFirstResponder()
        textView.text = text.htmlToString()
        textView.textColor = UIColor.black
        textView.resignFirstResponder()
    }
    
    override func currentValue() -> Any? {
        return textView.text as AnyObject?
    }
    
    override func isValueChanged(_ oldValue: Any?) -> Bool {
        if oldValue == nil || !(oldValue is String) {
            return super.isValueChanged(oldValue)
        } else {
            // Il testo è da considerarsi modificato nel caso in cui
            // il vecchio valore senza tag HTML sia differente da quello
            // attualmente presente nella UITextView.
            return textView.text != (oldValue as! String).htmlToString()
        }
    }
    
    // MARK: - Text view delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.darkGray {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text.replacingOccurrences(of: "\n", with: "<br/>")
        if text.utf8.count == 0 {
            textView.text = placeholder ?? ""
            textView.textColor = UIColor.darkGray
        } else {
            delegate?.valueChanged(text, forField: self)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let string = (textView.text as NSString).replacingCharacters(in: range, with: text)
        textView.textColor = string == placeholder ? UIColor.darkGray : UIColor.black
        return true
    }
    
}
