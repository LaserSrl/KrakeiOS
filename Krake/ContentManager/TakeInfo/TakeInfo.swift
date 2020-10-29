//
//  TakeInfo.swift
//  CitizenDemo
//
//  Created by Patrick on 09/07/15.
//  Copyright (c) 2015 Laser Group. All rights reserved.
//

import Foundation
import LaserPicker
import LaserFloatingTextField

public enum PickerImageMode
{
    case none
    case tintedImage
    case image
}

open class TakeInfo: ContentModificationViewController, FieldItemWithSelectionDelegate {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    
    fileprivate var task: OMLoadDataTask!
    fileprivate var openObserver: AnyObject!
    fileprivate var closeObserver: AnyObject!
    fileprivate var isImageVisible = false
    fileprivate var objectsValue: [ContentTypeSelectionFieldItem]?


    override open var fields: [FieldItem]! {
        didSet {
            for view in mainScrollView.subviews {
                if view is DropDownTextField || view is EGFloatingTextField {
                    view.removeFromSuperview()
                }
            }
            var beforeView: UIView = mainScrollView
            for dic in fields {
                let view: UIView = dic.view!
                mainScrollView.addSubview(view)
                
                let widthConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: mainScrollView, attribute: .width, multiplier: 1, constant: -40)
                mainScrollView.addConstraint(widthConstraint)
                let heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: 48)
                heightConstraint.priority = UILayoutPriority.priority(999)
                mainScrollView.addConstraint(heightConstraint)
                let alignCenterConstraint = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: mainScrollView, attribute: .centerX, multiplier: 1, constant: 0)
                mainScrollView.addConstraint(alignCenterConstraint)
                let topConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: beforeView, attribute: .bottom, multiplier: 1, constant: 16)
                mainScrollView.addConstraint(topConstraint)
                beforeView = view
            }
            let bottomConstraint = NSLayoutConstraint(item: beforeView, attribute: .bottom, relatedBy: .greaterThanOrEqual
                , toItem: mainScrollView, attribute: .top, multiplier: 1, constant: 16)
            mainScrollView.addConstraint(bottomConstraint)
            mainScrollView.setNeedsUpdateConstraints()
            mainScrollView.layoutIfNeeded()
        }
    }
    
    override open var title: String?{
        didSet{
            titleLabel.text = title
        }
    }
    
    deinit{
        KLog("RELEASED")
    }
    
    // MARK: - Function to generate standard FieldItem
    @available(*, deprecated, message: "Use newFieldItemWithPopoverTableView with imageMode")
    open func newFieldItemWithPopoverTableView(_ keyPath: String!,
                                               coreDataKeyPath: String? = nil,
                                               placeholder: String!,
                                               required: Bool = false) -> FieldItem {

        return newFieldItemWithPopoverTableView(keyPath,
                                                coreDataKeyPath: coreDataKeyPath,
                                                placeholder: placeholder,
                                                required: required,
                                                imageMode: isImageVisible ? PickerImageMode.tintedImage : PickerImageMode.none)
    }

    open func newFieldItemWithPopoverTableView(_ keyPath: String,
                                                 coreDataKeyPath: String? = nil,
                                                 placeholder: String,
                                                 required: Bool = false,
                                                 imageMode: PickerImageMode = .none) -> FieldItem {
        
        let fieldWithPopover = PopoverPickerField(key: keyPath, required: required)
        fieldWithPopover.coreDataKeyPath = coreDataKeyPath
        fieldWithPopover.placeholder = placeholder
        fieldWithPopover.imageMode = imageMode
        fieldWithPopover.delegate = self
        return fieldWithPopover
    }

    open func newFieldItemWithPopoverTableViewForContentPicker(_ keyPath: String,
                                                               contentPickerDiplayAlias: String,
                                               coreDataKeyPath: String? = nil,
                                               multipleSelection: Bool = false,
                                               placeholder: String,
                                               required: Bool = false,
                                               imageMode: PickerImageMode = .none) -> FieldItem {

        let fieldWithPopover = PopoverPickerField(key: keyPath,
                                                  contentDiplayAlias: contentPickerDiplayAlias,
                                                  mutipleSelection: multipleSelection,
                                                  required: required)
        fieldWithPopover.coreDataKeyPath = coreDataKeyPath
        fieldWithPopover.placeholder = placeholder
        fieldWithPopover.imageMode = imageMode
        fieldWithPopover.delegate = self
        return fieldWithPopover
    }

    /// Create a view to select a TermPart or an Enum
    ///
    /// - Parameters:
    ///   - keyPath: orchard key of the field, used to send data to WS and to configure the data from WS call to get Term and Enum values
    ///   - coreDataKeyPath: keyPath of coredata, used only when loading the intial data from a CoreData object to update it
    ///   - placeholder: name of the field to display to the user
    ///   - arrayElements: elements to configure the possibile selection ignoring orchard values
    ///   - canShowImages: if the field need to display the images
    ///   - pickType: indicate if the value is a TermPart or an Enum. The data is sent to orchard in a different JSON format, if the slected element is enum the ID as an integer is sent, otherwise an array contain the selected ids is sent.
    ///   - required: is the user need to select at least a value
    /// - Returns: the field item configured
    open func newFieldItemWithTermOrEnumView(_ keyPath: String,
                                          coreDataKeyPath: String? = nil,
                                          placeholder: String?,
                                          arrayElements: [ContentTypeSelectionFieldItem]? = nil,
                                          imageMode: PickerImageMode = .none,
                                          pickType: PickType = .termPart,
                                          required: Bool = false,
                                          visibleOnly: Bool = false,
                                          isDefaultFirstValueSelected: Bool = true) -> FieldItem {
        
        let dropDownField = DropDownTextPickerField(withKey: keyPath, arrayElements: arrayElements, pickType: pickType, required: required, isDefaultFirstValueSelected: isDefaultFirstValueSelected)
        dropDownField.delegate = self
        dropDownField.coreDataKeyPath = coreDataKeyPath
        dropDownField.placeholder = placeholder
        dropDownField.imageMode = imageMode
        dropDownField.visibleOnly = visibleOnly
        return dropDownField
    }

    @available(*, deprecated, message: "Use newFieldItemWithTermOrEnumView with imageMode")
    open func newFieldItemWithTermOrEnumView(_ keyPath: String,
                                             coreDataKeyPath: String? = nil,
                                             placeholder: String?,
                                             arrayElements: [ContentTypeSelectionFieldItem]? = nil,
                                             canShowImages: Bool,
                                             pickType: PickType = .termPart,
                                             required: Bool = false) -> FieldItem {

        return newFieldItemWithTermOrEnumView(keyPath, coreDataKeyPath: coreDataKeyPath, placeholder: placeholder, arrayElements: arrayElements, imageMode: canShowImages ? .tintedImage : .none, pickType: pickType, required: required)
    }

    open func newFieldItemWithContentPickerField(_ keyPath: String,
                                                 contentPickerFieldDisplayAlias: String,
                                                 extras: [String : Any]? = nil,
                                             coreDataKeyPath: String? = nil,
                                             placeholder: String?,
                                             imageMode: PickerImageMode = .none,
                                             required: Bool = false,
                                             multipleSelection: Bool = false,
                                             visibleOnly: Bool = false,
                                             isDefaultFirstValueSelected: Bool = true) -> FieldItem {

        let dropDownField = DropDownTextPickerField(withContentPickerKey: keyPath, displayAlias: contentPickerFieldDisplayAlias, extras: extras, required: required, mutipleSelection: multipleSelection)
        dropDownField.delegate = self
        dropDownField.coreDataKeyPath = coreDataKeyPath
        dropDownField.placeholder = placeholder
        dropDownField.imageMode = imageMode
        dropDownField.visibleOnly = visibleOnly
        dropDownField.isDefaultFirstValueSelected = isDefaultFirstValueSelected
        return dropDownField
    }
    
    open func newFieldItemWithTextField(_ keyPath: String!,
                                          coreDataKeyPath: String? = nil,
                                          placeholder: String?,
                                          validationType: EGFloatingTextFieldValidationType? = .Default,
                                          required: Bool = false,
                                          visibleOnly: Bool = false) -> FieldItem {
        
        let textField = SinglelineTextField(key: keyPath, required: required, validationType: validationType)
        textField.delegate = self
        textField.coreDataKeyPath = coreDataKeyPath
        textField.placeholder = placeholder
        textField.visibleOnly = visibleOnly
        return textField
    }
    
    open func newFieldItemWithSwitch(_ keyPath: String!,
                                       coreDataKeyPath: String? = nil,
                                       placeholder: String,
                                       defaultVal: Bool = false,
                                       required: Bool = false,
                                       visibleOnly: Bool = false) -> FieldItem {
        
        let switchField = SwitchField(key: keyPath, placeholder: placeholder, required: required)
        switchField.delegate = self
        switchField.coreDataKeyPath = coreDataKeyPath
        switchField.setInitialValue(defaultVal)
        switchField.visibleOnly = visibleOnly
        return switchField
    }
    
    open func newFieldItemWithTextView(_ keyPath: String!,
                                         coreDataKeyPath: String? = nil,
                                         placeholder: String? = KLocalization.descrizione,
                                         numberOfLines: Int = 5,
                                         required: Bool = false,
                                         visibleOnly: Bool = false) -> FieldItem {
        
        let textViewField = MultilineTextField(key: keyPath, required: required, numberOfLines: numberOfLines)
        textViewField.delegate = self
        textViewField.coreDataKeyPath = coreDataKeyPath
        textViewField.placeholder = placeholder
        textViewField.visibleOnly = visibleOnly
        return textViewField
    }
    
    @available(*, deprecated, renamed: "newFieldItemWithDateTimePicker(_:coreDataKeyPath:placeholder:fieldTitle:visualDateFormat:krakeDateFormat:required:disableHistorySelection:disableFutureSelection:visibleOnly:showTime:)")
    open func newFieldItemWithDatePicker(_ keyPath: String!,
                                           coreDataKeyPath: String? = nil,
                                           placeholder: String? = nil,
                                           fieldTitle: String = "Data".localizedString(),
                                           visualDateFormat: String = DateTimePickerField.DefaultVisualDateFormat,
                                           krakeDateFormat: String = DateTimePickerField.DefaultRemoteDateFormat,
                                           required: Bool = false,
                                           disableHistorySelection: Bool = true,
                                        disableFutureSelection: Bool = false,
                                        visibleOnly: Bool = false) -> FieldItem
    {
        return self.newFieldItemWithDateTimePicker(keyPath,
                                                   coreDataKeyPath: coreDataKeyPath,
                                                   placeholder: placeholder,
                                                   fieldTitle: fieldTitle,
                                                   visualDateFormat: visualDateFormat,
                                                   krakeDateFormat: krakeDateFormat,
                                                   required: required,
                                                   disableHistorySelection: disableHistorySelection,
                                                   disableFutureSelection: disableFutureSelection,
                                                   visibleOnly: visibleOnly,
                                                   showTime: false)
    }
    
    open func newFieldItemWithDateTimePicker(_ keyPath: String!,
                                         coreDataKeyPath: String? = nil,
                                         placeholder: String? = nil,
                                         fieldTitle: String = "Data".localizedString(),
                                         visualDateFormat: String = DateTimePickerField.DefaultVisualDateFormat,
                                         krakeDateFormat: String = DateTimePickerField.DefaultRemoteDateFormat,
                                         required: Bool = false,
                                         disableHistorySelection: Bool = true,
                                         disableFutureSelection: Bool = false,
                                         visibleOnly: Bool = false,
                                         showTime: Bool = false) -> DateTimePickerField
    {
        let dateField = DateTimePickerField(key: keyPath,
                                            required: required,
                                            descriptionText: fieldTitle,
                                            remoteDateFormat: krakeDateFormat,
                                            visualDateFormat: visualDateFormat,
                                            disableHistorySelection: disableHistorySelection,
                                            disableFutureSelection: disableFutureSelection,
                                            showTime: showTime)
        dateField.delegate = self
        dateField.coreDataKeyPath = coreDataKeyPath
        dateField.placeholder = placeholder
        dateField.visibleOnly = visibleOnly
        return dateField
    }
    
    // MARK: - View
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.backgroundColor = KTheme.current.color(.tint)
        titleLabel.textColor = KTheme.current.color(.textTint)
        
        mainScrollView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(TakeInfo.closeInputViewController)))
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        openObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: nil) { [weak self](notification: Notification) -> Void in
            if let mySelf = self{
                
                let rect = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

                if UIDevice.current.userInterfaceIdiom == .phone {
                    mySelf.mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: rect.height, right: 0)
                }
                else {

                    let convertedRect = mySelf.view.window!.convert(rect, to: mySelf.view)
                    let viewRect = mySelf.view.convert(mySelf.view.frame, to: nil)
                    let bottom = viewRect.height-convertedRect.origin.y
                    mySelf.mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottom > 0 ? bottom : 0, right: 0)
                }

                mySelf.mainScrollView.scrollIndicatorInsets = mySelf.mainScrollView.contentInset
                for subV in mySelf.mainScrollView.subviews{
                    if subV.isFirstResponder{
                        let cos = mySelf.mainScrollView.frame.height-rect.height
                        let y = subV.frame.origin.y + subV.frame.height
                        if y > cos {
                            mySelf.mainScrollView.setContentOffset(CGPoint(x:0, y:y-cos), animated: true)
                        }
                        break
                    }
                }
            }
        }
        
        closeObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: nil) { [weak self](notification: Notification) -> Void in
            if let mySelf = self{
                mySelf.mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                mySelf.mainScrollView.scrollIndicatorInsets = mySelf.mainScrollView.contentInset
            }
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let height = fields.last!.view!.frame.origin.y + fields.last!.view!.frame.height + 16
        mainScrollView.contentSize = CGSize(width:0, height: height)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        mainScrollView.scrollIndicatorInsets = mainScrollView.contentInset
        if let openObserver = openObserver {
            NotificationCenter.default.removeObserver(openObserver)
        }
        openObserver = nil
        if let closeObserver = closeObserver {
            NotificationCenter.default.removeObserver(closeObserver)
        }
        closeObserver = nil
    }
    
    @objc func closeInputViewController() {
        view.endEditing(true)
    }
    
    //MARK: - Set initial data
    
    override open func setInitialData(_ item: AnyObject) {
        for field in fields {
            if let coreDataKeyPath = field.coreDataKeyPath {
                if let value = (item as? NSObject)?.value(forKeyPath: coreDataKeyPath) {
                    if let array = value as? NSOrderedSet {
                        if array.count == 0{
                            params[field.key] = [Int]()
                        }else if array.firstObject is TermPartProtocol {
                            var termini = [Int]()
                            for elem in array {
                                let term = elem as! TermPartProtocol
                                termini.append(term.identifier!.intValue)
                            }
                            params[field.key] = termini
                        }
                    } else {
                        if let
                            jsonFormattedValue = field.jsonValue(fromValue: value ) {
                            
                            params[field.key] = jsonFormattedValue
                        }
                    }
                }
            }
        }
    }
    
    override open func reloadAllDataFromParams() {
        mainScrollView.layoutIfNeeded()
        
        for field in fields {
            if field is FieldItemWithSelection {
                if let contentTypeSelectionFields = contentTypeSelectionFields {
                    for contentType in contentTypeSelectionFields {
                        if contentType.key == field.key {
                            field.setInitialValue(contentType)
                            break
                        }
                    }
                }
            } else {
                field.setInitialValue(params[field.key])
            }
        }
    }
    
    // MARK: - FieldItem delegate
    
    open func valueChanged(_ value: Any?, forField fieldItem: FieldItem) {
        // Controllo se il field causerà una modifica al dictionary dei params.
        if fieldItem.isValueChanged(params[fieldItem.key]) {
            // Aggiorno il valore.
            params[fieldItem.key] = value
            // Imposto a "Modificato" il contenuto.
            if containerViewController != nil{
                    containerViewController.isChanged = true
                
            }
        }
    }
    
    // MARK: - FieldItemWithSelection delegate
    
    open func valueToMarkAsSelected(forField fieldItem: FieldItemWithSelection) -> [ContentTypeSelectionFieldItem]? {
        if let storedValue = params[fieldItem.key] {

            let selectedValues : [Any]

            if storedValue is [Any] {
                selectedValues = storedValue as! [Any]
            } else {
                selectedValues = [storedValue]
            }

            return fieldItem.allValues?.filter({ (item) -> Bool in
                item.hasAny(ofValues: selectedValues)
            })
        }
        
        return nil
    }
    
}
