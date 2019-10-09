//
//  KNetworkManager.swift
//  Pods
//
//  Created by Patrick on 28/07/16.
//
//

import Foundation
import AFNetworking
import Alamofire

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

public enum KResponseSerializer: Int {
    case json
}

public enum KRequestSerializer: Int {
    case json
    case http
}

private extension KRequestSerializer {
    func af() -> ParameterEncoder {
        switch self {
        case .json:
            return JSONParameterEncoder()
        case .http:
            return URLEncodedFormParameterEncoder(destination: .httpBody)
        }
    }
}

public enum KMethod: Int {
    case get
    case post
    case put
    case delete
}

private extension KMethod {
    func afMethod() -> HTTPMethod {
        switch self {
        case .get:
            return HTTPMethod.get
        case .post:
            return HTTPMethod.post
        case .put:
            return HTTPMethod.put
        case .delete:
            return HTTPMethod.delete
        }
    }
}

public class KRequest<KParameters:Encodable> {

    var path: String = ""

    var queryParameters = [URLQueryItem]()

    var method: KMethod = .get
    var parameters: KParameters? = nil
    var requestSerializer: KRequestSerializer? = nil

    var responseSerializer: KResponseSerializer? = nil

    var uploadProgress: ((Progress) -> Void)? = nil
    var downloadProgress: ((Progress) -> Void)? = nil
}

extension KRequest {

    func asURL(_ baseUrl: URL) -> URL {

        var components = URLComponents(url: baseUrl.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        components?.queryItems = queryParameters

        return try! (components?.asURL())!
    }
}

public class KMultipartFormData {
    private let multiformData: MultipartFormData

    public func appendParameters(_ params: [String: String]) {

        for (key, value) in params {
            multiformData.append(value.data(using: String.Encoding.utf8)!, withName: key)
        }
    }

    public func appendPart(_ data: Data, withName name: String, fileName: String? = nil, mimeType: String? = nil) {
        multiformData.append(data,
                             withName: name,
                             fileName: fileName,
                             mimeType: mimeType)
    }

    fileprivate init(_ multiformData: MultipartFormData) {
        self.multiformData = multiformData
    }
}

@objc
public class KDataTask: NSObject {
    internal let dataRequest: DataRequest

    init(dataRequest: DataRequest) {
        self.dataRequest = dataRequest
    }
    

    public func cancel() {
        dataRequest.cancel()
    }

    public var isRunning: Bool {
        get {
            return dataRequest.isResumed
        }
    }

    public var response: HTTPURLResponse? {
        get {
            return dataRequest.response
        }
    }
}

@objc public class KNetworkManager: NSObject {

    private var authenticated: Bool = false
    private var checkHeaderResponse: Bool = false
    public var requestSerializer: KRequestSerializer  = .json
    public var responseSerializer: KResponseSerializer  = .json
    public let baseURL: URL
    private let sessionManager: Session

    public init(baseURL: URL, auth: Bool) {
        
        sessionManager = Session(configuration: URLSessionConfiguration.krakeSessionConfiguration(auth: auth))
        self.baseURL = baseURL

        super.init()
    }
    
    @objc public static func defaultManager(_ auth: Bool = false, checkHeaderResponse: Bool = false) -> KNetworkManager{
        let manager = KNetworkManager(baseURL: KInfoPlist.KrakePlist.path, auth: auth)
        manager.requestSerializer = .json
        manager.responseSerializer = .json
        manager.authenticated = auth
        manager.checkHeaderResponse = checkHeaderResponse
        return manager
    }
    
    @objc public static func signalTriggerManager(_ auth: Bool = false, checkHeaderResponse: Bool = false) -> KNetworkManager{
        let manager = KNetworkManager(baseURL: KInfoPlist.KrakePlist.path, auth: auth)
        manager.requestSerializer = .http
        manager.responseSerializer = .json
        manager.authenticated = auth
        manager.checkHeaderResponse = checkHeaderResponse
        return manager
    }

    //MARK: Post Signal Trigger
    
