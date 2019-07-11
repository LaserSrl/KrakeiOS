//
//  UIViewController+Krake.swift
//  Krake
//
//  Created by joel on 10/03/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import UIKit
import LaserWebViewController

public extension UIViewController{

    /// Adds a `UIBarButtonItem` that can be used to dismiss self as `leftBarButtonItem`
    /// of the `navigationItem`.
    /// - precondition: self has been presented and it is the only view
    /// controller in the current navigation controller.
    func insertLeftNavigationItemToCloseModalDetail() {
        if navigationController?.presentingViewController != nil &&
            (navigationController?.viewControllers.count ?? 0) == 1
        {
            let button = UIBarButtonItem(barButtonSystemItem: .stop,
                                         target: self,
                                         action: #selector(UIViewController.dismissDetailViewController))
            navigationItem.leftBarButtonItem = button
        }
    }

    func insertRightNavigationItemToCloseModalDetail() {
        if navigationController?.presentingViewController != nil &&
            (navigationController?.viewControllers.count ?? 0) == 1
        {
            let button = UIBarButtonItem(barButtonSystemItem: .stop,
                                         target: self,
                                         action: #selector(UIViewController.dismissDetailViewController))
            navigationItem.rightBarButtonItem = button
        }
    }

    /**
     Utility function used to dismiss a `UIViewController` that has been
     presented via `UIViewController.present(detailViewController:detail:extras:detailDelegate:)`
     function or a `UIViewController` on which `insertLeftNavigationItemToCloseModalDetail` has
     been called.
 	*/
    @objc func dismissDetailViewController() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    /**
     Utility function used to dismiss a `UIViewController` animated and without
     the necessity of specifying a completion block.
    */
    @objc func dismissViewController() {
        let vc = presentedViewController ?? self
        vc.dismiss(animated: true, completion: nil)
    }

    /// Se il controller è presente all'interno di un UINavigationViewController apre tramite un "pushViewController" il browser con l'URL richiesto, oppure se non vi è un UINavigationViewController lo apre tramite un "presentViewController"
    /// Present a view controller with basic browser functionalities, embedded in
    /// a `UINavigationController`, starting from the page at the URL specified.
    /// - precondition: The URL must be a URL that can be opened via `UIApplication.canOpenURL(_:)`.
    /// - parameter url: URL used as first page of the browser.
    /// - parameter title: title to assign to the created view controller. The default
    /// value is the name of the application.
    func present(browserViewController url: URL,
                        title: String? = KInfoPlist.appName,
                        showToolbar: Bool = true,
                        delegate: GDWebViewControllerDelegate? = nil,
                        closeButtonIsOnLeftSide: Bool = true) {
        if UIApplication.shared.canOpenURL(url) {
            let browser = GDWebViewController()
            browser.loadURL(url)
            browser.allowsBackForwardNavigationGestures = true
            browser.showToolbar(showToolbar, animated: true)
            browser.delegate = delegate
            browser.title = title
            let closeButton = UIBarButtonItem(barButtonSystemItem: .stop,
                                              target: browser,
                                              action: #selector(UIViewController.dismissViewController))
            if closeButtonIsOnLeftSide{
                browser.navigationItem.leftBarButtonItem = closeButton
            }else{
                browser.navigationItem.rightBarButtonItem = closeButton
            }
            let nav = UINavigationController(rootViewController: browser)
            KTheme.current.applyTheme(toNavigationBar: nav.navigationBar,
                                    style: .default)
            present(nav, animated: true, completion: nil)
        } else {
            let errorMessage = String(format: "Non è possibile aprire il seguente url %@".localizedString(),
                                      url.description)
            KMessageManager.showMessage(errorMessage,
                                        type: .error)
        }
    }
    
    /// Utility function that present a `KDetailViewController` created using
    /// the given parameters.
    ///
    /// - parameter endPoint: The endpoint used to retrieve the information from
    /// Krake for the detail object.
    /// - parameter detail: The content item that will be displayed by the view
    /// controller.
    /// - parameter extras: dictionary containing extra information to send to Krake.
    /// - parameter detailDelegate: delegate of the `KDetailViewController`. If this
    /// attribute is not specified, the default `KDetailPresenterDefaultDelegate` will be used.
    func present(detailViewController endPoint: String? = nil,
                        detail: ContentItem? = nil,
                        extras: [String: Any]? = nil,
                        detailDelegate: KDetailPresenterDelegate? = KDetailPresenterDefaultDelegate(),
                        analyticsExtras: [String : Any]? = nil) {
        // Creating a new `KDetailViewController` using the factory with the given
        // parameters.
        if let vc = KDetailViewControllerFactory.factory
            .newDetailViewController(detailObject: detail,
                                     endPoint: endPoint,
                                     extras: extras,
                                     detailDelegate: detailDelegate,
                                     analyticsExtras: analyticsExtras) {
            // Embedding the generated detail view controller in a `UINavigationController`.
            let nav = UINavigationController(rootViewController: vc)
            KTheme.current.applyTheme(toNavigationBar: nav.navigationBar, style: .default)
            nav.modalPresentationStyle = .formSheet
            // Adding the button to close the presented view controller.
            vc.navigationItem
                .leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                     target: self,
                                                     action: #selector(UIViewController.dismissViewController))
            present(nav, animated: true, completion: nil)
        }
    }
    
    /// Utility function that present a Gallery Controller created using the given parameters.
    ///
    /// - Parameters:
    ///   - withImages: array of images to show
    ///   - selectedIndex: index of first element to show in fullscreen mode
    ///   - target: UIView to use as a source of the transition
    ///   - callback: block to be invoke at the gallery controller closing
    func present(galleryController withImages: [Any],
                        selectedIndex: Int = 0,
                        target: UIImageView? = nil,
                        callback: KGalleryCallback? = nil )
    {
        if let gallery = KGallery.galleryViewController(images: withImages, selectedIndex: selectedIndex, target: target, callback: callback)
        {
            (UIApplication.shared.delegate as! KAppDelegate).lockInterfaceOrientationMask = .all
            present(galleryController: gallery, animated: true, completion: nil)
        }
    }
}
