//
//  KMixedBarButton.swift
//  Pods
//
//  Created by Patrick on 15/09/16.
//
//

import Foundation
import UIKit

public class KMixedBarButton: NSObject{
    
    var calendar : KCalendar? = KCalendar()
    var content: ContentItemWithShareLinkPart?
    var activityPart: ContentItemWithActivityPart?
    weak var detailDelegate: KDetailPresenterDelegate?
    weak var fromViewController: UIViewController?
    var menuItems: [AnyObject]!
    var arrayButton: [KButtonItem]?
    
    deinit {
        KxMenu.dismiss()
    }
            
    public func loadData(object: AnyObject, detailDelegate: KDetailPresenterDelegate?, viewController: UIViewController) -> UIBarButtonItem?
    {
        content = object as? ContentItemWithShareLinkPart
        activityPart = object as? ContentItemWithActivityPart
        fromViewController = viewController
        self.detailDelegate = detailDelegate
        
        arrayButton = [KButtonItem]()
        
        if let shareLinkPart = content?.shareLinkPartReference(){
            if !((shareLinkPart.sharedText ?? "").isEmpty && (shareLinkPart.sharedImage ?? "").isEmpty && (shareLinkPart.sharedLink ?? "").isEmpty){
                let share = KButtonItem(title: "Condividi".localizedString(), image: UIImage(krakeNamed:"share_icon"), target: self, selector: #selector(KMixedBarButton.share))
                arrayButton?.append(share)
            }
        }
        
        if let activity = activityPart?.activityPartReference(), let _ = activity.dateTimeStart{
            arrayButton?.append(KButtonItem(title: "Aggiungi al calendario".localizedString(), image: UIImage(krakeNamed:"add_alarm"), target: self, selector: #selector(KMixedBarButton.addToCalendar)))
        }
        
        if let elems = detailDelegate?.createAttachmentButtons(viewController, element: object) {
            for elem in elems{
                arrayButton?.append(elem)
            }
        }
        if arrayButton!.count > 1{
            menuItems = [AnyObject]()
            for button in arrayButton!{
                let item: KxMenuItem
                if button.target != nil{
                    item = KxMenuItem.init(button.title, image: button.image?.imageTinted(UIColor.white), target: button.target!, action: button.selector!)
                }else{
                    item = KxMenuItem.init(button.title, image: button.image?.imageTinted(UIColor.white), target: self, action: #selector(KMixedBarButton.openAllegato(sender:)))
                }
                menuItems.append(item)
            }
            return UIBarButtonItem(image: UIImage(krakeNamed: "more"), style: .done, target: self, action: #selector(KMixedBarButton.openMenu))
        }else if arrayButton!.count == 1{
            let elem = arrayButton![0]
            let image: UIImage? = elem.image
            var action: Selector = elem.selector!
            var target: AnyObject? = self
            if elem.title == "Condividi".localizedString() {
                
            }else{
                if elem.target != nil{
                    target = elem.target
                }else{
                    action = #selector(KMixedBarButton.openAllegato(sender:))
                }
            }
            if elem.showTitle{
                return UIBarButtonItem(title: elem.title, style: .done, target: target, action: action)
            }else{
                return UIBarButtonItem(image: image, style: .done, target: target, action: action)
            }
        }else{
            return nil
        }
    }
    
    @objc public func share(sender: AnyObject){
        if let share = content?.shareLinkPartReference() {
            let activities = detailDelegate?.shareActivitiesFor(content: content)
            KShareManager.share(content: share, otherItems: [content!], activities: activities, sender: sender, fromViewController: fromViewController!)
        }
    }

    @objc public func addToCalendar() {
        if let dettaglio = activityPart,
            let fromDate = dettaglio.activityPartReference()?.dateTimeStart,
            let toDate = dettaglio.activityPartReference()?.dateTimeEnd{
            var location = ""
            if let detMap = dettaglio as? ContentItemWithMapPart, let mappa = detMap.mapPartReference(), let info = mappa.locationAddress{
                location = info
            }
            let description = (dettaglio as? ContentItemWithDescription)?.bodyPart()?.htmlToString() ?? ""
            calendar?.presentAddToCalendar(CalendarInfo(title: dettaglio.titlePartTitle ?? "", abstract: description, location: location, fromDate: fromDate, toDate: toDate), nav: fromViewController?.navigationController)
        }
    }
    
    @objc public func openMenu(){
        let frame = CGRect(origin: CGPoint(x: fromViewController!.navigationController!.navigationBar.frame.width-54, y: fromViewController!.navigationController!.navigationBar.frame.origin.y),
            size: CGSize(width: 44, height: fromViewController!.navigationController!.navigationBar.frame.height))
        
        KxMenu.show(in: fromViewController!.navigationController!.view, from: frame, menuItems: menuItems)
    }
    
    @objc public func openAllegato(sender: KxMenuItem){
        if let elems = arrayButton{
            for elem in elems{
                if elem.title == sender.title{
                    if fromViewController is UINavigationController{
                        (fromViewController as! UINavigationController).pushBrowserViewController(URL(string: elem.mediaUrl!)!, title: elem.title)
                    }else{
                        fromViewController?.present(browserViewController: URL(string: elem.mediaUrl!)!, title: elem.title)
                    }
                    break
                }
            }
        }
    }

}
