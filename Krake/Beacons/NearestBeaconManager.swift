//
// Please report any problems with this app template to contact@estimote.com
//

import CoreLocation

public protocol NearestBeaconManagerDelegate: class {

    func nearestBeaconManager(_ nearestBeaconManager: NearestBeaconManager, didUpdateNearestBeacon nearestBeacon: CLBeacon)

    func nearestBeaconManager(_ nearestBeaconManager: NearestBeaconManager, didEnterRegion region: CLBeaconRegion)

    func nearestBeaconManager(_ nearestBeaconManager: NearestBeaconManager, didExitRegion region: CLBeaconRegion)

    func nearestBeaconManager(_ nearestBeaconManager: NearestBeaconManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError)

    func nearestBeaconManager(_ manager: NearestBeaconManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError)
}

public let NBMFoundSuperBeaconNotification = "FoundSuperBeacon"
public let NBMDidEnterRegionNotification = "EnterRegion"
public let NBMDidExitRegioneNotification = "ExitRegion"
public let NBMNotificationKeyRegion = "Region"
public let NBMNotificationKeyRegionIsMain = "IsMain"

open class NearestBeaconManager: NSObject, CLLocationManagerDelegate {

    open weak var delegate: NearestBeaconManagerDelegate?

    public let mainRegion: CLBeaconRegion
    fileprivate let allRegions: [CLBeaconRegion]

    public let beaconManager = KLocationManager()

    fileprivate var beaconRSSIMedia =  [NSNumber:[CLLocationAccuracy]]()

    fileprivate var nearBeaconsTime =  [NSNumber:Date]()
    fileprivate let beaconNumberOfDistanceSamples = KInfoPlist.Beacon.beaconDistanceToBeNearInMeter.intValue
    fileprivate let beaconNearMaxDistance = KInfoPlist.Beacon.beaconDistanceToBeNearInMeter.doubleValue
    fileprivate let minDiffierenceToGetSuperBeacon = KInfoPlist.Beacon.beaconDistanceBetweenSuperBeaconAndOthers.doubleValue
    fileprivate let minTimeToBecomeSuperBeacon = KInfoPlist.Beacon.beaconMinimunTimeToBecomeSuperBeacon.doubleValue
    fileprivate var firstEventSent = false
    fileprivate var inRegion = false
    fileprivate var backgroundTask = KBackgroundTaskInvalid
    fileprivate var didEnterBackgroundObserver : AnyObject?;
    fileprivate var willEnterForegroundObserver : AnyObject?;

    public init(mainRegion: CLBeaconRegion, additionalRegions: CLBeaconRegion...) {
        self.mainRegion = mainRegion
        self.allRegions = [mainRegion] + additionalRegions
        super.init()
        self.beaconManager.delegate = self

    }

