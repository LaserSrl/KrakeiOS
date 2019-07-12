//
//  UIColor.swift
//  Pods
//
//  Created by Patrick on 26/07/16.
//
//

import Foundation

extension UIColor{
    
    public func hexColor() -> String {
        var red, green, blue : Float!

        let components = self.cgColor.components;
        if self.cgColor.numberOfComponents == 4 {
            red = roundf(Float(components![0]) * 255.0)
            green = roundf(Float(components![1]) * 255.0)
            blue = roundf(Float(components![2]) * 255.0)
        } else if self.cgColor.numberOfComponents == 2 {
            red = roundf(Float(components![0]) * 255.0)
            green = roundf(Float(components![0]) * 255.0)
            blue = roundf(Float(components![0]) * 255.0)
        }
        return String(format: "#%02x%02x%02x", arguments: [Int(red), Int(green), Int(blue)])
    }

    @available(*, deprecated, message: "KTheme.current.color(.tint)")
    open class var tint: UIColor { get{ return KTheme.current.color(.tint)} }
    @available(*, deprecated, message: "KTheme.current.color(.alternate)")
    open class var alternate: UIColor { get{ return KTheme.current.color(.alternate)} }

    public convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    public func constrastTextColor() -> UIColor
    {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0

        self.getRed(&red, green: &green, blue: &blue, alpha: nil)

        let mapped = [red,green,blue].map({ (color) -> CGFloat in  if color <= 0.03928 { return color / 12.92 } else { return pow((color + 0.055) / 1.055, 2.4)}})

        let luminance = 0.2126 * mapped[0] + 0.7152 * mapped[1] + 0.0722 * mapped[2]

        if (luminance > 0.179) {
            return UIColor.black
        }
        else {
            return UIColor.white
        }
    }
    
    public func lighter(_ value: CGFloat = 0.05) -> UIColor
    {
        var r:CGFloat = 0.0, g:CGFloat = 0.0, b:CGFloat = 0.0, a:CGFloat = 0.0
        if (self == UIColor.clear){
            return UIColor.white
        }
        if (self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + value, 1.0), green: min(g + value, 1.0), blue: min(b + value, 1.0), alpha: a)
        }
        return UIColor.clear
    }
    
    public func darker(_ value: CGFloat = 0.05) -> UIColor
    {
        var r:CGFloat = 1.0, g:CGFloat = 1.0, b:CGFloat = 1.0, a:CGFloat = 1.0
        if (self == UIColor.clear){
            return UIColor.white
        }
        if (self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: max(r - value, 0.0), green: max(g - value, 0.0), blue: max(b - value, 0.0), alpha: a)
        }
        return UIColor.clear
    }
}

