//
//  KListMapDelegate.swift
//  Krake
//
//  Created by Patrick on 10/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import MapKit

//MARK: - PROTOCOL KListMapDelegate
public protocol KListMapDelegate: NSObjectProtocol {

    func viewForAnnotation(_ annotation : MKAnnotation, mapView: KExtendedMapView) -> MKAnnotationView?
    
    func didSelect(_ object: AnyObject, fromViewController: KListMapViewController)
    func didSelectTab(_ manager: KTabManager, fromViewController: KListMapViewController, object: Any?)
    func didSelectNavigatorButton(_ object: AnyObject, mapView: KExtendedMapView, fromViewController: UIViewController)
    func didSelectShareButton(_ object: AnyObject, sender: AnyObject, fromViewController: KListMapViewController)
    func didSelectAddToCalendarButton(_ object: AnyObject, fromNavigationController: UINavigationController, calendar : KCalendar)
    
    func setInitialDateValues(_ extras: inout [String : Any], dateFilterManager: KDateFilterManager)
    func extendedMapView(_ mapView: KExtendedMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) -> Bool
    func defaultSelectedIndex(tabs: [Any]) -> UInt?
    func viewDidLoad(_ viewController: KListMapViewController)
    func viewWillDisappear(_ viewController: KListMapViewController)
    func viewDidAppear(_ viewController: KListMapViewController)
    func viewWillAppear(_ viewController: KListMapViewController)

    func registerCell(_ collectionView: UICollectionView)
    
    func collectionView(_ object: AnyObject, collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath, mapIsVisible: Bool) -> CGSize
    func collectionView(_ object: AnyObject, collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    func collectionView(_ object: AnyObject, buttonItemsAtIndexPath indexPath: IndexPath) -> [UIButton]?
    func collectionView(_ collectionView: UICollectionView, willShowNumberOfSections sections:Int)
    func collectionView(_ collectionView: UICollectionView, willShowNumberOfItems items:Int, inSection section: Int)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
}

public extension KListMapDelegate {
    
    func defaultSelectedIndex(tabs: [Any]) -> UInt?{
        return nil
    }

    func viewDidLoad(_ viewController: KListMapViewController) {
        
    }
    
    func didSelect(_ object: AnyObject, fromViewController: KListMapViewController)
    {
        fromViewController.view.isUserInteractionEnabled = false
        if let segueVC = KDetailViewControllerFactory.factory
            .newDetailViewController(detailObject: object,
                                     endPoint: (object as? ContentItem)?.autoroutePartDisplayAlias,
                                     detailDelegate: fromViewController.detailDelegate,
                                     analyticsExtras: fromViewController.analyticsExtras) {
            
            if fromViewController.traitCollection.verticalSizeClass == .regular && fromViewController.traitCollection.horizontalSizeClass == .regular {
                let navVC = UINavigationController(rootViewController: segueVC)
                KTheme.current.applyTheme(toNavigationBar: navVC.navigationBar,
                                          style: .default)
                navVC.modalPresentationStyle = .formSheet
                
                fromViewController.present(navVC, animated: true, completion: nil)
                segueVC.insertLeftNavigationItemToCloseModalDetail()
            }else{
                fromViewController.navigationController?.pushViewController(segueVC, animated: true)
            }
        }
        fromViewController.view.isUserInteractionEnabled = true
    }
    
    func didSelectTab(_ manager: KTabManager, fromViewController: KListMapViewController, object: Any?){

    }

    func setInitialDateValues(_ extras: inout [String : Any], dateFilterManager: KDateFilterManager){
        let fromDate: Date = dateFilterManager.dateFilterOptions.dateRangeFromDate ?? Date()
        let toDate: Date = dateFilterManager.dateFilterOptions.dateRangeToDate ?? Date()
        extras.update(other: [REQUEST_DATE_START : dateFilterManager.serviceDateFormatter.string(from: fromDate)])
        extras.update(other: [REQUEST_DATE_END : dateFilterManager.serviceDateFormatter.string(from: toDate)])
        if fromDate.compare(Date()) != .orderedDescending && toDate.compare(Date()) != .orderedAscending
        {
            dateFilterManager.selectedDates = [Date()]
        }
        else
        {
            switch dateFilterManager.dateFilterOptions.selectionType
            {
            case .single, .multi:
                if toDate.compare(Date()) == .orderedAscending
                {
                    dateFilterManager.selectedDates = [toDate]
                }
                else if fromDate.compare(Date()) == .orderedDescending
                {
                    dateFilterManager.selectedDates = [fromDate]
                }
            case .range:
                dateFilterManager.selectedDates = [fromDate, toDate]
            }
        }
    }

    func viewForAnnotation(_ annotation : MKAnnotation, mapView: KExtendedMapView) -> MKAnnotationView?{
        if annotation is AnnotationProtocol {
            var pinView = mapView.dequeueReusableAnnotationViewWithAnnotation(annotation)
            if pinView == nil {
                pinView = KAnnotationView(annotation: annotation)
                pinView?.addNavigationButton()
                pinView?.addButtonDetail()
            }
            return pinView
        } else {
            return nil
        }
    }

