//
//  KOtpStopTimesDateHeader.swift
//  Krake
//
//  Created by joel on 24/05/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import UIKit

class KOtpStopTimesDateHeader: UITableViewHeaderFooterView {

    public weak var controller: KOTPStopTimesViewController?
    @IBOutlet weak var prevNextSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dateLabel: UILabel!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)


        let dateView = UIImageView(image:  UIImage(otpNamed: "ic_plan_date")!)
        dateView.setContentHuggingPriority(.required, for: .horizontal)
        dateView.contentMode = .scaleAspectFit

        let dateLabel = UILabel()
        self.dateLabel = dateLabel
        let segmented = UISegmentedControl(items:
        [UIImage(otpNamed: "date_previous")!,
            UIImage(otpNamed: "date_forward")!])

        segmented.isMomentary = true
        segmented.setContentHuggingPriority(.required, for: .horizontal)

        segmented.addTarget(self, action: #selector(changeDate(_:)), for: .valueChanged)

        self.prevNextSegmentedControl = segmented

        let stack = UIStackView(arrangedSubviews: [dateView, dateLabel, prevNextSegmentedControl])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill

        self.contentView.addSubview(stack)

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[stack]-(8)-|",
                                                              options: .alignAllCenterX,
                                                              metrics: nil, views: ["stack":stack]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[stack]-(8)-|",
                                                                  options: .alignAllCenterY,
                                                                  metrics: nil, views: ["stack":stack]))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBAction func changeDate(_ sender: UISegmentedControl) {
        controller?.updateDate(header: self, previous: sender.selectedSegmentIndex == 0)
    }
}
