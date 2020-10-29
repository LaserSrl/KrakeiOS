//
//  KAppDelegate.swift
//  Pods
//
//  Created by Patrick on 07/03/17.
//
//

import Foundation
import FirebaseCrashlytics
import AlamofireNetworkActivityIndicator
import MBProgressHUD
import FirebaseCore
import FirebaseMessaging

open class KAppDelegate: OGLAppDelegate, KStreamingProviderSupplier {
    
    private lazy var streamingProviders: [KStreamingProvider] = []
    public var checkLaunchOptions = true
    
    open override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        let value = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        NetworkActivityIndicatorManager.shared.isEnabled = true
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseConfiguration.shared.setLoggerLevel(.error)
            FirebaseApp.configure()
        }
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // Istanzio la classe di default degli analytics se non già fatto in app.
        if (AnalyticsCore.shared == nil)
        {
            AnalyticsCore.shared = KDefaultAnalytics()
        }
        
        // Registrazione al servizio di notifica push.
        if (KInfoPlist.KrakePlist.pushRegistrationOnDidFinishLaunchingWithOptions)
        {
            KPushManager.requestAndRegisterForRemoteNotifications()
        }
        else
        {
            KLog(type: .warning, "PUSH: token NOT REGISTERED -> call KPushManager.pushRegistrationRequest() or set, on info.plist, YES the 'PushRegistrationOnDidFinishLaunchingWithOptions' value")
        }
        
        if let notificationUserInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any], checkLaunchOptions
        {
            self.application(application, didReceiveRemoteNotification: notificationUserInfo)
        }
        return value
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if let url = userActivity.webpageURL,
           let nonce = KLoginManager.shared.extractNonce(url: url) {
            if let view = window?.rootViewController?.view {
                MBProgressHUD.showAdded(to: view, animated: true)
            }
            KLoginManager.shared.verifyNonce(nonce) { [weak self] (success, error) in
                if (success) {
                    if let view = self?.window?.rootViewController?.view {
                        MBProgressHUD.hide(for: view, animated: true)
                    }
                    KMessageManager.showMessage(KLocalization.Login.verificationMailMessage,
                                                type: .success)
                    NotificationCenter.default.post(name: KLoginManager.UserEmailVerified, object: KLoginManager.shared)
                    KLoginManager.shared.delegate?.userEmailVerified()
                }
            }
            return true
        }
        return false
    }
    
    // MARK: - Streaming provider
    
    open func register(streamingProvider provider: KStreamingProvider) {
        // Checking that the same streaming provider hasn't already been registered.
        var isAlreadyRegistered = false
        if !streamingProviders.isEmpty {
            for streamingProvider in streamingProviders {
                if streamingProvider.name == provider.name {
                    isAlreadyRegistered = true
                    break
                }
            }
        }
        // Adding the streaming provider to the list of providers, if isn't
        // already present.
        if !isAlreadyRegistered {
            streamingProviders.append(provider)
        }
    }
    
    open func getStreamingProvider(fromSource string: String) throws -> KStreamingProvider {
        if let pipeIndex = string.range(of: "|") {
            let sourceProvider = String(string[..<pipeIndex.lowerBound]).uppercased()
            if let provider = streamingProviders.filter({ $0.name == sourceProvider })
                .first {
                return provider
            } else {
                throw KStreamingProviderErrors.unknownProvider
            }
        }
        throw KStreamingProviderErrors.malformedProviderString
    }
    
}

extension KAppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    open func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken = fcmToken {
            KPushManager.setDeviceToken(fcmToken)
        }
    }
    
    //MARK: - Push sharedApplicationDelegate
    @objc open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    @objc open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        KPushManager.showOrOpenPush(userInfo, applicationState: application.applicationState)
    }
    
    @objc open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        KLog("PUSH: fail to register with error -> " + error.localizedDescription)
    }
}