    open func startBeaconRegionMonitoring() {

        self.beaconManager.requestAuthorization(always: true, completion: { [weak self](manager, status) in
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                if let sSelf = self {
                    for region in sSelf.allRegions
                    {
                        sSelf.beaconManager.startMonitoring(for: region)
                        sSelf.beaconManager.requestState(for: region)
                    }
                }
            }
        })
    }

    open func stopBeaconRegionMonitoring() {
        for region in allRegions
        {
            self.beaconManager.stopMonitoring(for: region)
            self.locationManager(self.beaconManager, didExitRegion: region)
        }
    }

    fileprivate func startNearestBeaconUpdatesInMainRegion() {
        inRegion = true
        self.beaconManager.startRangingBeacons(in: mainRegion)

        didEnterBackgroundObserver = NotificationCenter.default
            .addObserver(forName: KApplicationDidEnterBackground,
                         object: UIApplication.shared,
                         queue: nil,
                         using: { [weak self](notification) in

                            if let sSelf = self {
                                if sSelf.inRegion {
                                    sSelf.backgroundTask = sSelf.createBackgroundTask()
                                    if sSelf.backgroundTask == KBackgroundTaskInvalid {
                                        sSelf.stopNearestBeaconUpdatesInMainRegion()
                                    }

                                }
                            }
            });

        willEnterForegroundObserver = NotificationCenter.default
            .addObserver(forName: KApplicationWillEnterForeground,
                         object: UIApplication.shared,
                         queue: nil,
                         using: { [weak self](notification) in
                            
                            self?.backgroundTask = KBackgroundTaskInvalid
            });
    }

    fileprivate func stopNearestBeaconUpdatesInMainRegion() {
        inRegion = false
        self.beaconManager.stopRangingBeacons(in: mainRegion)
        nearBeaconsTime.removeAll()
        beaconRSSIMedia.removeAll()
    }

    open func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {

        var nearBeaconsDistance = [(CLBeacon,Double)]()
        var nearBeacons = [NSNumber]()
        var insertedMinors = [NSNumber]()
        for beacon in beacons {

            if beacon.accuracy >= 0 && insertedMinors.index(of: beacon.minor) == nil {
                insertedMinors.append(beacon.minor)
                if var distances = beaconRSSIMedia[beacon.minor] {

                    if distances.count == beaconNumberOfDistanceSamples {
                        distances.removeFirst()
                    }
                    distances.append(beacon.accuracy)

                    beaconRSSIMedia[beacon.minor] = distances
                }
                else {
                    let distances = [beacon.accuracy]
                    beaconRSSIMedia[beacon.minor] = distances
                }
            }

            if let distances = beaconRSSIMedia[beacon.minor] , distances.count == beaconNumberOfDistanceSamples {

                let distance = computeDistance(distances)

                if distance < beaconNearMaxDistance {
                    nearBeaconsDistance.append((beacon,distance))

                    nearBeacons.append(beacon.minor)

                    if (nearBeaconsTime[beacon.minor]) == nil {
                        nearBeaconsTime[beacon.minor] = Date()
                    }
                }
            }
        }


        for near  in nearBeaconsTime {
            if !(nearBeacons.contains(near.0)) {
                nearBeaconsTime.removeValue(forKey: near.0)
            }
        }

        nearBeaconsDistance.sort { (first, second) -> Bool in
            return first.1 < second.1
        }

        if let possibleSuperBeacon = nearBeaconsDistance.first {

            if nearBeaconsDistance.count > 1 {
                let secondBeacon = nearBeaconsDistance[1]

                if abs(possibleSuperBeacon.1-secondBeacon.1) < minDiffierenceToGetSuperBeacon {
                    return
                }
            }

            let superBeacon = possibleSuperBeacon.0

            if abs(nearBeaconsTime[superBeacon.minor]!.timeIntervalSinceNow) > minTimeToBecomeSuperBeacon {
                nearBeaconsTime.removeAll()
                self.delegate?.nearestBeaconManager(self, didUpdateNearestBeacon: superBeacon)
                NotificationCenter.default.post(name: Notification.Name(rawValue: NBMFoundSuperBeaconNotification),
                                                object: self,
                                                userInfo: ["Beacon": superBeacon])
            }

        }
    }

    fileprivate func createBackgroundTask() -> UIBackgroundTaskIdentifier {
        return UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.stopNearestBeaconUpdatesInMainRegion()
            self.beaconManager.stopMonitoring(for: self.mainRegion)

            let backGround = self.backgroundTask;
            self.backgroundTask = KBackgroundTaskInvalid
            self.beaconManager.startMonitoring(for: self.mainRegion)
            self.beaconManager.requestState(for: self.mainRegion)

            KLog(type: .info, "Fine task. Aspetto quello nuovo.");

            UIApplication.shared.endBackgroundTask(backGround)

        });
    }

    open func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if(region.isKind(of: CLBeaconRegion.self))
        {
            if state == .inside {
                self.locationManager(manager, didEnterRegion: region)
            }
            else if state == .outside {

                self.locationManager(manager, didExitRegion: region)
            }
        }
    }

    open func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {

        delegate?.nearestBeaconManager(self, monitoringDidFailForRegion: region, withError: error as NSError)
    }

    open func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        delegate?.nearestBeaconManager(self, rangingBeaconsDidFailForRegion: region, withError: error as NSError)
    }


    open func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if(region.isKind(of: CLBeaconRegion.self))
        {
            KLog(type: .info, "Nella region");
            NotificationCenter.default.post(name: Notification.Name(rawValue: NBMDidEnterRegionNotification),
                                            object: self,
                                            userInfo: [NBMNotificationKeyRegion: region,
                                                       NBMNotificationKeyRegionIsMain: region == mainRegion])

            self.delegate?.nearestBeaconManager(self, didEnterRegion: region as! CLBeaconRegion)
            if(region == mainRegion)
            {
                if UIApplication.shared.applicationState != .background {
                    startNearestBeaconUpdatesInMainRegion()
                }
                else {
                    self.backgroundTask = createBackgroundTask()
                    
                    if self.backgroundTask != KBackgroundTaskInvalid {

                        KLog(type: .info, "Nella region in background");
                        startNearestBeaconUpdatesInMainRegion()
                    }
                }
            }

        }
    }

    open func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if(region.isKind(of: CLBeaconRegion.self))
        {
            KLog(type: .info, "Uscito dalla region")
            if region == mainRegion {
                stopNearestBeaconUpdatesInMainRegion()
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: NBMDidExitRegioneNotification),
                                            object: self,
                                            userInfo: [NBMNotificationKeyRegion: region,
                                                       NBMNotificationKeyRegionIsMain: region == mainRegion])
            self.delegate?.nearestBeaconManager(self, didExitRegion: region as! CLBeaconRegion)

        }
    }

    fileprivate func computeDistance(_ rssis: [CLLocationAccuracy]) -> Double{

        var total = 0.0;
        for v in rssis {
            total+=v
        }

        return  total / Double(rssis.count)
    }

}
