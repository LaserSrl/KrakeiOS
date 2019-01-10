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

open class LinkedInKit: NSObject, OAuthDelegate{
    
    fileprivate var completionBlock: AuthProviderBlock? = nil
    fileprivate var config: OAuthConfiguration!
    
    public static let shared: LinkedInKit = {
        let shared = LinkedInKit()
        shared.config = OAuthConfiguration(providerURL: KInfoPlist.LinkedIn.providerURL, redirectURL: OAuth.oAuthRedirectUri, clientId: KInfoPlist.LinkedIn.clientId, extras: ["response_type" : "code", "state" : String.randomStringWithLength(16), "scope" : "r_basicprofile%20r_emailaddress"])
        return shared
    }()
    
    open func generateButton(_ completionBlock: AuthProviderBlock? = nil) -> UIBarButtonItem{
        self.completionBlock = completionBlock
        return UIBarButtonItem(image: UIImage(krakeNamed:"linkedin_circle"), style: .plain, target: self, action: #selector(LinkedInKit.signIn))
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
