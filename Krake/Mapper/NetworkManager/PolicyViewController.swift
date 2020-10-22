//
//  PolicyViewController.swift
//  Pods
//
//  Created by Patrick on 21/07/16.
//
//

import UIKit
import WebKit.WKWebView
import WebKit.WKNavigationDelegate

open class PolicyViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {

    weak var webView: WKWebView?
    fileprivate var largeMargin: Bool = false
    fileprivate var policyEndPoint: String? = nil
    fileprivate var policyTitle: String? = nil
    fileprivate var policyText: String? = nil

    public init(policyEndPoint endPoint: String? = nil, policyTitle: String? = nil, policyText: String? = nil, largeMargin: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.policyText = policyText
        self.policyTitle = policyTitle
        self.policyEndPoint = endPoint
        self.largeMargin = largeMargin
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        webView?.scrollView.delegate = nil
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge.all
        if presentingViewController != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .stop,
                target: self,
                action: #selector(PolicyViewController.closeRules))
        }
        let webView = prepareWebView()
        view.addSubview(webView)
        view.backgroundColor = UIColor.white
        KTheme.current.applyTheme(toView: view, style: .policy)

		let viewRefs = ["webView" : webView]
        if largeMargin {
            view.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "|-(16)-[webView]-(16)-|",
                    options: .directionLeftToRight,
                    metrics: nil,
                    views: viewRefs))
            view.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-(80)-[webView]-(80)-|",
                    options: .directionLeftToRight,
                    metrics: nil,
                    views: viewRefs))
        } else {
            view.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "|-[webView]-|",
                    options: .directionLeftToRight,
                    metrics: nil,
                    views: viewRefs))
            view.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-[webView]-|",
                    options: .directionLeftToRight,
                    metrics: nil,
                    views: viewRefs))
        }
        self.webView = webView

        if let policyEndPoint = policyEndPoint {
            OGLCoreDataMapper.sharedInstance()
                .loadData(
                    withDisplayAlias: policyEndPoint,
                    extras: KRequestParameters.parametersShowPrivacy(),
                    completionBlock: { [weak self] (parsedObject, error, completed) in
                        guard let strongSelf = self, completed else {
                            return
                        }

                        if parsedObject != nil {
                            let cache = OGLCoreDataMapper.sharedInstance().displayPathCache(from: parsedObject!)
                            if let policy = cache.cacheItems.firstObject as? PolicyProtocol {
                                strongSelf.loadPolicy(
                                    policy.titlePartTitle,
                                    text: policy.bodyPartText)
                            }
                        }
                })
        } else {
            loadPolicy(policyTitle, text: policyText)
        }
    }

    func loadPolicy(_ policyTitle: String?, text: String?){
        title = policyTitle
        if let text = text {
            let familyName = UIFont.systemFont(ofSize: 12.0).familyName
            _ = webView?.loadHTMLString(
                String(format: "<div style='text-align:justify;font-family:\"%@\";'>%@</div>", familyName , text),
                baseURL: nil)
        }
    }

    @objc func closeRules(){
        dismiss(animated: true, completion: nil)
    }

    private func prepareWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes =
                KInfoPlist.Location.openExternalNav ? [.all] : [.calendarEvent, .link, .phoneNumber]
       
        // Aggiungo script per fare in modo che il calcolo delle dimensioni
        // della web view sia corretto.
        let source = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); meta.setAttribute('initial-scale', '1.0'); meta.setAttribute('maximum-scale', '1.0'); meta.setAttribute('minimum-scale', '1.0'); meta.setAttribute('user-scalable', 'no'); meta.setAttribute('shrink-to-fit', 'no'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let magnificationScript = WKUserScript(
            source: source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true)
        // Aggiungo script per evitare l'autoresize del testo sulla rotazione.
        let autoresizeDisableScript = "var style=document.createElement(\"style\"),css=\"html {-webkit-text-size-adjust: none;}\";style.type=\"text/css\",style.styleSheet?style.styleSheet.cssText=css:style.appendChild(document.createTextNode(css)),document.getElementsByTagName(\"head\")[0].appendChild(style);"
        let autoresizeDisableUserScript = WKUserScript(
            source: autoresizeDisableScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(magnificationScript)
        userContentController.addUserScript(autoresizeDisableUserScript)
        configuration.userContentController = userContentController
        // Generazione della web view con la configurazione creata.
        let wv = WKWebView(frame: .zero, configuration: configuration)
        wv.translatesAutoresizingMaskIntoConstraints = false
        wv.navigationDelegate = self
        wv.scrollView.delegate = self
        wv.isOpaque = false
        wv.backgroundColor = UIColor.white
        KTheme.current.applyTheme(toWebView: wv, style: .policy)
        return wv
    }

    // MARK: - Scroll view delegate

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        // Ritorno un valore nullo in modo da evitare che la web view
        // permetta lo zoom del contenuto.
        return nil
    }


    // MARK: - WKNavigationDelegate

    public func webView(_ webView: WKWebView,
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
            UIApplication.shared.open(requestURL)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
}
