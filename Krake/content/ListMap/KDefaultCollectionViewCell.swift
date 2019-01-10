//
//  ListaMappa.swift
//  Carlino130
//
//  Created by Patrick on 16/07/15.
//  Copyright (c) 2015 Laser Group. All rights reserved.
//

import Foundation
import UIKit
import LaserSwippableCell

//MARK: - DEFAULT CELL KDefaultCollectionViewCell

class KDefaultCollectionViewCell: CADRACSwippableCell{
    
    //MARK: - IBOUTLET
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    
}
