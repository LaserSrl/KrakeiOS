//
//  KOTPStopTimesViewController.swift
//  Krake
//
//  Created by joel on 23/05/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import UIKit

class KOTPStopTimesViewController: UITableViewController {

    var route: KOTPRoute!
    var stopItem: KOTPStopItem!

    private lazy var dateFormatter: DateFormatter = {
        let format = DateFormatter()
        format.timeStyle = DateFormatter.Style.short
        format.dateStyle = DateFormatter.Style.none
        return format
    }()

    var times = [KOTPTimes]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = stopItem.name
        
        KOpenTripPlannerLoader.shared.retrieveTimes(for: stopItem, route: route, date: Date()) { (times) in
            if let times = times {
                self.times = times
            }
        }

        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return times.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let time = times[indexPath.row]
        if let cell = cell as? KStopTimeCell, let departureDate = time.scheduledDeparture?.otpSecondsToDate() {
            cell.scheduledTimeLabel.text = dateFormatter.string(from: departureDate)
        }

        return cell
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
