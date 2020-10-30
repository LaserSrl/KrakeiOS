//
//  BeaconAdsLoader.swift
//  Beacons
//
//  Created by joel on 28/04/16.
//  Copyright © 2016 Mobile Team PRO. All rights reserved.
//

import UIKit
import CoreLocation


public let BeaconAdsLoaderDidLoadBeaconFromService = "LoadedKrakeBeaconForSuper"
public let BeaconAdsLoaderDidLoadAdsFromService = "LoadedADSPerBeacon"

public protocol BeaconAdsLoaderDelegate: NSObjectProtocol {
    func nearestBeaconManager(_ nearestBeaconManager: NearestBeaconManager, didUpdateNearestBeacon nearestBeacon: CLBeacon)
    
    func adsLoader(_ adsLoader: BeaconAdsLoader, didEnterRegion region: CLBeaconRegion, isMain: Bool)
    
    func adsLoader(_ adsLoader: BeaconAdsLoader, didExitRegion region: CLBeaconRegion, isMain: Bool)
    
    func adsLoader(_ adsLoader: BeaconAdsLoader, monitoringDidFailForRegion region: CLRegion?, withError error: NSError)
    
    func adsLoader(_ adsLoader: BeaconAdsLoader, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError)
    
    func adsLoader(_ adsLoader: BeaconAdsLoader, loadingOfBeaconFromServerFailed beacon: CLBeacon, withError error: NSError)
    
    func adsLoader(_ adsLoader: BeaconAdsLoader, didLoadServerBeacon krakeBeacon: KrakeBeaconProtocol?, forBeacon beacon: CLBeacon)
    
    func adsLoader(_ adsLoader: BeaconAdsLoader, loadingOfAdsFromServerFailed beacon: KrakeBeaconProtocol, withError error: NSError)
    
    func adsLoader(_ adsLoader: BeaconAdsLoader, didLoadAds ads: [AnyObject], forBeacon beacon: KrakeBeaconProtocol)
    
}

open class BeaconAdsLoader: NSObject, NearestBeaconManagerDelegate {
    
    open weak var delegate: BeaconAdsLoaderDelegate?
    
    public var currentSuperBeacon: CLBeacon?
    fileprivate var currentKrakeBeacon: KrakeBeaconProtocol?
    public var currentLoadingTask: OMLoadDataTask? {didSet { oldValue?.cancel() }}
    public var lastTimeNotifiedBeacon =  [NSNumber: Date]()
    fileprivate var exitRegionClearDataTimer : Timer?
    
    
    fileprivate let maxNumberOfNotification = KInfoPlist.Beacon.beaconADSMaxNotificationInSameVisit.intValue
    fileprivate let minTimeToNotifiySameBeacon = KInfoPlist.Beacon.beaconADSMinimumTimeToNotifySameBeacon.doubleValue
    
    open func nearestBeaconManager(_ nearestBeaconManager: NearestBeaconManager, didUpdateNearestBeacon nearestBeacon: CLBeacon)  {
        KLog(type: .info, "Found super beacon");
        
        if shouldShowAds(nearestBeacon){
            currentSuperBeacon = nearestBeacon
            
            currentLoadingTask?.cancel()
            
            currentLoadingTask = OGLCoreDataMapper.sharedInstance()
                .loadData(withDisplayAlias: "elenco-beacon",
                          extras: ["UUID": currentSuperBeacon!.proximityUUID.uuidString,
                                   "major":currentSuperBeacon!.major,
                                   "minor":currentSuperBeacon!.minor],
                          completionBlock: { [weak self](objectID, error, cacheValid) in
                            
                            if let sSelf = self {
                                if objectID != nil && cacheValid {
                                    
                                    KLog(type: .info, "Downloaded super beacon");
                                    let cache = OGLCoreDataMapper.sharedInstance().managedObjectContext .object(with: objectID!) as! DisplayPathCache
                                    sSelf.processBeaconDisplayCache(cache)
                                    sSelf.delegate?.adsLoader(sSelf, didLoadServerBeacon: cache.cacheItems.firstObject as? KrakeBeaconProtocol, forBeacon: sSelf.currentSuperBeacon!)
                                }
                                else if error != nil {
                                    
                                    KLog(type: .info, "Downloaded super beacon fail");
                                    sSelf.delegate?.adsLoader(sSelf, loadingOfBeaconFromServerFailed: sSelf.currentSuperBeacon!, withError: error! as NSError)
                                }
                            }
                })
            
            
        }
    }
    
