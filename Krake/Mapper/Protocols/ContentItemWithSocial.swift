//
//  ContentItemWithSocial.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol ContentItemWithSocial : ContentItem {
    var facebookValue: String? {get}
    var twitterValue: String? {get}
    var pinterestValue: String? {get}
    var instagramValue: String? {get}
}
