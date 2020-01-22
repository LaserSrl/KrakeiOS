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
                                   windowLevel: KWindowLevel = KWindowLevelStatusBar,
                                   fromViewController: UIViewController? = nil,
                                   viewId: String? = nil,
                                   buttonTitle: String? = nil,
                                   buttonCompletion: (()->Void)? = nil){
        
        var config = SwiftMessages.Config()
        config.presentationStyle = convertPositionBlock(position)
        if let fromViewController = fromViewController {
            config.presentationContext = SwiftMessages.PresentationContext.viewController(fromViewController)
        }else{
            config.presentationContext = SwiftMessages.PresentationContext.window(windowLevel: windowLevel)
        }
        config.duration = convertDurationBlock(duration)
        
        SwiftMessages.show(config: config) {
            let view = MessageView.viewFromNib(layout: convertLayoutBlock(layout))
            view.configureTheme(convertModeBlock(type))
            view.configureContent(title: title, body: subtitle)
            view.button?.isHidden = buttonCompletion == nil // bottone aggiuntivo
            view.button?.setTitle(buttonTitle, for: .normal)
            if let viewId = viewId {
                view.id = viewId
            }
            view.buttonTapHandler = {(button) in
                buttonCompletion?()
                SwiftMessages.hideAll()
            }
            KTheme.current.applyTheme(toMessageView: view)
            return view
        }
    }
    
}
