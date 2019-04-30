//
//  KNetworkManager.swift
//  Pods
//
//  Created by Patrick on 28/07/16.
//
//

import Foundation
import AFNetworking

@objc public enum SwiftKrakeAuthenticationProvider: Int{
    case facebook
    case twitter
    case google
    case linkedin
    case instagram
    case orchard
}

@objc public class KrakeAuthenticationProvider: NSObject {
    public static let facebook = "facebook"
    public static let twitter = "twitter"
    public static let google = "google"
    public static let linkedin = "linkedin"
    public static let instagram = "instagram"
    @objc public static let orchard = "orchard"
}

public typealias KrakeAuthBlock = (_ success: Bool, _ withResponse: [AnyHashable : Any]?, _ error: Error?) -> Void
public let KNEKrakeResponse = "KrakeResponse"

@objc public class KNetworkManager: AFHTTPSessionManager{



    private var authenticated: Bool = false
    private var checkHeaderResponse: Bool = false
    
    @objc public static func defaultManager(_ auth: Bool = false, checkHeaderResponse: Bool = false) -> KNetworkManager{
        let manager = KNetworkManager(baseURL: KInfoPlist.KrakePlist.path, auth: auth)
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.authenticated = auth
        manager.checkHeaderResponse = checkHeaderResponse
        return manager
    }
    
    @objc public static func signalTriggerManager(_ auth: Bool = false, checkHeaderResponse: Bool = false) -> KNetworkManager{
        let manager = KNetworkManager(baseURL: KInfoPlist.KrakePlist.path, auth: auth)
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.authenticated = auth
        manager.checkHeaderResponse = checkHeaderResponse
        return manager
    }
    
    //TODO: DA RIVEDERE COMPLETAMENTE
    @available(*, deprecated, message: "Use postSignalTrigger()") 
    @objc public static func sendSignalTrigger(_ params: [AnyHashable: Any], url: URL, auth: Bool, completion: ((_ parsedObject: [AnyHashable: Any]?, _ error: Error?) -> Void)?){
        let manager = AFHTTPSessionManager(baseURL: url, auth: auth)
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        var tmpParams = params
        tmpParams["lang"] = KConstants.currentLanguage
        manager.post("Signal/Trigger", parameters: tmpParams, progress: nil, success: { (task, responseObject) in
            if let object = responseObject as? [String : String],
                let error = object["Errore"]{
                completion?(nil, NSError(domain: "Signal/Trigger", code: 101, userInfo: [NSLocalizedDescriptionKey : error]))
            }else{
                completion?(responseObject as? [AnyHashable: Any], nil)
            }
            manager.invalidateSessionCancelingTasks(true)
        }) { (task: URLSessionDataTask?, error: Error) in
            completion?(nil, error)
            manager.invalidateSessionCancelingTasks(true)
        }
    }
    
    //MARK: Post Signal Trigger
    
