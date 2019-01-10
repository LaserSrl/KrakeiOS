//
//  UIImageView+Krake.swift
//  Krake
//
//  Created by Marco Zanino on 01/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import SDWebImage
import MBProgressHUD
import LaserVideoPhotoGallery

@objc public enum KImageCacheType : NSInteger {
    case none
    case disk
    case memory
}
public typealias KICompletionBlock = (UIImage?, Error?, KImageCacheType, URL?) -> Void

public extension UIImageView{

    public convenience init(image: UIImage?, contentMode: KViewContentMode!){
        self.init(image: image)
        self.contentMode = contentMode
    }

    public func setImage(media: Any? = nil,
                         placeholderImage: UIImage? = KTheme.current.placeholder(.default),
                         options: KMediaImageLoadOptions = KMediaImageLoadOptions(),
                         sdOptions: SDWebImageOptions = [.allowInvalidSSLCertificates, .retryFailed],
                         completed: KICompletionBlock? = nil){
        image = placeholderImage
        var targetUrl: URL? = nil
        switch media {
        case is URL:
            targetUrl = media as? URL
        case is NSURL:
            targetUrl = media as? URL
        case is String:
            targetUrl = KMediaImageLoader.generateURL(forMediaPath: media as? String, mediaImageOptions: options, imageView: self)
        case is YoutubeVideoProtocol:
            let youtube = media as! YoutubeVideoProtocol
            backgroundColor = UIColor(red: 0.8691, green: 0.8691, blue: 0.8691, alpha: 1.0)
            image = KTheme.current.placeholder(.video)?.imageTinted(KTheme.current.color(.tint).withAlphaComponent(0.955))
            if let video = youtube.videoUrlValue{
                MHGallerySharedManager.sharedInstance().startDownloadingThumbImage(video) { (image, intero, error) in
                    if image != nil{
                        self.image = image!.addWatermark(MHGalleryImage("playButton"), fill: .none, position: .center)
                        completed?(self.image, nil, .disk, nil)
                    }
                }
            }
        case is MediaPartProtocol:
            let mediaImage = media as! MediaPartProtocol
            if let types = mediaImage.mimeType?.components(separatedBy: "/"), let type = types.first, let mediaUrl = mediaImage.mediaUrl{
                switch type{
                case "text":
                    if mediaUrl.hasPrefix("Vimeo"){
                        backgroundColor = UIColor(red: 0.8691, green: 0.8691, blue: 0.8691, alpha: 1.0)
                        image = KTheme.current.placeholder(.video)?.imageTinted(KTheme.current.color(.tint).withAlphaComponent(0.955))
                        if let streamingProviderSupplier = UIApplication.shared.delegate as? KStreamingProviderSupplier {
                            do {
                                let provider = try streamingProviderSupplier.getStreamingProvider(fromSource: mediaUrl)
                                if let videoURL = provider.retrieveVideoURL(from: mediaUrl) {
                                    MHGallerySharedManager.sharedInstance().startDownloadingThumbImage(videoURL) { (image, intero, error) in
                                        if image != nil{
                                            self.image = image!.addWatermark(MHGalleryImage("playButton"), fill: .none, position: .center)
                                            completed?(self.image, nil, .disk, nil)
                                        }
                                    }
                                }
                            } catch {}
                        }
                    }
                case "video":
                    backgroundColor = UIColor(red: 0.8691, green: 0.8691, blue: 0.8691, alpha: 1.0)
                    image = KTheme.current.placeholder(.video)?.imageTinted(KTheme.current.color(.tint).withAlphaComponent(0.955))
                    if let mediaUrl = mediaImage.mediaUrl {
                        let url: String
                        if mediaUrl.hasPrefix("http") {
                            url = mediaUrl
                        } else {
                            url = KInfoPlist.KrakePlist.path
                                .appendingPathComponent(mediaUrl.removingPercentEncoding ?? "")
                                .absoluteString
                        }
                        MHGallerySharedManager.sharedInstance().startDownloadingThumbImage(url) { (image, intero, error) in
                            if image != nil{
                                self.image = image!.addWatermark(MHGalleryImage("playButton"), fill: .none, position: .center)
                                completed?(self.image, nil, .disk, nil)
                            }
                        }
                    }
                case "audio":
                    backgroundColor = UIColor(red: 0.8691, green: 0.8691, blue: 0.8691, alpha: 1.0)
                    tintColor = UIColor.darkGray
                    image = KTheme.current.placeholder(.audio)
                    completed?(image, nil, .disk, nil)
                case "image":
                    targetUrl = KMediaImageLoader.generateURL(forMediaPath: mediaImage.mediaUrl, mediaImageOptions: options, imageView: self)
                default:
                    break
                }
            }
        case is NSNumber:
            targetUrl = KMediaImageLoader.generateURL(forMediaPath: String(format: "%ld", (media as! NSNumber).int64Value), mediaImageOptions: options, imageView: self)
        case is UIImage:
            image = media as? UIImage
            completed?(image, nil, .none, nil)
        default:
            break
        }
        if targetUrl != nil {
            sd_setImage(with: targetUrl, placeholderImage: placeholderImage, options: sdOptions, progress: nil) { (image, error, cacheType, url) in
                completed?(image, error, KImageCacheType(rawValue: cacheType.rawValue)!, url)
            }
        }
    }
    
}
