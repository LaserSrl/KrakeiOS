import Foundation
import UIKit

public typealias KAutoUpdateManagerResultHandler = (KAutoUpdateManager.UpdateResult) -> Void

public class KAutoUpdateManager {

    /// Available update status
    ///
    /// - updatesAvailable: there is an update available
    /// - noUpdatesAvailable: there isn't an update available
    public enum UpdateResult {
        case updatesAvailable
        case noUpdatesAvailable
    }
    
    /// Set this params with the manifest plist path. By default get "AppUpdatePlistPath" value from Krake dictionary on target plist file
    public static var appUpdatePlistPath: String? = {
        KInfoPlist.appUpdateUrlPath
    }()

    /// Check if there is an update available on remote plist path and call completion with UpdateResult
    ///
    /// - Parameter completion: update result
    public class func checkForUpdates(handledBy completion: @escaping KAutoUpdateManagerResultHandler) {
        #if !(DEBUG)
            guard let appUpdatePlistPath = appUpdatePlistPath,
                let urlUpdatePlist = URL(string: appUpdatePlistPath) else {
                    completion(.noUpdatesAvailable)
                    return
            }

            DispatchQueue.global(qos: .userInteractive).async {
                guard let updatePlist = NSDictionary(contentsOf: urlUpdatePlist) else {
                    DispatchQueue.main.async {
                        completion(.noUpdatesAvailable)
                    }
                    return
                }

                if let storeVersion =
                    (updatePlist.object(forKey: "items") as? [NSDictionary])?
                        .last?
                        .value(forKeyPath: "metadata.bundle-version") as? String,
                    let installedVersion = Bundle.main
                        .object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {

                    let isUpdateAvailable =
                        storeVersion.compare(installedVersion, options: .numeric) == .orderedDescending

                    DispatchQueue.main.async {
                        if isUpdateAvailable {
                            completion(.updatesAvailable)
                        } else {
                            completion(.noUpdatesAvailable)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.noUpdatesAvailable)
                    }
                }
            }
        #else
            completion(.noUpdatesAvailable)
        #endif
    }

    /// Start download new aspp version
    public class func downloadUpdate() {
        guard let appUpdatePlistPath = appUpdatePlistPath,
            let downloadUrl = URL(string: "itms-services://?action=download-manifest&url=\(appUpdatePlistPath)") else { return }

        if UIApplication.shared.canOpenURL(downloadUrl) {
            UIApplication.shared.openURL(downloadUrl)
        }
    }
}

