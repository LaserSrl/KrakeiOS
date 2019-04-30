//
//  KPushManager.swift
//  Krake
//
//  Created by Patrick on 27/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import UserNotifications

extension KAPIConstants
{
    public static let push = "Api/Laser.Orchard.Mobile/Device"
}

/// # KPushManager
open class KPushManager: NSObject{
    
    public static func pushRegistrationRequest(){
        
        let settings = UIUserNotificationSettings(types: [.badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
                if !accepted {
                    print("Notification access denied.")
                }
            }
        }
    }
    
    public static func setPushDeviceToken(_ deviceToken: Data){
        var serializedToken: String = NSData(data: deviceToken).description
        serializedToken = serializedToken.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "<", with: "")
            .replacingOccurrences(of: ">", with: "")
        
        let uuid = KConstants.uuid
        let wsURL = KInfoPlist.KrakePlist.path
		let wsPath = wsURL.absoluteString

        if serializedToken != UserDefaults.standard.string(forConstantKey: .pushDeviceToken) ||
            KConstants.currentLanguage != UserDefaults.standard.string(forConstantKey: .pushLanguage) ||
            uuid != UserDefaults.standard.string(forConstantKey: .pushDeviceUUID) ||
            wsPath != UserDefaults.standard.string(forConstantKey: .pushURL)
        {
            let httpClient = KNetworkManager(baseURL: wsURL, auth: true)
            httpClient.requestSerializer = AFJSONRequestSerializer()
            httpClient.responseSerializer = AFJSONResponseSerializer()
            let requestParameters : [String: Any] = [KParametersKeys.token : serializedToken,
                                                     KParametersKeys.device : "Apple",
                                                     KParametersKeys.UUID : uuid,
                                                     KParametersKeys.language : KConstants.currentLanguage,
                                                     KParametersKeys.produzione : !KConstants.isDebugMode]
            
            _ = httpClient.put(KAPIConstants.push,
                               parameters: requestParameters,
                               success: { (task: URLSessionDataTask, object: Any?) in
                                UserDefaults.standard.setStringAndSync(serializedToken as String, forConstantKey: .pushDeviceToken)
                                UserDefaults.standard.setStringAndSync(uuid, forConstantKey: .pushDeviceUUID)
                                UserDefaults.standard.setStringAndSync(KConstants.currentLanguage, forConstantKey: .pushLanguage)
                                UserDefaults.standard.setStringAndSync(wsPath, forConstantKey: .pushURL)
            }, failure: { (task:  URLSessionDataTask?, error: Error) in
                KLog(type: .error, error.localizedDescription)
            })
            
            
        }
    }
    
    public static func showOrOpenPush(_ notification: [AnyHashable: Any], applicationState: KApplicationState){
        if let aps = notification["aps"] as? [AnyHashable: Any],
            let pushTitle = aps["alert"] as? String
        {
            if let displayAlias = notification["Al"] as? String{
                showOrOpenDetailWithMessage(pushTitle, displayAlias: displayAlias, applicationState: applicationState, userInfoNotification: notification)
            }else if let externalUrl = notification["Eu"] as? String, let url = URL(string: externalUrl){
                if UIApplication.shared.canOpenURL(url){
                    let mainVC = (UIApplication.shared.delegate as? OGLAppDelegate)?.window?.rootViewController
                    if applicationState == .active{
                        let alertViewController = UIAlertController(title: KInfoPlist.appName, message: pushTitle, preferredStyle: .alert)
                        alertViewController.message = String(format:"VUOI_APRIRE_PUSH".localizedString(), pushTitle)
                        alertViewController.addAction(UIAlertAction(title: "No".localizedString(), style: .cancel, handler: nil))
                        alertViewController.addAction(UIAlertAction(title: "Si".localizedString(), style: .default, handler: { (action: UIAlertAction) in
                            mainVC?.present(browserViewController: url, title: pushTitle)
                        }))
                        DispatchQueue.main.async(execute: {
                            if let pvc = mainVC?.presentedViewController {
                                pvc.present(alertViewController, animated: true, completion: nil)
                            }
                            else {
                                mainVC?.present(alertViewController, animated: true, completion: nil)
                                
                            }
                        })
                    }else{
                        DispatchQueue.main.async(execute: {
                            mainVC?.present(browserViewController: url, title: pushTitle)
                        })
                    }
                }
            }else{
                if applicationState == .active{
                    let mainVC = (UIApplication.shared.delegate as? OGLAppDelegate)?.window?.rootViewController
                    let alertViewController = UIAlertController(title: KInfoPlist.appName, message: pushTitle, preferredStyle: .alert)
                    alertViewController.message = pushTitle
                    alertViewController.addAction(UIAlertAction(title: "Ok".localizedString(), style: .default, handler: nil))
                    DispatchQueue.main.async(execute: {
                        mainVC?.present(alertViewController, animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    public static func showOrOpenContentFromLocalNotificaiton(_ notification: UILocalNotification, applicationState: KApplicationState){
        var moId: NSManagedObjectID? = nil
        let userInfo = notification.userInfo
        if let cacheIdri = userInfo?[LocalNotificationCacheID] as? String {
            moId = OGLAppDelegate.sharedApplicationDelegate().persistentStoreCoordinator.managedObjectID(forURIRepresentation: URL(string: cacheIdri)!)
        }
        showOrOpenDetailWithMessage(notification.alertBody, displayAlias: userInfo?[KParametersKeys.displayAlias] as? String, cacheObjectID: moId, applicationState: applicationState, userInfoNotification: userInfo)
    }
    
    fileprivate static func showOrOpenDetailWithMessage(_ message: String? = "", displayAlias: String?, cacheObjectID: NSManagedObjectID? = nil, applicationState: KApplicationState, userInfoNotification: [AnyHashable: Any]?){
        let appDelegate = UIApplication.shared.delegate as? OGLAppDelegate
        let mainWindow = appDelegate?.window
        let mainVC = mainWindow?.rootViewController
        if applicationState == .active{
            let alertViewController = UIAlertController(title: KInfoPlist.appName, message: message, preferredStyle: .alert)
            if (displayAlias != nil && !(displayAlias ?? "").isEmpty) || cacheObjectID != nil {
                alertViewController.message = String(format:"VUOI_APRIRE_PUSH".localizedString(), message!)
                alertViewController.addAction(UIAlertAction(title: "No".localizedString(), style: .cancel, handler: nil))
                alertViewController.addAction(UIAlertAction(title: "Si".localizedString(), style: .default, handler: { (action: UIAlertAction) in
                    self.loadOrDownloadWithAlias(displayAlias, cacheID: cacheObjectID, userInfoNotification: userInfoNotification)
                }))
            }else{
                alertViewController.addAction(UIAlertAction(title: "Ok".localizedString(), style: .default, handler: { (action: UIAlertAction) in
                }))
            }
            DispatchQueue.main.async(execute: {
                if let pvc = mainVC?.presentedViewController {
                    pvc.present(alertViewController, animated: true, completion: nil)
                }
                else {
                    mainVC?.present(alertViewController, animated: true, completion: nil)
                }
            })
        }else if (displayAlias != nil && !(displayAlias ?? "").isEmpty) || cacheObjectID != nil {
            loadOrDownloadWithAlias(displayAlias, cacheID: cacheObjectID, userInfoNotification: userInfoNotification)
        }
    }
    
    fileprivate static func loadOrDownloadWithAlias(_ alias: String?, cacheID: NSManagedObjectID?, userInfoNotification: [AnyHashable: Any]?){
        if cacheID != nil {
            let pathCache = OGLCoreDataMapper.sharedInstance().displayPathCache(from: cacheID!)
            showDetailWithAlias(alias, pathCache: pathCache, userInfoNotification: userInfoNotification)
        }else if alias != nil{
            OGLCoreDataMapper.sharedInstance().loadData(withDisplayAlias: alias!, extras: nil, completionBlock: { (parsedObject, error, completed) in
                if parsedObject != nil && completed{
                    let pathCache = OGLCoreDataMapper.sharedInstance().displayPathCache(from: parsedObject!)
                    self.showDetailWithAlias(pathCache.displayPath, pathCache: pathCache, userInfoNotification: userInfoNotification)
                }
            })
        }
    }
    
    fileprivate static func showDetailWithAlias(_ alias: String?, pathCache: DisplayPathCache?, userInfoNotification: [AnyHashable: Any]?){
        if let delegate = UIApplication.shared.delegate as? OGLAppDelegate{
            if alias != nil && !delegate.alreadyShownContentFromNotification(alias!, cache: pathCache, userInfoNotification: userInfoNotification){
                var extras: [String : Any]? = nil
                if let pushId = userInfoNotification?["Id"] as? NSNumber{
                    extras = ["PushId" : pushId]
                }
                if let vc = KDetailViewControllerFactory.factory.newDetailViewController(detailObject: pathCache?.cacheItems.firstObject as AnyObject?, endPoint: alias, analyticsExtras: extras)
                {
                    let nav = UINavigationController(rootViewController: vc)
                    KTheme.current.applyTheme(toNavigationBar: nav.navigationBar, style: .default)
                    nav.modalPresentationStyle = .fullScreen
                    let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: nav, action: #selector(UINavigationController.dismissViewController))
                    vc.navigationItem.leftBarButtonItem = closeButton
                    delegate.window?.rootViewController?.present(nav, animated: true, completion: nil)
                }
            }
        }
    }
    
}

