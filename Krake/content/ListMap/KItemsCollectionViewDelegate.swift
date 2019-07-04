//
//  KItemsCollectionViewDelegate.swift
//  Krake
//
//  Created by joel on 06/03/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
public protocol KItemsCollectionViewDelegate: NSObjectProtocol
{
    func viewDidLoad(_ viewController: KItemsCollectionViewController)
    func registerCell(_ collectionView: UICollectionView, from viewController: KItemsCollectionViewController)
    func viewWillAppear(_ viewController: KItemsCollectionViewController)
    func viewDidAppear(_ viewController: KItemsCollectionViewController)
    func viewWillDisappear(_ viewController: KItemsCollectionViewController)
    func viewDidDisappear(_ viewController: KItemsCollectionViewController)

    func itemsCollectionController(_ itemsCollectionController: KItemsCollectionViewController,
                                   willChangeEmptyViewVisibility visible: Bool)

    func itemsCollectionController(_ itemsCollectionController: KItemsCollectionViewController,
                                   didLoadItems items: NSOrderedSet,
                                   loadingCompleted completed: Bool)

    func numberOfSection(in itemsController: KItemsCollectionViewController) -> Int

    func itemsCollectionController(_ itemsCollectionController: KItemsCollectionViewController,
                                   willShowNumberSection sections:Int,
                                   collectionView: UICollectionView)

    func itemsCollectionController(_ itemsController: KItemsCollectionViewController,
                                   numberOfItemsInSection section: Int) -> Int

    func itemsCollectionController(_ itemsCollectionController: KItemsCollectionViewController,
                                   willShowNumberOfItems items: Int,
                                   inSection section:Int,
                                   collectionView: UICollectionView)

    func itemsCollectionController(_ itemsController: KItemsCollectionViewController,
                                   itemAt indexPath: IndexPath) -> Any

    func itemsCollectionController(_ itemsCollectionController: KItemsCollectionViewController,
                                   layout collectionViewLayout: UICollectionViewLayout,
                                   collectionView: UICollectionView,
                                   cellForItem item: Any,
                                   atIndexPath indexPath: IndexPath) -> UICollectionViewCell

    func itemsCollectionController(_ itemsController: KItemsCollectionViewController,
                                   collectionView: UICollectionView,
                                   didSelectObject object: Any)


    func itemsCollectionController(_ itemsCollectionController: KItemsCollectionViewController,
                                   layout collectionViewLayout: UICollectionViewLayout,
                                   collectionView: UICollectionView,
                                   sizeForItem item: Any,
                                   atIndexPath indexPath: IndexPath) -> CGSize
    
    func itemsCollectionController(_ itemsCollectionController: KItemsCollectionViewController,
                                   collectionView: UICollectionView,
                                   viewForSupplementaryElementOfKind kind: String,
                                   at indexPath: IndexPath) -> UICollectionReusableView?
}

@available(iOS 10.0, *)
public extension KItemsCollectionViewDelegate
{
    func viewDidLoad(_ viewController: KItemsCollectionViewController) { }

    func viewWillAppear(_ viewController: KItemsCollectionViewController) { }

    func viewDidAppear(_ viewController: KItemsCollectionViewController) { }

    func viewWillDisappear(_ viewController: KItemsCollectionViewController) { }

    func viewDidDisappear(_ viewController: KItemsCollectionViewController) { }

    func itemsCollectionController(_ itemsCollectionController: KItemsCollectionViewController,
                                   willChangeEmptyViewVisibility visible: Bool)
    {

    }
    
    func itemsCollectionController(_ itemsCollectionController: KItemsCollectionViewController,
                                   didLoadItems items: NSOrderedSet,
                                   loadingCompleted completed: Bool)
    {

    }
    
    func numberOfSection(in itemsController: KItemsCollectionViewController) -> Int
    {
        return 1
    }

    func itemsCollectionController(_ itemsCollectionController: KItemsCollectionViewController,
                                   willShowNumberSection sections:Int,
                                   collectionView: UICollectionView) { }

    func itemsCollectionController(_ itemsController: KItemsCollectionViewController,
                                   numberOfItemsInSection section: Int) -> Int
    {
        return itemsController.loadedElements?.count ?? 0
    }

    func itemsCollectionController(_ itemsCollectionController: KItemsCollectionViewController,
                                   willShowNumberOfItems items: Int,
                                   inSection section:Int,
                                   collectionView: UICollectionView) { }


    func itemsCollectionController(_ itemsController: KItemsCollectionViewController,
                                   itemAt indexPath: IndexPath) -> Any
    {
        return itemsController.loadedElements!.object(at: indexPath.row)
    }

    func itemsCollectionController(_ itemsController: KItemsCollectionViewController,
                                   collectionView: UICollectionView,
                                   didSelectObject object: Any)
    {
        itemsController.view.isUserInteractionEnabled = false
        if let segueVC = KDetailViewControllerFactory.factory
            .newDetailViewController(detailObject: object as AnyObject,
                                     endPoint: (object as? ContentItem)?.autoroutePartDisplayAlias,
                                     detailDelegate: itemsController.detailDelegate,
                                     analyticsExtras: itemsController.analyticsExtras)
        {

            if itemsController.traitCollection.verticalSizeClass == .regular &&
                itemsController.traitCollection.horizontalSizeClass == .regular
            {
                let navVC = UINavigationController(rootViewController: segueVC)
                KTheme.current.applyTheme(toNavigationBar: navVC.navigationBar,
                                          style: .default)
                navVC.modalPresentationStyle = .formSheet

                itemsController.present(navVC, animated: true, completion: nil)
                segueVC.insertLeftNavigationItemToCloseModalDetail()
            }
            else
            {
                itemsController.navigationController?.pushViewController(segueVC, animated: true)
            }
        }
        itemsController.view.isUserInteractionEnabled = true
    }

    func itemsCollectionController(_ itemsCollectionController: KItemsCollectionViewController,
                                   layout collectionViewLayout: UICollectionViewLayout,
                                   collectionView: UICollectionView,
                                   sizeForItem item: Any,
                                   atIndexPath indexPath: IndexPath) -> CGSize
    {
        var width = collectionView.bounds.size.width
        if let flow = collectionViewLayout as? UICollectionViewFlowLayout
        {
            //     let padding = flow.minimumLineSpacing

            let margin = flow.sectionInset.left + flow.sectionInset.right
            width = width - margin
        }

        let height = width / 5 * 3
        return CGSize(width: width,height: height)
    }
    
    func itemsCollectionController(_ itemsCollectionController: KItemsCollectionViewController,
                                   collectionView: UICollectionView,
                                   viewForSupplementaryElementOfKind kind: String,
                                   at indexPath: IndexPath) -> UICollectionReusableView?{
        return nil
    }
}
