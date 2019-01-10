//
//  KSearchViewController.swift
//  Krake
//
//  Created by Patrick on 29/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import MapKit
import UIKit

@objc public protocol KSearchPlaceDelegate: NSObjectProtocol{
    
    func searchPlace(_ tableView: UITableView, didSelect mapItem: MKMapItem, forTextField: UITextField?)
    
}

open class KSearchPlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate var myLocation: MKMapItem?
    fileprivate var items: [MKMapItem]?
    fileprivate let locManager = KLocationManager()
    fileprivate var searchPlace: MKLocalSearch?
    
    fileprivate var searchRequest:KLocalSearchRequest?{
        didSet{
            if KSearchPlaceViewController.prefferedRegion != nil{
                searchRequest?.region = KSearchPlaceViewController.prefferedRegion!
            }
        }
    }
    
    open weak var delegate: KSearchPlaceDelegate? = nil
    open weak var searchField: UITextField? = nil
    
    public static var prefferedRegion: MKCoordinateRegion? = nil
    
    //MARK: - static method
    
    public static func getViewController() -> KSearchPlaceViewController{
        let bundle = Bundle(url: Bundle(for: KSearchPlaceViewController.self).url(forResource: "Location", withExtension: "bundle")!)
        let story = UIStoryboard(name: "KSearch", bundle: bundle)
        return story.instantiateInitialViewController() as! KSearchPlaceViewController
    }
    
    public static func stringFromPlacemark(_ placemark: CLPlacemark) -> String{
        let startAddressString = NSMutableString()
        if let elem = placemark.thoroughfare{
            startAddressString.append(elem + " ")
        }
        if let elem = placemark.subThoroughfare{
            startAddressString.append(elem + ", ")
        }
        if let elem = placemark.postalCode{
            startAddressString.append(elem + ", ")
        }
        if (startAddressString as NSString).length == 0{
            if let elem = placemark.locality{
                startAddressString.append(elem)
            }
        }
        if (startAddressString as NSString).length == 0{
            if let loc = placemark.location{
                if loc.coordinate.latitude != 0 && loc.coordinate.longitude != 0 {
                    startAddressString.append(String(format: "Lat: %.6f Lon: %.6f", loc.coordinate.latitude, loc.coordinate.longitude))
                }
            }
        }
        return startAddressString as String
    }
    
    //MARK: - View
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        #if swift(>=4.2)
        searchRequest = MKLocalSearch.Request()
        #else
        searchRequest = MKLocalSearchRequest()
        #endif
        view.tintColor = KTheme.current.color(.tint)
        view.backgroundColor = KTheme.current.color(.tint)
        
        searchBar.barTintColor = KTheme.current.color(.tint)
        for sView in searchBar.subviews.first!.subviews{
            if let button = sView as? UIButton{
                button.setTitleColor(UIColor.white, for: KControlState.normal)
                button.setTitleColor(UIColor.white.withAlphaComponent(0.9), for: .highlighted)
            }
        }
        
        locManager.requestStartUpdatedLocation { [weak self] (manager, location) in
            if let mySelf = self{
                if let location = location {
                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                        if let placemark = placemarks?.first{
                            mySelf.myLocation = MKMapItem(placemark: KUserLocationPlacemark(placemark: placemark))
                            mySelf.tableView.reloadData()
                        }
                    })
                }else{
                    mySelf.myLocation = nil
                    mySelf.tableView.reloadData()
                }
            }
            manager.stopUpdatingLocation()
        }
        if let textToSearch = searchField?.text{
            searchBar.text = textToSearch
            searchBar(searchBar, textDidChange: textToSearch)
        }
        searchBar.placeholder = searchField?.placeholder
        searchBar.becomeFirstResponder()
    }
    
    //MARK: - UISearchBar Delegate
    
    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchRequest?.naturalLanguageQuery = searchText
        
        if searchPlace?.isSearching ?? false{
            searchPlace?.cancel()
        }
        if searchRequest != nil {
            searchPlace = MKLocalSearch(request: searchRequest!)
        }
        searchPlace?.start(completionHandler: { (response, error) in
            self.items = response?.mapItems
            self.tableView.reloadData()
        })
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchPlace?.cancel()
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - UITableView Delegate & DataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return myLocation != nil ? 2 : 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (myLocation != nil && section == 0) ? 1 : items?.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let imageView = cell.viewWithTag(100) as? UIImageView
        let title = cell.viewWithTag(101) as! UILabel
        let subtitle = cell.viewWithTag(102) as! UILabel
        
        if myLocation != nil && (indexPath as NSIndexPath).section == 0 {
            title.text = "LAMIAPOS".localizedString()
            subtitle.text = myLocation?.placemark.title
            imageView?.image = UIImage(krakeNamed: "pin_pos")!.withRenderingMode(.alwaysTemplate)
        }else{
            if let item = items?[(indexPath as NSIndexPath).row]{
                title.text = item.name
                subtitle.text = item.placemark.title
                let imageNamed = searchBar.placeholder == "To".localizedString() ? "pin_traguardo" : "pin_partenza"
                imageView?.image = UIImage(krakeNamed: imageNamed)!.withRenderingMode(.alwaysTemplate)
            }
        }
        
        KTheme.current.applyTheme(toLabel: title, style: .title)
        KTheme.current.applyTheme(toLabel: subtitle, style: .subtitle)
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchPlace?.cancel()
        if myLocation != nil && (indexPath as NSIndexPath).section == 0 {
            delegate?.searchPlace(tableView, didSelect: myLocation!, forTextField: searchField)
        }else{
            if let item = items?[(indexPath as NSIndexPath).row]{
                delegate?.searchPlace(tableView, didSelect: item, forTextField: searchField)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
}
