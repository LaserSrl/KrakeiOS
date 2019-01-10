//
//  ContentItemWithYoutubeVideo.swift
//  OrchardGen
//
//  Created by Patrick on 18/05/17.
//  Copyright © 2017 Dream Team. All rights reserved.
//

import Foundation

public protocol ContentItemWithYoutubeVideo : ContentItem {
    var youtubeVideoContentItems: NSOrderedSet? {get}
}