    @objc public func postSignalTrigger(signalName: String, contentId: String, params: [AnyHashable: Any]? = nil, success: ((URLSessionDataTask, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) -> URLSessionDataTask?{
        var tmpParams = params ?? [AnyHashable: Any]()
        tmpParams["lang"] = KConstants.currentLanguage
        tmpParams["Name"] = signalName
        tmpParams["ContentId"] = contentId
        return post(KAPIConstants.signal, parameters: tmpParams, progress: nil, success: { (task, responseObject) in
            success?(task, responseObject)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure?(task, error)
        }
    }
    
    //MARK: - Metodi di autenticazione

    public func krakeLogin(providerName: String, params: [AnyHashable : Any], completion: @escaping KrakeAuthBlock )
    {
        let success: (URLSessionDataTask, Any?) -> Void =
        {
            (task, object) in
            self.loginCompletion(task, object: object, completion: completion)
        }
        let failure: (URLSessionDataTask?, Error) -> Void =
        {
            (task, error) in
            self.loginCompletion(task, error: error, completion: completion)
        }

        let extras = NSMutableDictionary(dictionary: params)
        extras["UUID"] = KConstants.uuid

        switch providerName {
        case KrakeAuthenticationProvider.orchard:
            let queryString = String(format: "%@/SignInSsl?Lang=%@", KAPIConstants.userExtensions, KConstants.currentLanguage)
            super.post(queryString, parameters: extras, progress: nil, success: success, failure: failure)
        default:
            let queryString = KAPIConstants.externalTokenLogon
            extras[KParametersKeys.language] = KConstants.currentLanguage
            extras[KParametersKeys.Login.provider] = providerName
            super.get(queryString, parameters: extras, progress: nil, success: success, failure: failure)
        }
    }

    @objc public func krakeRegisterUser(_ params: NSDictionary, completion: @escaping KrakeAuthBlock){
        let post = String(format: "%@/RegisterSsl?UUID=%@&Lang=%@", KAPIConstants.userExtensions, KConstants.uuid, KConstants.currentLanguage)
        super.post(post, parameters: params, progress: nil, success: { (task, object) in
            self.loginCompletion(task, object: object, completion: completion)
        }) { (task, error) in
            self.loginCompletion(task, error: error, completion: completion)
        }
    }
    
    fileprivate func loginCompletion(_ task: URLSessionDataTask?, object: Any? = nil, error: Error? = nil, completion: KrakeAuthBlock){
        if let error = error{
            parseAndCheckKrakeError(error)
            KLoginManager.shared.userLogout()
            completion(false, nil, error)
        }else{
            let response = KrakeResponse(object: object)
            if (response?.success ?? false){
                completedLogin(task, responseObject: response, completion: completion)
            }else{
                KLoginManager.shared.userLogout()
                completion(false, nil, NSError(domain: "Login", code: (response?.errorCode ?? 0), userInfo: [NSLocalizedDescriptionKey : (response?.message ?? "Generic error".localizedString())]))
            }
        }
        invalidateSessionCancelingTasks(true)
    }
    
    //MARK: - Krake lost password request
    
    @objc public func requestKrakeLostPassword(_ queryString: String, params: [AnyHashable : Any], completion: @escaping KrakeAuthBlock){
        let post = String(format: "%@/%@?Lang=%@", KAPIConstants.userExtensions, queryString, KConstants.currentLanguage)
        super.post(post, parameters: params, progress: nil, success: { (task, object) in
            if let responseObject = object as? [String : AnyObject] , let response = KrakeResponse(object: responseObject as AnyObject) , response.success == false{
                completion(false, nil, NSError(domain: "Request lost password", code: response.errorCode, userInfo: [NSLocalizedDescriptionKey : response.message]))
            }else{
                completion(true, nil, nil)
            }
            self.invalidateSessionCancelingTasks(true)
        }) { (task, error) in
            completion(false, nil, error as Error?)
            self.invalidateSessionCancelingTasks(true)
        }
    }
    
    //MARK: - Krake additional registration infos
    
    @objc public func policiesRegistration(_ completion: @escaping (_ success: Bool, _ withResponse: AnyObject?, _ error: Error?) -> Void){
        let get = String(format: "%@/GetCleanRegistrationPoliciesSsl?Lang=%@", KAPIConstants.userExtensions, KConstants.currentLanguage)
        super.get(get, parameters: nil, progress: nil, success: { (task, object) in
            if var responseObject = object as? [String : AnyObject], let policies = responseObject["Policies"] {
                completion(true, policies, nil)
            }else{
                completion(false, nil, NSError(domain: "Registration", code: KErrorCode.genericError, userInfo: [NSLocalizedDescriptionKey : "Generic error".localizedString()]))
            }
            self.invalidateSessionCancelingTasks(true)
        }) { (task, error) in
            completion(false, nil, error)
            self.invalidateSessionCancelingTasks(true)
        }
    }
    
    //MARK: - aggiornare il profilo utente
    
    @objc public func updateUserProfile(_ params: NSDictionary, completion: @escaping KrakeAuthBlock){
        super.post(KAPIConstants.userStartupConfig, parameters: params, progress: nil, success: { (task, object) in
            if let responseObject = object , let response = KrakeResponse(object: responseObject) {
                if response.success == true{
                    completion(true, response.data, nil)
                }else{
                    completion(false, nil, NSError(domain: "User update profile", code: response.errorCode, userInfo: [NSLocalizedDescriptionKey : response.message]))
                }
            }else{
                completion(false, nil, NSError(domain: "User update profile", code: KErrorCode.genericError, userInfo: [NSLocalizedDescriptionKey : "Generic error".localizedString()]))
            }
        }) { (task, error) in
            completion(false, nil, error)
        }
    }
    
    //MARK: - Metodi sovrascritti per gestire gli errori di krake e l'invalidateSessionManager

    @objc public override func get(_ URLString: String, parameters: Any?, progress downloadProgress: ((Progress) -> Void)?, success: ((URLSessionDataTask, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) -> URLSessionDataTask?{
        return super.get(URLString, parameters: parameters, progress: downloadProgress, success: { (task, object) in
            self.checkHeaderResponse(task)
            if let responseObject = object as? [String : AnyObject] , let kSuccess = responseObject["Success"] as? NSNumber ?? responseObject["success"] as? NSNumber , kSuccess == 0
            {
                self.checkKrakeResponse(KrakeResponse(object: responseObject),
                                        parameters: parameters,
                                        checkSuccess: { (manager) in
                                            _ = manager.get(URLString,
                                                            parameters: parameters,
                                                            progress: downloadProgress,
                                                            success: { (task, object) in
                                                                success?(task, object)
                                                                manager.invalidateSessionCancelingTasks(true)
                                            },
                                                            failure: { (task, error) in
                                                                failure?(task, error)
                                                                manager.invalidateSessionCancelingTasks(true)
                                            })
                }, checkFailure: { (error: Error) in
                    failure?(task, error)
                    self.invalidateSessionCancelingTasks(true)
                })
            }
            else
            {
                success?(task, object)
                self.invalidateSessionCancelingTasks(true)
            }
        }, failure: {(task, error) in
            self.parseAndCheckKrakeError(error)
            failure?(task, error)
            self.invalidateSessionCancelingTasks(true)
        })
    }
    
    @objc public override func put(_ URLString: String, parameters: Any?, success: ((URLSessionDataTask, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) -> URLSessionDataTask? {
        return super.put(URLString, parameters: parameters, success: { (task, object) in
            self.checkHeaderResponse(task)
            if let responseObject = object as? [String : AnyObject] , let kSuccess = responseObject["Success"] as? NSNumber ?? responseObject["success"] as? NSNumber , kSuccess == 0{
                self.checkKrakeResponse(KrakeResponse(object: responseObject), parameters: parameters, checkSuccess: { (manager) in
                    _ = manager.put(URLString, parameters: parameters, success: { (task, object) in
                        success?(task, object)
                        manager.invalidateSessionCancelingTasks(true)
                    }, failure: { (task, error) in
                        failure?(task, error)
                        manager.invalidateSessionCancelingTasks(true)
                    })
                }, checkFailure: { (error: Error) in
                    failure?(task, error)
                    self.invalidateSessionCancelingTasks(true)
                })
            }else{
                success?(task, object)
                self.invalidateSessionCancelingTasks(true)
            }
            }, failure: {(task: URLSessionDataTask?, error: Error) in
                self.parseAndCheckKrakeError(error)
                failure?(task, error)
                self.invalidateSessionCancelingTasks(true)
        })
    }
    
    @objc public override func post(_ URLString: String, parameters: Any?, progress uploadProgress: ((Progress) -> Void)?, success: ((URLSessionDataTask, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) -> URLSessionDataTask? {
        return super.post(URLString, parameters: parameters, progress: uploadProgress, success: { (task, object) in
            self.checkHeaderResponse(task)
            if let responseObject = object as? [String : AnyObject] , let kSuccess = responseObject["Success"] as? NSNumber ?? responseObject["success"] as? NSNumber , kSuccess == 0{
                self.checkKrakeResponse(KrakeResponse(object: responseObject), parameters: parameters, checkSuccess: { (manager) in
                    _ = manager.post(URLString, parameters: parameters, progress: uploadProgress, success: { (task, object) in
                        success?(task, object)
                        manager.invalidateSessionCancelingTasks(true)
                    }, failure: { (task, error) in
                        failure?(task, error)
                        manager.invalidateSessionCancelingTasks(true)
                    })
                }, checkFailure: { (error: Error) in
                    failure?(task, error)
                    self.invalidateSessionCancelingTasks(true)
                })
            }else{
                success?(task, object)
                self.invalidateSessionCancelingTasks(true)
            }
            }, failure: {(task: URLSessionDataTask?, error: Error) in
                self.parseAndCheckKrakeError(error)
                failure?(task, error)
                self.invalidateSessionCancelingTasks(true)
        })
    }
    
    @objc public override func post(_ URLString: String, parameters: Any?, constructingBodyWith block: ((AFMultipartFormData) -> Void)?, progress uploadProgress: ((Progress) -> Void)?, success: ((URLSessionDataTask, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) -> URLSessionDataTask?{
        return super.post(URLString, parameters: parameters, constructingBodyWith: block, progress: uploadProgress, success: { (task, object) in
            self.checkHeaderResponse(task)
            if let responseObject = object as? [String : AnyObject] , let kSuccess = responseObject["Success"] as? NSNumber ?? responseObject["success"] as? NSNumber , kSuccess == 0{
                self.checkKrakeResponse(KrakeResponse(object: responseObject), parameters: parameters, checkSuccess: { (manager) in
                    _ = manager.post(URLString, parameters: parameters, constructingBodyWith: block, progress: uploadProgress, success: { (task, object) in
                        success?(task, object)
                        manager.invalidateSessionCancelingTasks(true)
                    }, failure: { (task, error) in
                        failure?(task, error)
                        manager.invalidateSessionCancelingTasks(true)
                    })
                }, checkFailure: { (error: Error) in
                    failure?(task, error)
                    self.invalidateSessionCancelingTasks(true)
                })
            }else{
                success?(task, object)
                self.invalidateSessionCancelingTasks(true)
            }
            }, failure: {(task: URLSessionDataTask?, error: Error) in
                self.parseAndCheckKrakeError(error)
                failure?(task, error)
                self.invalidateSessionCancelingTasks(true)
        })
    }
    
    //MARK: - Metodi privati
    
    fileprivate func checkKrakeResponse(_ responseObject: KrakeResponse?, parameters: Any? = nil, checkSuccess: ((KNetworkManager) -> Void)? = nil, checkFailure: ((Error) -> Void)? = nil){
        if let response = responseObject{
            switch response.resolutionAction{
            case KResolutionAction.userHaveToLogin:
                if !authenticated && KLoginManager.shared.isKrakeLogged {
                    let manager = KNetworkManager.defaultManager(true)
                    checkSuccess?(manager)
                }else{
                    //USER HAVE TO LOGGED IN
                    KLoginManager.shared.userLogout()
                    if KLoginManager.shared.delegate?.shouldDisplayLoginControllerAfterFailure(with: responseObject, parameter: parameters) ?? true
                    {
                        KLoginManager.shared.presentLogin(completion: { (loginSuccess, serviceRegistrated, roles, error) in
                            if loginSuccess{
                                let manager = KNetworkManager.defaultManager(true)
                                checkSuccess?(manager)
                            }else{
                                let error = NSError(domain: KInfoPlist.appName, code: response.errorCode, userInfo: [NSLocalizedDescriptionKey : response.message])
                                checkFailure?(error)
                            }
                        })
                    }
                }
            case KResolutionAction.userHaveToAcceptPolicy:
                //USER HAVE TO ACCEPT POLICIES
                if let data = response.data as? [String : AnyObject]{
                    OGLCoreDataMapper.sharedInstance().importAndSave(inCoreData: data, parameters: parameters as? [AnyHashable: Any], loadDataTask: nil)
                }
                checkKrakeError(response, checkFailure: checkFailure)
            default:
                checkKrakeError(response, checkFailure: checkFailure)
            }
        }else{
            checkKrakeError(nil, checkFailure: checkFailure)
        }
    }
    
    fileprivate func checkKrakeError(_ responseObject: KrakeResponse?, checkFailure: ((Error) -> Void)? = nil){
        if let response = responseObject{
            switch response.errorCode {
            case KErrorCode.userNotHavePermission:
                Date.networkTimeSync()
            default:
                break
            }
            let error = NSError(domain: KInfoPlist.appName, code: response.errorCode, userInfo: [NSLocalizedDescriptionKey : response.message, KNEKrakeResponse: response])
            checkFailure?(error)
        }else{
            let error = NSError(domain: KInfoPlist.appName, code: KErrorCode.genericError, userInfo: [NSLocalizedDescriptionKey : "Generic error".localizedString()])
            checkFailure?(error)
        }
    }
    
    fileprivate func parseAndCheckKrakeError(_ errore: Error){
        let error = errore as NSError
        if let data = error.userInfo["com.alamofire.serialization.response.error.data"] as? Data,
            let dic = (try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)) as? [String : AnyObject]{
            checkKrakeResponse(KrakeResponse(object: dic as AnyObject))
        }
    }
    
    fileprivate func completedLogin(_ task: URLSessionDataTask?, responseObject: KrakeResponse?, completion: KrakeAuthBlock){
        if let task = task {
            checkHeaderResponse(task)
            let error: Error? = !(responseObject?.message ?? "").isEmpty ? NSError(domain: KInfoPlist.appName, code: 0, userInfo: [NSLocalizedDescriptionKey : responseObject!.message!]) : nil
            completion(true, responseObject?.data, error)
        }else{
            completion(false, nil, nil)
        }
    }
    
    fileprivate func checkHeaderResponse(_ task : URLSessionDataTask ){
        if checkHeaderResponse {
            if let response = task.response as? HTTPURLResponse,
                let headers = response.allHeaderFields as? [String : String]{
                let array = HTTPCookie.cookies(withResponseHeaderFields: headers, for: baseURL!)
                URLSessionConfiguration.parse(cookies: array)
            }
        }
    }
    
}
