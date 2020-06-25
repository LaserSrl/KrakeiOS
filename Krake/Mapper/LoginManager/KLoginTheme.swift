//
//  KQuestionnaireTheme.swift
//  Krake
//
//  Created by Patrick on 28/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import LaserFloatingTextField

@objc public enum KLoginButtonStyle: Int{
    case back
    case close
    case small
    case `default`
}

@objc public enum KLoginSocialStyle: Int{
    case dark
    case light
}

@objc public enum KLoginColorType: Int{
    case background
    case backgroundNavigationButton
    case tint
}

@objc public enum KLoginLabelStyle: Int {
    case title
    case policyTitle
    case policySubtitle
}

@objc public protocol KLoginTheme: NSObjectProtocol {
    
    func centerViewStyle() -> UIBlurEffect.Style
    func socialStyle() -> KLoginSocialStyle
    func color(_ type:KLoginColorType) -> UIColor
    func applyTheme(to textField: EGFloatingTextField)
    func applyTheme(toLabel: UILabel, style: KLoginLabelStyle)
    func applyTheme(toImageView imageView: UIImageView)
    func applyTheme(to button: UIButton, style: KLoginButtonStyle)
    
}

extension KLoginTheme {
    
    
}

@objc open class KLoginDefaultTheme: NSObject, KLoginTheme {
    
    /**
     Method deprecated, implement the new one applyTheme(toLabel: UILabel, style: KLoginLabelStyle)
     */
    @available(*, deprecated, message: "🐙 Implement a new method", renamed: "applyTheme(toLabel:style:)")
    open func applyTheme(toTitle label: UILabel) {
        applyTheme(toLabel: label, style: .title)
    }
    
    /// Apply login theme to Label
    /// - Parameters:
    ///   - toLabel: the label to apply the themee (used on section title like "Login", "Register" and on policy title and subtitle)
    ///   - style: the style to be apply (.title, .policyTitle, .policySubtitle)
    open func applyTheme(toLabel: UILabel, style: KLoginLabelStyle) {
        switch style {
        case .title:
            toLabel.textColor = color(.tint)
            toLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        case .policyTitle:
            toLabel.textColor = color(.tint)
            toLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        case .policySubtitle:
            toLabel.textColor = color(.tint)
            toLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        }
    }
    
    
    open func centerViewStyle() -> UIBlurEffect.Style {
        return .dark
    }
    
    open func socialStyle() -> KLoginSocialStyle {
        return .light
    }
    
    open func color(_ type:KLoginColorType) -> UIColor {
        switch type {
        case .background:
            return KTheme.current.color(.tint)
        case .backgroundNavigationButton:
            return UIColor.black.withAlphaComponent(0.2)
        case .tint:
            return .white
        }
    }
    
    open func applyTheme(to textField: EGFloatingTextField) {
        textField.tintColor = color(.tint)
        textField.defaultActiveColor = color(.tint)
        textField.defaultInactiveColor = color(.tint)
        textField.defaultLabelTextColor = color(.tint)
        textField.textColor = color(.tint)
    }
    
    open func applyTheme(to button: UIButton, style: KLoginButtonStyle) {
        switch style {
        case .back:
            button.tintColor = color(.tint)
            button.backgroundColor = color(.backgroundNavigationButton)
        case .close:
            button.tintColor = color(.tint)
            button.backgroundColor = color(.backgroundNavigationButton)
        case .default:
            button.backgroundColor = KTheme.current.color(.tint)
            button.setTitleColor(KTheme.current.color(.textTint), for: .normal)
            button.layer.cornerRadius = 5.0
        case .small:
            button.backgroundColor = .clear
            button.setTitleColor(color(.tint), for: .normal)
            button.layer.cornerRadius = 5.0
            button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        }
    }
    
    open func applyTheme(toImageView imageView: UIImageView) {
        imageView.image = UIImage(named: "background_login")
    }
}

@objc extension KTheme {
    public static var login: KLoginTheme = KLoginDefaultTheme()
}

