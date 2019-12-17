//
//  GoogleKit.swift
//
//  Created by Patrick on 22/08/16.
//  Copyright © 2016 Laser Group. All rights reserved.
//

import Foundation
import GoogleSignIn

public class GoogleKit: NSObject, KLoginProviderProtocol, GIDSignInDelegate, GIDSignInUIDelegate{
    
    fileprivate static var google: GoogleKit!
    fileprivate var completionBlock: AuthProviderBlock? = nil
    
    public static var shared: KLoginProviderProtocol = {
        let google = GoogleKit()
        GIDSignIn.sharedInstance().clientID = KInfoPlist.Google.clientID
        GIDSignIn.sharedInstance().serverClientID = KInfoPlist.Google.serverClientID
        GIDSignIn.sharedInstance().delegate = google
        GIDSignIn.sharedInstance().uiDelegate = google
        GIDSignIn.sharedInstance().signOut()
        return google
    }()
    
    public static func handleURL(_ app: UIApplication, url: URL, options: [KApplicationOpenURLOptionsKey: Any]) -> Bool{
        if let option = options[KApplicationOpenURLOptionsKey.sourceApplication] as? String{
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: option, annotation: options[KApplicationOpenURLOptionsKey.annotation])
        }
        return false
    }
    
    public func getLoginView() -> UIView {
        let button = UIButton(type: .system)
        button.setImage(UIImage(krakeNamed:"google_circle"), for: .normal)
        button.addTarget(self, action: #selector(GoogleKit.logIn), for: .touchUpInside)
        return button
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let user = user, let code = user.serverAuthCode{
            makeCompletion(true, params: ["token" : code], error: error as NSError?)
        }else{
            if (error as NSError).code != GIDSignInErrorCode.canceled.rawValue{
                makeCompletion(false, error: error as NSError?)
            }
        }
    }
    
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    public func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    public func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    public func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        let root = (UIApplication.shared.delegate as? OGLAppDelegate)?.window?.rootViewController
        let mainViewController = root?.presentedViewController ?? root
        mainViewController?.present(viewController, animated: true, completion: nil)
    }
    
    @objc public func logIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    fileprivate func makeCompletion(_ success: Bool, params: [String : String]? = nil, error: NSError? = nil){
        GIDSignIn.sharedInstance().signOut()
        if self.completionBlock == nil {
            if let params = params , success{
                KLoginManager.shared.login(with: KrakeAuthenticationProvider.google, params: params, saveTokenParams: true)
            }else if let error = error {
                KMessageManager.showMessage(error.localizedDescription, type: .error)
            }
        }else{
            self.completionBlock?(success, params, error)
        }
    }
}