    public func postSignalTrigger(signalName: String,
                                        contentId: String,
                                        params: [String: String]? = nil,
                                        success: ((KDataTask, Any?) -> Void)?,
                                        failure: ((KDataTask?, Error) -> Void)?) -> KDataTask?{
        var tmpParams = params ?? [String: String]()
        tmpParams["lang"] = KConstants.currentLanguage
        tmpParams["Name"] = signalName
        tmpParams["ContentId"] = contentId
        return post(KAPIConstants.signal, parameters: tmpParams, progress: nil, success: { (task, responseObject) in
            success?(task, responseObject)
        }) { (task: KDataTask?, error: Error) in
            failure?(task, error)
        }
    }
    
    //MARK: - Metodi di autenticazione

    public func krakeLogin(providerName: String,
                           params: [String: String],
                           completion: @escaping KrakeAuthBlock )
    {
        let success: (KDataTask, Any?) -> Void =
        {
            (task, object) in
            self.loginCompletion(task, object: object, completion: completion)
        }
        let failure: (KDataTask?, Error) -> Void =
        {
            (task, error) in
            self.loginCompletion(task, error: error, completion: completion)
        }

        var extras = [String: String]()
        extras["UUID"] = KConstants.uuid
        params.forEach { (key: String, value: String) in
            extras[key] = value
        }

        let request = KRequest<[String: String]>()
        request.parameters = extras
        switch providerName {
        case KrakeAuthenticationProvider.orchard:
            request.path = KAPIConstants.userExtensions + "/SignInSsl"
            request.queryParameters.append(URLQueryItem(name:"Lang",value: KConstants.currentLanguage))
            request.method = .post
        default:
            request.path = KAPIConstants.externalTokenLogon
            request.queryParameters.append(URLQueryItem(name: KParametersKeys.language, value: KConstants.currentLanguage))
            request.queryParameters.append(URLQueryItem(name: KParametersKeys.Login.provider, value: providerName))
            request.method = .get
        }

        _ = self.request(request,
                     successCallback: success,
                     failureCallback: failure)
    }

    @objc public func krakeRegisterUser(_ params: [String: String],
                                        completion: @escaping KrakeAuthBlock) {
        let request = KRequest<[String: String]>()
        request.path = KAPIConstants.userExtensions + "/RegisterSsl"
        request.queryParameters.append(URLQueryItem(name: "UUID", value: KConstants.uuid))
        request.queryParameters.append(URLQueryItem(name: "Lang", value: KConstants.currentLanguage))
        request.method = .post
        request.parameters = params

        _ = self.request(request,
                         successCallback: { (task, object) in
                            self.loginCompletion(task, object: object, completion: completion)
        }, failureCallback: { (task, error) in
            self.loginCompletion(task, error: error, completion: completion)
        })
    }
    
