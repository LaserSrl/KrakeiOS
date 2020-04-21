//
//  DropDownTextPickerField.swift
//  Krake
//
//  Created by Marco Zanino on 05/08/16.
//
//

import UIKit

public enum PickType {
    case orchardEnum
    case termPart
    case contentPickerField
}

class DropDownTextPickerField: NSObject, FieldItemWithSelection, DropDownTextFieldDelegate {

    var key: String
    var coreDataKeyPath: String?
    var placeholder: String?{
        didSet{
            dropDownTextField.IBPlaceholder = placeholder
        }
    }
    var required: Bool{
        didSet{
            dropDownTextField.required = required
        }
    }
    let contentPickerDisplayAlias: String?
    var view: UIView? {
        return dropDownTextField
    }
    var isDefaultFirstValueSelected: Bool = true
    
    fileprivate lazy var dropDownTextField: DropDownTextField = {
        let view = DropDownTextField()
        view.ddDelegate = self
        view.required = required
        view.imageMode = self.imageMode
        view.translatesAutoresizingMaskIntoConstraints = false
        view.itemList = self.arrayElements
        let toolbar: UIToolbar! = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.barTintColor = KTheme.current.color(.tint)
        toolbar.tintColor = KTheme.current.color(.textTint)
        toolbar.sizeToFit()
        let buttonflexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let buttonDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(DropDownTextPickerField.doneClicked))
        toolbar.setItems([buttonflexible, buttonDone], animated: true)
        view.inputAccessoryView = toolbar
        view.IBPlaceholder = self.placeholder
        view.isEnabled = false
        return view
    }()
    
    var allValues: [ContentTypeSelectionFieldItem]? {
        return arrayElements
    }
    
    var pickType: PickType
    var arrayElements: [ContentTypeSelectionFieldItem]?
    var imageMode = PickerImageMode.none {
        didSet{
            if imageMode != .none {
                dropDownTextField.imageMode = imageMode
            }
        }
    }
    
    var visibleOnly: Bool = false{
        didSet{
            dropDownTextField.isEnabled = !visibleOnly
        }
    }
    
    weak var delegate: FieldItemWithSelectionDelegate?
    
    fileprivate var valuesChanged = false
    
    init(withKey key: String,
         arrayElements: [ContentTypeSelectionFieldItem]? = nil,
         pickType: PickType = .termPart,
         required: Bool = false,
         isDefaultFirstValueSelected: Bool = true) {
        
        self.key = key
        self.required = required
        self.arrayElements = arrayElements
        self.pickType = pickType
        self.isDefaultFirstValueSelected = isDefaultFirstValueSelected
        contentPickerDisplayAlias = nil
    }

    init(withContentPickerKey key: String,
         displayAlias: String,
         extras: [String : Any]? = nil,
         required: Bool = false,
         mutipleSelection: Bool = false,
         isDefaultFirstValueSelected: Bool = true) {

        self.key = key
        self.required = required
        self.arrayElements = nil
        self.pickType = .contentPickerField
        self.isDefaultFirstValueSelected = isDefaultFirstValueSelected
        contentPickerDisplayAlias = displayAlias
        super.init()
        dropDownTextField.isMultiSelection = mutipleSelection

        OGLCoreDataMapper
            .sharedInstance().loadData(withDisplayAlias: displayAlias,
                                       extras: extras,
                                       loginRequired: true) { (object, error, completed) in
                                        if object != nil && completed {

                                            if let values = OGLCoreDataMapper.sharedInstance().displayPathCache(from: object!).cacheItems {
                                                
                                                self.setValues(elements: values.map({ (managedObject) -> ContentTypeSelectionContentItem in
                                                    return ContentTypeSelectionContentItem(contentItem: managedObject as! ContentItem)
                                                }))

                                            }
                                        }
        }
    }
    
    // MARK: - DropDownTextField delegate
    
    func textField(_ textField: DropDownTextField, didSelectItems: [ContentTypeSelectionFieldItem]) {
        valuesChanged = true
        if pickType != .orchardEnum {
            delegate?.valueChanged(didSelectItems.map({$0.referenceValue()!}), forField: self)
        }
        else {
            delegate?.valueChanged(didSelectItems.first?.referenceValue(), forField: self)
        }
    }
    
    @objc func doneClicked(){
        dropDownTextField.endEditing(true)
    }
    
    // MARK: - FieldItem protocol
    
    func setInitialValue(_ value: Any?) {
        guard let contentType = value as? ContentTypeSelectionField else {
            return
        }
        required = required ? required : contentType.settings.required
        dropDownTextField.isMultiSelection = contentType.settings.selectionType == .multiple

        let values : [ContentTypeSelectionFieldItem]
        if(arrayElements == nil)
        {
            values = contentType.values
            arrayElements =  contentType.values
        }
        else
        {
            values = arrayElements!
        }
        
        valuesChanged = false
        setValues(elements: values)
    }

    fileprivate func setValues(elements:  [ContentTypeSelectionFieldItem])
    {
        dropDownTextField.itemList = elements

        // Marking as selected some items.
        if let selectedItems = delegate?.valueToMarkAsSelected(forField: self)
        {
            dropDownTextField.setSelectedItems(selectedItems)
        }
        else  if isDefaultFirstValueSelected
        {
            let selectedItem = dropDownTextField.itemList?.first
            let selected = selectedItem?.referenceValue()
            
            if let selectedItem = selectedItem {
                dropDownTextField.setSelectedItems([selectedItem])
            }
            
            if pickType == .orchardEnum {
                delegate?.valueChanged(selected, forField: self)
            }
            else {
                delegate?.valueChanged(selected != nil ? [selected] : [], forField: self)
            }
        }
        self.dropDownTextField.isEnabled = true && !visibleOnly
    }

    func currentValue() -> Any? {

        var values = [Any]()

        for item in dropDownTextField.mSelectedItems {
            values.append(item.referenceValue()!)
        }

        return values
    }
    
    func jsonValue(fromValue value: Any?) -> Any? {
        if let value = value {
            if value is String {
                return value as! String as AnyObject?
            } else if (value as? NSObject)?.responds(to: #selector(UISlider.value(forKey:))) ?? false {
                return (value as? NSObject)?.value(forKey: "value") as AnyObject
            }
        }
        return nil
    }
    
    func isValueChanged(_ oldValue: Any?) -> Bool {
        return valuesChanged
    }
    
    
    
}
