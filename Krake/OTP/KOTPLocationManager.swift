//
//  KOTPLocationManager.swift
//  Krake
//
//  Created by Patrick on 01/08/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import Foundation
import UserNotifications

class KOTPLocationManager: KLocationManager
{
    public static let shared = KOTPLocationManager()
    
    public var completion: ((String)->Void)?
    
    override init() {
        super.init()
        for region in monitoredRegions
        {
            requestState(for: region)
        }
    }
    
    public func startMonitoring(regionFrom stopItem: KOTPStopItem?, completion: @escaping (Bool)->Void)
    {
        guard let stopItem = stopItem else { return }
        guard let originalId = stopItem.originalId else { return }
        if monitoredRegions.count >= 20
        {
            let alert = UIAlertController(title: KInfoPlist.appName, message: "Puoi attivare al massimo 20 fermate. Prima di procedere con l'attivazione di una nuova fermata devi disabilitarne un'altra.".appLocalizedString(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Disattiva tutte le fermate".appLocalizedString(), style: .destructive, handler: { (action) in
                self.stopMonitoringRegions()
                self.startMonitoring(regionFrom: stopItem, completion: completion)
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Ok".localizedString(), style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            UIApplication.shared.delegate?.window??.rootViewController?.present(alert, animated: true, completion: nil)
            return
        }
        let region = CLCircularRegion(center: stopItem.coordinate, radius: KInfoPlist.OTP.stopRegionRadiusMeter, identifier: originalId)
        requestAuthorization(always: true) { (manager, status) in
            if status == CLAuthorizationStatus.authorizedAlways{
                self.startMonitoring(for: region)
                self.requestState(for: region)
                UserDefaults.standard.set(stopItem.name, forKey: originalId)
                completion(true)
            }else if status != CLAuthorizationStatus.notDetermined{
                KMessageManager.showMessage("Non puoi usufruire della funzionalità, devi prima abilitare l'utilizzo del GPS!".appLocalizedString(), type: KMessageManager.Mode.error, buttonTitle: "Impostazioni".localizedString(), buttonCompletion: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                })
                completion(false)
            }
        }
    }
    
    public func monitoring(from identifier: String?) -> CLRegion?
    {
        guard let identifier = identifier else { return nil }
        for region in monitoredRegions where region.identifier == identifier
        {
            return region
        }
        return nil
    }
    
    public func stopMonitoring(region: CLRegion)
    {
        stopMonitoring(for: region)
    }
    
    public func stopMonitoringRegions()
    {
        for region in monitoredRegions
        {
            stopMonitoring(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside
        {
            locationManager(manager, didEnterRegion: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)
    {
        if let message = UserDefaults.standard.string(forKey: region.identifier){
            let messaggeBody = String(format: "Stai arrivando alla fermata '%@'".appLocalizedString(), message)
            if UIApplication.shared.applicationState == .active
            {
                self.stopMonitoring(region: region)
                let alert = UIAlertController(title: KInfoPlist.appName, message: messaggeBody, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok".appLocalizedString(), style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                let vc = (UIApplication.shared.delegate as? OGLAppDelegate)?.window?.rootViewController
                vc?.present(alert, animated: true, completion: nil)
            }else{
                let content = UNMutableNotificationContent()
                content.title = KInfoPlist.appName
                content.body = messaggeBody
                content.sound = UNNotificationSound.default
                content.badge = 0
                let identifier = "LocalNotification"
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { (error) in
                    if error != nil{
                        self.stopMonitoring(region: region)
                    }
                }
            }
            completion?(region.identifier)
        }
    }
    
}
