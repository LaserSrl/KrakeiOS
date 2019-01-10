//
//  ContentItemWithContacts.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol ContentItemWithContacts : ContentItem {
    var telefonoValue: String? {get}
    var sitoWebValue: String? {get}
    var eMailValue: String? {get}
}
