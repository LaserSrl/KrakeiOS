//
//  KTabAndCollectionViewItems.swift
//  Krake
//
//  Created by joel on 26/06/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import Foundation
import UIKit
import Segmentio

public class KTabAndCollectionViewItems: UIViewController, KTabManagerDelegate {

    @IBOutlet weak var tabSegmentControl: Segmentio!

    private var tabManager: KTabManager!
    public var tabOptions: KTabManagerOptions!
    /**
     * Solo il metodo per il tab di default è utilizzato
     */
    public var tabDelegate: KTabManagerDelegate?
    public var itemsCollectionInfo: KItemsCollectionInfo!

    public var itemsViewController: KItemsCollectionViewController!
    public var itemsViewControllerDelegate: KItemsCollectionViewDelegate!

    override public func viewDidLoad() {
        super.viewDidLoad()

        tabManager = KTabManager(segmentedControl: tabSegmentControl,
                                 tabManagerOptions: tabOptions,
                                 delegate: self)
        tabManager.setupInViewDidLoad()
    }

    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is KItemsCollectionViewController {
            itemsViewController = (segue.destination as! KItemsCollectionViewController)
            if itemsCollectionInfo.loadBeforeFirstSelection {
                itemsViewController.endPoint = itemsCollectionInfo.endPoint
            }
            itemsViewController.extras = itemsCollectionInfo.extras
            itemsViewController.collectionItemsDelegate = itemsViewControllerDelegate
        }
    }

    public func tabManager(_ manager: KTabManager, didSelectTermPart termPart: TermPartProtocol?) {
        if !itemsCollectionInfo.loadBeforeFirstSelection {
            itemsViewController.endPoint = itemsCollectionInfo.endPoint
        }
        if let termPart = termPart
        {
            itemsViewController.extras[KParametersKeys.terms] = termPart.identifier!.stringValue
        }
        else if let allTermId = manager.tabManagerOptions.allTabTermId
        {
            itemsViewController.extras[KParametersKeys.terms] = allTermId
        }
        else
        {
            itemsViewController.extras.removeValue(forKey: KParametersKeys.terms)
        }

        itemsViewController.loadFromWS()
    }

    public func tabManager(_ manager: KTabManager, defaultSelectedIndex tabs: [Any]) -> UInt? {
        return tabDelegate?.tabManager(manager, defaultSelectedIndex: tabs)
    }
}

public class KItemsCollectionInfo {
    let endPoint: String
    let loadBeforeFirstSelection: Bool
    let extras: [String : Any]

    public init(endPoint: String,
         extras: [String : Any] = KRequestParameters.parameters(currentPage: 1, pageSize: 15),
         loadBeforeFirstSelection: Bool = true) {
        self.endPoint = endPoint
        self.extras = extras
        self.loadBeforeFirstSelection = loadBeforeFirstSelection
    }
}
