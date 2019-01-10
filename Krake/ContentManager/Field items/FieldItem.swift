//
//  FieldItem.swift
//  Krake
//
//  Created by Marco Zanino on 09/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import UIKit

enum FieldItemError : Error {
    case notValidData(String)
}

public protocol FieldItem {
    var key: String { get set }
    var coreDataKeyPath: String? { get set }
    var placeholder: String? { get set }
    var view: UIView? { get }
    var required: Bool { get set }
    var visibleOnly: Bool { get set }
    
    func setInitialValue(_ value: Any?)
    func currentValue() -> Any?
    
    // Optional functions.
    func jsonValue(fromValue value: Any?) -> Any?
    func isValueChanged(_ oldValue: Any?) -> Bool
    
    func isDataValid(params: NSMutableDictionary) throws 
    
}

// MARK: - FieldItem extension for optional functions


extension FieldItem {
    
    public var visibleOnly: Bool{
        get{
            return false
        }
        set{
            
        }
    }
    
    public func jsonValue(fromValue value: Any?) -> Any? {
        return nil
    }
    
    public func isValueChanged(_ oldValue: Any?) -> Bool {
        return true
    }
    
    //se il campo è obbligatorio verifica che ci sia un contenuto
    //se il dato è obbligatorio e vuoto genera una eccezione
    public func isDataRequired(params: NSMutableDictionary) throws {
        
        var error = String()
        var isValidTmp = true
        
        if required {
            let value = params[key]
            if value == nil || (value as AnyObject).length == 0 || (value as? [Any])?.count == 0 {
                var field = key.localizedString()
                if field == key{
                    field = NSLocalizedString(key, comment: key)
                }
                error.append(field)
                error.append(" ")
                error.append("obbligatorio".localizedString())
                isValidTmp = false
            }
        }
        
        if(!isValidTmp) {
            throw FieldItemError.notValidData(error)
        }
    }
   
    // per i campi di base controlla solo se sono richiestie valorizzati. Per la texfield controlla anche il regex
    public func isDataValid(params: NSMutableDictionary) throws
    {
        try isDataRequired(params: params)
    }
}

/// Base FieldItem class with the purpose to be used as a container
/// of parameters.
open class FieldItemWithoutView: FieldItem {
    open var key: String
    open var coreDataKeyPath: String?
    open var placeholder: String?
    open var view: UIView? {
        return nil
    }
    open var required: Bool
    
    open var visibleOnly: Bool
    
    public init(key: String, coreDataKeyPath: String?, placeholder: String?, required: Bool = false, visibleOnly: Bool = false) {
        self.key = key
        self.coreDataKeyPath = coreDataKeyPath
        self.placeholder = placeholder
        self.required = required
        self.visibleOnly = visibleOnly
    }
    
    open func setInitialValue(_ value: Any?) {}
    open func currentValue() -> Any? {
        return nil
    }
}

// MARK: - Field item subclasses

public protocol SingleValueFieldItem: FieldItem {
    var delegate: FieldItemDelegate? { get set }
}

public protocol FieldItemWithSelection: FieldItem {
    var allValues: [ContentTypeSelectionFieldItem]? { get }
    
    var delegate: FieldItemWithSelectionDelegate? { get set }
}

// MARK: - Field item delegates

public protocol FieldItemWithSelectionDelegate: FieldItemDelegate {
    func valueToMarkAsSelected(forField fieldItem: FieldItemWithSelection) -> [ContentTypeSelectionFieldItem]?
}

public protocol FieldItemDelegate: NSObjectProtocol {
    func valueChanged(_ value: Any?, forField fieldItem: FieldItem)
}
