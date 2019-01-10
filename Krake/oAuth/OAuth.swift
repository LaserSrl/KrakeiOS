//
//  OAuth.swift
//  Krake
//
//  Created by Patrick on 30/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

struct OAuthConfiguration{
    var providerURL: String!
    var redirectURL: String!
    var clientId: String!
    var extras: [String : String]?
    
    init(providerURL: String!, redirectURL: String!, clientId: String!, /*clientSecret: String!,*/ extras: [String : String]? = nil){
        self.providerURL = providerURL
        self.redirectURL = redirectURL
        self.clientId = clientId
        self.extras = extras
    }
}

class OAuth: NSObject{
    
    public static let oAuthRedirectUri = KInfoPlist.KrakePlist.path.appendingPathComponent("External/LogOn").absoluteString
    
    static func oAuthViewController(_ oAuthConfig: OAuthConfiguration, delegate: OAuthDelegate, title: String? = nil) -> UIViewController?{
        let story = UIStoryboard(name: "OAuth", bundle: Bundle(url: Bundle(for: OAuth.self).url(forResource: "OAuth", withExtension: "bundle")!))
        let vc = story.instantiateInitialViewController() as? UINavigationController
        let oauth = vc?.viewControllers.last as? OAuthViewController
        oauth?.oAuthConfig = oAuthConfig
        oauth?.delegate = delegate
        oauth?.title = title
        return vc
    }
}

protocol OAuthDelegate: NSObjectProtocol{
    func didEndOAuth(_ success: Bool, params : [String: String]?, forOAuthConfig: OAuthConfiguration, error: NSError?)
}

class OAuthViewController: UIViewController, UIWebViewDelegate{
    
    @IBOutlet weak var webView: UIWebView!
    
    var oAuthConfig: OAuthConfiguration!
    weak var delegate: OAuthDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stringURL = NSMutableString(string: oAuthConfig.providerURL)
        stringURL.appendFormat("?client_id=%@", oAuthConfig.clientId)
        stringURL.appendFormat("&redirect_uri=%@", oAuthConfig.redirectURL)
        if let extras = oAuthConfig.extras{
            for key in extras.keys{
                if let value = extras[key]{
                    stringURL.appendFormat("&%@=%@", key, value)
                }
            }
        }
        if let url = URL(string: stringURL as String){
            let urlRequest = URLRequest(url: url)
            webView.loadRequest(urlRequest)
            MBProgressHUD.showAdded(to: view, animated: true)
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: KWebViewNavigationType) -> Bool {
        if let url = request.url{
            let absoluteString = url.absoluteString
            if absoluteString.hasPrefix(oAuthConfig.redirectURL){
                if let queryComponents = url.query?.components(separatedBy: "&"){
                    var dic = [String : String]()
                    var failed = false
                    for elem in queryComponents{
                        let keyValue = elem.components(separatedBy: "=")
                        if keyValue.count == 2 {
                            var valueString = keyValue[1].replacingOccurrences(of: "+", with: " ")
                            if let stringEscaped = valueString.removingPercentEncoding{
                                valueString = stringEscaped
                            }
                            dic[keyValue[0]] = valueString
                        }
                        if keyValue[0].hasPrefix("error"){
                            failed = true
                        }
                    }
                    var error: NSError? = nil
                    if let error_string = dic["error_description"] {
                        error = NSError(domain: "OAuth", code: 1, userInfo: [NSLocalizedDescriptionKey : error_string])
                    }
                    navigationController?.dismiss(animated: true, completion: nil)
                    delegate.didEndOAuth(!failed, params: failed ? nil : dic, forOAuthConfig: oAuthConfig, error: error)
                }
                return false
            }
        }
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    @IBAction func closeOAuthViewController(_ sender: UIBarButtonItem?){
        navigationController?.dismiss(animated: true, completion: nil)
        delegate.didEndOAuth(false, params: nil, forOAuthConfig: oAuthConfig, error: nil)
    }
    
}
