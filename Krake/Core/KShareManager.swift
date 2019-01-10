//
//  KShareManager.swift
//  Krake
//
//  Created by Patrick on 28/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//
import Foundation
import MBProgressHUD
import Social

/**
 Handles the share actions using the system `UIActivityViewController` to present
 the share opportunities to the user.
*/
open class KShareManager {
	/**
     Presents the view controller `UIActivityViewController` to share the content
     via the available extensions.
    
     - Parameters:
       - content: The object containing the information to share. If any image URL
     is defined, that image is downloaded before opening any share view controller.
       - otherItems: additional information that will compose the items that will
     be shared.
       - activities: Additional activities that the user can choose to share the
     content.
       - sender: Object that has triggered the share action. If this is a `UIView`
     or a `UIBarButtonItem`, it is used as origin for the presentation of the `UIActivityViewController`
     on an iPad.
       - fromViewController: The view controller that has triggered the share action.
     It is used to present the `UIActivityViewController`.
 	*/
    public static func share(content: ShareProtocol,
                           otherItems: [AnyObject]? = nil,
                           activities: [UIActivity]? = nil,
                           sender: AnyObject,
                           fromViewController: UIViewController) {
        DispatchQueue.main.async {
            // Preparing the items to share using the given content.
            var itemsToShare = [AnyObject]()
            if let sharedText = content.sharedText, !sharedText.isEmpty {
                itemsToShare.append(sharedText.htmlToString() as AnyObject)
            }
            if let sharedLink = content.sharedLink, !sharedLink.isEmpty, let shareLinkURL = URL(string: sharedLink) {
                itemsToShare.append(shareLinkURL as AnyObject)
            }
            // Adding the additional information that should be shared.
            if let otherItems = otherItems {
				itemsToShare.append(contentsOf: otherItems)
            }
            // Creating the name of the event that will be sent to the analytics
            // service.
            let logName = otherItems?.first != nil ? String(describing: type(of: otherItems!.first!)) : content.sharedText ?? "Contenuto generico"
            // Downloading the image to share, if any.
            if let sharedImage = content.sharedImage,
                let sharedURL = URL(string: sharedImage), !sharedImage.isEmpty {
                // Presenting a progress view while downloading the image.
                DispatchQueue.main.async {
                    MBProgressHUD.showAdded(to: fromViewController.view, animated: true)
                }
                // Downloading the image.
                UIImage.downloadImage(sharedURL) { (image, error, cacheType, url) in
                    // Adding to the items to share the downloaded image, if any.
                    if image != nil {
                        itemsToShare.insert(image!, at: 0)
                    }
                    // Hiding the progress view and presenting the view controller
                    // to share the content.
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: fromViewController.view, animated: true)
                        share(items: itemsToShare,
                              using: activities,
                              from: sender,
                              in: fromViewController,
                              logName: logName)
                    }
                }
            } else {
                // Presenting the view controller to share the content.
                DispatchQueue.main.async {
                    share(items: itemsToShare,
                          using: activities,
                          from: sender,
                          in: fromViewController,
                          logName: logName)
                }
            }
        }
    }

    fileprivate static func share(items itemsToShare: [AnyObject],
                                  using customActivities: [UIActivity]?,
                                  from sender: AnyObject,
                                  in sourceViewController: UIViewController,
                                  logName: String) {
        // Creating the UIActivityViewController for the items to share.
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: customActivities)
        // Setting a completion handler that will be called when the user will
        // select any item from the activity controller.
        activityViewController.completionWithItemsHandler = { (activityType, completed, returndItems, activityError) in
            if completed {
                AnalyticsCore.shared?.log(share: activityType?.rawValue ?? "Condivisione",
                                          contentType: logName,
                                          itemId: nil,
                                          parameters: nil)
            }
        }
        // Excluding activity types that are unsupported by the KShareManager.
        activityViewController.excludedActivityTypes = [.assignToContact]
        // Checking if the device is an iPad. In that case, the UIActivityViewController
        // should be presented modally.
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.modalPresentationStyle = .popover
            // Based on the sender's type, setting the source point of the presentation,
            // if a popover presentation controller is specified for the UIActivityViewController.
            if let popoverPresentationController = activityViewController.popoverPresentationController {
                if let buttonItem = sender as? UIBarButtonItem {
                    popoverPresentationController.barButtonItem = buttonItem
                } else if let view = sender as? UIView {
                    popoverPresentationController.sourceView = view
                    popoverPresentationController.sourceRect = view.frame
                } else if let rightItem = sourceViewController.navigationItem.rightBarButtonItem {
                    popoverPresentationController.barButtonItem = rightItem
                }
            }
        }
        // Presenting the UIActivityViewController.
        sourceViewController.present(activityViewController, animated: true, completion: nil)
    }
}
