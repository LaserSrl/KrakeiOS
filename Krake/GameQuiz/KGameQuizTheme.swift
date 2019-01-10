//
//  KGameQuizTheme.swift
//  Pods
//
//  Created by Patrick on 29/06/17.
//
//

import Foundation

public enum KGameQuizThemeColor{
    case tint
    case tintText
    case text
    case starTint
    case starBackground
    case active
    case future
    case past
    case correct
    case wrong
    case cellBackground
    case cellText
}

public enum KGameQuizThemeViewStyle{
    case `default`
    case background
    case bar
}

public enum KGameQuizThemeButtonStyle{
    case `default`
}

public protocol KGameQuizTheme{
    
    func color(_ style: KGameQuizThemeColor) -> UIColor
    func applyTheme(toView view: UIView, style: KGameQuizThemeViewStyle)
    func applyTheme(toButton button: UIButton, style: KGameQuizThemeButtonStyle)
}

extension KGameQuizTheme{
    
    public func color(_ style: KGameQuizThemeColor) -> UIColor{
        return .black
    }
    
    public func applyTheme(toView view: UIView, style: KGameQuizThemeViewStyle){
        
    }
    
    public func applyTheme(toButton button: UIButton, style: KGameQuizThemeButtonStyle){
        
    }
}

public class KDefaultGameQuizTheme: KGameQuizTheme{
    public init()
    {}
}