    open func nearestBeaconManager(_ nearestBeaconManager: NearestBeaconManager, didExitRegion region: CLBeaconRegion) {
        self.delegate?.adsLoader(self, didExitRegion: region, isMain: region == nearestBeaconManager.mainRegion)
        if region == nearestBeaconManager.mainRegion
        {
            exitRegionClearDataTimer?.invalidate()
            exitRegionClearDataTimer = Timer.scheduledTimer(timeInterval: 180, target: self, selector: #selector(BeaconAdsLoader.clearData), userInfo: nil, repeats: false)
        }
    }
    
    open func nearestBeaconManager(_ nearestBeaconManager: NearestBeaconManager, didEnterRegion region: CLBeaconRegion) {
        self.delegate?.adsLoader(self, didEnterRegion: region,isMain: region == nearestBeaconManager.mainRegion)
        if region == nearestBeaconManager.mainRegion {
            exitRegionClearDataTimer?.invalidate()
            exitRegionClearDataTimer = nil
        }
    }
    
    open func nearestBeaconManager(_ nearestBeaconManager: NearestBeaconManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError)
    {
        self.delegate?.adsLoader(self, monitoringDidFailForRegion: region, withError: error)
    }
    
    open func nearestBeaconManager(_ manager: NearestBeaconManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError)
    {
        self.delegate?.adsLoader(self, rangingBeaconsDidFailForRegion: region, withError: error)
    }
    
    @objc func clearData()
    {
        KLog(type: .info, "Cleat all")
        currentLoadingTask = nil
        currentKrakeBeacon = nil
        currentSuperBeacon = nil
        lastTimeNotifiedBeacon.removeAll()
    }
    
    public func shouldShowAds(_ beacon: CLBeacon) -> Bool
    {
        if lastTimeNotifiedBeacon.count < maxNumberOfNotification {
            var notifiy = true
            if let lastTimeNotifiedBeacon = lastTimeNotifiedBeacon[beacon.minor] {
                if abs(lastTimeNotifiedBeacon.timeIntervalSinceNow) < minTimeToNotifiySameBeacon {
                    notifiy = false
                }
            }
            
            return notifiy;
        }
        return false;
    }
    
    fileprivate func processBeaconDisplayCache(_ cache: DisplayPathCache)
    {
        currentKrakeBeacon = cache.cacheItems.firstObject as? KrakeBeaconProtocol
        
        if let url = currentKrakeBeacon?.urlReference()?.contentUrl {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: BeaconAdsLoaderDidLoadBeaconFromService), object: self, userInfo: ["KBeacon":currentKrakeBeacon!,"Beacon":currentSuperBeacon!]);
            
            var extras = [String: AnyObject]()
            
            let dotRange = url.range(of: "?")
            let displayAlias : String
            if let dotRange = dotRange, dotRange.lowerBound != dotRange.upperBound {
                displayAlias = String(url[...dotRange.lowerBound])
                let query = (String(url[dotRange.upperBound...]) as NSString).removingPercentEncoding! as NSString
                let tokens =  query.components(separatedBy: "&")
                for token in tokens {
                    let range = token.range(of: "=")!
                    extras[String(token[...range.lowerBound])] = String(token[range.upperBound]) as AnyObject?
                }
            }
            else
            {
                displayAlias = url
            }
            
            currentLoadingTask = OGLCoreDataMapper.sharedInstance()
                .loadData(withDisplayAlias: displayAlias,
                          extras: extras,
                          completionBlock: { [weak self] (objectID, error, cacheValid) in
                            if let sSelf = self {
                                if objectID != nil && cacheValid {
                                    KLog(type: .info, "Downloaded Spam");
                                    let cache = OGLCoreDataMapper.sharedInstance().managedObjectContext .object(with: objectID!) as! DisplayPathCache
                                    sSelf.processAdsDisplayCache(cache)
                                    sSelf.delegate?.adsLoader(sSelf, didLoadAds: cache.cacheItems.array as [AnyObject], forBeacon: sSelf.currentKrakeBeacon!)
                                }
                                else if error != nil {
                                    KLog(type: .info, "Downloaded Spam fail");
                                    sSelf.delegate?.adsLoader(sSelf, loadingOfAdsFromServerFailed: sSelf.currentKrakeBeacon!, withError: error! as NSError)
                                }
                            }
                })
        }
    }
    
    fileprivate func processAdsDisplayCache(_ cache: DisplayPathCache)
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: BeaconAdsLoaderDidLoadAdsFromService), object: self, userInfo: ["KBeacon":currentKrakeBeacon!,"Beacon":currentSuperBeacon!,"Count":cache.cacheItems.count]);
        
        if cache.cacheItems.count > 0 {
            
            lastTimeNotifiedBeacon[currentSuperBeacon!.minor] = Date();
            
            let notificaiton = UILocalNotification()
            if #available(iOS 8.2, *) {
                notificaiton.alertTitle = KInfoPlist.appName
            }
            let notificationBody: String
            if let termName = currentKrakeBeacon?.termPart()?.name{
                notificationBody = KLocalization.Beacon.notificationBody(termName)
            }else{
                notificationBody = currentKrakeBeacon?.testodellaNotificaValue ?? ""
            }
            notificaiton.alertBody = notificationBody
            notificaiton.userInfo = [LocalNotificationCacheID:cache.objectID.uriRepresentation().description, KParametersKeys.displayAlias: cache.displayPath]
            notificaiton.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notificaiton)
        }
    }
}
