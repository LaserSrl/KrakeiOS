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
    
}

public struct KrakeLog {
    public static var level: LogLevel = LogLevel.warning

    public enum LogLevel: Int
    {
        case verbose = 0
        case debug = 1
        case info = 2
        case warning = 3
        case error = 4
    }

    
}

func KLog<T>(type: KrakeLog.LogLevel = .debug, _ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if DEBUG || VERBOSE
    if type.rawValue < KrakeLog.level.rawValue {
        return
    }
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
    print("🐙 [\(errorType) \(type.rawValue)] [\(queue)] \(fileURL) \(function)[\(line)]: \(value)")
    #endif
}
