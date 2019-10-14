//
//  OCTermPinImageDownloader.swift
//  OrchardCore
//
//  Created by joel on 09/03/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import SDWebImage

class KTermPinImageDownloader: NSObject {
    
    static var sharedDownloader = KTermPinImageDownloader()
    
    fileprivate var imagesInDownload = [String]()
    
    func startImageDownload(_ url:URL, identifier: String)
    {
        if imagesInDownload.firstIndex(of: identifier) == nil {
            imagesInDownload.append(identifier)
            SDWebImageDownloader.shared.downloadImage(with: url, options: SDWebImageDownloaderOptions.useNSURLCache, progress: nil, completed: { (image, data, error, finished) -> Void in
                if(finished)
                {
                    SDImageCache.shared.store(image, forKey: identifier)
                }
                
                self.imagesInDownload.remove(at: self.imagesInDownload.firstIndex(of: identifier)!);
            })
            
        }
    }
}