    func extendedMapView(_ mapView: KExtendedMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) -> Bool {
        return false
    }

    func collectionView(_ object: AnyObject, collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath, mapIsVisible: Bool) -> CGSize {
        return makeStandardSize(collectionView, layout: collectionViewLayout, mapIsVisible: mapIsVisible)
    }

    func makeStandardSize(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, mapIsVisible: Bool) -> CGSize {
        var width = collectionView.bounds.size.width
        let padding = (collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing
        let margin = (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset.left + (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset.right
        width = width - margin
        if (collectionView.traitCollection.verticalSizeClass == .regular || collectionView.traitCollection.verticalSizeClass == .compact) && collectionView.traitCollection.horizontalSizeClass == .regular {
            var coef: CGFloat = 1.0
            if UIDevice.current.orientation.isLandscape && collectionView.traitCollection.verticalSizeClass == .regular {
                coef = (mapIsVisible ? 2 : 3)
            }else{
                coef = (mapIsVisible ? 4 / 3 : 2)
            }
            width = ((width - (coef >= 2 ? padding * (coef-1) : 0)) / coef)
        }else if collectionView.traitCollection.verticalSizeClass == .compact{
            width = width / 2 - (padding / 2)
        }
        let height = width / 5 * 3
        return CGSize(width: width,height: height)
    }

    func collectionView(_ object: AnyObject, buttonItemsAtIndexPath indexPath: IndexPath) -> [UIButton]?{
        return nil
    }

    func didSelectNavigatorButton(_ object: AnyObject, mapView: KExtendedMapView, fromViewController: UIViewController){
        KExtendedMapView.defaultOpenAnnotation?(object as? MKAnnotation, fromViewController)
    }

    func didSelectShareButton(_ object: AnyObject, sender: AnyObject, fromViewController: KListMapViewController){
        if let elem = object.value(forKey: "shareLinkPart") as? ShareProtocol {
            KShareManager.share(content: elem, otherItems: [object], activities: nil, sender: sender, fromViewController: fromViewController)
        }
    }

    func didSelectAddToCalendarButton(_ object: AnyObject, fromNavigationController: UINavigationController, calendar: KCalendar){
        if let detail = object as? ContentItem{
            var location = ""
            if let dettaglio = detail as? ContentItemWithMapPart, let mappa = dettaglio.mapPartReference(), let info = mappa.locationAddress{
                location = info
            }
            if let detActivity = detail as? ContentItemWithActivityPart,
                let activity = detActivity.activityPartReference(),
                let startDate = activity.dateTimeStart,
                let endDate = activity.dateTimeEnd
            {
                let description = (detail as? ContentItemWithDescription)?.bodyPart()?.htmlToString() ?? ""
                let info = CalendarInfo(title: detail.titlePartTitle!, abstract: description, location: location, fromDate: startDate, toDate: endDate)
                calendar.presentAddToCalendar(info, nav: fromNavigationController)
            }
        }
    }
    
    func viewWillDisappear(_ viewController: KListMapViewController)
    {
        
    }

    func viewWillAppear(_ viewController: KListMapViewController)
    {

    }
    
    func viewDidAppear(_ viewController: KListMapViewController){
        
    }

    func collectionView(_ collectionView: UICollectionView, willShowNumberOfSections sections:Int)
    {

    }

    func collectionView(_ collectionView: UICollectionView, willShowNumberOfItems items:Int, inSection section: Int)
    {

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    {
        return CGSize.zero
    }
}

//MARK: - DEFAULT CLASS KListMapDelegate

public class KDefaultListMapDelegate: NSObject, KListMapDelegate{

    open func registerCell(_ collectionView: UICollectionView){
        let bundle = Bundle(url: Bundle(for: KListMapViewController.self).url(forResource: "Content", withExtension: "bundle")!)
        collectionView.register(UINib(nibName: "KStandardCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: "kStandardCell")
    }

    open func collectionView(_ object: AnyObject, collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kStandardCell", for: indexPath) as! KDefaultCollectionViewCell
        cell.cellImage.image = nil
        cell.cellTitle.text = nil
        if let elem = object as? ContentItem{
            if let title = elem.titlePartTitle{
                cell.cellTitle.text = title
                KTheme.current.applyTheme(toLabel: cell.cellTitle, style: .cellTitle)
            }
        }
        if let elem = object as? ContentItemWithGallery{
            if let image = elem.galleryMediaParts?.firstObject as? MediaPartProtocol{
                cell.cellImage.setImage(media: image)
            }
        }
        return cell
    }
    
   
    
    
    open func viewWillDisappear(_ viewController: KListMapViewController){
        
    }
    
    open func viewDidAppear(_ viewController: KListMapViewController){
        
    }
}
