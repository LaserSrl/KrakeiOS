//
//  KListReport.swift
//  Krake
//
//  Created by Patrick on 08/07/15.
//  Copyright (c) 2015 Laser Group. All rights reserved.
//

import UIKit
import LaserSwippableCell

public struct ContentStatus {
    public var keyPath: String
    public var title: String
    public var textColor: UIColor = KTheme.current.color(.textTint)
    public var backgroundColor: UIColor = KTheme.current.color(.tint)
    
    public init(keyPath: String, title: String, textColor: UIColor, backgroundColor: UIColor) {
        self.keyPath = keyPath
        self.title = title
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
}

open class KListReportCell: CADRACSwippableCell {

    @IBOutlet weak var reportLeftLine: UIView!
    @IBOutlet weak var reportStatus: UIView!
    @IBOutlet weak var reportStatusView: UIView!
    @IBOutlet weak var reportImage: UIImageView!
    @IBOutlet weak var reportTitle: UILabel!
    @IBOutlet weak var reportSubtitle: UILabel!
    @IBOutlet weak var reportStatusLabel: UILabel!

    override open func awakeFromNib() {
        super.awakeFromNib()
        reportStatus.layer.cornerRadius = 5.0
        reportStatus.layer.borderWidth = 1
        reportStatus.backgroundColor = UIColor.clear
        reportLeftLine.backgroundColor = KTheme.current.color(.tint)
        backgroundColor = UIColor(white: 0.965, alpha: 1.0)
    }

    func configureCell(_ report: Report, isMyReport: Bool, colors: [ContentStatus]) {
        // Adding the first image of the report, if any.
        reportImage.image = nil
        reportImage.setImage(media: report.galleryMediaParts?.firstObject as AnyObject?)
        // Adding the title of the report.
        reportTitle?.text = report.titlePartTitle
        // Adding the subtitle of the report.
        reportSubtitle?.text = report.sottotitoloValue
        // Adding the information about the status of the report's pubblication
        // using the given colors, if the report contains that information and
        // the author of the report is the logged user.
        if let publishStatusDescription = report.publishExtensionPartPublishExtensionStatusReference()?.value, isMyReport {
            let status = colors.filter({ $0.keyPath == publishStatusDescription })
            if let first = status.first {
                reportStatus.layer.borderColor = first.backgroundColor.cgColor
                reportStatusLabel.textColor = first.textColor
                reportStatusLabel.text = first.title.localizedString()
                reportStatusView.isHidden = false
            } else {
                reportStatusView.isHidden = true
            }
        } else {
            reportStatusView.isHidden = !isMyReport
        }
    }
}

public protocol KListReportDelegate: NSObjectProtocol {
    @available(iOS, deprecated, message: "Use contentTypeDefinitionForNewReport(_:) instead.")
    func listReport(didTouchAddButton addButton: UIBarButtonItem) -> ContentTypeDefinition

	/**
     Creates the content definition that will be used to configure the view controller
     for the report creation.

     - parameter sender: the UIBarButtonItem that has triggered the action.
     - returns: the ContentTypeDefinition for the report creation.
 	*/
    func contentTypeDefinitionForNewReport(_ sender: UIBarButtonItem) -> ContentTypeDefinition
}

public extension KListReportDelegate {
    @available(iOS, deprecated, message: "Use contentTypeDefinitionForNewReport(_:) instead.")
    func listReport(didTouchAddButton addButton: UIBarButtonItem) -> ContentTypeDefinition {
        return contentTypeDefinitionForNewReport(addButton)
    }
}

/**
 Default delegate for the list of report.

 Besides the base functionalities required to a KListMapDelegate, it offers the
 following functionalities:
  * presentation of policies related to a tab;
  * creation of a new report via ContentModification.

 - seealso: `KListMapDelegate` for the documentation about base functions.
*/
class KListReport: NSObject, KListMapDelegate, ContentModificationContainerViewControllerDelegate {

    let statuses: [ContentStatus]
    internal weak var listVC: KListMapViewController!
    weak var delegate: KListReportDelegate?
    lazy var buttonAddReport : UIBarButtonItem = {
		return UIBarButtonItem(image: UIImage(omNamed: "ic_add"),
		                       style: .plain,
		                       target: self,
		                       action: #selector(KListReport.addReport))
    }()
    lazy var buttonPolicy : UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(omNamed: "license"),
                               style: .plain,
                               target: self,
                               action: #selector(KListReport.showPolicy))
    }()
    var selectedTab: TabBarItem?

    public init(reportStatuses statuses: [ContentStatus]) {
		self.statuses = statuses
        super.init()
    }

