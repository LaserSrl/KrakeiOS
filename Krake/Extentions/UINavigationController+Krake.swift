//
//  UINavigationController.swift
//  Pods
//
//  Created by Patrick on 26/07/16.
//
//

import Foundation
import LaserWebViewController

public extension UINavigationController{
    
    func pushDetailViewController(_ endPoint: String? = nil, detail: ContentItem? = nil, extras: [String: Any]? = nil, detailDelegate: KDetailPresenterDelegate? = KDetailPresenterDefaultDelegate(), analyticsExtras: [String: Any]? = nil){
        if let vc = KDetailViewControllerFactory.factory.newDetailViewController(detailObject: detail, endPoint: endPoint, extras: extras, detailDelegate: detailDelegate, analyticsExtras: analyticsExtras) {
            pushViewController(vc, animated: true)
        }
    }
    
    /**
     Se il controller è presente all'interno di un UINavigationViewController apre tramite un "pushViewController" il browser con l'URL richiesto, oppure se non vi è un UINavigationViewController lo apre tramite un "presentViewController"
     
     Il metodo effettua il check sull'URL che si richiede di aprire, nel caso in cui il canOpenURL ritorni false viene presentato un messaggio di errore
     
     - parameter url:   NSURL da aprire
     - parameter title: Titolo da assegnare al UIViewController del browser, di default è il nome dell'app (opzionale)
     */
    func pushBrowserViewController(_ url: URL,
                                          title: String? = KInfoPlist.appName,
                                          showToolbar: Bool = true,
                                          delegate: GDWebViewControllerDelegate? = nil){
        if UIApplication.shared.canOpenURL(url){
            let browser = GDWebViewController()
            browser.loadURL(url)
            browser.allowsBackForwardNavigationGestures = true
            browser.showToolbar(showToolbar, animated: true)
            browser.title = title
            browser.delegate = delegate
            pushViewController(browser, animated: true)
        }else{
            KMessageManager.showMessage(String(format:"Non è possibile aprire il seguente url %@".localizedString(), url.description), type: .error)
        }
    }
}
