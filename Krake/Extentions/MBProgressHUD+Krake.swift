//
//  MBProgressHUD.swift
//  Pods
//
//  Created by Patrick on 26/07/16.
//
//

import Foundation
import MBProgressHUD

public extension MBProgressHUD{

    func showAsUploadProgress()
    {
        self.mode = .indeterminate
        self.label.text = "wait".localizedString()
        self.detailsLabel.text = nil
        self.show(animated: true)
    }
    
    func dismissAsUploadProgress(completedWithSuccess success: Bool)
    {
        self.mode = .customView
        if success {
            self.customView = UIImageView(image: KAssets.Images.success.image)
            self.customView!.tintColor = UIColor.white
            self.label.text = "Completed".localizedString()
            self.label.textColor = self.customView!.tintColor
            self.bezelView.color = UIColor ( red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0 )
            self.bezelView.style = .solidColor
        }else{
            self.customView = UIImageView(image: KAssets.Images.error.image)
            self.customView!.tintColor = UIColor.white
            self.label.text = "Error".localizedString()
            self.label.textColor = self.customView!.tintColor
            self.bezelView.color =  UIColor ( red: 0.6, green: 0.0, blue: 0.0, alpha: 1.0 )
            self.bezelView.style = .solidColor
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1500), execute: {
            self.hide(animated: true)
            self.mode = .indeterminate
            self.customView!.tintColor = UIColor.black
            self.label.textColor = self.customView!.tintColor
            self.customView = nil
            self.bezelView.color = UIColor(white: 0.8, alpha: 0.6)
            self.bezelView.style = .blur
        })
    }
}
