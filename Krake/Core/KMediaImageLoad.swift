//
//  KMediaImageLoad.swift
//  Krake
//
//  Created by joel on 02/09/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation

open class KMediaImageLoader: NSObject {
    
    fileprivate static let serviceUrl : URL = {
        return KInfoPlist.KrakePlist.path
            .appendingPathComponent(KAPIConstants.imageBasePath)
    }()
    
    fileprivate static let screenScale : CGFloat = {let scale = UIScreen.main.scale; return scale > 1 ? scale : 2.0 }()
    
    fileprivate static let defaultImageSize : CGSize = { return CGSize(width: 512 * screenScale, height: 512 * screenScale) }()
    
    open class func generateURL(forMediaPath mediaPath: String?, mediaImageOptions options: KMediaImageLoadOptions, imageView: UIImageView? = nil) -> URL?
    {
        guard let mediaPath = mediaPath else { return nil }
        
        if let mediaURL = URL(string: mediaPath) {
            if !((mediaURL.scheme?.isEmpty) ?? true) {
                return mediaURL
            }
        }
        
        var size: CGSize = options.size
        
        if __CGSizeEqualToSize(options.size, CGSize.zero)
        {
            if let imageSize = imageView?.bounds.size , !__CGSizeEqualToSize(imageSize, CGSize.zero) {
                
                size = CGSize(width: imageSize.width * screenScale, height: imageSize.height * screenScale)
            }
            else {
                size = defaultImageSize
            }
        }
        
        let escapedPath = mediaPath.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
        
        return URL(string: String(format: "%@?Path=%@&Width=%.0f&Height=%.0f&Mode=%@&Alignment=%@", serviceUrl.description, escapedPath!, size.width, size.height, options.mode.rawValue, options.alignement.rawValue))
    }
    
    open class func objc_generateURL(forMediaPath mediaPath: String?, imageView: UIImageView?, size: CGSize) -> URL?
    {
        return generateURL(forMediaPath: mediaPath, mediaImageOptions: KMediaImageLoadOptions(size: size), imageView: imageView)
    }
}

public struct KMediaImageLoadOptions
{
    public var size : CGSize
    public var alignement : ImageAlignement
    public var mode : ImageResizeMode
    
    public init (size: CGSize = CGSize.zero, mode: ImageResizeMode = .Crop, alignement : ImageAlignement = .MiddleCenter)
    {
        self.size = size
        self.mode = mode
        self.alignement = alignement
    }
}

public enum ImageResizeMode : String {
    case Crop = "crop"
    case Max = "max"
    case Stretch = "stretch"
    case Pan = "pan"
}

public enum ImageAlignement : String {
    
    case TopLeft = "topleft"
    case TopCenter = "topcenter"
    case TopRight = "topright"
    
    case MiddleLeft = "middleleft"
    case MiddleCenter = "middlecenter"
    case MiddleRight = "middleright"
    
    case BottomLeft = "bottomleft"
    case BottomCenter = "bottomcenter"
    case BottomRight = "bottomright"
}
