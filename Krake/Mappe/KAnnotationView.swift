//
//  star.swift
//  Fondation
//
//  Created by Patrick on 30/12/14.
//  Copyright (c) 2014 Laser Group srl. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import SDWebImage
import MapKit

open class KAnnotationView: MKAnnotationView
{
    public static let CalloutNavigationButtonTag = 10
    public static let CalloutDetailButtonTag = 11
    
    fileprivate var bottomLayer:CAShapeLayer!
    fileprivate var bottomCircle:CAShapeLayer!
    fileprivate var whiteCircle:CAShapeLayer!
    fileprivate var downloading = false
    
    fileprivate var pinBase = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 135))
    fileprivate let pinImage = UIImageView(frame: CGRect(x: 15, y: 15, width: 60, height: 56))
    
    public init(annotation: MKAnnotation!, forcedColor: UIColor? = nil){
        var identifier = "StandardPin"
        var imageNamed = "StandardPin"
        var subtext: String? = nil
        var localImage: UIImage? = nil
        var termIconIdentifier: String? = nil
        var tintColor: UIColor? = KTheme.current.color(.tint)
        if let elem = annotation as? AnnotationProtocol {
            identifier = elem.annotationIdentifier() + (forcedColor?.description ?? "")
            imageNamed = elem.nameAnnotation()
            localImage = elem.imageInset()?.withRenderingMode(.alwaysTemplate)
            tintColor = elem.color()
            subtext = elem.boxedText()
            termIconIdentifier = elem.termIconIdentifier()
        }
        tintColor = forcedColor ?? tintColor
        downloading = false
        super.init(annotation: annotation, reuseIdentifier: identifier)
        if let img = SDImageCache.shared().imageFromMemoryCache(forKey: reuseIdentifier) {
            image = img
            centerOffset = CGPoint(x: 0, y: -(image!.size.height/2))
        }else{
            pinImage.image = localImage
            pinImage.tintColor = tintColor
            if (annotation as? AnnotationProtocol) != nil {
                
                if let img = UIImage(named: imageNamed)?.withRenderingMode(KImageRenderingMode.alwaysTemplate) {
                    pinImage.image = img
                }
                
                if let termIconIdentifier = termIconIdentifier, let url = KMediaImageLoader.generateURL(forMediaPath: termIconIdentifier, mediaImageOptions: KMediaImageLoadOptions(size: CGSize(width: 200, height: 200),mode: ImageResizeMode.Pan))
                {
                    if let image = SDImageCache.shared().imageFromDiskCache(forKey: termIconIdentifier){
                        pinImage.image = image.withRenderingMode(.alwaysTemplate)
                    }else{
                        downloading = true
                        KLog(type: .warning, "Download term icon image '%@' for PIN from KRAKE.", termIconIdentifier)
                        KTermPinImageDownloader.sharedDownloader.startImageDownload(url, identifier: termIconIdentifier)
                    }
                }
                if pinImage.image == nil {
                    KLog(type: .warning, "PIN: Manca reference di questo reuseIdentifier = " + reuseIdentifier!)
                }
            }
            defaultPin(subtext)
        }
        canShowCallout = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func defaultPin(_ subtext: String? = nil){
        standardPin(pinImage.tintColor)
        pinBase.addSubview(pinImage)
        if (subtext != nil){
            let overlayText = UILabel(frame: CGRect(x: 10, y: 80, width: 70, height: 25))
            overlayText.text = subtext
            overlayText.textColor = UIColor.black
            overlayText.backgroundColor = UIColor.white
            overlayText.font = UIFont.systemFont(ofSize: 19.0)
            overlayText.adjustsFontSizeToFitWidth = true
            overlayText.minimumScaleFactor = 0.7
            overlayText.textAlignment = NSTextAlignment.center
            overlayText.layer.borderColor = pinImage.tintColor.cgColor
            overlayText.layer.borderWidth = 2.0
            pinBase.addSubview(overlayText)
        }
        generateImage()
    }
    
    func generateImage(){
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 90,height: 135), false, 0.0)
        pinBase.layer.render(in: UIGraphicsGetCurrentContext()!)
        if let img = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            let size = img.size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
            let scale: CGFloat = 0.0
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            img.draw(in: CGRect(origin: CGPoint.zero, size: size))
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            centerOffset = CGPoint(x: 0, y: -(image!.size.height/2))
            if !downloading{
                SDImageCache.shared().store(image, forKey: reuseIdentifier!, toDisk: false)
            }
        }
    }
    
    func standardPin(_ color: UIColor?) {
        
        let padding: CGFloat = 4
        let pinWidth = pinBase.bounds.width - padding * 2
        let pinHeigth = pinBase.bounds.height - padding * 2
        let circleRadius: CGFloat = (pinWidth / 2)
        let semiCircleRadius = circleRadius * 0.85
        let quadControlPointHeight = pinHeigth * 3.2 * 0.2
        let firstPoint = CGPoint(x: pinBase.bounds.width - padding, y: circleRadius)
        let bottomMiddlePoint = CGPoint(x: pinBase.bounds.midX, y: pinHeigth + padding)
        
        if (bottomLayer == nil)
        {
            let ovalPath = UIBezierPath()
            ovalPath.addArc(withCenter: CGPoint(x: pinBase.bounds.width * 0.5, y: circleRadius + padding), radius: circleRadius, startAngle: 0.0, endAngle: CGFloat(Double.pi), clockwise: false)
            ovalPath.addQuadCurve(to: bottomMiddlePoint, controlPoint: CGPoint(x: padding, y: quadControlPointHeight))
            ovalPath.addQuadCurve(to: firstPoint, controlPoint: CGPoint(x: firstPoint.x, y: quadControlPointHeight))
            ovalPath.close()
            bottomLayer = CAShapeLayer()
            bottomLayer.path = ovalPath.cgPath
            bottomLayer.lineWidth = 0
            bottomLayer.strokeColor = lighterColorForColor(color!).cgColor
            bottomLayer.fillColor = color!.cgColor
            bottomLayer.frame = bounds
            
            #if swift(>=4.2)
            bottomLayer.contentsGravity = CALayerContentsGravity.resizeAspectFill
            #else
            bottomLayer.contentsGravity = kCAGravityResizeAspectFill
            #endif
            pinBase.layer.addSublayer(bottomLayer)
        }
        if (whiteCircle == nil)
        {
            let ovalPath = UIBezierPath()
            ovalPath.addArc(withCenter: CGPoint(x: pinBase.bounds.width/2, y: circleRadius + padding), radius: semiCircleRadius, startAngle: 0, endAngle: CGFloat(Double.pi)*2, clockwise: false)
            whiteCircle = CAShapeLayer()
            whiteCircle.path = ovalPath.cgPath
            whiteCircle.lineWidth = 2
            whiteCircle.strokeColor = UIColor.white.cgColor
            whiteCircle.fillColor = UIColor.white.cgColor
            whiteCircle.frame = bounds
            
            #if swift(>=4.2)
            whiteCircle.contentsGravity = CALayerContentsGravity.resizeAspectFill
            #else
            whiteCircle.contentsGravity = kCAGravityResizeAspectFill
            #endif
            pinBase.layer.addSublayer(whiteCircle)
        }
    }
    
    func lighterColorForColor(_ c: UIColor) -> UIColor
    {
        var r:CGFloat = 0.0, g:CGFloat = 0.0, b:CGFloat = 0.0, a:CGFloat = 0.0
        if (c == UIColor.clear){
            return UIColor.white
        }
        if (c.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + 0.25, 1.0), green: min(g + 0.25, 1.0), blue: min(b + 0.25, 1.0), alpha: a)
        }
        return UIColor.clear
    }
}



