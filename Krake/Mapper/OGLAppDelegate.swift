//
//  OGLAppDelegate.swift
//  OrchardGen
//
//  Created by joel on 04/02/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import UIKit
import CoreData

open class OGLAppDelegate: UIResponder, UIApplicationDelegate, KNetworkAccessDelegate{
    
    fileprivate let defaultCacheDelegate = KMAutoQueryDivideCacheManager()
    
    public let blurSupported:Bool = {
        let poorGraphicsDevices =  ["iPad", "iPad1,1","iPhone1,1","iPhone1,2",
                                    "iPhone2,1","iPhone3,1","iPhone3,2",
                                    "iPhone3,3","iPod1,1","iPod2,1","iPod2,2",
                                    "iPod3,1","iPod4,1","iPad2,1","iPad2,2",
                                    "iPad2,3","iPad2,4","iPad3,1","iPad3,2","iPad3,3"]
        
        return !poorGraphicsDevices.contains(OMSystemInfo().machine)
    }()
    
    open var isOnBackgroundScreenVisibile: Bool = true {
        didSet{
            if !isOnBackgroundScreenVisibile && UIApplication.shared.applicationState != .active
            {
                self.presentBlurViewOverWindow()
            }
        }
    }
    
    @objc open var lockInterfaceOrientationMask: UIInterfaceOrientationMask = .all{
        didSet{
            switch lockInterfaceOrientationMask {
            case UIInterfaceOrientationMask.portrait:
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue,
                                          forKey: "orientation")
            case UIInterfaceOrientationMask.landscapeLeft:
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue,
                                          forKey: "orientation")
            case UIInterfaceOrientationMask.landscapeRight:
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue,
                                          forKey: "orientation")
            default:
                UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue,
                                          forKey: "orientation")
            }
        }
    }

    open var window: UIWindow?
    
    fileprivate let BLUR_VIEW_TAG = 1234
    
    open func presentBlurViewOverWindow()
    {
        if (!self.isOnBackgroundScreenVisibile) {
            let colorView: UIView
            
            if (!UIAccessibility.isReduceTransparencyEnabled && self.blurSupported){
                colorView =  UIVisualEffectView(effect: UIBlurEffect(style: .light))
                colorView.alpha = 0;
            }else{
                colorView = UIView();
                colorView.backgroundColor = UIColor.white
            }
            
            colorView.translatesAutoresizingMaskIntoConstraints = false
            colorView.tag = BLUR_VIEW_TAG
            
            
            if let sWindow = self.window
            {
                sWindow.addSubview(colorView)
                sWindow.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(0)-[colorView]-(0)-|",
                    options: .directionLeftToRight, metrics: nil, views: ["colorView":colorView]))
                sWindow.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[colorView]-(0)-|",
                    options: .directionLeftToRight, metrics: nil, views: ["colorView":colorView]))
                sWindow.bringSubviewToFront(sWindow)
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    colorView.alpha = 1
                })
            }
        }
    }
    
    func removeBlurViewOverWindow() {
        if (!self.isOnBackgroundScreenVisibile) {
            if let colorView = self.window?.viewWithTag(BLUR_VIEW_TAG)
            {
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    colorView.alpha = 0
                    }, completion: { (animated: Bool) -> Void in
                        colorView.removeFromSuperview()
                })
            }
        }
    }
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        OMSettings.registerDefaultsSettings()
        
        let oglMapper = OGLCoreDataMapper(managedObjectContext: managedObjectContext, model: managedObjectModel)
        oglMapper.delegate = defaultCacheDelegate
        OGLCoreDataMapper.setSharedInstance(oglMapper)
        
        KNetworkAccess.sharedInstance().delegate = self
        
        KStoreKitManager.shared.promptReviewRequestIfNeeded()
        
        return true
    }
    
    open func applicationWillResignActive(_ application: UIApplication) {
        self.presentBlurViewOverWindow()
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
        self.removeBlurViewOverWindow()
    }
    
    open func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return lockInterfaceOrientationMask
    }
    
    // MARK: - Core Data stack
    
    lazy open var applicationDocumentsDirectory: Foundation.URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.laser.hh" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy open var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "MappedOrchardDataModel", withExtension: "momd")!
        let model =  NSManagedObjectModel(contentsOf: modelURL)!
        if #available(iOS 10, *) {
        }else{
            model.kc_generateOrderedSetAccessors()
        }
        return model
    }()
    
    lazy open var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let sqliteDBName = String.localizedStringWithFormat("MappedDatabase-%@.sqlite", KConstants.currentLanguage);
        let url = self.applicationDocumentsDirectory.appendingPathComponent(sqliteDBName)
        if OMSettings.needToResetDataBase(){
            do {
                try FileManager.default.removeItem(at: url)
            }catch{
            }
        }
        let orcws = KInfoPlist.KrakePlist.host.absoluteString
        if orcws != UserDefaults.standard.string(forKey: "lastDBPath"){
            UserDefaults.standard.setValue(orcws, forKey: "lastDBPath")
            UserDefaults.standard.synchronize()
            do {
                try FileManager.default.removeItem(at: url)
            }catch{
                
            }
        }
        var failureReason = "There was an error creating or loading the application's saved data."
        
        let options = [NSMigratePersistentStoresAutomaticallyOption:true,NSInferMappingModelAutomaticallyOption:true];
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            do {
                try FileManager.default.removeItem(at: url)
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
            } catch {
                // Report any error we got.
                var dict = [String: AnyObject]()
                dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
                dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
                
                dict[NSUnderlyingErrorKey] = error as NSError
                let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
                // Replace this with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                KLog(type: .error, "Unresolved error \(wrappedError), \(wrappedError.userInfo)")
                abort()
            }
        }
        
        return coordinator
    }()   
    
    lazy open var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    open func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                KLog(type: .error, "Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    //MARK: push open management
    
    @available(*, unavailable, renamed: "alreadyShownContentFromNotification(_:cache:userInfoNotification:)")
    open func alreadyShownContentFromNotification(_ displayAlias : String, cache : DisplayPathCache?) ->Bool {
        return false
    }
    
    open func alreadyShownContentFromNotification(_ displayAlias : String, cache : DisplayPathCache?, userInfoNotification: [AnyHashable: Any]?) ->Bool {
        return false
    }
    
    //MARK: - shared application delegate
    public static func sharedApplicationDelegate() -> OGLAppDelegate {
        return UIApplication.shared.delegate as! OGLAppDelegate
    }
    
    //MARK: - OMNetwordAccess Delegate
    
    open func privacy(_ accepted: Bool, viewController: OMPrivacyViewController, error: Error?) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    open func privacy(_ viewController: OMPrivacyViewController) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            
            let nav = self.window?.rootViewController?.presentedViewController ?? self.window?.rootViewController
            if !(nav is OMPrivacyViewController){
                nav?.present(viewController, animated: true, completion: nil)
            }
            
        }
    }
    
}
