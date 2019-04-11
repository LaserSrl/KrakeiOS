//
//  KWebView.swift
//  Pods
//
//  Created by Marco Zanino on 01/03/2017.
//
//

import UIKit
import WebKit

open class KWebView: UIView, WKNavigationDelegate, UIScrollViewDelegate {

    open private(set) var configuration: WKWebViewConfiguration

    internal weak var internalWebView: WKWebView?

    // MARK: - Initializers

    override init(frame: CGRect) {
        configuration = WKWebViewConfiguration.default
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        configuration = WKWebViewConfiguration.default
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit{
        internalWebView?.scrollView.delegate = nil
    }

    private func commonInit() {
        // Creazione della web view secondo la configurazione di default.
        createWebView(from: configuration)
    }

    // MARK: - WKWebView configuration update

    open func updateConfiguration(_ configuration: WKWebViewConfiguration) {
        self.configuration = configuration
        invalidateInternalWebView()
    }

    // MARK: - UI utils

    private func invalidateInternalWebView() {
        // Rimozione dell'istanza di web view precedente.
        if let internalWebView = internalWebView {
            internalWebView.removeFromSuperview()
        }
        // Rigenerazione della web view.
        createWebView(from: configuration)
    }

    private func createWebView(from configuration: WKWebViewConfiguration) {
        // Creazione della nuova istanza di web view con le configurazioni
        // aggiornate.
        let webView = prepareWebView(using: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isOpaque = false
        // Aggiunta della web view alla gerarchia.
        addSubview(webView)
        // Assegnazione dei constraints di modo che la web view occupi esattamente
        // tutto lo spazio della superview.
        addConstraints([
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-0-[wv]-0-|",
                options: .directionLeftToRight,
                metrics: nil,
                views: ["wv" : webView]),
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[wv]-0-|",
                options: .directionLeftToRight,
                metrics: nil,
                views: ["wv" : webView])
            ].flatMap({ $0 }))
        // Aggiorno la reference alla web view.
        internalWebView = webView
        KTheme.current.applyTheme(toView: webView, style: .webView)
    }

    internal func prepareWebView(using configuration: WKWebViewConfiguration) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.delegate = self
        return webView
    }

    // MARK: - Content handling

    open func loadHTMLString(_ string: String, baseURL: URL? = nil) {
        _ = internalWebView?
            .loadHTMLString(string,
                            baseURL: baseURL)
    }

    // MARK: - WKWebView navigation delegate

    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Modifica del colore dei testi dei link in modo dinamico, poiché i link
        // generati dai data detector presentano un proprio style.
        webView.evaluateJavaScript("var x=document.querySelectorAll(\"a\"),i;" +
            "for(i=0;i<x.length;i++)x[i].style.color=\"\(UIColor.tint.hexColor())\",x[i].style.textDecoration=\"none\";",
            completionHandler: nil)
    }

    open func webView(_ webView: WKWebView,
                      decidePolicyFor navigationAction: WKNavigationAction,
                      decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let requestURL = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        let requestDescription = requestURL.description
        if requestDescription.range(of: "youtube") != nil ||
            requestDescription.range(of: "livestream.com") != nil ||
            requestDescription == "about:blank" {

            decisionHandler(.allow)
        } else if UIApplication.shared.canOpenURL(requestURL) {
            UIApplication.shared.openURL(requestURL)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    // MARK: - Scroll view delegate

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        // Ritorno un valore nullo in modo da evitare che la web view
        // permetta lo zoom del contenuto.
        return nil
    }

}

public extension WKWebViewConfiguration {

    public class var `default`: WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        if #available(iOS 10.0, *) {
            configuration.dataDetectorTypes =
                KInfoPlist.Location.openExternalNav ? [.all] : [.calendarEvent, .link, .phoneNumber]
        } else {
            // Fallback on earlier versions
        }
        // Aggiungo script per fare in modo che il calcolo delle dimensioni
        // della web view sia corretto.
        let source = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); meta.setAttribute('initial-scale', '1.0'); meta.setAttribute('maximum-scale', '1.0'); meta.setAttribute('minimum-scale', '1.0'); meta.setAttribute('user-scalable', 'no'); meta.setAttribute('shrink-to-fit', 'no'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let magnificationScript = WKUserScript(
            source: source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true)
        // Aggiungo script per evitare l'autoresize del testo sulla rotazione.
        var cssString: String = ""
        if let pathCss = Bundle.main.path(forResource: "Detail", ofType: "css"),
            let text = try? String(contentsOfFile: pathCss, encoding: String.Encoding.utf8){
            cssString = text.replacingOccurrences(of: "\n", with: " ")
        }
        let textColor = KTheme.current.color(.normal).hexColor()
        let autoresizeDisableScript = "var style=document.createElement(\"style\"),css=\"" + cssString + "html {-webkit-text-size-adjust: none; color: " + textColor + ";}\";style.type=\"text/css\",style.styleSheet?style.styleSheet.cssText=css:style.appendChild(document.createTextNode(css)),document.getElementsByTagName(\"head\")[0].appendChild(style);"
        let autoresizeDisableUserScript = WKUserScript(
            source: autoresizeDisableScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(magnificationScript)
        userContentController.addUserScript(autoresizeDisableUserScript)
        configuration.userContentController = userContentController
        return configuration
    }
    
}
