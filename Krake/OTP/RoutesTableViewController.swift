//
//  RoutesTableViewController.swift
//  Krake
//
//  Created by joel on 23/05/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import UIKit

public class KOTPRoutesTableViewController: UITableViewController, UISearchResultsUpdating {

    public static func newViewController() -> KOTPRoutesTableViewController{
        let bundle = Bundle(url: Bundle(for: KOTPRoutesTableViewController.self).url(forResource: "OTP", withExtension: "bundle")!)
        let storyboard = UIStoryboard(name: "OCOTPStoryboard", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: "KOTPRoutesTableViewController") as! KOTPRoutesTableViewController
    }

    private var allRoutes = [KOTPRoute]() {
        didSet {
            filterRoutes(nil)
        }
    }
    private var filteredRoutes = [KOTPRoute]() {
        didSet {
            tableView.reloadData()
        }
    }

     fileprivate var searchController: UISearchController!

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        self.definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        if let searchBar = searchController?.searchBar
        {
            KTheme.current.applyTheme(toSearchBar: searchBar, style: .listMap)
        }
        navigationItem.searchController = searchController
       
        KOpenTripPlannerLoader
            .shared
            .retrieveRoutesInfos(with:{ [weak self](routes) in
                if let routes = routes {
                self?.allRoutes = routes
                }
        })

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showStops",
            let destination = segue.destination as? KOTPStopsInRouteViewController,
            let cell = sender as? UITableViewCell,
        let indexPath = tableView.indexPath(for: cell)
        {
        let route = filteredRoutes[indexPath.row]
           destination.route = route
        }
    }

    // MARK: - UISearchResultsUpdating

    public func updateSearchResults(for searchController: UISearchController) {
        filterRoutes(searchController.searchBar.text)
    }

    // MARK: - Table view data source

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredRoutes.count
    }


    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell", for: indexPath)

        if let cell = cell as? KOTPStopDetailViewCell {
            let route = filteredRoutes[indexPath.row]
            cell.titleLabel.text = route.longName
            cell.busImageView.image = KTripTheme.shared.imageFor(vehicleType: route.mode).withRenderingMode(.alwaysTemplate)
            cell.busImageView.backgroundColor = route.color ?? UIColor.tint
            cell.busImageView.tintColor = cell.busImageView.backgroundColor?.constrastTextColor()
        }

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    private func filterRoutes(_ filter: String?) {
        let routes: [KOTPRoute]
        if let filter = filter, !filter.isEmpty {
            routes = allRoutes.filter({ (route) -> Bool in
                return route.shortName.localizedCaseInsensitiveContains(filter) ||
                    route.longName.localizedCaseInsensitiveContains(filter)
            })
        }
        else {
            routes = allRoutes
        }

        filteredRoutes = routes.sorted(by: { (first, second) -> Bool in
            first.longName.compare(second.longName) == .orderedAscending
        })
    }
}
