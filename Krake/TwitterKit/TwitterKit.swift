//
//  TwitterKit.swift
//  Krake
//
//  Created by Patrick on 10/07/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation
import TwitterKit

public class TwitterKit: NSObject, KLoginProviderProtocol{
    
    public static var shared: KLoginProviderProtocol = TwitterKit()
    fileprivate var completionBlock: AuthProviderBlock? = nil
    
    public func start()
    {
        TWTRTwitter.sharedInstance().start()
    }
    
    public static func handleURL(_ app: UIApplication, url: URL, options: [KApplicationOpenURLOptionsKey: Any]) -> Bool
    {
        return TWTRTwitter.sharedInstance().application(app, open:url, options: options)
    }
    
    public func getLoginView() -> UIView {
        let button = UIButton(type: .system)
        button.setImage(UIImage(krakeNamed:"twitter_login"), for: .normal)
        button.addTarget(self, action: #selector(TwitterKit.signIn), for: .touchUpInside)
        return button
    }
    
    public func loginStackPosition() -> KLoginStackPosition {
        return .horizontal
    }
    
    @objc public func signIn()
    {
        KLoginManager.shared.showProgressHUD()
        TWTRTwitter.sharedInstance().logIn { session, error in
            if let session = session {
                self.makeCompletion(true, params: ["token" : session.authToken, "secret" : session.authTokenSecret])
            } else {
                self.makeCompletion(false, error: error as NSError?)
            }
        }
    }
    
    fileprivate func makeCompletion(_ success: Bool, params: [String : String]? = nil, error: NSError? = nil)
    {
        DispatchQueue.main.async {
            KLoginManager.shared.hideProgressHUD()
        }
        if self.completionBlock == nil {
            if let params = params , success{
                KLoginManager.shared.login(with: KrakeAuthenticationProvider.twitter, params: params, saveTokenParams: true)
            }else if let error = error{
                KMessageManager.showMessage(error.localizedDescription, type: .error)
            }
        }else{
            self.completionBlock?(success, params, error)
        }
    }
}
