//
//  AppleSignIn.swift
//  Krake
//
//  Created by Patrick on 17/12/2019.
//

import Foundation
import AuthenticationServices

@available(iOS 13.0, *)
@objc public class AppleIDSignIn: NSObject, KLoginProviderProtocol
{
    public static var shared: KLoginProviderProtocol = AppleIDSignIn()
    
    fileprivate var completionBlock: AuthProviderBlock? = nil
    fileprivate let delegate = AuthDelegate()
    
    public func getLoginView() -> UIView {
        let authorizationButton = ASAuthorizationAppleIDButton(type: .default, style: (KTheme.login.socialStyle() == .light) ? .white : .black)
        authorizationButton.addTarget(self, action: #selector(handleLogInWithAppleIDButtonPress), for: .touchUpInside)
        return authorizationButton
    }
    
    @objc private func handleLogInWithAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
            
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = delegate
        authorizationController.presentationContextProvider = delegate
        authorizationController.performRequests()
    }
}

@available(iOS 13.0, *)
class AuthDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding
{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.delegate!.window!!
    }
    
    // ASAuthorizationControllerDelegate function for successful authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let userFirstName = appleIDCredential.fullName?.givenName
            let userLastName = appleIDCredential.fullName?.familyName
            let userEmail = appleIDCredential.email
            
            
            
            if let data = appleIDCredential.authorizationCode,
                let userIdentityToken = String(data: data, encoding: .utf8)
            {
                makeCompletion(true, params: ["token" : userIdentityToken], error: nil)
            }
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            //Navigate to other view controller
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        makeCompletion(false, params: nil, error: error)
    }
    
    
    fileprivate func makeCompletion(_ success: Bool, params: [String : String]? = nil, error: Error? = nil){
        KLoginManager.shared.hideProgressHUD()
        if let params = params , success{
            KLoginManager.shared.login(with: KrakeAuthenticationProvider.apple, params: params, saveTokenParams: true)
        }else if let error = error{
            KMessageManager.showMessage(error.localizedDescription, type: .error)
        }
    }
}
