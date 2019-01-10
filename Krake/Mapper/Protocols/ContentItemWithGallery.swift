//
//  ContentItemWithGallery.swift
//  Pods
//
//  Created by joel on 30/01/17.
//
//

import Foundation

public protocol ContentItemWithGallery: ContentItem {
    var galleryMediaParts: NSOrderedSet? {get}
}
