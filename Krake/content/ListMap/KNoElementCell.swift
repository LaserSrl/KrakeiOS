//
//  KNoElementCell.swift
//  Krake
//
//  Created by Patrick on 09/04/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import Foundation
import UIKit

open class KNoElementCell: UICollectionViewCell
{
    @IBOutlet weak var textLabel: UILabel?
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        textLabel?.textColor = KTheme.current.color(.normal)
    }
}
