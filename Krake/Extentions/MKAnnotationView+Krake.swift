//
//  MKAnnotationView+Krake.swift
//  Krake
//
//  Created by Patrick on 29/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import MapKit

public extension MKAnnotationView{
    
    public func addButtonDetail(){
        if rightCalloutAccessoryView == nil {
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.backgroundColor = KTheme.current.color(.tint)
            rightButton.tintColor = KTheme.current.color(.textTint)
            rightButton.frame = CGRect(x: 0, y: 0, width: 32, height: 56)
            rightButton.imageEdgeInsets = UIEdgeInsets(top: 13, left: 2, bottom: 14, right: 2)
            rightButton.tag = KAnnotationView.CalloutDetailButtonTag
            rightCalloutAccessoryView = rightButton
        }
    }
    
    public func addNavigationButton(){
        if KInfoPlist.Location.enableNavigationOnPin && leftCalloutAccessoryView == nil {
            let leftButton = UIButton(frame: CGRect(x: 0,y: 0,width: 32,height: 56))
            leftButton.tag = KAnnotationView.CalloutNavigationButtonTag
            leftButton.setImage(UIImage(krakeNamed: "OCnavigaverso")?.withRenderingMode(.alwaysTemplate), for: .normal)
            leftButton.imageEdgeInsets = UIEdgeInsets(top: 13, left: 2, bottom: 14, right: 2)
            leftButton.backgroundColor = UIColor(red: 0, green: 103.0/255.0, blue: 1.0, alpha: 1.0)
            leftButton.tintColor = UIColor.white
            leftCalloutAccessoryView = leftButton
        }
    }
}
