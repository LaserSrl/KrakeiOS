//
//  KLoginManager.swift
//  Krake
//
//  Created by Patrick on 04/01/18.
//

import Foundation
import MBProgressHUD

public protocol KLoginManagerDelegate: KeyValueCodingProtocol{
    
    var canUserRegisterWithKrake: Bool {get}
    var canUserLoginWithKrake: Bool {get}
    var canUserLogout: Bool {get}
    var canUserRecoverPasswordWithSMS: Bool {get}
    var canUserRecoverPassword: Bool {get}
    var canUserCancelLogin: Bool {get}
    var userHaveToRegisterWithSMS: Bool {get}
    var socialsLoginProvider: [KLoginProviderProtocol.Type]? {get}
    var domainsAccepted: [String]? {get}
    
    func loginCompleted(withStatus logged: Bool, roles: [String]?, serviceRegistrated: [String]?, error: String?)
    func userLoggedOut()
    func userRegisteredWaitingEmailVerification()
    func userEmailVerified()
    func shouldDisplayLoginControllerAfterFailure(with response: KrakeResponse?, parameter: Any?) -> Bool
}

public extension KLoginManagerDelegate{
    
    var canUserRegisterWithKrake: Bool{
        return true
    }
    
    var canUserLoginWithKrake: Bool{
        return true
    }
    
    var canUserLogout: Bool{
        return true
    }
    
    var canUserRecoverPasswordWithSMS: Bool{
        return false
    }
    
    var canUserCancelLogin: Bool{
        return true
    }
    
    var userHaveToRegisterWithSMS: Bool{
        return false
    }
    
    func loginCompleted(withStatus logged: Bool, roles: [String]?, serviceRegistrated: [String]?, error: String?){
        
    }
    
    func userLoggedOut(){
        
    }
    
    func userRegisteredWaitingEmailVerification()
    {
        
    }
    
    func userEmailVerified()
    {
        
    }

    var canUserRecoverPassword: Bool{
        return true
    }

    func shouldDisplayLoginControllerAfterFailure(with response: KrakeResponse?, parameter: Any?) -> Bool
    {
        return true
    }
}

public struct KUser{
    public var registeredServices: [String]?
    public var roles: [String]?
    public var identifier: String?
    public var contactIdentifier: String?
}

public typealias RequestLostPassword = (_ loginSuccess : Bool, _ message : String?) -> Void
public typealias AuthRegistrationBlock = (_ loginSuccess : Bool, _ serviceRegistrated: [String]?, _ roles: [String]?, _ error : Error?) -> Void

@objc public class KLoginManager: NSObject{
    
    static let KUserDataRolesKey = "UserRoles"
    static let KUserDataRegisteredServicesKey = "UserRegisteredServices"
    static let KUserDataIdentifierKey = "UserIdentifier"
    static let KUserDataContactIdentifierKey = "ContactIdentifier"
    static let KUserTokenKey = "UserToken"
    
    public static let UserLoggedIn = Notification.Name("UserLoggedIn")
    public static let UserLoggedOut = Notification.Name("UserLoggedOut")
    public static let UserEmailVerified = Notification.Name("UserEmailVerified")
    public static let UserRegisteredWaitingEmailVerification = Notification.Name("UserRegisteredWaitingEmailVerification")
    
    fileprivate var loginViewController: OCLoginViewController?
    
    @objc public static let shared: KLoginManager = KLoginManager()
    
    public var currentUser: KUser?
    public var isKrakeLogged: Bool{
        return URLConfigurationCookies.shared.isValidAuthCookie()
    }
    public weak var delegate: KLoginManagerDelegate?
    
    @objc public var socials: [KLoginProviderProtocol.Type]? {
        return delegate?.socialsLoginProvider
    }
    
    fileprivate var mainCompletion: AuthRegistrationBlock?

    private(set) var loginIn: Bool = false
    
