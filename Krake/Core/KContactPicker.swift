//
//  KContactPicker.swift
//  Krake
//
//  Created by Patrick on 09/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import ContactsUI
import Contacts

public typealias CompletionBlock = (_ name: String?, _ email: String?) -> Void

public protocol ContactPicker: NSObjectProtocol{
    func presentListOfContacts(_ navigation: UINavigationController, completion: @escaping CompletionBlock)
}

@available(iOS 9, *)
open class KContactPicker: NSObject, ContactPicker, CNContactPickerDelegate{
    
    fileprivate var addressPicker: CNContactPickerViewController? = nil
    fileprivate var completion: CompletionBlock!
    
    open func presentListOfContacts(_ navigation: UINavigationController, completion: @escaping CompletionBlock){
        self.completion = completion
        addressPicker = CNContactPickerViewController()
        addressPicker?.delegate = self
        addressPicker?.modalPresentationStyle = .formSheet
        addressPicker?.displayedPropertyKeys = [CNContactEmailAddressesKey]
        addressPicker?.predicateForEnablingContact = NSPredicate(format:"%K.@count > 0", argumentArray: ["emailAddresses"])
        navigation.present(addressPicker!, animated: true, completion: nil)
    }
    
    open func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        let contact = contactProperty.contact
        let mail = contactProperty.value as! String
        let name = contact.givenName
        completion(name, mail)
        KLog(mail)
    }
    
    
}
