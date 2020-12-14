//
//  KMessageManager.swift
//  Krake
//
//  Created by Patrick on 28/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import SwiftMessages

@objc open class KMessageManager: NSObject{
    
    @objc public enum Mode: Int{
        case message = 0
        case success
        case warning
        case error
    }
    
    @objc public enum Layout: Int{
        case messageView
        case cardView
        case tabView
        case statusLine
    }
    
    public enum Position{
        case top
        case bottom
    }
    
    public enum Duration {
        case automatic
        case forever
        case seconds(seconds: TimeInterval)
    }
    
    static let convertLayoutBlock: (KMessageManager.Layout) -> MessageView.Layout = { (layout) in
        switch layout{
        case .messageView:
            return MessageView.Layout.messageView
        case .cardView:
            return MessageView.Layout.cardView
        case .tabView:
            return MessageView.Layout.tabView
        case .statusLine:
            return MessageView.Layout.statusLine
        }
    }
    
    static let convertModeBlock: (KMessageManager.Mode) -> Theme = { (mode) in
        switch mode{
        case .message:
            return .info
        case .success:
            return .success
        case .error:
            return .error
        case .warning:
            return .warning
        }
    }
    
    static let convertPositionBlock: (KMessageManager.Position) -> SwiftMessages.PresentationStyle = {(position) in
        switch position{
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }
    
    static let convertDurationBlock: (KMessageManager.Duration) -> SwiftMessages.Duration = { (duration) in
        switch duration{
        case .automatic:
            return .automatic
        case .forever:
            return .forever
        case .seconds(let seconds):
            return .seconds(seconds: seconds)
        }
    }
    
    @objc public static func showMessage(ObjC subtitle: String, type: KMessageManager.Mode = .message, layout: KMessageManager.Layout = .tabView, fromViewController: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController?.presentedViewController ?? UIApplication.shared.delegate?.window??.rootViewController, duration: Double = 0.0){
        let durationTmp: KMessageManager.Duration = duration == 0.0 ? .automatic : KMessageManager.Duration.seconds(seconds: duration)
        self.showMessage(subtitle, type: type, layout: layout, position: .top, duration: durationTmp, fromViewController: fromViewController)
    }
    
    public static func showMessage(_ subtitle: String,
                                   title: String =  KInfoPlist.appName,
                                   type: KMessageManager.Mode = .message,
                                   layout: KMessageManager.Layout = .tabView,
                                   position: KMessageManager.Position = .top,
                                   duration: KMessageManager.Duration = .automatic,
                                   windowLevel: UIWindow.Level = .statusBar,
                                   fromViewController: UIViewController? = nil,
                                   viewId: String? = nil,
                                   buttonTitle: String? = nil,
                                   buttonCompletion: (()->Void)? = nil){
        var config = Config()
        config.type = type
        config.layout = layout
        config.position = position
        config.duration = duration
        config.windowLevel = windowLevel
        config.fromViewController = fromViewController
        config.viewId = viewId
        config.buttonTitle = buttonTitle
        config.buttonCompletion = buttonCompletion
        showMessage(subtitle,
                    title: title,
                    config: config)
        
    }
    
    public static func showMessage(_ subtitle: String,
                                   title: String =  KInfoPlist.appName,
                                   config: KMessageManager.Config = KMessageManager.Config.default){
        
        var swiftMessageConfig = SwiftMessages.Config()
        swiftMessageConfig.presentationStyle = convertPositionBlock(config.position)
        swiftMessageConfig.preferredStatusBarStyle = config.fromViewController?.preferredStatusBarStyle ?? UIApplication.shared.delegate?.window??.rootViewController?.preferredStatusBarStyle
        if let fromViewController = config.fromViewController {
            swiftMessageConfig.presentationContext = SwiftMessages.PresentationContext.viewController(fromViewController)
        }else{
            swiftMessageConfig.presentationContext = SwiftMessages.PresentationContext.window(windowLevel: config.windowLevel)
        }
        swiftMessageConfig.duration = convertDurationBlock(config.duration)
        
        SwiftMessages.show(config: swiftMessageConfig) {
            let view = MessageView.viewFromNib(layout: convertLayoutBlock(config.layout))
            if let backgroundColor = config.backgroundColor,
               let foregroundColor = config.foregroundColor {
                view.configureTheme(backgroundColor: backgroundColor, foregroundColor: foregroundColor)
            } else {
                view.configureTheme(convertModeBlock(config.type))
            }
            view.configureContent(title: title, body: subtitle)
            view.button?.isHidden = config.buttonCompletion == nil // bottone aggiuntivo
            view.button?.setTitle(config.buttonTitle, for: .normal)
            if let viewId = config.viewId {
                view.id = viewId
            }
            view.buttonTapHandler = {(button) in
                config.buttonCompletion?()
                SwiftMessages.hideAll()
            }
            view.titleLabel?.numberOfLines = 0
            if config.isLeftIconVisible {
                if let image = config.leftIcon {
                    view.iconImageView?.image = image
                }
            } else {
                view.iconImageView?.isHidden = true
            }
            KTheme.current.applyTheme(toMessageView: view)
            return view
        }
    }
    
    public struct Config {
        
        public static let `default` = Config()
        
        public init() {
            
        }
        
        public var type: KMessageManager.Mode = .message
        public var layout: KMessageManager.Layout = .tabView
        public var position: KMessageManager.Position = .top
        public var duration: KMessageManager.Duration = .automatic
        public var windowLevel: UIWindow.Level = .statusBar
        public var fromViewController: UIViewController? = nil
        public var viewId: String? = nil
        public var buttonTitle: String? = nil
        public var leftIcon: UIImage?
        public var isLeftIconVisible: Bool = true
        public var buttonCompletion: (()->Void)? = nil
        public var backgroundColor: UIColor? = nil
        public var foregroundColor: UIColor? = nil
        
    }
    
}
