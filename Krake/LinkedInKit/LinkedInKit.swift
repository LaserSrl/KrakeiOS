//
//  LinkedinKit.swift
//
//  Created by Patrick on 22/08/16.
//  Copyright © 2016 Laser Group. All rights reserved.
//

import Foundation

extension KInfoPlist
{
    open class LinkedIn: NSObject
    {
        public static let providerURL = "https://www.linkedin.com/oauth/v2/authorization"
        
        public static let clientId: String = {
            return (Bundle.main.object(forInfoDictionaryKey: "LinkedIn") as! [String : String])["ClientId"]!
        }()
        
        public static let clientSecret: String = {
            return (Bundle.main.object(forInfoDictionaryKey: "LinkedIn") as! [String : String])["ClientSecret"]!
        }()
    }
}

open class LinkedInKit: NSObject, KLoginProviderProtocol, OAuthDelegate{
    
    fileprivate var completionBlock: AuthProviderBlock? = nil
    fileprivate var config: OAuthConfiguration!
    
    public static var shared: KLoginProviderProtocol = {
        let shared = LinkedInKit()
        shared.config = OAuthConfiguration(providerURL: KInfoPlist.LinkedIn.providerURL, redirectURL: OAuth.oAuthRedirectUri, clientId: KInfoPlist.LinkedIn.clientId, extras: ["response_type" : "code", "state" : String.randomStringWithLength(16), "scope" : "r_basicprofile%20r_emailaddress"])
        return shared
    }()
    
    open func getLoginView() -> UIView {
        let button = UIButton(type: .system)
        button.setImage(UIImage(krakeNamed:"linkedin_circle"), for: .normal)
        button.addTarget(self, action: #selector(LinkedInKit.signIn), for: .touchUpInside)
        return button
    }
    
    @objc func signIn(){
        KLoginManager.shared.showProgressHUD()
        if let vc = OAuth.oAuthViewController(config, delegate: self, title: "LinkedIn"),
            let mainvc = UIApplication.shared.windows.first?.rootViewController?.presentedViewController ?? UIApplication.shared.windows.first?.rootViewController{
            mainvc.present(vc, animated: true, completion: nil)
        }
    }
    
    func didEndOAuth(_ success: Bool, params: [String : String]?, forOAuthConfig: OAuthConfiguration, error: NSError?) {
        KLoginManager.shared.hideProgressHUD()
        if self.completionBlock == nil {
            if let params = params, let code = params["code"] , success{
                let extras = ["token" : code]
                KLoginManager.shared.login(with: KrakeAuthenticationProvider.linkedin, params: extras, saveTokenParams: true)
            }else if let error = error{
                KMessageManager.showMessage(error.localizedDescription, type: .error)
            }
        }else{
            self.completionBlock?(success, params, error)
        }
    }
    
}
