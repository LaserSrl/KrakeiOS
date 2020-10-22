//
//  KDetailWebView.swift
//  Krake
//
//  Created by Marco Zanino on 06/03/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import UIKit
import WebKit

/*
 Display a String value from the detailObject in a WebView.
 Normally the bodyPart of ContentItemWithDescription will be displayed.
 You can change the element displayed by settting the keyPathToLoad
 */
open class KDetailWebView: KWebView, KDetailViewProtocol, KDetailViewSizeChangesListener {


    /// Show a different value instead of bodyPart
    @IBInspectable var keyPathToLoad: String? = nil

    open weak var detailPresenter: KDetailPresenter?
    open var detailObject: AnyObject? {
        didSet {
            updateDisplayedContent(using: detailObject)
        }
    }

    internal weak var heightConstraint: NSLayoutConstraint?

    // MARK: - Initializers

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        // Creazione del constraint che verrà utilizzato per assegnare un'altezza
        // fissa.
        let heightConstraint = heightAnchor.constraint(equalToConstant: 50)
        heightConstraint.priority = UILayoutPriority.priority(999)
        addConstraint(heightConstraint)
        self.heightConstraint = heightConstraint
        KTheme.current.applyTheme(toView: self, style: .detailBodyView)
    }

	// MARK: - Internal web view

    override open func prepareWebView(using configuration: WKWebViewConfiguration) -> WKWebView {
        let webView = super.prepareWebView(using: configuration)
        webView.scrollView.bounces = false
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    // MARK: - Content handling

    private func updateDisplayedContent(using content: AnyObject?) {

        let body: String?

        if keyPathToLoad == nil {
            body = (content as? ContentItemWithDescription)?.bodyPart()
        }
        else if let keyPath = keyPathToLoad
        {
            body = content?.value(forKeyPath: keyPath) as? String
        }
        else {
            body = nil
        }

        if let body = body {
            let stringStyle = KInfoPlist.detailBodyStyle
            
            let fontSize = String(format: "%.f", UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body).pointSize)
            
            let stringHTML =
                "<html><head></head><body>" +
                    String(format: "<div style='%@; font-size:%@px;'>", stringStyle, fontSize) +
                    body +
                    "</div></body></html>"
            _ = internalWebView?.loadHTMLString(stringHTML, baseURL: nil)
            hiddenAnimated = false
        } else {
            hiddenAnimated = true
        }
    }

    // MARK: - WKWebView navigation delegate

    open override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        super.webView(webView, didFinish: navigation)
        invalidateWebViewHeight()
    }

    // MARK: - KDetailViewSizeChangesListener implementation

    public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { [unowned self] (_) in
            self.heightConstraint?.constant = 50.0
            self.setNeedsUpdateConstraints()
            self.internalWebView?.setNeedsLayout()
            self.updateDisplayedContent(using: self.detailObject)
        }
    }

    // MARK: - Web view utils

    internal final func invalidateWebViewHeight() {
        // Aggiornamento dell'altezza di modo che tutto il contenuto della
        // web view sia visibile, dal momento che lo scroll è disabilitato.
        internalWebView?
            .evaluateJavaScript("Math.max(document.body.offsetHeight, document.body.scrollHeight);",
                                completionHandler: { [weak self] (result, error) in
                                    guard let height = result as? Int,
                                        let strongSelf = self else {
                                            return
                                    }

                                    DispatchQueue.main.async {
                                        strongSelf.heightConstraint?.constant = CGFloat(height)
                                        strongSelf.setNeedsUpdateConstraints()
                                    }
            })
        
        
    }

}
