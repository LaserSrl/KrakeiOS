//
//  OCGallery.swift
//  OrchardCore
//
//  Created by Patrick on 03/09/15.
//  Copyright © 2015 Laser Group srl. All rights reserved.
//
public typealias KGalleryCallback = (NSInteger) -> UIImageView?

import Foundation
import LaserVideoPhotoGallery.MHGalleryController
import CryptoSwift

open class KGallery {

    // Empty public constructor for initializer accessibility.
    public init() {}

    @available(*, deprecated, renamed: "present(galleryController:selectedIndex:target:callback:)")
    public static func openCollectionFullScreen(_ viewController: UIViewController,
                                              images: NSOrderedSet?,
                                              selectedIndex: NSInteger,
                                              target: UIImageView? = nil,
                                              callback: KGalleryCallback? = nil) {
        // Checking if images are available.
        if let images = images, images.count > 0 {
            let vc = viewController.presentedViewController ?? viewController
            vc.present(galleryController: images.array, selectedIndex: selectedIndex, target: target, callback: callback)
        }
    }

    /**
     Prepare the view controller  gallery with the given medias.
     The first time the gallery is opened, the media at `selectedIndex`
     will be presented full screen.
     
     - parameter images: The `NSOrderedSet` containing the medias to show in the
     gallery. The following are the classes or protocols supported by the gallery:
     `Data`, `UIImage`, `YoutubeVideoProtocol`, `MediaPartProtocol`, `String`,
     `NSInteger` and `URL`.
     - parameter selectedIndex: The index of the media that will be presented when
     the gallery will first show.
     - parameter target: The source `UIImageView` of the presentation.
     - parameter callback: The closure that returns the `UIImageView` focused
     after the gallery is dismissed.
     
     - precondition: The set of `images` must not be empty or nil.
     */
    public static func galleryViewController(images: [Any],
                                      selectedIndex: Int = 0,
                                      target: UIImageView? = nil,
                                      callback: KGalleryCallback? = nil) -> MHGalleryController?
    {
        if images.count == 0
        {
            return nil
        }
        let orientationMode = (UIApplication.shared.delegate as! KAppDelegate).lockInterfaceOrientationMask
        // Preparing the items that will be shown by the gallery.
        var array = [MHGalleryItem]()
        for image in images {
            // If the image is a URL, its relative string is used to create
            // the item, otherwise the image itself is used.
            let img = (image as? URL)?.relativeString ?? image
            // Creating the item of the gallery based on the image class.
            switch img {
            case is Data:
                array.append(MHGalleryItem(image: UIImage(data: img as! Data)))
            case is UIImage:
                array.append(MHGalleryItem(image: (img as! UIImage)))
            case is YoutubeVideoProtocol:
                array.append(MHGalleryItem(url: (img as! YoutubeVideoProtocol).videoUrlValue,
                                           galleryType: .video))
            case is MediaPartProtocol:
                var item: MHGalleryItem? = nil
                let mediaImage = img as! MediaPartProtocol
                
                if let types = mediaImage.mimeType?.components(separatedBy:"/"),
                    let type = types.first,
                    let mediaUrl = mediaImage.mediaUrl {
                    switch type {
                    case "text":
                        if mediaUrl.hasPrefix("Vimeo") {
                            if let streamingProviderSupplier = UIApplication.shared.delegate as? KStreamingProviderSupplier {
                                do {
                                    let provider = try streamingProviderSupplier.getStreamingProvider(fromSource: mediaUrl)
                                    if let videoURL = provider.retrieveVideoURL(from: mediaUrl) {
                                        item = MHGalleryItem(url: videoURL,
                                                             galleryType: .video)
                                    }
                                } catch KStreamingProviderErrors.unknownProvider {
                                    KLog(type: .error, "No streaming provider found for the media %@.", mediaUrl)
                                } catch KStreamingProviderErrors.malformedProviderString {
                                    KLog(type: .error, "Malformed provider string representation found for the media %@.", mediaUrl)
                                } catch _ {}
                            }
                        }else{
                            item = MHGalleryItem(url: mediaUrl, galleryType: .video)
                        }
                    case "video", "audio":
                        let url: String
                        if mediaUrl.hasPrefix("http") {
                            url = mediaUrl
                        } else {
                            url = KInfoPlist.KrakePlist.path
                                .appendingPathComponent(mediaUrl.removingPercentEncoding ?? "")
                                .absoluteString
                        }
                        item = MHGalleryItem(url: url,
                                             galleryType: .video)
                    case "image":
                        let url: String?
                        if mediaUrl.hasPrefix("http") {
                            url = mediaUrl
                        } else {
                            let imageOptions = KMediaImageLoadOptions(size: CGSize(width:3000,
                                                                                   height: 3000),
                                                                      mode: .Pan)
                            url = KMediaImageLoader
                                .generateURL(forMediaPath: mediaUrl,
                                             mediaImageOptions: imageOptions)?.description
                        }
                        item = MHGalleryItem(url: url,
                                             galleryType: .image)
                    default:break
                    }
                }
                if item != nil {
                    array.append(item!)
                }
            case is String:
                var added: Bool = false
                if (img as! String).contains("www.youtube.com") {
                    let arrayString = (img as! String).components(separatedBy: "v=")
                    if arrayString.count > 0 {
                        let videoID: String! = arrayString.last
                        array.append(MHGalleryItem(youtubeVideoID: videoID))
                        added = true
                    }
                }
                if !added {
                    let url = URL(string: img as! String)!
                    if ["mp4", "m4a", "mov", "avi", "aac"].contains(url.pathExtension.lowercased()) {
                        array.append(MHGalleryItem(url: (img as! String),
                                                   galleryType: MHGalleryType.video))
                    } else {
                        array.append(MHGalleryItem(url: (img as! String),
                                                   galleryType: MHGalleryType.image))
                    }
                }
            case is NSInteger:
                let url = KMediaImageLoader.generateURL(forMediaPath: String(format: "%d", locale: nil, (img as! NSInteger)),
                                                        mediaImageOptions: KMediaImageLoadOptions(size: CGSize(width: 3000,height: 3000),
                                                                                                  mode: .Pan))
                array.append(MHGalleryItem(url: url!.description, galleryType: MHGalleryType.image))
            default:break
            }
        }
        let fakeNavigationBar = UINavigationBar()
        KTheme.current.applyTheme(toNavigationBar: fakeNavigationBar, style: .gallery)
        let customStyle =  MHUICustomization()
        customStyle.barTintColor = fakeNavigationBar.barTintColor
        customStyle.barButtonsTintColor = fakeNavigationBar.tintColor
        customStyle.barTitleTextAttributes = fakeNavigationBar.titleTextAttributes
        customStyle.showMHShareViewInsteadOfActivityViewController = false
        customStyle.showOverView = array.count > 1 ? true : false
        let gallery = MHGalleryController(presentationStyle: MHGalleryViewMode.imageViewerNavigationBarHidden)!
        gallery.galleryItems = array
        gallery.presentingFromImageView = target
        gallery.presentationIndex = array.count != images.count ? 0 : selectedIndex
        gallery.preferredStatusBarStyleMH = UIApplication.shared.statusBarStyle
        gallery.uiCustomization = customStyle
        gallery.finishedCallback = { (index, image, transition, viewMode) in
            DispatchQueue.main.async {
                (UIApplication.shared.delegate as! KAppDelegate).lockInterfaceOrientationMask = orientationMode
                var dismissImageView = target
                if callback != nil {
                    let imageView = callback!(index)
                    if imageView != nil {
                        dismissImageView = imageView
                    }
                }
                gallery.dismiss(animated: true, dismiss: dismissImageView) {
                    if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
                        MHStatusBar().alpha = 1.0
                    }
                }
            }
        }
        return gallery
    }
}
