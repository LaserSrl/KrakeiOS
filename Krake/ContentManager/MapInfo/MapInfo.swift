//
//  MapInfo.swift
//  Carlino130
//
//  Created by Patrick on 10/07/15.
//  Copyright (c) 2015 Laser Group. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewAnnotation : NSObject, MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.title = title
        self.coordinate = coordinate
    }
    override func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
    
}

class MapInfo : ContentModificationViewController, MKMapViewDelegate, UISearchBarDelegate, KSearchPlaceDelegate {
    var titlePosition: String! = "LAMIAPOS".localizedString()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var titleLabel: UILabel!
    
    let locManager = KLocationManager()
    
    override var title: String?{
        didSet{
            titleLabel.text = title
        }
    }
    
    deinit{
        KLog("RELEASED")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        mapView.delegate = self
        
        searchBar.barTintColor = KTheme.current.color(.tint)
        searchBar.placeholder = "SEARCH".localizedString()
        titleLabel.backgroundColor = KTheme.current.color(.tint)
        titleLabel.textColor = KTheme.current.color(.textTint)
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(MapInfo.longTapMapPosition(_:)))
        mapView.addGestureRecognizer(longTap)
    }
    
    fileprivate func stopUpdatingLocation(_ parent: UIViewController?) {
        if parent != nil {
            locManager.requestStartUpdatedLocation { [weak self] (manager, location) in
                if location != nil {
                    self?.updateLocationOnMap(location!.coordinate, address: self?.titlePosition)
                }
                manager.stopUpdatingLocation()
            }
        } else {
            locManager.stopUpdatingLocation()
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        stopUpdatingLocation(parent)
    }
    
    override func setInitialData(_ item: AnyObject) {
        
        if let coreDataKeyPath = fields.first!.coreDataKeyPath, let value = item.value(forKeyPath: coreDataKeyPath), let mappa = value as? MapPartProtocol{
            
            params[fields.first!.key] = "1"
            params[fields.first!.key + "." + ContentManagerKeys.LATITUDE] = mappa.location?.coordinate.latitude
            params[fields.first!.key + "." + ContentManagerKeys.LONGITUDE] = mappa.location?.coordinate.longitude
            titlePosition = mappa.locationInfo
        }
    }
    
    override func reloadAllDataFromParams() {
        if params[fields.first!.key + "." + ContentManagerKeys.LATITUDE] != nil && params[fields.first!.key + "." + ContentManagerKeys.LONGITUDE] != nil {
            let lat: Double = params[fields.first!.key + "." + ContentManagerKeys.LATITUDE] as! Double
            let lng: Double = params[fields.first!.key + "." + ContentManagerKeys.LONGITUDE] as! Double
            let pa = MapViewAnnotation(coordinate: CLLocationCoordinate2DMake(lat, lng), title: titlePosition)
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(pa)
            mapView.centerMap()
        }
    }
    
    @objc func longTapMapPosition( _ gesture : UITapGestureRecognizer){
        if gesture.state != UIGestureRecognizer.State.ended{
            return
        }
        let touchPoint = gesture.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        updateLocationOnMap(touchMapCoordinate, address: titlePosition)
    }
    
    func updateLocationOnMap(_ location : CLLocationCoordinate2D?, address infoAddress: String?){
        if location != nil {
            mapView.removeAnnotations(mapView.annotations)
            let pa = MapViewAnnotation(coordinate: location!, title: (infoAddress != nil ? infoAddress : titlePosition)!)
            mapView.addAnnotation(pa)
            mapView.centerMap()
            if params != nil && fields != nil {
                // Creating the keys for the latitude and longitude values.
                let latitudeKey = fields.first!.key + "." + ContentManagerKeys.LATITUDE
                let longitudeKey = fields.first!.key + "." + ContentManagerKeys.LONGITUDE
                // Getting the old location parameters, if any.
                let oldLatitude = params[latitudeKey] as? Double
                let oldLongitude = params[longitudeKey] as? Double
                // Getting the new location parameters.
                let newLatitude = location!.latitude
                let newLongitude = location!.longitude
               	// Checking if changes are necessary based on old and new values.
                if params[fields!.first!.key] == nil ||
                    (oldLatitude == nil || oldLatitude! != newLatitude) ||
                    (oldLongitude == nil || oldLongitude! != newLongitude) {
                    
                    params[fields.first!.key] = "1"
                    params[latitudeKey] = newLatitude
                    params[longitudeKey] = newLongitude
                    containerViewController.isChanged = true
                }
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let searchvc = KSearchPlaceViewController.getViewController()
        searchvc.delegate = self
        navigationController?.present(searchvc, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        if (newState == MKAnnotationView.DragState.starting) {
            view.dragState = MKAnnotationView.DragState.dragging
        } else if (newState == MKAnnotationView.DragState.ending || newState == MKAnnotationView.DragState.canceling){
            view.dragState = MKAnnotationView.DragState.none
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        
        var pinView : MKAnnotationView! = mapView.dequeueReusableAnnotationViewWithAnnotation(annotation)
        
        if pinView == nil
        {
            pinView = KAnnotationView(annotation: annotation)
            
            pinView.canShowCallout = true
            pinView.isDraggable = true
        }
        
        return pinView;
    }
    
    //MARK: - KSearchPlace Delegate
    
    func searchPlace(_ tableView: UITableView, didSelect mapItem: MKMapItem, forTextField: UITextField?) {
        updateLocationOnMap(mapItem.placemark.location!.coordinate, address: mapItem.placemark.name!)
        searchBar.text = mapItem.placemark.name!
        titlePosition = mapItem.placemark.name!
    }
}
