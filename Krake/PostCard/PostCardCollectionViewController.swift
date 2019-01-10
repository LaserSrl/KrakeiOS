//
//  PostCardCollectionViewController.swift
//  Krake
//
//  Created by Patrick on 28/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import UIKit

class PostCardCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    @IBOutlet weak var collection: UICollectionView!
    
    fileprivate let refreshControl = UIRefreshControl()
    
    var endPoint: String!
    var allElements: [AnyObject]!
    var ratio: CGFloat = 1.0
    var lastCache: DisplayPathCache!
    var task: OMLoadDataTask?
    //MARK: - UIView funciton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            if navigationController?.navigationBar.prefersLargeTitles == true {
                refreshControl.tintColor = KTheme.current.color(.textTint)
            }
            else
            {
                refreshControl.tintColor = .black
            }
        } else {
            refreshControl.tintColor = .black
        }
     
        refreshControl.addTarget(self, action: #selector( refreshContent ), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collection.refreshControl = refreshControl
        } else {
            collection.addSubview(refreshControl)
        }
        
        loadData()
        KTheme.current.applyTheme(toView: view, style: .default)
    }
    
    @objc func refreshContent()
    {
        if lastCache != nil {
            lastCache.date = Date(timeIntervalSince1970: 0)
            loadData()
        }else{
            refreshControl.endRefreshing()
        }
    }
    
    func loadData(){
        task = OGLCoreDataMapper.sharedInstance().loadData(withDisplayAlias: endPoint, extras: KRequestParameters.parameters(currentPage: 1, pageSize: 9999)) { (parsedObject, error, completed) -> Void in
            if parsedObject != nil {
                self.lastCache = (OGLCoreDataMapper.sharedInstance().managedObjectContext.object(with: parsedObject!) as! DisplayPathCache)
                self.allElements = self.lastCache.cacheItems.array as [AnyObject]
                self.collection.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if task != nil {
            task!.cancel()
            task = nil
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collection.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: - UICollectionView Delegate & DataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allElements != nil ? allElements.count : 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
        let image = cell.viewWithTag(100) as! UIImageView
        if let media = allElements[indexPath.row] as? PostCardProtocol{
            image.setImage(media: media.galleryMediaParts?.firstObject, options: KMediaImageLoadOptions(size: CGSize.zero, mode: .Max))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let sender = allElements[indexPath.row] as? PostCardProtocol{
            let vc = storyboard?.instantiateViewController(withIdentifier: "PostCardViewController") as! PostCardViewController
            vc.postCard = sender
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad{
                let nav = UINavigationController(rootViewController: vc)
                KTheme.current.applyTheme(toNavigationBar: nav.navigationBar, style: .default)
                nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
                let closeButton = UIBarButtonItem(barButtonSystemItem: KBarButtonSystemStyle.stop, target: self, action: #selector(PostCardCollectionViewController.dismissViewController))
                vc.navigationItem.leftBarButtonItem = closeButton
                navigationController?.present(nav, animated: true, completion: nil)
            }else{
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = (collectionView.frame.width - (5 * 3)) / 2
        width = width > 300 ? 300.0 : width
        return CGSize(width: width, height: width*ratio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
}
