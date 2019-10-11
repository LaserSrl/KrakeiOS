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

public typealias KParamaters = [String: Any]

private extension KRequestSerializer {
    func encoding() -> ParameterEncoding {
        switch self {
        case .json:
            return JSONEncoding.default
        case .http:
            return URLEncoding.default
        }
    }

    func encoder() -> ParameterEncoder {
        switch self {
        case .json:
            return JSONParameterEncoder()
        case .http:
            return URLEncodedFormParameterEncoder(destination: .methodDependent)
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

open class KRequest {

    var path: String = ""

    var queryParameters = [URLQueryItem]()

    var method: KMethod = .get
    var parameters: KParamaters? = nil
    var requestSerializer: KRequestSerializer? = nil

    var responseSerializer: KResponseSerializer? = nil

    var uploadProgress: ((Progress) -> Void)? = nil
    var downloadProgress: ((Progress) -> Void)? = nil

    func genericParamters() -> Any? {
        return parameters
    }
}

public class KCodableRequest<Parameters: Encodable>: KRequest {
    var codableParameters: Parameters? = nil

    public init(_ codableParameters: Parameters? = nil) {
        self.codableParameters = codableParameters
        super.init()
    }

    override func genericParamters() -> Any? {
        return codableParameters
    }
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
    public let request: KRequest

    init(request: KRequest, data: DataRequest) {
        self.dataRequest = data
        self.request = request
    }
    

    @objc public func cancel() {
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

    @objc public static func defaultDataNetworkManager(_ auth: Bool) -> KNetworkManager{
        let manager = KNetworkManager(baseURL: KInfoPlist.KrakePlist.path, auth: auth)
        manager.requestSerializer = .http
        manager.responseSerializer = .json
        manager.authenticated = auth
        return manager
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
                                        params: KParamaters? = nil,
                                        success: ((KDataTask, Any?) -> Void)?,
                                        failure: ((KDataTask?, Error) -> Void)?) -> KDataTask?{
        var tmpParams = params ?? KParamaters()
        tmpParams["lang"] = KConstants.currentLanguage
        tmpParams["Name"] = signalName
        tmpParams["ContentId"] = contentId
        return request(KAPIConstants.signal, method: .post, parameters: tmpParams, successCallback: success, failureCallback: failure)
    }
    
    //MARK: - Metodi di autenticazione

    public func krakeLogin(providerName: String,
                           params: KParamaters,
                           completion: @escaping KrakeAuthBlock )
    {

        var extras = KParamaters()
        extras["UUID"] = KConstants.uuid
        params.forEach { (key: String, value: Any) in
            extras[key] = value
        }

        let request = KRequest()
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


        _ = self.request(request,
                callbackWrapperLevel: .none,
                     successCallback: success,
                     failureCallback: failure)
    }

    @objc public func krakeRegisterUser(_ params: KParamaters,
                                        completion: @escaping KrakeAuthBlock) {
        let request = KRequest()
        request.path = KAPIConstants.userExtensions + "/RegisterSsl"
        request.queryParameters.append(URLQueryItem(name: "UUID", value: KConstants.uuid))
        request.queryParameters.append(URLQueryItem(name: "Lang", value: KConstants.currentLanguage))
        request.method = .post
        request.parameters = params

        _ = self.request(request,
                         callbackWrapperLevel: .none,
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
                if let task = task {
                           checkHeaderResponse(task)
                           let error: Error? = !(response?.message ?? "").isEmpty ? NSError(domain: KInfoPlist.appName, code: 0, userInfo: [NSLocalizedDescriptionKey : response!.message!]) : nil
                           completion(true, response?.data, error)
                       }
                       else {
                           completion(false, nil, nil)
                       }
            }else{
                KLoginManager.shared.userLogout()
                completion(false, nil, NSError(domain: "Login", code: (response?.errorCode ?? 0), userInfo: [NSLocalizedDescriptionKey : (response?.message ?? "Generic error".localizedString())]))
            }
        }
        invalidateSessionCancelingTasks(true)
    }
    
    //MARK: - Krake lost password request
    
    @objc public func requestKrakeLostPassword(_ queryString: String,
                                               params: KParamaters,
                                               completion: @escaping KrakeAuthBlock) {
        let request = KRequest()
        request.method = .post
        request.parameters = params
        request.path = KAPIConstants.userExtensions + "/" + queryString
        request.queryParameters.append(URLQueryItem(name: "Lang", value: KConstants.currentLanguage))

        _ = self.request(request,
                         callbackWrapperLevel: .none,
                         successCallback: { (task, object) in
                            if let responseObject = object as? [String : AnyObject] , let response = KrakeResponse(object: responseObject as AnyObject) , response.success == false{
                                completion(false, nil,
                                           NSError(domain: "Request lost password",
                                                   code: response.errorCode,
                                                   userInfo: [NSLocalizedDescriptionKey : response.message ?? ""]))
                            }
                            else {
                                completion(true, nil, nil)
                            }
                            self.invalidateSessionCancelingTasks(true)
        },
                         failureCallback: { (task, error) in
                            completion(false, nil, error as Error?)
                                       self.invalidateSessionCancelingTasks(true)
        })
    }

    func request(_ path: String,
                                method: KMethod,
                                parameters: KParamaters? = nil,
                                query: [URLQueryItem] = [],
        successCallback: ((KDataTask, Any?) -> Void)?,
        failureCallback: ((KDataTask, Error) -> Void)?) -> KDataTask {

        let request = KRequest()
        request.path = path
        request.method = method
        request.parameters = parameters
        request.queryParameters = query
        return self.request(request, successCallback: successCallback, failureCallback: failureCallback)
    }

    func request<Parameters: Encodable>(_ request: KCodableRequest<Parameters>,
                 successCallback: ((KDataTask, Any?) -> Void)?,
                 failureCallback: ((KDataTask, Error) -> Void)?) -> KDataTask {

        let dataRequest = sessionManager.request(request.asURL(baseURL),
                                                 method: request.method.afMethod(),
                                                 parameters: request.codableParameters,
                                                 encoder: (request.requestSerializer ?? requestSerializer).encoder(),
                                                 interceptor: nil)
            .validate()

        if let dp = request.downloadProgress {
            dataRequest.downloadProgress(closure: dp)
        }

        if let up = request.uploadProgress {
            dataRequest.uploadProgress(closure: up)
        }

        return self.wrapAndExecute(request: request,
                                   dataRequest: dataRequest,
                                   successCallback: successCallback,
                                   failureCallback: failureCallback)
    }

    func request(_ request: KRequest,
                 successCallback: ((KDataTask, Any?) -> Void)?,
                 failureCallback: ((KDataTask, Error) -> Void)?) -> KDataTask {

        return self.request(request,
                            callbackWrapperLevel: .standard,
                            successCallback: successCallback,
                            failureCallback: failureCallback)
    }

    private func request(_ request: KRequest,
                         callbackWrapperLevel: CallbackWrapperLevel,
                 successCallback: ((KDataTask, Any?) -> Void)?,
                 failureCallback: ((KDataTask, Error) -> Void)?) -> KDataTask {

        let dataRequest = sessionManager.request(request.asURL(baseURL),
                                                 method: request.method.afMethod(),
                                                 parameters: request.parameters,
                                                 encoding: (request.requestSerializer ?? requestSerializer).encoding(),
                                                 interceptor: nil)
            .validate()

        if let dp = request.downloadProgress {
            dataRequest.downloadProgress(closure: dp)
        }

        if let up = request.uploadProgress {
            dataRequest.uploadProgress(closure: up)
        }

        return self.wrapAndExecute(callbackWrapperLevel: callbackWrapperLevel,
                                   request: request,
                                   dataRequest: dataRequest,
                                   successCallback: successCallback,
                                   failureCallback: failureCallback)
    }

    private func wrapAndExecute(
        callbackWrapperLevel: CallbackWrapperLevel = .standard,
        request: KRequest,
        dataRequest: DataRequest,
    successCallback: ((KDataTask, Any?) -> Void)?,
    failureCallback: ((KDataTask, Error) -> Void)?) -> KDataTask {

        let dataTask = KDataTask(request: request, data: dataRequest)


        let failureWrapper : ((KDataTask, Error) -> Void)?
        let successWrapper : ((KDataTask, Any?) -> Void)?

        switch callbackWrapperLevel {
        case .standard:
            failureWrapper  = { (task, error) in
                       self.parseAndCheckKrakeError(error)
                       failureCallback?(task, error)
                       self.invalidateSessionCancelingTasks(true)
                   }

            successWrapper = { (task, object) in
                                    self.checkHeaderResponse(task)
                                    if let responseObject = object as? [String : AnyObject] , let kSuccess = responseObject["Success"] as? NSNumber ?? responseObject["success"] as? NSNumber , kSuccess == 0{
                                        self.checkKrakeResponse(KrakeResponse(object: responseObject), parameters: request.genericParamters(), checkSuccess: { (manager) in
                                            _ = manager.wrapAndExecute(callbackWrapperLevel: .afterLogin,
                                                                   request: request,
                                                                   dataRequest: dataRequest,
                                                                   successCallback: successCallback,
                                                                   failureCallback: failureCallback)
                                        }, checkFailure: { (error: Error) in
                                            failureCallback?(task, error)
                                            self.invalidateSessionCancelingTasks(true)
                                        })
                                    }
                                    else{
                                        successCallback?(task, object)
                                        self.invalidateSessionCancelingTasks(true)
                                    }
            }

        case .afterLogin:
            failureWrapper = { (task, error) in
                failureCallback?(task, error)
                self.invalidateSessionCancelingTasks(true)
            }

            successWrapper = { (task, object) in
                successCallback?(task, object)
                self.invalidateSessionCancelingTasks(true)
            }
        default:
            failureWrapper = failureCallback
            successWrapper = successCallback
        }

        dataRequest.responseJSON { response in
            switch response.result {
            case let .success(json):
                successWrapper?(dataTask,json)
                print(json)
            case let .failure(error):
                failureWrapper?(dataTask,error)
                print(error)
            }
        }
        return dataTask
    }

    private func createRequest(path: String,
                               method: KMethod,
                               queryItems: [URLQueryItem],
                               parameters: KParamaters?) -> KRequest {
        let request = KRequest()
        request.path = path
        request.method = method
        request.queryParameters = queryItems
        request.parameters = parameters
        return request
    }

    //MARK: - Krake additional registration infos
    
    @objc public func policiesRegistration(_ completion: @escaping (_ success: Bool, _ withResponse: AnyObject?, _ error: Error?) -> Void){

        let request = KRequest()
        request.path = KAPIConstants.userExtensions + "/GetCleanRegistrationPoliciesSsl"
        request.method = .get
        request.queryParameters = [URLQueryItem(name: "Lang", value: KConstants.currentLanguage)]


        _ = self.request(request,
                         callbackWrapperLevel: .none,
                         successCallback: { (task, object) in
                                         if let responseObject = object as? [String : AnyObject],
                                             let policies = responseObject["Policies"] {
                                             completion(true, policies, nil)
                                         }else{
                                             completion(false, nil, NSError(domain: "Registration", code: KErrorCode.genericError, userInfo: [NSLocalizedDescriptionKey : "Generic error".localizedString()]))
                                         }
                                         self.invalidateSessionCancelingTasks(true)
                         },
                         failureCallback: { (task, error) in
                             completion(false, nil, error)
                             self.invalidateSessionCancelingTasks(true)
                         })
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
    
    @objc public func updateUserProfile(_ params: KParamaters, completion: @escaping KrakeAuthBlock){

        _ = request(KAPIConstants.userStartupConfig,
                    method: .post,
                    parameters: params,
                    successCallback: { (task, object) in
                        if let responseObject = object , let response = KrakeResponse(object: responseObject) {
                            if response.success == true {
                                completion(true, response.data, nil)
                            }
                            else {
                                completion(false, nil, NSError(domain: "User update profile",
                                                               code: response.errorCode,
                                                               userInfo: [NSLocalizedDescriptionKey : response.message ?? ""]))
                            }
                        }
                        else {
                            completion(false, nil, NSError(domain: "User update profile",
                                                           code: KErrorCode.genericError,
                                                        userInfo: [NSLocalizedDescriptionKey : "Generic error".localizedString()]))
                        }
        }) { (task, error) in
            completion(false, nil, error)
        }
    }

    //MARK: - Metodi sovrascritti per gestire gli errori di krake e l'invalidateSessionManager
    @available(*, deprecated, renamed: "request(_:method:parameters:query:successCallback:failureCallback:)")
    @objc public func get(_ URLString: String,
                          parameters: KParamaters?,
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

    @available(*, deprecated, renamed: "request(_:method:parameters:query:successCallback:failureCallback:)")
    public func put(_ URLString: String,
                                   parameters: KParamaters?,
                                   success: ((KDataTask, Any?) -> Void)?,
                                   failure: ((KDataTask, Error) -> Void)?) -> KDataTask {
        let request = createRequest(path: URLString,
                             method: .put,
                             queryItems: [],
                             parameters: parameters)
        return self.request(request,
                            successCallback: success,
                            failureCallback:  failure)
    }

    @available(*, deprecated, renamed: "request(_:method:parameters:query:successCallback:failureCallback:)")
    public func post(_ URLString: String,
                           parameters: KParamaters?,
                           progress uploadProgress: ((Progress) -> Void)?,
                           success: ((KDataTask, Any?) -> Void)?,
                           failure: ((KDataTask, Error) -> Void)?) -> KDataTask {
        let request = createRequest(path: URLString,
        method: .post,
        queryItems: [],
        parameters: parameters)
        request.uploadProgress = uploadProgress

        return self.request(request,
                            successCallback:  success,
                            failureCallback: failure)
    }
    
    public func upload(_ path: String,
                           constructingBodyWith block: ((KMultipartFormData) -> Void)?,
                           progress uploadProgress: ((Progress) -> Void)? = nil,
                           successCallback: ((KDataTask, Any?) -> Void)? = nil,
                           failureCallback: ((KDataTask?, Error) -> Void)? = nil) -> KDataTask?{

        let uploadRequest = KRequest()
        uploadRequest.method = .post
        uploadRequest.path = path

        let dataRequest = sessionManager.upload(multipartFormData: { (multiFormData) in
            block?(KMultipartFormData(multiFormData))
        }, to:  self.baseURL.appendingPathComponent(path))
            .validate()

        if let up = uploadProgress {
            dataRequest.uploadProgress(closure: up)
        }

        return self.wrapAndExecute(request: uploadRequest,
            dataRequest: dataRequest,
                                   successCallback: successCallback,
                                   failureCallback: failureCallback)

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
        }
        else {
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


    fileprivate func checkHeaderResponse(_ task : KDataTask ){
        if checkHeaderResponse  && task.request.method != .get {
            if let response = task.dataRequest.response,
                   let headers = response.allHeaderFields as? [String : String]{
                   let array = HTTPCookie.cookies(withResponseHeaderFields: headers, for: baseURL)
                   URLSessionConfiguration.parse(cookies: array)
               }
           }
       }
}

private enum CallbackWrapperLevel {
    case standard
    case afterLogin
    case none
}
