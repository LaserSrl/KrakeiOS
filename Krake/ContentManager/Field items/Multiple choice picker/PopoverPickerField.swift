//
//  PopoverPickerField.swift
//  Pods
//
//  Created by Marco Zanino on 05/08/16.
//
//

import UIKit
import LaserPicker

class PopoverPickerField: NSObject, FieldItemWithSelection, CZPickerViewDataSource, CZPickerViewDelegate {
    
    var key: String
    var coreDataKeyPath: String?
    var placeholder: String?
    var required: Bool
    var view: UIView? {
        return openPickerButton
    }
    
    fileprivate lazy var openPickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(self.placeholder, for: KControlState.normal)
        button.addTarget(self, action: #selector(PopoverPickerField.openPicker), for: .touchUpInside)
        KTheme.current.applyTheme(toButton: button, style: .default)
        return button
    }()
    
    var allValues: [ContentTypeSelectionFieldItem]?
    var imageMode = PickerImageMode.none
    var multiple = false
    var selectedIndexes: [Int]?
    let contentItemsAlias: String?
    
    weak var delegate: FieldItemWithSelectionDelegate?

    init(key: String, contentDiplayAlias: String, mutipleSelection: Bool, required: Bool) {
        self.key = key
        self.required = required
        self.multiple = mutipleSelection
        self.contentItemsAlias = contentDiplayAlias
        super.init()

        OGLCoreDataMapper
            .sharedInstance().loadData(withDisplayAlias: contentDiplayAlias,
                                       extras: nil) { (object, error, completed) in
                                        if object != nil && completed {

                                            if let values = OGLCoreDataMapper.sharedInstance().displayPathCache(from: object!).cacheItems {
                                                self.allValues =  values.map({ (managedObject) -> ContentTypeSelectionContentItem in
                                                    return ContentTypeSelectionContentItem(contentItem: managedObject as! ContentItem)
                                                })

                                                self.loadValues()
                                            }
                                        }
        }

    }

    init(key: String, required: Bool) {
        self.key = key
        self.required = required
        contentItemsAlias = nil
    }
    
    // MARK: - FieldItem methods
    
    func setInitialValue(_ value: Any?) {
        guard let possibleValues = value as? ContentTypeSelectionField else {
            return
        }
        required = required ? required : possibleValues.settings.required
        multiple = possibleValues.settings.selectionType == .multiple

        allValues = {
            var contentValues = [ContentTypeSelectionFieldItem]()
            for contentTypeFirstLevelValue in possibleValues.values {
                contentValues.append(contentTypeFirstLevelValue)
                
                if let fieldChildren = contentTypeFirstLevelValue.children {
                    for child in fieldChildren {
                        contentValues.append(child)
                    }
                }
            }
            return contentValues
        }()

        self.loadValues()
    }

    private func loadValues()
    {
        if let contentValues = allValues {

            var selectedValues: [ContentTypeSelectionFieldItem]
            let selectionFromDelegate: Bool

            if let delegateSelection = delegate?.valueToMarkAsSelected(forField: self) {
                selectedValues = delegateSelection
                selectionFromDelegate = true
            }
            else {
                selectionFromDelegate = false
                if let first = contentValues.first {
                    selectedValues = [first]
                }
                else {
                    selectedValues = []
                }
            }

            var indexToSelect = [Int]()
            // Getting the positions for all selected values.
            for value in selectedValues {
                // Searching the position for the current value.
                for (index, contentValue) in contentValues.enumerated() {
                    if contentValue.isEqual(to: value) {
                        indexToSelect.append(index)
                        break
                    }
                }
            }

            selectedIndexes = indexToSelect

            if !selectionFromDelegate {
                delegate?.valueChanged(selectedValues.map({$0.referenceValue()!}), forField: self)
            }
        }
    }
    
    /**
     Return the selected items.
     
     - returns: list of ContentTypeSelectionFieldItem that have been selected
     by the user.
     */
    func currentValue() -> Any? {
        guard selectedIndexes != nil && allValues != nil else {
            return nil
        }
        
        var selectedItems = [Any]()
        for index in selectedIndexes! {
            if let contentValue = allValues![index].referenceValue() {
                selectedItems.append(contentValue)
            }
        }
        return selectedItems
    }
    
    func jsonValue(fromValue value: Any?) -> Any? {
        if (value as? NSObject)?.responds(to: #selector(UISlider.value(forKey:))) ?? false {
            return (value as? NSObject)?.value(forKey: "value")
        }
        return value
    }
    
    func isValueChanged(_ oldValue: Any?) -> Bool {
        return selectedIndexes != nil
    }
    
    // MARK: - CZPicker presentation
    
    /**
     Create and open the picker view.
     */
    @objc func openPicker() {
        openPickerButton.superview?.endEditing(true)
        
        let tintColor = KTheme.current.color(.tint)
        let textTintColor = KTheme.current.color(.textTint)
        
        let picker = CZPickerView(headerTitle: placeholder, cancelButtonTitle: "UNDO".localizedString(), confirmButtonTitle: "Ok".localizedString())!
        picker.tintColor = tintColor
        picker.delegate = self
        picker.dataSource = self
        picker.needFooterView = true
        picker.allowMultipleSelection = multiple
        picker.headerBackgroundColor = tintColor
        picker.headerTitleColor = textTintColor
        picker.confirmButtonBackgroundColor = tintColor
        picker.confirmButtonNormalColor = textTintColor
        
        // Marking selected elements, if any.
        if let indexes = selectedIndexes {
            picker.setSelectedRows(indexes)
        }

        // Presenting the picker.
        picker.show()
    }
    
    // MARK: - CZPicker data source
    
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return allValues?.count ?? 0
    }
    
    func czpickerView(_ pickerView: CZPickerView!, imageForRow row: Int) -> UIImage! {
        if imageMode == .none {
            return nil
        }
        
        let currentContentItem = allValues![row]
        if let itemMediaIdentifier = currentContentItem.mediaId {
            let url = KMediaImageLoader.generateURL(forMediaPath: itemMediaIdentifier.stringValue, mediaImageOptions: KMediaImageLoadOptions(size: CGSize(width: 200, height: 200), mode: .Crop))
            if let data = try? Data(contentsOf: url!){
                let image = UIImage(data: data)
                if imageMode == .tintedImage {
                    return image?.imageTinted(KTheme.current.color(.tint))
                }
                else {
                   return image
                }
            }
        }
        return nil
    }

    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return allValues![row].name
    }
    
    func czpickerView(_ pickerView: CZPickerView!, indentationLevelForRow row: Int) -> Int {
        return allValues![row].level
    }
    
    func czpickerView(_ pickerView: CZPickerView!, shouldSelectRow row: Int) -> Bool {
        return allValues![row].selectable
    }
    
    // MARK: - CZPicker delegate
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [Any]!) {
        
        var values = [Any]()
        for index in rows as! [Int] {
            if let value = allValues![index].referenceValue() {
                values.append(value)
            }
        }
        // Saving the selected values for the future.
        selectedIndexes = rows as? [Int]
        // Notifying the delegate that values are changed for the current key.
        delegate?.valueChanged(values as AnyObject?, forField: self)
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int) {
        if let value = allValues![row].referenceValue() {
            // Saving the position of the selected item.
            selectedIndexes = [row]
            // Notifying the delegate that values are changed for the current key.
            delegate?.valueChanged([value], forField: self)
        }
    }
    
   
    
}
