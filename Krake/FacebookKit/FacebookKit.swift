//
//  FacebookKit.swift
//
//  Created by Patrick on 22/08/16.
//  Copyright © 2016 Laser Group. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FBSDKCoreKit

/**
 # FacebookKit
 FacebookKit is a singleton class, use shared property to use them

 Before use it follow this step:
 1. Create project and follow all steps on [Facebook docs](https://developers.facebook.com/docs/facebook-login/ios)
 1. Call the following method on AppDelegate
     ````
     override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool{
         ...
         FacebookKit.application(application: application, didFinishLaunchingWithOptions: launchOptions)
         ...
         return ...
     }
     ````
 1. Implement the following method on AppDelegate
     ````
     func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let canOpen = FacebookKit.handleURL(app, url: url, options: options) // || TwitterKit.handleURL....
 
        return canOpen
        
     }
     ````
*/
open class FacebookKit: NSObject{
    
    fileprivate var completionBlock: AuthProviderBlock? = nil
    fileprivate var options: [AnyHashable: Any]!
    fileprivate var manager: LoginManager!
    
    public static let shared: FacebookKit = {
        let facebook = FacebookKit()
        facebook.manager = LoginManager()
        return facebook
    }()
    
    /**
     # Generate Facebook UIBarButtonItem for login button view
    
     ````
     let facebook = FacebookKit.shared.generateButton()
     OMLoginManager.shared().startButtons([facebook])
     ````
    
     - Parameter completionBlock: complettion block to execute when user loggedin or close the loginViewController
     - Returns: return UIBarButtonItem
     */
    open func generateButton(_ completionBlock: AuthProviderBlock? = nil) -> UIBarButtonItem{
        self.completionBlock = completionBlock
        return UIBarButtonItem(image: UIImage(krakeNamed:"facebook_icon"), style: .plain, target: self, action: #selector(FacebookKit.signIn))
    }
    
    static public func application(application: UIApplication!, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey : Any]?){
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: didFinishLaunchingWithOptions)
    }
    
    static public func handleURL(_ app: UIApplication, url: URL, options: [KApplicationOpenURLOptionsKey: Any]) -> Bool{
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    /**
     This method is called when user touch the facebook login button. When the user complete the facebook login step the completion block will be called. If the access token is valid we call the makeCompletion method.
     */
    @objc func signIn(){
        KLoginManager.shared.showProgressHUD()
        manager.logOut()
        manager?.logIn(permissions: ["public_profile", "email"], from: nil) { (result, error) in
            if let token = result?.token?.tokenString {
                let params = ["token" : token]
                self.makeCompletion(true, params: params)
            }else{
                self.makeCompletion(false, error: error as NSError?)
            }
        }
    }
    
    /**
     This method use OCLoginManager to send user's token and the provider to Krake and all error/warning.
    
     - Parameters:
       - success: is login success
       - params: can contains user token
       - error: error
     */
    fileprivate func makeCompletion(_ success: Bool, params: [String : String]? = nil, error: NSError? = nil){
        KLoginManager.shared.hideProgressHUD()
        if self.completionBlock == nil {
            if let params = params , success{
                KLoginManager.shared.login(with: KrakeAuthenticationProvider.facebook, params: params, saveTokenParams: true)
            }else if let error = error{
                KMessageManager.showMessage(error.localizedDescription, type: .error)
            }
        }else{
            self.completionBlock?(success, params, error)
        }
    }
    
}
