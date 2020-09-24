//
//  UIImage+OM.swift
//  OrchardGen
//
//  Created by Patrick on 25/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    
    public convenience init?(omNamed: String){
        guard let bundlePath = Bundle(for: OGLAppDelegate.self).path(forResource: "KrakeImages", ofType: "bundle") else { return nil }
        self.init(named: omNamed, in: Bundle(path: bundlePath), compatibleWith: nil)
    }
}
