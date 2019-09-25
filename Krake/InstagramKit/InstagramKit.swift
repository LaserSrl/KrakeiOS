//
//  InstagramKit.swift
//
//  Created by Patrick on 22/08/16.
//  Copyright © 2016 Laser Group. All rights reserved.
//

import Foundation

extension KInfoPlist
{
    open class Instagram: NSObject
    {
        public static let clientId: String = {
        return (Bundle.main.object(forInfoDictionaryKey: "Instagram") as! [String : String])["ClientId"]!
        }()
        
        public static let clientSecret: String = {
        return (Bundle.main.object(forInfoDictionaryKey: "Instagram") as! [String : String])["ClientSecret"]!
        }()
    }
}

open class InstagramKit: NSObject, OAuthDelegate{
    
    fileprivate static var instagram: InstagramKit!
    fileprivate var completionBlock: AuthProviderBlock? = nil
    fileprivate var config: OAuthConfiguration!
    
    public static let shared: InstagramKit = {
        let instagram = InstagramKit()
        instagram.config = OAuthConfiguration(providerURL: "https://api.instagram.com/oauth/authorize/", redirectURL: OAuth.oAuthRedirectUri, clientId: KInfoPlist.Instagram.clientId, extras: ["response_type" : "code"])
        return instagram
    }()
    
    open func generateButton(_ completionBlock: AuthProviderBlock? = nil) -> UIButton
    {
        self.completionBlock = completionBlock
        let button = UIButton(type: .system)
        button.setImage(UIImage(krakeNamed:"instagram_circle"), for: .normal)
        button.addTarget(self, action: #selector(InstagramKit.signIn), for: .touchUpInside)
        return button
    }
    
    @objc func signIn(_ sender: UIBarButtonItem?){
        KLoginManager.shared.showProgressHUD()
        if let vc = OAuth.oAuthViewController(config, delegate: self, title: "Instagram"),
            let mainvc = UIApplication.shared.windows.first?.rootViewController?.presentedViewController ?? UIApplication.shared.windows.first?.rootViewController{
            mainvc.present(vc, animated: true, completion: nil)
        }
    }
    
    func didEndOAuth(_ success: Bool, params: [String : String]?, forOAuthConfig: OAuthConfiguration, error: NSError?) {
        KLoginManager.shared.hideProgressHUD()
        if self.completionBlock == nil {
            if let params = params, let code = params["code"] , success{
                let extras = ["token" : code]
                KLoginManager.shared.login(with: KrakeAuthenticationProvider.instagram, params: extras, saveTokenParams: true)
            }else if let error = error{
                KMessageManager.showMessage(error.localizedDescription, type: .error)
            }
        }else{
            self.completionBlock?(success, params, error)
        }
    }
    
}
