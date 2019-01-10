//
//  KBTPaymentManager.swift
//  KrakePay
//
//  Created by joel on 12/02/16.
//  Copyright © 2016 Mobile Team PRO. All rights reserved.
//

import UIKit
import Braintree

public protocol KBTPaymentManagerDelegate {
    func paymentManager(_ manager: KBTPaymentManager,apiClientAvailable apiClient: BTAPIClient)
}

/// Class to manage the Payment with BraintreePayment
open class KBTPaymentManager: NSObject {
    fileprivate static var _sharedInstance : KBTPaymentManager? = nil
    
    public static let KBTPaymentManagerDidLoadApiClientNotification = NSNotification.Name(rawValue: "KPay Apiclient loaded")
    
    public let delegate:KBTPaymentManagerDelegate
    public let serverURL : URL
    open var client: BTAPIClient?
    
    
    enum KBTPaymentError : Error {
        case sharedInstanceAlreadySet
    }
    
    static public func sharedInstance() -> KBTPaymentManager {
        return _sharedInstance!
    }
    
    
    static public func setSharedInstance(_ shared: KBTPaymentManager) throws {
        guard _sharedInstance == nil  else {
            throw KBTPaymentError.sharedInstanceAlreadySet
        }
        
        _sharedInstance = shared
    }
    
    public init(returnURLScheme scheme: String,
                         delegate newDelegeate: KBTPaymentManagerDelegate) {
        
        delegate = newDelegeate
        serverURL = KInfoPlist.KrakePlist.path
            .appendingPathComponent("PaypalInit")
        BTAppSwitch.setReturnURLScheme(scheme)
        super.init()
        loadClient()
    }
    
    fileprivate func loadClient()
    {
        var clientTokenRequest = URLRequest(url: serverURL)
        
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest, completionHandler: { (data, response, error) -> Void in
            if data != nil
            {
                // TODO: Handle errors
                if let clientToken = String(data: data!, encoding: String.Encoding.utf8){
                    
                    self.client = BTAPIClient(authorization: clientToken)
                    if self.client != nil{
                        self.delegate.paymentManager(self, apiClientAvailable: self.client!)
                    }
                    NotificationCenter.default.post(Notification(name: KBTPaymentManager.KBTPaymentManagerDidLoadApiClientNotification, object: self))
                }
            }
            else {
                
            }
            
            }) .resume()
    }
}
