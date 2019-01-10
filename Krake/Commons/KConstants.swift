//
//  OMConstants.swift
//  Pods
//
//  Created by Patrick on 26/07/16.
//
//

import Foundation
import UIKit

@objc public class KConstants: NSObject
{
    public static let uuid: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    
    @objc public static let isDebugMode: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    @objc public static let currentLanguage: String = {
        let lang = "LANGUAGE".appLocalizedString()
        if lang == "LANGUAGE"{
            assertionFailure("DEVI CONFIGUARE LA KEY 'LANGUAGE' NEL LOCALIZABLE.STRINGS")
        }
        return lang
    }()
    
    @objc public static func iPhone6OrBigger() -> Bool{
        return UIScreen.main.bounds.width * UIScreen.main.scale > 640.0 && UIScreen.main.bounds.height * UIScreen.main.scale > 640.0
    }
    
    @objc public static func iPhone6Plus() -> Bool{
        return UIScreen.main.bounds.width * UIScreen.main.scale > 1000.0 && UIScreen.main.bounds.height * UIScreen.main.scale > 1000.0
    }
    
    @objc public static func iPhone4() -> Bool{
        return UIScreen.main.bounds.height * UIScreen.main.scale == 960.0 || UIScreen.main.bounds.width * UIScreen.main.scale == 960.0
    }
    
}


public enum LogLevel: String
{
    case verbose
    case debug
    case info
    case warning
    case error
}

public func KLog<T>(type: LogLevel = .debug, _ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if DEBUG
    let value = object()
    let fileURL = NSURL(string: file)?.lastPathComponent ?? "Unknown file"
    let queue = Thread.isMainThread ? "UI" : "BG"
    let errorType: String
    switch type {
    case .error:
        errorType = "‼️"
    case .warning:
        errorType = "⚠️"
    case .info:
        errorType = "ℹ️"
    case .debug:
        errorType = "💬"
    case .verbose:
        errorType = "🔬"
    }
    print("🐙 [\(errorType) \(type.rawValue)] [\(queue)] \(fileURL) \(function)[\(line)]: " + String(reflecting: value))
    #endif
}
