//
//  KOTPStopTimesViewController.swift
//  Krake
//
//  Created by joel on 23/05/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import UIKit
import MBProgressHUD

class KOTPStopTimesViewController: UITableViewController {

    var route: KOTPRoute!
    var stopItem: KOTPStopItem!

    private var currentDate = Date().midnight()
    private let minimumDate = Date().midnight()

    private lazy var timeFormatter: DateFormatter = {
        let format = DateFormatter()
        format.timeStyle = DateFormatter.Style.short
        format.dateStyle = DateFormatter.Style.none
        return format
    }()

    private lazy var dateFormatter: DateFormatter = {
        let format = DateFormatter()
        format.timeStyle = DateFormatter.Style.none
        format.dateStyle = DateFormatter.Style.medium
        return format
    }()

    var times = [KOTPTimes]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = route.longName

        tableView.register(KOtpStopTimesDateHeader.self, forHeaderFooterViewReuseIdentifier: "SelectDateHeader")
        
        reloadStops()

        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return times.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let time = times[indexPath.row]
        if let cell = cell as? KStopTimeCell,
            let departureDate = time.scheduledDeparture?.otpSecondsToDate() {
            cell.scheduledTimeLabel.text = timeFormatter.string(from: departureDate)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SelectDateHeader") as? KOtpStopTimesDateHeader
        header?.dateLabel.text = dateFormatter.string(from: currentDate)
        header?.controller = self
        return header
    }

    private func reloadStops() {
        MBProgressHUD.showAdded(to: self.view, animated: true)

        KOpenTripPlannerLoader.shared.retrieveTimes(for: stopItem, route: route, date: currentDate) { (times) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let times = times {
                self.times = times
            }
        }
    }

    public func updateDate(header: KOtpStopTimesDateHeader, previous: Bool) {

        let difference: TimeInterval = (previous ? -1 : 1) * 24.0 * 60.0 * 60.0


        currentDate = currentDate.addingTimeInterval(difference)

        if currentDate.compare(minimumDate) == .orderedAscending {
            currentDate = minimumDate
            return
        }

        header.dateLabel.text = dateFormatter.string(from: currentDate)

        reloadStops()

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class KStopTimeCell: UITableViewCell {
    @IBOutlet weak var scheduledTimeLabel: UILabel!

}
