//
//  KOTPStopsInRouteViewController.swift
//  Krake
//
//  Created by joel on 23/05/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class KOTPStopsInRouteViewController: KOTPBasePublicTransportListMapViewController<KOTPStopItem> {

    var route: KOTPRoute!
    public override var items: [KOTPStopItem]? {
        didSet {
            // Rimuovo le vecchie annotations dalla mappa, se presenti.
            if let oldItems = oldValue, !oldItems.isEmpty {
                mapView.removeAnnotations(oldItems)
            }
            // Verifico se sono presenti nuove annotations. In caso positivo, le
            // mostro su mappa, altrimenti mostro un messaggio di errore all'utente.
            if items?.isEmpty ?? true {
                KMessageManager.showMessage("CAN_NOT_FIND_STOPS".localizedString(), type: .message)
            } else {
                mapView.addAnnotations(items!)

            }
            prepareTableViewForFirstUsage(using: items, animated: true)
            tableView.reloadData()
            mapView.centerMap()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = route.longName

        KOpenTripPlannerLoader
            .shared
            .retrieveStops(for: route) { (stops) in
                if let stops = stops {
                    self.items = stops.sorted(by: { (a, b) -> Bool in
                        return (a.name ?? "").compare(b.name ?? "") == .orderedAscending
                    })
                }
                else {
                    self.items = []
                }
        }

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? KOTPStopTimesViewController
        {
            if let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
                destination.stopItem = items![indexPath.row]
            }
            else if let stop = sender as? KOTPStopItem {
                destination.stopItem = stop
            }
            destination.route = route

        }
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let cell = cell as? StopItemCell {
            let stop = items![indexPath.row]
            cell.titleLabel.text = stop.title!
            cell.busImageView.image = (stop as? AnnotationProtocol)?.imageInset()
            cell.busImageView.tintColor = (stop as? AnnotationProtocol)?.color() ?? KTheme.current.color(.tint)
            cell.selectedBackgroundView = UIView()
            KTheme.current.applyTheme(toView: cell.selectedBackgroundView!, style: .selected)
        }
        return cell
    }


    override func tableViewContainerAvailableFrame() -> CGRect {
        return CGRect(
            origin: CGPoint(x: 0,
                            y: 0),
            size: CGSize(
                width: view.bounds.width,
                height: view.bounds.height))
    }

    override func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = super.mapView(mapView, viewFor: annotation)

        view?.addButtonDetail()

        return view
    }

    override func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        super.mapView(mapView, annotationView: view, calloutAccessoryControlTapped: control)

        if !(view.annotation is UserSelectedPoint) &&
            control.tag == KAnnotationView.CalloutDetailButtonTag
        {
            performSegue(withIdentifier: "ShowStop", sender: view.annotation)
        }
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

class StopItemCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var busImageView: UIImageView!

    public override func awakeFromNib() {
        super.awakeFromNib()
        // Imposto il tint color dell'immagine.
        busImageView.tintColor = .tint
    }
}
