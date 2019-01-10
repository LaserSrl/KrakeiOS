//
//  Report.swift
//  Krake
//
//  Created by Marco Zanino on 26/05/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import MapKit.MKAnnotation

public protocol Report: ContentItemWithGallery, ContentItemWithDescription, MKAnnotation {
    var sottotitoloValue : String? { get }

    func publishExtensionPartPublishExtensionStatusReference()-> EnumerationFieldProtocol?
}

public extension Report {
    var sottotitoloValue : String? { return nil }
    var youtubeVideoContentItems: NSOrderedSet? { return nil }

    func publishExtensionPartPublishExtensionStatusReference()-> EnumerationFieldProtocol? {
        return value(forKey: "publishExtensionPartPublishExtensionStatus") as? EnumerationFieldProtocol
    }
}
