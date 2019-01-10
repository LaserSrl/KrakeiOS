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
    
    public convenience init?(omNamed named: String){
        self.init(named: named, in: Bundle(for: OGLAppDelegate.self), compatibleWith: nil)
    }
}
