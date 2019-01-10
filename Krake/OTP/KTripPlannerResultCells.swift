//
//  KTripPlannerResultCells.swift
//  Krake
//
//  Created by joel on 11/05/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import UIKit

public class SingleModeHeaderCell : UITableViewCell
{
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var planTypeLabel: UILabel!
}

public class SingleModeStepCell : UITableViewCell
{
    @IBOutlet weak var instructionImage: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
}

public class TransitHeaderCell : UITableViewCell
{
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var partsStackView: UIStackView!
}

public class TransitCell : UITableViewCell
{
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var lineIcon: UIImageView!

    @IBOutlet weak var startOfLine: UILabel!
    @IBOutlet weak var endOfLine: UILabel!

    @IBOutlet weak var headsign: UILabel!
    @IBOutlet weak var lineName: UILabel!
}
