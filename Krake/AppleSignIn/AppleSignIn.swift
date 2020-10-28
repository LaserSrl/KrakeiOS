//
//  AppleSignIn.swift
//  Krake
//
//  Created by Patrick on 17/12/2019.
//

import Foundation
import AuthenticationServices

@available(iOS 13.0, *)
@objc public class AppleIDSignIn: NSObject {
    
    override init() {
        super.init()
        if let userID = KeychainItem.currentUserIdentifier {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userID) { (state, error) in
                switch state
                {
                case .authorized: // valid user id
                    break
                case .revoked: // user revoked authorization
                    KLoginManager.shared.userLogout()
                    KeychainItem.deleteUserIdentifierFromKeychain()
                    break
                case .notFound: //not found
                    break
                default: // other cases
                    break
                }
            }
        }
    }
    
    @objc private func handleLogInWithAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    fileprivate func makeCompletion(_ success: Bool, params: [String : String]? = nil, error: Error? = nil){
        KLoginManager.shared.hideProgressHUD()
        if let params = params , success{
            KLoginManager.shared.login(with: KrakeAuthenticationProvider.apple, params: params, saveTokenParams: false)
        }
    }
}

@available(iOS 13.0, *)
//MARK: - Extension of KLoginProviderProtocol
extension AppleIDSignIn: KLoginProviderProtocol {
    
    public static var shared: KLoginProviderProtocol = AppleIDSignIn()
    
    public func getLoginView() -> UIView {
        let authorizationButton = ASAuthorizationAppleIDButton(type: .default, style: (KTheme.login.socialStyle() == .light) ? .white : .black)
        authorizationButton.addTarget(self, action: #selector(handleLogInWithAppleIDButtonPress), for: .touchUpInside)
        return authorizationButton
    }
    
    public func loginStackPosition() -> KLoginStackPosition {
        return .vertical
    }
    
}

@available(iOS 13.0, *)
//MARK: - Extension of ASAuthorizationControllerDelegate
extension AppleIDSignIn: ASAuthorizationControllerDelegate {
    
    // ASAuthorizationControllerDelegate function for successful authorization
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            KeychainItem.set(userIdentifier: userIdentifier)
            if let data = appleIDCredential.authorizationCode,
                let userIdentityToken = String(data: data, encoding: .utf8)
            {
                makeCompletion(true, params: ["token" : userIdentityToken], error: nil)
            }
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        makeCompletion(false, params: nil, error: error)
    }
}

@available(iOS 13.0, *)
//MARK: - Extension of ASAuthorizationControllerPresentationContextProviding
extension AppleIDSignIn: ASAuthorizationControllerPresentationContextProviding {
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.delegate!.window!!
    }
}

//MARK: - Extension of KeychainItem
extension KeychainItem {
    
    static var currentUserIdentifier: String? {
        do {
            let storedIdentifier = try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "userIdentifier").readItem()
            return storedIdentifier
        } catch {
            return nil
        }
    }
    
    static func set(userIdentifier: String) {
        do {
            try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    static func deleteUserIdentifierFromKeychain() {
        do {
            try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "userIdentifier").deleteItem()
        } catch {
            print("Unable to delete userIdentifier from keychain")
        }
    }
}
