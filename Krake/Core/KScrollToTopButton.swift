//
//  ScrollToTopButton.swift
//  OrchardCore
//
//  Created by Patrick on 06/08/15.
//  Copyright (c) 2015 Laser Group srl. All rights reserved.
//

import Foundation
import UIKit

public typealias ButtonAction = (_ button : UIButton?, _ inView : UIView?) -> Void

/**
 Used to create, and hold, a button with a FAB style. Usually this button will
 be used by a view controller with a `UIScrollView` in its view hierarchy to fast
 scroll to the top of the scroll view's content.
*/
open class KScrollToTopButton: NSObject {
    /// Closure called when `scrollToTopButton` is touched.
    private var mainCompletion : ButtonAction!
    /// Button for the scroll to top action. It is created when a valid reference
    /// of `view` is given.
    open var scrollToTopButton: UIButton?
    /// Parent view of the `scrollToTopButton`.
    private var view: UIView!

    /**
     Generates the button and add it to the view hierarchy.

     - parameter view: The view used to add the generated button to the view hierarchy.
     - parameter completion: The completion that will be called after the user touch the
     button.
     */
    open func generateButton(in view: UIView, completion : @escaping ButtonAction) {
        mainCompletion = completion
        self.view = view
        addButton(to: view)
    }

    /**
     Create the button and attach it to the view hierarchy.
     
     - attention:
     Never use this method directly, use `generateButton(in:completion:)` instead.
     
     - parameter view: The `UIView` used to attach the button to the view hierarchy.
     If this view has a superview, the superview is used as superview of the created
     button, otherwise the view itself is used as superview of the button.
 	*/
    open func addButton(to view: UIView) {
        // Creating the button.
        let scrollToTopButton = UIButton(frame: CGRect(origin: .zero,
                                                       size: CGSize(width: 36,
                                                                    height: 36)))
        scrollToTopButton.translatesAutoresizingMaskIntoConstraints = false
        // Adding colors and normal image.
        scrollToTopButton.setImage(KAssets.Images.scrollTop.image,
                                   for: .normal)
        // Setting the target of touchUpInside event.
        scrollToTopButton.addTarget(self,
                                    action: #selector(KScrollToTopButton.scrollToTop),
                                    for: .touchUpInside)
        // Initially hiding the button. Its visibility will be setted by the
        // view controller that handles the container view.
        scrollToTopButton.alpha = 0.0
        KTheme.current.applyTheme(toButton: scrollToTopButton, style: .fabButton)
        // Modifying layer to simulate a FAB as defined by Material Design.
        // Adding shadows.
        let drawingRect = scrollToTopButton.frame
        let pathRect = CGRect(origin: CGPoint(x: drawingRect.origin.x + 1,
                                              y: drawingRect.origin.y + 1),
                              size: drawingRect.size)
        let path = CGPath(roundedRect: pathRect,
                          cornerWidth: drawingRect.width * 0.5,
                          cornerHeight: drawingRect.height * 0.5,
                          transform: nil)
        scrollToTopButton.layer.shadowPath = path
        scrollToTopButton.layer.shadowOffset = .zero
        scrollToTopButton.layer.shadowColor = UIColor.black.cgColor
        scrollToTopButton.layer.shadowRadius = 2.0
        scrollToTopButton.layer.shadowOpacity = 0.5
        // Making the button round.
        scrollToTopButton.layer.cornerRadius = 18.0
		// Adding the button to the container view.
        let containerView = view.superview ?? view
        containerView.addSubview(scrollToTopButton)
        // Adding constraints to position the button at the bottom right edge
        // of the container view.
        containerView.addConstraints([
            view.bottomAnchor.constraint(equalTo: scrollToTopButton.bottomAnchor, constant: 12),
            view.trailingAnchor.constraint(equalTo: scrollToTopButton.trailingAnchor, constant: 12),
            scrollToTopButton.widthAnchor.constraint(equalToConstant: 36),
            scrollToTopButton.heightAnchor.constraint(equalToConstant: 36)
            ])
        // Saving a reference to the created button for future usages.
        self.scrollToTopButton = scrollToTopButton
    }

    /**
     Invokes the closure that were give in the button generation phase (i.e. call
     to function `generateButton(_:completion:)`.
     This function is called after the event `touchUpInside` occurs.
     */
    @objc dynamic func scrollToTop() {
        mainCompletion(scrollToTopButton, view)
    }
    
}

//Mark: - Deprecated
@available(*, deprecated, renamed:"KScrollToTopButton")
open class ScrollToTopButton: KScrollToTopButton {}