    fileprivate func loginCompletion(_ task: KDataTask?,
                                     object: Any? = nil,
                                     error: Error? = nil,
                                     completion: KrakeAuthBlock) {
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
    
    @objc public func requestKrakeLostPassword(_ queryString: String,
                                               params: [String: String],
                                               completion: @escaping KrakeAuthBlock) {
        let request = KRequest<[String: String]>()
        request.method = .post
        request.parameters = params
        request.path = KAPIConstants.userExtensions + "/" + queryString
        request.queryParameters.append(URLQueryItem(name: "Lang", value: KConstants.currentLanguage))

        _ = self.request(request,
                         successCallback: { (task, object) in
                            if let responseObject = object as? [String : AnyObject] , let response = KrakeResponse(object: responseObject as AnyObject) , response.success == false{
                                completion(false, nil,
                                           NSError(domain: "Request lost password",
                                                   code: response.errorCode,
                                                   userInfo: [NSLocalizedDescriptionKey : response.message ?? ""]))
                            }else{
                                completion(true, nil, nil)
                            }
                            self.invalidateSessionCancelingTasks(true)
        },
                         failureCallback: { (task, error) in
                            completion(false, nil, error as Error?)
                                       self.invalidateSessionCancelingTasks(true)
        })
    }

    private func request(_ URLString: String,
                         method: KMethod,
                         parameters: [String: String]?,
                         success: ((KDataTask, Any?) -> Void)?,
                         failure: ((KDataTask, Error) -> Void)?) -> KDataTask {

        let request = createRequest(path: URLString,
                                    method: method,
                                    queryItems: [],
                                    parameters: parameters)

        return self.request(request, successCallback: success, failureCallback: failure)
    }

    func request<KP: Encodable>(_ path: String,
                                method: KMethod,
                                parameters: KP? = nil,
                                query: [URLQueryItem] = [],
    successCallback: ((KDataTask, Any?) -> Void)?,
    failureCallback: ((KDataTask, Error) -> Void)?) -> KDataTask {

        let request = KRequest<KP>()

        request.method = method
        request.parameters = parameters
        request.queryParameters = query
        return self.request(request, successCallback: successCallback, failureCallback: failureCallback)

    }

    func request<KP: Encodable>(_ request: KRequest<KP>,
                 successCallback: ((KDataTask, Any?) -> Void)?,
                 failureCallback: ((KDataTask, Error) -> Void)?) -> KDataTask {

        let dataRequest = sessionManager.request(request.asURL(baseURL),
                                                 method: request.method.afMethod(),
                                                 parameters: request.parameters,
                                                 encoder: (request.requestSerializer ?? requestSerializer).af(),
                                                 interceptor: nil)
            .validate()

        if let dp = request.downloadProgress {
            dataRequest.downloadProgress(closure: dp)
        }

        if let up = request.uploadProgress {
            dataRequest.uploadProgress(closure: up)
        }

        return self.wrapAndExecute(dataRequest: dataRequest, successCallback: successCallback, failureCallback: failureCallback)
    }

    private func wrapAndExecute(dataRequest: DataRequest,
    successCallback: ((KDataTask, Any?) -> Void)?,
    failureCallback: ((KDataTask, Error) -> Void)?) -> KDataTask {

        let dataTask = KDataTask(dataRequest: dataRequest)

        dataRequest.responseJSON { response in
            switch response.result {
            case let .success(json):
                successCallback?(dataTask,json)
                print(json)
            case let .failure(error):
                failureCallback?(dataTask,error)
                print(error)
            }
        }
        return dataTask
    }

    private func createRequest(path: String,
                               method: KMethod,
                               queryItems: [URLQueryItem],
                               parameters: [String: String]?) -> KRequest<[String: String]> {
        let request = KRequest<[String: String]>()
        request.method = method
        request.queryParameters = queryItems
        request.parameters = parameters
        return request
    }

    public func get(_ URLString: String,
                    parameters: [String: String]?,
                    success: ((KDataTask, Any?) -> Void)?,
                    failure: ((KDataTask, Error) -> Void)? = nil) -> KDataTask {
        return request(URLString, method: .get, parameters: parameters, success: success, failure: failure)
    }

    public func post(_ URLString: String,
                     parameters: [String: String]?,
                     success: ((KDataTask, Any?) -> Void)?,
                     failure: ((KDataTask, Error) -> Void)? = nil) -> KDataTask {
        return request(URLString, method: .post, parameters: parameters, success: success, failure: failure)
    }

    
    //MARK: - Krake additional registration infos
    
    @objc public func policiesRegistration(_ completion: @escaping (_ success: Bool, _ withResponse: AnyObject?, _ error: Error?) -> Void){
        let get = String(format: "%@/GetCleanRegistrationPoliciesSsl?Lang=%@", KAPIConstants.userExtensions, KConstants.currentLanguage)
        _ = request(get,
                    method: .get,
                    parameters: nil,
                    success: { (task, object) in
                        if let responseObject = object as? [String : AnyObject],
                            let policies = responseObject["Policies"] {
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

    func invalidateSessionCancelingTasks(_ cancelTask: Bool) {
        //TODO: capire come fare
        /*
        if (cancelTask) {
            [self.session invalidateAndCancel];
        } else {
            [self.session finishTasksAndInvalidate];
        }*/
    }
    
    //MARK: - aggiornare il profilo utente
    
    @objc public func updateUserProfile(_ params: [String: String], completion: @escaping KrakeAuthBlock){

        _ = request(KAPIConstants.userStartupConfig,
                    method: .post,
                    parameters: params,
                    success: { (task, object) in
                        if let responseObject = object , let response = KrakeResponse(object: responseObject) {
                            if response.success == true{
                                completion(true, response.data, nil)
                            }else{
                                completion(false, nil, NSError(domain: "User update profile",
                                                               code: response.errorCode,
                                                               userInfo: [NSLocalizedDescriptionKey : response.message ?? ""]))
                            }
                        }else{
                            completion(false, nil, NSError(domain: "User update profile",
                                                           code: KErrorCode.genericError,
                                                           userInfo: [NSLocalizedDescriptionKey : "Generic error".localizedString()]))
                        }
        }) { (task, error) in
            completion(false, nil, error)
        }
    }
    
    //MARK: - Metodi sovrascritti per gestire gli errori di krake e l'invalidateSessionManager

    @objc public func get(_ URLString: String,
                          parameters: [String: String]?,
                          progress downloadProgress: ((Progress) -> Void)?,
                          success: ((KDataTask, Any?) -> Void)?,
                          failure: ((KDataTask, Error) -> Void)?) -> KDataTask{

        let request = createRequest(path: URLString,
                      method: .get,
                      queryItems: [],
                      parameters: parameters)
        request.downloadProgress = downloadProgress

        return self.request(request,
                     successCallback: { (task, object) in
                        if let responseObject = object as? [String : AnyObject] , let kSuccess = responseObject["Success"] as? NSNumber ?? responseObject["success"] as? NSNumber , kSuccess == 0
                        {
                            self.checkKrakeResponse(KrakeResponse(object: responseObject),
                                                    parameters: parameters,
                                                    checkSuccess: { (manager) in
                                                        _ = manager.request(request,
                                                                            successCallback: { (task, object) in
                                                                                success?(task, object)
                                                                                manager.invalidateSessionCancelingTasks(true)
                                                        },
                                                                            failureCallback: { (task, error) in
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
        }) { (task, error) in
            self.parseAndCheckKrakeError(error)
            failure?(task, error)
            self.invalidateSessionCancelingTasks(true)
        }
    }
    
    @objc public func put(_ URLString: String,
                                   parameters: [String: String]?,
                                   success: ((KDataTask, Any?) -> Void)?,
                                   failure: ((KDataTask, Error) -> Void)?) -> KDataTask {
        let request = createRequest(path: URLString,
                             method: .put,
                             queryItems: [],
                             parameters: parameters)
        return self.request(request,
                            successCallback: { (task, object) in
                                self.checkHeaderResponse(task)
                                if let responseObject = object as? [String : AnyObject] , let kSuccess = responseObject["Success"] as? NSNumber ?? responseObject["success"] as? NSNumber , kSuccess == 0{
                                    self.checkKrakeResponse(KrakeResponse(object: responseObject), parameters: parameters, checkSuccess: { (manager) in
                                        _ = manager.request(request,
                                                            successCallback: { (task, object) in
                                                                success?(task, object)
                                                                manager.invalidateSessionCancelingTasks(true)
                                                            },
                                                            failureCallback:  { (task, error) in
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
        },
                            failureCallback:  { (task, error) in
            self.parseAndCheckKrakeError(error)
            failure?(task, error)
            self.invalidateSessionCancelingTasks(true)
        })
    }
    
    @objc public func post(_ URLString: String,
                           parameters: [String: String]?,
                           progress uploadProgress: ((Progress) -> Void)?,
                           success: ((KDataTask, Any?) -> Void)?,
                           failure: ((KDataTask, Error) -> Void)?) -> KDataTask {
        let request = createRequest(path: URLString,
        method: .post,
        queryItems: [],
        parameters: parameters)
        request.uploadProgress = uploadProgress

        return self.request(request,
                            successCallback:  { (task, object) in
                                       self.checkHeaderResponse(task)
                                       if let responseObject = object as? [String : AnyObject] , let kSuccess = responseObject["Success"] as? NSNumber ?? responseObject["success"] as? NSNumber , kSuccess == 0{
                                           self.checkKrakeResponse(KrakeResponse(object: responseObject), parameters: parameters, checkSuccess: { (manager) in
                                            _ = manager.request(request,
                                                                successCallback: { (task, object) in
                                                                    success?(task, object)
                                                                    manager.invalidateSessionCancelingTasks(true)
                                                                },
                                                                failureCallback: { (task, error) in
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
                                   },
                            failureCallback: {(task, error) in
                                self.parseAndCheckKrakeError(error)
                                failure?(task, error)
                                self.invalidateSessionCancelingTasks(true)
                            })
    }
    
    public func upload(_ URLString: String,
                           constructingBodyWith block: ((KMultipartFormData) -> Void)?,
                           progress uploadProgress: ((Progress) -> Void)? = nil,
                           successCallback: ((KDataTask, Any?) -> Void)? = nil,
                           failureCallback: ((KDataTask?, Error) -> Void)? = nil) -> KDataTask?{

        let dataRequest = sessionManager.upload(multipartFormData: { (multiFormData) in
            block?(KMultipartFormData(multiFormData))
        }, to:  self.baseURL.appendingPathComponent(URLString))
            .validate()

        if let up = uploadProgress {
            dataRequest.uploadProgress(closure: up)
        }

        let success = { (task: KDataTask, object: Any) in
            self.checkHeaderResponse(task)
            if let responseObject = object as? [String : AnyObject] , let kSuccess = responseObject["Success"] as? NSNumber ?? responseObject["success"] as? NSNumber , kSuccess == 0 {
                self.checkKrakeResponse(KrakeResponse(object: responseObject),
                                        parameters: nil, checkSuccess: { (manager) in
                                            _ = self.wrapAndExecute(dataRequest: dataRequest,
                                       successCallback: { (task, object) in
                                           successCallback?(task, object)
                                           manager.invalidateSessionCancelingTasks(true)
                                       },
                                       failureCallback: { (task, error) in
                                           failureCallback?(task, error)
                                           manager.invalidateSessionCancelingTasks(true)
                                       })
                }, checkFailure: { (error: Error) in
                    failureCallback?(task, error)
                    self.invalidateSessionCancelingTasks(true)
                })
            }else{
                successCallback?(task, object)
                self.invalidateSessionCancelingTasks(true)
            }
        }

        let failure = {(task: KDataTask?, error: Error) in
            self.parseAndCheckKrakeError(error)
            failureCallback?(task, error)
            self.invalidateSessionCancelingTasks(true)
        }

        return self.wrapAndExecute(dataRequest: dataRequest,
                                   successCallback: success,
                                   failureCallback: failure)

    }
    
    //MARK: - Metodi privati
    
    fileprivate func checkKrakeResponse(_ responseObject: KrakeResponse?,
                                        parameters: Any? = nil,
                                        checkSuccess: ((KNetworkManager) -> Void)? = nil,
                                        checkFailure: ((Error) -> Void)? = nil){
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
                                let error = NSError(domain: KInfoPlist.appName, code: response.errorCode, userInfo: [NSLocalizedDescriptionKey : response.message as Any])
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
            let error = NSError(domain: KInfoPlist.appName,
                                code: response.errorCode,
                                userInfo: [NSLocalizedDescriptionKey : response.message ?? "", KNEKrakeResponse: response])
            checkFailure?(error)
        }
        else {
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
    
    fileprivate func completedLogin(_ task: KDataTask?,
                                    responseObject: KrakeResponse?,
                                    completion: KrakeAuthBlock){
        if let task = task {
            checkHeaderResponse(task)
            let error: Error? = !(responseObject?.message ?? "").isEmpty ? NSError(domain: KInfoPlist.appName, code: 0, userInfo: [NSLocalizedDescriptionKey : responseObject!.message!]) : nil
            completion(true, responseObject?.data, error)
        }
        else {
            completion(false, nil, nil)
        }
    }

    fileprivate func checkHeaderResponse(_ task : KDataTask ){
           if checkHeaderResponse {
            if let response = task.dataRequest.response,
                   let headers = response.allHeaderFields as? [String : String]{
                   let array = HTTPCookie.cookies(withResponseHeaderFields: headers, for: baseURL)
                   URLSessionConfiguration.parse(cookies: array)
               }
           }
       }

    fileprivate func checkHeaderResponse(_ task : URLSessionDataTask ){
        if checkHeaderResponse {
            if let response = task.response as? HTTPURLResponse,
                let headers = response.allHeaderFields as? [String : String]{
                let array = HTTPCookie.cookies(withResponseHeaderFields: headers, for: baseURL)
                URLSessionConfiguration.parse(cookies: array)
            }
        }
    }
    
}