    public override init() {
        super.init()
        if URLConfigurationCookies.shared.isValidAuthCookie() {
            var registeredServices: [String]? {
                guard let data = UserDefaults.standard.object(forKey: KLoginManager.KUserDataRegisteredServicesKey) as? Data else{
                    return nil
                }
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? [String]
            }
            var roles: [String]? {
                guard let data = UserDefaults.standard.object(forKey: KLoginManager.KUserDataRolesKey) as? Data else{
                    return nil
                }
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? [String]
            }
            var identifier: String?{
                return UserDefaults.standard.string(forKey: KLoginManager.KUserDataIdentifierKey)
            }
            var contactIdentifier: String?{
                return UserDefaults.standard.string(forKey: KLoginManager.KUserDataContactIdentifierKey)
            }
            if let identifier = identifier{
                currentUser = KUser(registeredServices: registeredServices, roles: roles, identifier: identifier, contactIdentifier: contactIdentifier)
            }
        }
        else if let tokenInfos = UserDefaults.standard.value(forKey: KLoginManager.KUserTokenKey) as? [String: Any]
        {
            login(with: tokenInfos[KParametersKeys.Login.provider] as! String,
                  params: tokenInfos,
                  saveTokenParams: true)
        }
    }
    
    
    public func storeUserAdditionalInfos(with infos: [AnyHashable : Any]?)
    {
        if let infos = infos{
            var registeredServices: [String]?
            if let arrayOfRegisteredServices = infos["RegisteredServices"] as? [[String : Any]]
            {
                registeredServices = [String]()
                for registeredService in arrayOfRegisteredServices
                {
                    if let serviceName = registeredService["Key"] as? String
                    {
                        registeredServices?.append(serviceName)
                    }
                }
            }
            else
            {
                registeredServices = nil
            }
            let roles: [String]? = infos["Roles"] as? [String]
            let userIdentifier: String? = (infos["UserId"] as? NSNumber)?.stringValue
            let contactIdentifier: String? = (infos["ContactId"] as? NSNumber)?.stringValue
            
            let dataSR = registeredServices != nil ? NSKeyedArchiver.archivedData(withRootObject: registeredServices!) : nil
            let dataUR = roles != nil ? NSKeyedArchiver.archivedData(withRootObject: roles!) : nil
            
            currentUser = KUser(registeredServices: registeredServices, roles: roles, identifier: userIdentifier, contactIdentifier: contactIdentifier)
            UserDefaults.standard.set(dataSR, forKey: KLoginManager.KUserDataRegisteredServicesKey)
            UserDefaults.standard.set(dataUR, forKey: KLoginManager.KUserDataRolesKey)
            UserDefaults.standard.set(userIdentifier, forKey: KLoginManager.KUserDataIdentifierKey)
            UserDefaults.standard.set(contactIdentifier, forKey: KLoginManager.KUserDataContactIdentifierKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    public func presentLogin(completion: AuthRegistrationBlock?){
        if URLConfigurationCookies.shared.isValidAuthCookie(){
            completion?(true, currentUser?.registeredServices, currentUser?.roles, nil)
        }else{
            mainCompletion = completion
            let bundle = Bundle(url: Bundle(for: KLoginManager.self).url(forResource: "LoginManager", withExtension: "bundle")!)
            let story = UIStoryboard(name: "KLogin", bundle: bundle)
            loginViewController = story.instantiateViewController(withIdentifier: "KLoginViewController") as? OCLoginViewController
            loginViewController?.modalPresentationStyle = .formSheet
            if let nav = UIApplication.shared.delegate?.window??.rootViewController, let loginViewController = loginViewController{
                nav.present(loginViewController, animated: true, completion: {
                    if self.loginIn {
                        self.showProgressHUD()
                    }
                })
            }
        }
    }
    
    @objc public func userClosePresentedLoginViewController(){
        delegate?.loginCompleted(withStatus: false, roles: currentUser?.roles, serviceRegistrated: currentUser?.registeredServices, error: nil)
        mainCompletion?(false, currentUser?.registeredServices, currentUser?.roles, nil)
        loginViewController = nil
    }

    @objc public func objc_login(with providerName: String,
                                 params: [String: Any],
                                 saveTokenParams: Bool){
        login(with: providerName, params: params, saveTokenParams: saveTokenParams)
    }

    public func login(with providerName: String, params: [String: Any], saveTokenParams: Bool = false, completion: AuthRegistrationBlock? = nil){
        showProgressHUD()
        loginIn = true

        if saveTokenParams {
            var mutableParams = params
            mutableParams[KParametersKeys.Login.provider] = providerName
            UserDefaults.standard.set(mutableParams, forKey: KLoginManager.KUserTokenKey)
        }

        KNetworkManager.defaultManager(true, checkHeaderResponse: true)
            .krakeLogin(providerName: providerName, params: params) { [weak self] (loginSuccess, response, error) in
            self?.makeCompletion(loginSuccess, response: response, error: error)
            completion?(loginSuccess, self?.currentUser?.registeredServices, self?.currentUser?.roles, error)
                if !loginSuccess {
                    UserDefaults.standard.removeObject(forKey: KLoginManager.KUserTokenKey)
                }

            self?.loginIn = false
            self?.hideProgressHUD()
        }
    }
    
    @objc public func makeCompletion(_ success: Bool, response: [AnyHashable : Any]?, error: Error?){
        storeUserAdditionalInfos(with: response)
        if success{
            if isKrakeLogged{
                NotificationCenter.default.post(name: KLoginManager.UserLoggedIn, object: self, userInfo: response)
            }
            loginViewController?.dismiss(animated: true, completion: {
                self.loginViewController = nil
            })
            delegate?.loginCompleted(withStatus: isKrakeLogged, roles: currentUser?.roles, serviceRegistrated: currentUser?.registeredServices, error: error?.localizedDescription)
            mainCompletion?(isKrakeLogged, currentUser?.registeredServices, currentUser?.roles, error)
            AnalyticsCore.shared?.setUserInfoProperties()
            mainCompletion = nil
        }else{
            let mainNav = UIApplication.shared.delegate?.window??.rootViewController
            if !(mainNav?.presentedViewController == loginViewController){
                presentLogin(completion: mainCompletion)
            }else{
                if let error = error{
                    showMessage(error.localizedDescription, withType: .error)
                }
                delegate?.loginCompleted(withStatus: success, roles: currentUser?.roles, serviceRegistrated: currentUser?.registeredServices, error: error?.localizedDescription)
                mainCompletion?(success, currentUser?.registeredServices, currentUser?.roles, error)
            }
        }
    }
    
    @objc public func userRegisteredWaitingEmailVerification(response: Error?) {
        
        makeCompletion(true, response: nil, error: response)
        
        NotificationCenter.default.post(name: KLoginManager.UserRegisteredWaitingEmailVerification, object: self)
        delegate?.userRegisteredWaitingEmailVerification()
    }
    
    @objc public func callRequestPasswordLost(queryString: String, params: [String: Any]){
        showProgressHUD()
        KNetworkManager.defaultManager(true).requestKrakeLostPassword(queryString, params: params) { [weak self](success, response, error) in
            if success {
                self?.showMessage("reset_password_sended".localizedString(), withType: .success)
            }
            else {
                self?.showMessage(error?.localizedDescription ?? "Generic error".localizedString(), withType: .error)
            }
            self?.hideProgressHUD()
        }
    }

    public func extractNonce(url: URL) -> String? {
        if url.path == KAPIConstants.userChallengeMail,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {

            return components.queryItems?.first(where: { (item) -> Bool in
                return item.name == "nonce"
                })?.value
        }
        return nil
    }

    public func verifyNonce(_ nonce: String,
                            callback:@escaping ((Bool, Error?) -> Void)) {
        _ = KNetworkManager.defaultManager(true).request(KAPIConstants.userVerifyNonce,
                                                     method: .post,
                                                     parameters: ["nonce": nonce]   ,
                                                     successCallback: { (data, result) in
                                                        callback(true, nil)
        },
                                                     failureCallback: { (data, error) in
                                                        callback(false, error)
        })
    }

    public func userLogout()
    {
        if let cache = OGLCoreDataMapper.sharedInstance().cacheEntry(withParameters: [KParametersKeys.displayAlias : KCommonDisplayAlias.userInfo], context: OGLCoreDataMapper.sharedInstance().managedObjectContext){
            cache.date = Date(timeIntervalSince1970: 0)
            do {
                try OGLCoreDataMapper.sharedInstance().managedObjectContext.save()
            }
            catch
            {

            }
        }
        URLConfigurationCookies.shared.removeAuthCookie()
        UserDefaults.standard.set(nil, forKey: KLoginManager.KUserDataRolesKey)
        UserDefaults.standard.set(nil, forKey: KLoginManager.KUserDataRegisteredServicesKey)
        UserDefaults.standard.set(nil, forKey: KLoginManager.KUserDataIdentifierKey)
        UserDefaults.standard.set(nil, forKey: KLoginManager.KUserDataContactIdentifierKey)
        UserDefaults.standard.removeObject(forKey: KLoginManager.KUserTokenKey)
        UserDefaults.standard.synchronize()
        currentUser = nil
        NotificationCenter.default.post(name: KLoginManager.UserLoggedOut, object: self)
        delegate?.userLoggedOut()
    }
    
    @objc public func showMessage(_ message: String, withType: KMessageManager.Mode){
        if (loginViewController?.view) != nil {
            KMessageManager.showMessage(message, type: withType, layout: .tabView, fromViewController: loginViewController)
        }
    }
    
    public func showProgressHUD(){
        if let view = loginViewController?.view{
            MBProgressHUD.showAdded(to: view, animated: true)
        }
    }
    
    public func hideProgressHUD(){
        if let view = loginViewController?.view{
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
}
