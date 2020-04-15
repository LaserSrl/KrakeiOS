//
//  KAppDelegate.swift
//  Pods
//
//  Created by Patrick on 07/03/17.
//
//

import Foundation
import Fabric
import Crashlytics
import AlamofireNetworkActivityIndicator

open class KAppDelegate: OGLAppDelegate, KStreamingProviderSupplier {

    private lazy var streamingProviders: [KStreamingProvider] = []
    public var checkLaunchOptions = true

    open override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [KApplicationLaunchOptionsKey : Any]?) -> Bool {
        let value = super.application(application, didFinishLaunchingWithOptions: launchOptions)

        NetworkActivityIndicatorManager.shared.isEnabled = true
        // Istanzio la classe di default degli analytics se non già fatto in app.
        if (AnalyticsCore.shared == nil)
        {
            AnalyticsCore.shared = KDefaultAnalytics()
        }
        
        // Registrazione al servizio di notifica push.
        if (KInfoPlist.KrakePlist.pushRegistrationOnDidFinishLaunchingWithOptions)
        {
            KPushManager.pushRegistrationRequest()
        }
        else
        {
            KLog(type: .warning, "PUSH: token NOT REGISTERED -> call KPushManager.pushRegistrationRequest() or set, on info.plist, YES the 'PushRegistrationOnDidFinishLaunchingWithOptions' value")
        }
        
        if let notificationUserInfo = launchOptions?[KApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any], checkLaunchOptions
        {
            self.application(application, didReceiveRemoteNotification: notificationUserInfo)
        }
        return value
    }

    //MARK: - Push sharedApplicationDelegate
    @objc open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        KPushManager.setPushDeviceToken(deviceToken as Data)
    }
    
    @objc open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        KLog("PUSH: fail to register with error -> " + error.localizedDescription)
    }

    @objc open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        KPushManager.showOrOpenPush(userInfo, applicationState: application.applicationState)
    }

    func application(_ application: UIApplication,
              continue userActivity: NSUserActivity,
              restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

            if let url = userActivity.webpageURL,
                let nonce = KLoginManager.shared.extractNonce(url: url) {
                KLoginManager.shared.verifyNonce(nonce) { (success, error) in
                    if (success) {
                        KMessageManager.showMessage("VerificationMailMessage".localizedString(),
                                                    type: .success)
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
            #if swift(>=4)
                let sourceProvider = String(string[..<pipeIndex.lowerBound]).uppercased()
            #else
                let sourceProvider = string.substring(to: pipeIndex.lowerBound).uppercased()
            #endif
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
