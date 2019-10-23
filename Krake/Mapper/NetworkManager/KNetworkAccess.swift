//
//  KNetworkAccess.swift
//  Pods
//
//  Created by Patrick on 03/09/16.
//
//

import Foundation

@objc
public protocol KNetworkAccessDelegate: NSObjectProtocol{
    
    func privacy(_ viewController: OMPrivacyViewController)
    func privacy(_ accepted: Bool, viewController: OMPrivacyViewController, error: Error?)
}

@objc
public enum OMPrivacyStatus : NSInteger {
    case accepted = 0
    case notAccepted = 1
    case waitingAcceptance = 2
}

@objc public class KNetworkAccess: NSObject{
    
    fileprivate static var instance: KNetworkAccess!
    @objc public weak var delegate: KNetworkAccessDelegate!
    @objc dynamic open var privacyStatus: OMPrivacyStatus = .waitingAcceptance
    
    @objc public static func sharedInstance() -> KNetworkAccess {
        if instance == nil {
            instance = KNetworkAccess()
        }
        return instance
    }
    
    @objc public func sendPolicies(_ params: NSDictionary?, viewController: OMPrivacyViewController?){
        if let params = params{
            sendPoliciesToKrake(params, success: { (task, object) in
                if viewController != nil{
                    self.delegate.privacy(true, viewController: viewController!, error: nil)
                }
                self.privacyStatus = .accepted
                }, failure: { (task, error) in
                    if viewController != nil{
                        self.delegate.privacy(false, viewController: viewController!, error: error)
                    }
                    self.privacyStatus = .notAccepted
            })
        }else{
            if viewController != nil{
                delegate.privacy(false, viewController: viewController!, error: nil)
            }
            self.privacyStatus = .notAccepted
        }
    }
    
    public func sendPoliciesToKrake(_ params: NSDictionary, success: ((KDataTask, AnyObject?) -> Void)?, failure: ((KDataTask, Error) -> Void)?){
       var extras: KParamaters = [KParametersKeys.language : KConstants.currentLanguage as AnyObject]
        var arrPolicies = [[AnyHashable: Any]]()
        for key in params.allKeys as! [NSCopying]{
            arrPolicies.append(["AnswerId" : 0, "PolicyTextId" : key, "OldAccepted" : false, "Accepted" : params[key]!, "AnswerDate" : "0001-01-01T00:00:00"])
        }
        extras["PoliciesForUser"] = ["Policies" : arrPolicies]


        let manager = KNetworkManager.defaultManager(true)

        _ = manager.request(KAPIConstants.policies,
                        method: .post,
                        parameters: extras,
                        query: [],
                        successCallback: { (task, object) in
                            if let responseObject = object as? [String : AnyObject] , let response = KrakeResponse(object: responseObject as AnyObject) , response.success == true {
                                if let headersFields = task.response?.allHeaderFields as? [String : String]{
                                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: headersFields, for: manager.baseURL)
                                    URLConfigurationCookies.shared.parse(cookies: cookies)
                                }
                                success?(task, object as AnyObject?)
                            }else{
                                failure?(task, NSError(domain: "Policies", code: KErrorCode.genericError, userInfo: [NSLocalizedDescriptionKey : "Generic error".localizedString()]))
                            }
        },
                        failureCallback: failure)

    }
}
