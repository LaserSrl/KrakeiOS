//
//  UIImageView.swift
//  Pods
//
//  Created by Patrick on 26/07/16.
//
//

import Foundation
import SDWebImage


public enum WatermarkPosition: Int {
    case topLeft = 0
    case topCenter // 1
    case topRight // 2
    case centerLeft
    case center
    case centerRight
    case bottomLeft
    case bottomCenter
    case bottomRight
}

public enum AspectToFill: Int{
    case none = 0
    case width
    case height
}

public extension UIImage{
    
    convenience init?(krakeNamed named: String){
        self.init(named: named, in: Bundle(for: Krake.self), compatibleWith: nil)
    }
    
    @objc static func imageOBJC(_ color: UIColor, size: CGSize) -> UIImage{
        return image(color, size: size)
    }
    
    static func image(_ color: UIColor, size: CGSize? = CGSize(width: 1, height: 1)) -> UIImage{
        UIGraphicsBeginImageContext(size!)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size!.width, height: size!.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func imageTinted(_ color: UIColor, fraction: CGFloat? = 0.0) -> UIImage{
        let image: UIImage
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        var rect = CGRect.zero
        rect.size = size
        color.set()
        UIRectFill(rect)
        draw(in: rect, blendMode: .destinationIn, alpha: 1.0)
        if fraction! > 0.0 {
            draw(in: rect, blendMode: .sourceAtop, alpha: fraction!)
        }
        image = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return image
    }
    
    func makeImageRoundCornersAndBorded() -> UIImage{
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        KTheme.current.color(.tint).setFill()
        UIBezierPath(ovalIn: rect).fill()
        let interiorBox = rect.insetBy(dx: 2.0, dy: 2.0)
        let interior = UIBezierPath(ovalIn: interiorBox)
        interior.addClip()
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func resizeImage(_ maxSize : CGFloat) -> UIImage {
        var scale : CGFloat = 1.0
        if self.size.width>self.size.height {
            scale = maxSize / self.size.width
        } else {
            scale = maxSize / self.size.height
        }
        let newSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func addWatermark(_ watermark: UIImage, fill: AspectToFill, position: WatermarkPosition) -> UIImage{
        let photoTMP = self.copy() as! UIImage
        let newSize = CGSize(width: photoTMP.size.width, height: photoTMP.size.height)
        let waterSize = CGSize(width: watermark.size.width, height: watermark.size.height)
        UIGraphicsBeginImageContext( newSize )
        photoTMP.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        var rectWater = CGRect(x: 0, y: 0, width: waterSize.width, height: waterSize.height )
        let rapWidth = waterSize.width / newSize.width
        let rapHeight = waterSize.height / newSize.height
        let scaleFactor = max(rapHeight, rapWidth)
        switch fill {
        case .none:
            if scaleFactor > 1.0 {
                rectWater = CGRect(x: 0, y: 0, width: rectWater.width/scaleFactor, height: rectWater.height/scaleFactor)
            }
        case .width:
            rectWater = CGRect(x: 0, y: 0, width: rectWater.width/rapWidth, height: rectWater.height/rapWidth)
        case .height:
            rectWater = CGRect(x: 0, y: 0, width: rectWater.width/rapHeight, height: rectWater.height/rapHeight)
        }
        switch position {
        case .topLeft:
            rectWater = CGRect(x: 0, y: 0, width: rectWater.width, height: rectWater.height)
        case .topCenter:
            rectWater = CGRect(x: (photoTMP.size.width - rectWater.width)/2, y: 0, width: rectWater.width, height: rectWater.height)
        case .topRight:
            rectWater = CGRect(x: (photoTMP.size.width - rectWater.width), y: 0, width: rectWater.width, height: rectWater.height)
        case .centerLeft:
            rectWater = CGRect(x: 0, y: (photoTMP.size.height - rectWater.height)/2, width: rectWater.width, height: rectWater.height)
        case .center:
            rectWater = CGRect(x: (photoTMP.size.width - rectWater.width)/2, y: (photoTMP.size.height - rectWater.height)/2, width: rectWater.width, height: rectWater.height)
        case .centerRight:
            rectWater = CGRect(x: (photoTMP.size.width - rectWater.width), y: (photoTMP.size.height - rectWater.height)/2, width: rectWater.width, height: rectWater.height)
        case .bottomLeft:
            rectWater = CGRect(x: 0, y: (photoTMP.size.height - rectWater.height), width: rectWater.width, height: rectWater.height)
        case .bottomCenter:
            rectWater = CGRect(x: (photoTMP.size.width - rectWater.width)/2, y: (photoTMP.size.height - rectWater.height), width: rectWater.width, height: rectWater.height)
        case .bottomRight:
            rectWater = CGRect(x: (photoTMP.size.width - rectWater.width), y: (photoTMP.size.height - rectWater.height), width: rectWater.width, height: rectWater.height)
        }
        watermark.draw(in: rectWater, blendMode: CGBlendMode.normal, alpha: 1.0)
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return newImage
    }
    
    static func downloadImage(_ imageURL: URL?, completed: KICompletionBlock? = nil ){

        if let imageURL = imageURL {
            _ = SDWebImageManager.shared.loadImage(with: imageURL,
                                                   options: [.allowInvalidSSLCertificates],
                                                   context: nil,
                                                   progress: nil,
                                                   completed: { (image, data, error, cacheType, finished, url) in
                                                    if finished{
                                                        completed?(image, error, .disk, url)
                                                    }
            })
        }
    }
}
