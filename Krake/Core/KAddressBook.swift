//
//  OCAddressBook.swift
//  OrchardCore
//
//  Created by Patrick on 20/11/15.
//  Copyright © 2015 Laser Group srl. All rights reserved.
//

import Foundation
import AddressBookUI
import AddressBook

@available(iOS, deprecated: 9.0, message: "use KContactPicker")
class KAddressBook: NSObject, ContactPicker, ABPeoplePickerNavigationControllerDelegate {
    
    @available(iOS, deprecated: 9.0, message: "use KContactPicker")
    fileprivate var addressPicker: ABPeoplePickerNavigationController? = nil
    fileprivate var completion: CompletionBlock!
    
    @available(iOS, deprecated: 9.0, message: "use KContactPicker")
    func presentListOfContacts(_ navigation: UINavigationController, completion: @escaping CompletionBlock){
        addressPicker = ABPeoplePickerNavigationController()
        addressPicker!.peoplePickerDelegate = self
        addressPicker!.modalPresentationStyle = .formSheet
        addressPicker!.displayedProperties = [NSNumber(value: kABPersonEmailProperty.hashValue)]
        addressPicker!.predicateForEnablingPerson = NSPredicate(format:"%K.@count > 0", argumentArray: [ABPersonEmailAddressesProperty])
        self.completion = completion
        navigation.present(addressPicker!, animated: true, completion: nil)
    }
    
    @available(iOS, deprecated: 9.0, message: "use KContactPicker")
    func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord, property: ABPropertyID, identifier: ABMultiValueIdentifier){
        if property == kABPersonEmailProperty {
            let unmanagedEmails = ABRecordCopyValue(person, kABPersonEmailProperty)
            let emails: ABMultiValue = Unmanaged.fromOpaque(unmanagedEmails!.toOpaque()).takeUnretainedValue() as NSObject as ABMultiValue
            let unmanagedEmail = ABMultiValueCopyValueAtIndex(emails, identifier.hashValue)
            let email: String = Unmanaged.fromOpaque( unmanagedEmail!.toOpaque()).takeUnretainedValue() as NSObject as! String
            let unmanagedName = ABRecordCopyValue(person, kABPersonFirstNameProperty)
            let name: String = Unmanaged.fromOpaque( unmanagedName!.toOpaque()).takeUnretainedValue() as NSObject as! String
            completion(name, email)
        }
    }
    
}