    func registerCell(_ collectionView: UICollectionView) {
        
        let URLBundle = Bundle(for: object_getClass(self)!).url(forResource: "Reportages", withExtension: "bundle")!
        collectionView.register(UINib(nibName: "CellReport", bundle: Bundle(url: URLBundle)),
                                forCellWithReuseIdentifier: "cell")
        collectionView.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 70,right: 0)
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
    }

    func collectionView(_ object: AnyObject,
                        collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! KListReportCell
        cell.configureCell(object as! Report,
                           isMyReport: selectedTab?.addEnabled ?? false,
                           colors: statuses)
        return cell
    }

    func collectionView(_ object: AnyObject,
                        collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath,
                        mapIsVisible: Bool) -> CGSize {
        var standardSize = makeStandardSize(collectionView, layout: collectionViewLayout, mapIsVisible: mapIsVisible)
        let height: CGFloat = 100.0
        standardSize.height = height
        return standardSize
    }

    func didSelectTab(_ manager: KTabManager, fromViewController: KListMapViewController, object: Any?) {
        if let tab = object as? TabBarItem {
            // Saving the reference to the selected tab.
            selectedTab = tab
            // Preparing additional buttons to present for the selected tab.
            var arrayButton = [UIBarButtonItem]()
            // Checking that a valid policy endpoint has been specified for the
            // selected tab.
            if tab.policyEndPoint != nil {
                // Adding the button to show the policy because a valid policy
                // endpoint has been given.
                arrayButton.append(buttonPolicy)
            }
            // Checking if a report can be created for the selected tab.
            if tab.addEnabled {
                // Adding the button to add a new report.
                arrayButton.append(buttonAddReport)
            }
			// Adding additional button items to the view controller, if any.
            if !arrayButton.isEmpty {
                listVC.navigationItem
                    .setRightBarButtonItems(arrayButton, animated: true)
            }
        }
    }

    /**
     Present a policy view controller configured with the endpoint of the policy
     related to the selected tab.
 	*/
    @objc func showPolicy() {
        listVC.presentPolicyViewController(policyEndPoint: selectedTab?.policyEndPoint)
    }

    /**
     Checks if the user is logged in Krake, otherwise request a new login for Krake.
     After the user performs the login, it start the creation of a new report.
 	*/
    @objc func addReport(){
        let loginManager = KLoginManager.shared
        if !loginManager.isKrakeLogged {
            loginManager.presentLogin() { (logged, params, _, error) in
                if logged {
                    self.openAddReportViewController()
                } else {
                    if let error = error {
                        KMessageManager.showMessage(error.localizedDescription, type: .error)
                    }
                }
            }
        } else {
            openAddReportViewController()
        }
    }

    /**
     Prepare and present the view controller that will be used to create a new
     report.
 	*/
    private func openAddReportViewController(){
        let contentManagerType: ContentTypeDefinition
        // Requesting the content definition to the delegate.
        if let delegateContentDefinition = delegate?.contentTypeDefinitionForNewReport(buttonAddReport) {
			contentManagerType = delegateContentDefinition
        } else {
            // The delegate did not specified any content definition, using
            // the default.
			contentManagerType = ContentTypeDefinition(contentType: "UserReport",
			                                           viewControllers: [
                                                        ContentModificationContainerViewController.mediaViewController(),
                                                        ContentModificationContainerViewController.infoViewController(),
                                                        ContentModificationContainerViewController.mapViewController()],
			                                           customParams: [ContentManagerKeys.STATUS : "Created" as AnyObject])
        }
        // Preparing the view controller for the report creation.
        let contentModificationViewController = ContentModificationContainerViewController.newContentModificationContainer(contentManagerType: contentManagerType, delegate: self)
        let nav = UINavigationController(rootViewController: contentModificationViewController)
        KTheme.current.applyTheme(toNavigationBar: nav.navigationBar, style: .default)
        nav.modalPresentationStyle = .formSheet
        // Presenting the creation view controller embedded inside
        // a navigation controller.
        listVC.present(nav, animated: true, completion: nil)
    }

    func contentModificationViewController(_ controller: ContentModificationContainerViewController,
                                           valuesFromOriginalElement originalElement: AnyObject) -> [String : AnyObject] {
        return [String : AnyObject]()
    }

    func contentModificationViewController(_ controller: ContentModificationContainerViewController,
                                           didCloseAfterSendingOfElementCompleted sentCorrectly: Bool) {
        if sentCorrectly {
            // Invalidating the cache for the list of report related to the
            // currently focused tab.
            if listVC.lastDisplayCache != nil {
                listVC.lastDisplayCache.date = Date(timeIntervalSince1970: 0)
                do {
                    try listVC.lastDisplayCache.managedObjectContext!.save()
                } catch {}
            }
            // Reloading the entries for focused tab.
            listVC.loadFromWS()
        }
    }
}
