//
//  UIView+Krake.swift
//  Krake
//
//  Created by Patrick on 10/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
extension UIView {
    
    public var hiddenAnimated: Bool{
        get{
            return isHidden
        }
        set{
            if newValue != isHidden {
                UIView.animate(withDuration: 0.3, animations: {
                    self.isHidden = newValue
                })
            }
        }
    }
    
    public var alphaAnimated: CGFloat{
        get{
            return alpha
        }
        set{
            if newValue != alpha {
                superview?.layoutIfNeeded()
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = newValue
                })
            }
        }
    }
    
    public func kContainingViewController() -> UIViewController?
    {
        let target: UIView = superview != nil ? superview! : self
        return target.traverseResponderForUIViewController()
    }
    
    func traverseResponderForUIViewController() -> UIViewController?
    {
        let nextResponder = self.next as? UIViewController
        if nextResponder?.isKind(of: UITabBarController.self) ?? false
        {
            return (nextResponder as? UITabBarController)?.selectedViewController
        }
        return nextResponder
    }
    
    typealias ViewBlock = (_ view: UIView) -> Bool
    
    func loopViewHierarchy(block: ViewBlock?) {
        if block?(self) ?? true {
            for subview in subviews {
                subview.loopViewHierarchy(block: block)
            }
        }
    }
    
}
