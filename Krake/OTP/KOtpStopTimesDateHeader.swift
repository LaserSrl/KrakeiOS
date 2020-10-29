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
    weak var dateLabel: UILabel!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        let dateView = UIImageView(image: KOTPAssets.icPlanDate.image)
        dateView.setContentHuggingPriority(.required, for: .horizontal)
        dateView.contentMode = .scaleAspectFit

        let dateLabel = UILabel()
        self.dateLabel = dateLabel

        let prevButton = UIButton()
        prevButton.setImage(KOTPAssets.datePrevious.image, for: .normal)
        prevButton.addTarget(self, action: #selector(prevDate(_:)), for: .touchUpInside)
        prevButton.setContentHuggingPriority(.required, for: .horizontal)

        let nextButton = UIButton()
        nextButton.setImage(KOTPAssets.dateForward.image, for: .normal)
        nextButton.addTarget(self, action: #selector(nextDate(_:)), for: .touchUpInside)
        nextButton.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [dateView, dateLabel, prevButton, nextButton])
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

        let lineView = UIView(frame: CGRect.zero)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lineView)
        lineView.backgroundColor = .darkGray

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(1)]-(0)-|",
                                                                  options: .alignAllCenterX,
                                                                  metrics: nil, views: ["lineView":lineView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[lineView]-(0)-|",
                                                                  options: .alignAllCenterY,
                                                                  metrics: nil, views: ["lineView":lineView]))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBAction func nextDate(_ sender: Any) {
        controller?.updateDate(header: self, previous: false)
    }

    @IBAction func prevDate(_ sender: Any) {
        controller?.updateDate(header: self, previous: true)
    }
}
