//
//  KItemsCollectionViewController.swift
//  Krake
//
//  Created by joel on 28/02/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import UIKit
import MBProgressHUD

@available(iOS 10.0, *)
/**
 * Classe per mostrare una collection view di elementi presi da Orchard.
 *
 * Alla classe è necessario passare uno dei seguenti parametri
 * - endPoint: projection da cui caricare gli elementi dal server
 * - loadedElements: elementi da mostrare senza caricamento da remoto.
 * Se nessuno dei 2 viene passato non vengono mostrati dati.
 *
 * Oltre a questo la classe necessita di un collectionItemsDelegate oppure che alcuni metodi siano implementati nella sotto classe.
 * La classe può essere usata sia tramite collectionItemsDelegate, allora tutti i metodi dei dati saranno presi dal delegate.
 * Oppure senza delegate andando a creare una sotto classe che implementi correttamente il metodo func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
 * altrimenti genera un errore.
 * La collection non implementa il metodo collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
 * per consentire di utilizzare le celle con dimensione self sizing.
 */
open class KItemsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    /**
    * endPoint di una projection da cui caricare i dati
    */
    @IBInspectable public var endPoint: String?

    /**
     * Indicazione se necessario effettuare le chaimate loggate
     */
    @IBInspectable public var loginRequired: Bool = false

    /**
    * abilitazione del pull to refresh
    */
    @IBInspectable public var enableRefreshControl: Bool = false

    /**
     * dimensione automatica delle celle
     */
    @IBInspectable public var enableCellAutosizing: Bool = false

    @IBOutlet public private(set) var emptyStateView: UIView!
    @IBOutlet weak var emptyStateLabel: UILabel?

    /**
    * extras per caricamento dei da Orcahrd
    */
    public var extras: [String : Any] = KRequestParameters.parameters(currentPage: 1, pageSize: 25)

    /**
    * Delegate per utlizzare la KItems senza sotto classe
    */
    public var collectionItemsDelegate: KItemsCollectionViewDelegate? = nil

    /**
    * Delegate passato al dettaglio dopo l'apertura
    */
    public var detailDelegate: KDetailPresenterDelegate? = nil


    /*
     * default: self.title
     */
    public var analyticsTitle: String? = nil

    /**
     * analytics aggiuntivi da inviare a Firebase
     */
    public var analyticsExtras: [String: Any]? = nil

    /**
    * elementi dei dati caricati senza passare tramite Orchard
    */
    public private(set) var loadedElements: NSOrderedSet? {
        didSet {
            // Applying the sort function, if needed.
            if elementsSortOrder != nil {
                loadedElements?.sortedArray(comparator: elementsSortOrder!)
            }

            reloadElementsOnCollectionView()

            if loadedElements != nil && isViewLoaded
            {
                emptyStateView(loadedElements?.count ?? 0 == 0)
            }
        }
    }

    /**
    * ordinamento dei dati
    * se non specificato i dati sono mostarti nell'ordine di orchard
    */
    public var elementsSortOrder: ((Any, Any) -> ComparisonResult)? {
        didSet {
            if loadedElements != nil && elementsSortOrder != nil {
                loadedElements?.sortedArray(comparator: elementsSortOrder!)
                reloadElementsOnCollectionView()
            }
        }
    }

    /**
    * testo da mostrare se non ci sono elementi
    */
    public var noElementsText: String = KLocalization.Commons.noElements {
        didSet {
            if isViewLoaded {
                emptyStateLabel?.text = noElementsText
            }
        }
    }

    var lastDisplayCache : DisplayPathCache?
    fileprivate var task: OMLoadDataTask? = nil
    public let refreshControl = UIRefreshControl()
    private var isLoadingObjects = false

    /**
    * istanzia classe di base.
     * delegate: il delegate
    */
    public static func instantiateFromDefaultXib(endPoint: String,
                                                 loginRequired: Bool = false,
                                                 delegate: KItemsCollectionViewDelegate) -> KItemsCollectionViewController
    {
        let itemsController = KItemsCollectionViewController.instantiateFromDefaultXib(delegate: delegate)
        itemsController.endPoint = endPoint
        itemsController.loginRequired = loginRequired
        return itemsController
    }

    public static func instantiateFromDefaultXib(loadedElements: NSOrderedSet,
                                                 delegate: KItemsCollectionViewDelegate) -> KItemsCollectionViewController
    {
         let itemsController = KItemsCollectionViewController.instantiateFromDefaultXib(delegate: delegate)
        itemsController.loadedElements = loadedElements
        return itemsController
    }

    private static func instantiateFromDefaultXib(delegate: KItemsCollectionViewDelegate) -> KItemsCollectionViewController
    {
        let itemsController: KItemsCollectionViewController = KItemsCollectionViewController(nibName: "KItemsCollectionViewController", bundle: Bundle(url: Bundle(for: KItemsCollectionViewController.self).url(forResource: "Content", withExtension: "bundle")!))

        itemsController.collectionItemsDelegate = delegate
        return itemsController
    }

    override open func viewDidLoad()
    {
        super.viewDidLoad()

        if let navBar = navigationController?.navigationBar {
            KTheme.current.applyTheme(toNavigationBar: navBar, style: .default)
        }
        KTheme.current.applyTheme(toView: view, style: .default)

        collectionItemsDelegate?.registerCell(self.collectionView!, from: self)

        loadEmptyView()
        emptyStateView.translatesAutoresizingMaskIntoConstraints = true
        emptyStateView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView?.addSubview(emptyStateView)
        emptyStateView.frame = self.view.bounds
        emptyStateLabel?.text = noElementsText
        emptyStateView.alpha = 0

        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout, enableCellAutosizing
        {
            layout.estimatedItemSize = CGSize(width: collectionView!.bounds.width, height: 100)
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
        }

        if enableRefreshControl
        {
            var refreshControlColor = UIColor.black
            navigationItem.largeTitleDisplayMode = .always
            refreshControlColor = (navigationController?.navigationBar.prefersLargeTitles ?? false) ? KTheme.current.color(.textTint) : .black
            refreshControl.tintColor = refreshControlColor
            refreshControl.addTarget(self, action: #selector( refreshContent ), for: .valueChanged)

            collectionView?.refreshControl = refreshControl
        }

        collectionItemsDelegate?.viewDidLoad(self)

        if endPoint != nil
        {
            loadFromWS()
        }
        else
        {
            reloadElementsOnCollectionView()
            emptyStateView(loadedElements?.count ?? 0 == 0)
        }
    }

    override open func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    open override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        collectionItemsDelegate?.viewWillAppear(self)
    }

    open override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        if let analyticsScreenName = self.analyticsTitle != nil ? self.analyticsTitle : self.title,
            !analyticsScreenName.isEmpty
        {
            AnalyticsCore.shared?.log(itemList: analyticsScreenName, parameters: analyticsExtras)
        }

        emptyStateView.frame = self.collectionView.bounds
        collectionItemsDelegate?.viewDidAppear(self)
    }

    open override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        collectionItemsDelegate?.viewDidDisappear(self)
    }

    open override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        collectionItemsDelegate?.viewWillDisappear(self)
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        collectionItemsDelegate?.itemsCollectionController(self,
                                                           viewWillTransitionTo: size,
                                                           with: coordinator)
        collectionView?.reloadData()
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    open override func responds(to aSelector: Selector!) -> Bool {
        if #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:)) == aSelector && enableCellAutosizing
        {
            return false
        }
        return super.responds(to: aSelector)
    }

    deinit
    {
        if task != nil {
            task!.cancel()
            task = nil
        }
        // Releasing header view.
        KLog("RELEASED")
    }

    // MARK: UICollectionViewDataSource

    override open func numberOfSections(in collectionView: UICollectionView) -> Int {

        let sections =  collectionItemsDelegate?.numberOfSection(in: self) ?? (loadedElements != nil ? 1 : 0)
        collectionItemsDelegate?.itemsCollectionController(self, willShowNumberSection: sections, collectionView: collectionView)

        return sections
    }

    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let items =  collectionItemsDelegate?.itemsCollectionController(self, numberOfItemsInSection: section) ?? loadedElements?.count ?? 0
        collectionItemsDelegate?.itemsCollectionController(self, willShowNumberOfItems: items, inSection: section, collectionView: collectionView)
        return items
    }

    /**
     * Do not call super if you override this method
     */
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if let delegate = collectionItemsDelegate
        {
            let item = delegate.itemsCollectionController(self, itemAt: indexPath)
            return delegate
                .itemsCollectionController(self,
                                           layout: collectionView.collectionViewLayout,
                                           collectionView: collectionView,
                                           cellForItem: item,
                                           atIndexPath: indexPath)
        }
        else
        {
            abort()
        }
    }

    // MARK: UICollectionViewDelegate

    override open func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if let collection = collectionView, let lastIndex = collection.indexPathsForVisibleItems.sorted().last
        {
            if lastIndex.section == numberOfSections(in: collection) - 1
            {
                if lastIndex.row == collectionView(collection, numberOfItemsInSection: lastIndex.section) - 1
                {
                    let totaleElem = loadedElements?.count ?? 0
                    let pageSize: UInt = (extras[REQUEST_PAGE_SIZE_KEY] as? NSNumber ?? 0).uintValue
                    let page: UInt = (extras[REQUEST_PAGE_KEY] as? NSNumber ?? 0).uintValue
                    
                    if (page * pageSize) != 0  && UInt(totaleElem) >= (page * pageSize) && !isLoadingObjects
                    {
                        
                        if UInt(totaleElem) > (page * pageSize)
                        {
                            let pag = UInt(UInt(totaleElem) / pageSize)
                            requestObjects(atPage: pag + 1)
                        }
                        else
                        {
                            requestObjects(atPage: page + 1)
                        }
                    }
                }
            }
        }

        if let scrollDelegate = collectionItemsDelegate as? UIScrollViewDelegate
        {
            scrollDelegate.scrollViewDidScroll?(scrollView)
        }
    }

    open override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let scrollDelegate = collectionItemsDelegate as? UIScrollViewDelegate {
            scrollDelegate.scrollViewDidEndDecelerating?(scrollView)
        }
    }

    open override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let delegate = collectionItemsDelegate {
            return delegate.itemsCollectionController(self,
                                                      collectionView: collectionView,
                                                      shouldSelect: delegate.itemsCollectionController(self, itemAt: indexPath),
                                                      atIndexPath: indexPath)
        }
        else {
            return true
        }
    }

    override open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if let delegate = collectionItemsDelegate
        {
            delegate.itemsCollectionController(self,
                                               collectionView: collectionView,
                                               didSelectObject: delegate.itemsCollectionController(self, itemAt: indexPath))
        }
        else
        {
            let object = loadedElements![indexPath.row]
            view.isUserInteractionEnabled = false
            if let segueVC = KDetailViewControllerFactory.factory
                .newDetailViewController(detailObject: object as AnyObject,
                                         endPoint: (object as? ContentItem)?.autoroutePartDisplayAlias,
                                         detailDelegate: self.detailDelegate,
                                         analyticsExtras: self.analyticsExtras)
            {

                if traitCollection.verticalSizeClass == .regular &&
                    traitCollection.horizontalSizeClass == .regular
                {
                    let navVC = UINavigationController(rootViewController: segueVC)
                    KTheme.current.applyTheme(toNavigationBar: navVC.navigationBar,
                                              style: .default)
                    navVC.modalPresentationStyle = .formSheet

                    present(navVC, animated: true, completion: nil)
                    segueVC.insertLeftNavigationItemToCloseModalDetail()
                }
                else
                {
                    navigationController?.pushViewController(segueVC, animated: true)
                }
            }
            view.isUserInteractionEnabled = true
        }
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if let sizeDelegate = collectionItemsDelegate
        {
            return sizeDelegate.itemsCollectionController(self,
                                                          layout: collectionViewLayout,
                                                          collectionView: collectionView,
                                                          sizeForItem: sizeDelegate.itemsCollectionController(self, itemAt: indexPath),
                                                          atIndexPath: indexPath)
        }

        return (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionItemsDelegate?.itemsCollectionController(self, collectionView: collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath) ?? super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }

    /**
     * Load empty view from the correct xib file.
     * the file must connect the emptyStateLabel IBOutlet and optionally the no elements text massage
     */

    open func loadEmptyView()
    {
        KTheme.current.loadEmptyView(for: self)
    }

    // MARK: Data loading
    @objc open func refreshContent()
    {
        if lastDisplayCache != nil
        {
            lastDisplayCache?.date = Date(timeIntervalSince1970: 0)
            loadFromWS()
            refreshControl.beginRefreshing()
        }
        else
        {
            refreshControl.endRefreshing()
        }
    }

    open func loadFromWS()
    {
        if endPoint != nil
        {
            //Non rimuovere in quanto se viene cancellato il task inserisce due progress
            MBProgressHUD.hide(for: view, animated: true)
            MBProgressHUD.showAdded(to: view, animated: true)
            if loginRequired
            {
                KLoginManager.shared.presentLogin(completion: { [weak self] (logged, registeredService, roles, error) -> Void in
                    if let mySelf = self{
                        if logged {
                            mySelf.requestObjects()
                        }else{
                            MBProgressHUD.hide(for: mySelf.view, animated: true)
                            mySelf.lastDisplayCache = nil
                            mySelf.loadedElements = nil
                            if let error = error {
                                KMessageManager.showMessage(error.localizedDescription, type: .error)
                            }
                        }
                    }
                })
            }
            else {
                requestObjects()
            }
        }
    }

    func requestObjects(atPage page: UInt = 1)
    {
        if extras.keys.contains(REQUEST_PAGE_SIZE_KEY) {
            extras[REQUEST_PAGE_KEY] = page
        }else{
            extras[REQUEST_PAGE_SIZE_KEY] = 0
            extras[REQUEST_PAGE_KEY] = 0
        }
        isLoadingObjects = true
        task?.cancel()
        task = OGLCoreDataMapper.sharedInstance().loadData(withDisplayAlias: endPoint!, extras: extras, loginRequired : loginRequired) { [weak self] (parsedObject, error, completed) -> Void in
            if let mySelf = self
            {
                if parsedObject != nil
                {
                    let cache = OGLCoreDataMapper.sharedInstance().managedObjectContext.object(with: parsedObject!) as! DisplayPathCache
                    mySelf.lastDisplayCache = cache
                    mySelf.collectionItemsDelegate?.itemsCollectionController(mySelf,
                                                                             didLoadItems: cache.cacheItems,
                                                                             loadingCompleted: completed)
                    self?.setLoadedItems(cache.cacheItems, completed: completed)
                    MBProgressHUD.hide(for: mySelf.view, animated: true)
                }
                else if completed, mySelf.lastDisplayCache == nil
                {
                    self?.setLoadedItems(NSOrderedSet(), completed: completed)
                }
                
                if completed
                {
                    mySelf.isLoadingObjects = false
                    MBProgressHUD.hide(for: mySelf.view, animated: true)
                    mySelf.refreshControl.endRefreshing()
                }
            }
        }
    }

    open func setLoadedItems(_ items: NSOrderedSet, completed: Bool)
    {
        if collectionItemsDelegate != nil {
            loadedElements = collectionItemsDelegate?.itemsCollectionController(self, willSet: items)
        }
        else {
            loadedElements = items
        }
    }

    func reloadElementsOnCollectionView()
    {
        if isViewLoaded
        {
            let currentPage = extras[REQUEST_PAGE_KEY] as? NSNumber ?? 0
            let currentNumberOfSections = collectionView?.numberOfSections ?? 0
            let datasourceNumberOfSection = numberOfSections(in: collectionView!)

            if currentNumberOfSections > 0 && datasourceNumberOfSection == 1
            {
                let numberOfCurrentElements = collectionView(collectionView!, numberOfItemsInSection: 0)
                let numberOfObjectsInCollectionView = collectionView?.numberOfItems(inSection: 0) ?? 0
                let numberOfObjectsChanged = numberOfCurrentElements - numberOfObjectsInCollectionView

                if numberOfObjectsChanged == 0 {
                    if let items = collectionView?.indexPathsForVisibleItems, items.count > 0 {
                        collectionView?.reloadItems(at: items)
                        if currentPage.uintValue <= 1, let collectionV = collectionView, collectionView(collectionV, numberOfItemsInSection: 0) > 0 {
                            collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
                        }
                    }
                    else
                    {
                        collectionView?.reloadData()
                    }
                }
                else
                {
                    collectionView?.performBatchUpdates({
                        var indexPaths = [IndexPath]()
                        if numberOfObjectsChanged > 0
                        {
                            for i in numberOfObjectsInCollectionView...(numberOfCurrentElements - 1)
                            {
                                indexPaths.append(IndexPath(row: i, section: 0))
                            }
                            self.collectionView?.insertItems(at: indexPaths)
                        }
                        else
                        {
                            for i in numberOfCurrentElements...(numberOfObjectsInCollectionView - 1)
                            {
                                indexPaths.append(IndexPath(row: i, section: 0))
                            }
                            self.collectionView?.deleteItems(at: indexPaths)
                        }
                    }, completion: { [weak self](finished) in
                        guard let mySelf = self else { return }
                        if let items = mySelf.collectionView?.indexPathsForVisibleItems, finished {
                            mySelf.collectionView?.reloadItems(at: items)
                        }
                        if currentPage.uintValue <= 1, let collectView = mySelf.collectionView, mySelf.collectionView(collectView, numberOfItemsInSection: 0) > 0 {
                            mySelf.collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
                        }
                    })
                }
            }
            else
            {
                self.collectionView?.reloadData()
            }
        }
    }

    private func emptyStateView(_ visible: Bool)
    {
        collectionItemsDelegate?.itemsCollectionController(self, willChangeEmptyViewVisibility: visible)
        UIView.animate(withDuration: 0.2) {
            self.emptyStateView.alpha = visible ? 1.0 : 0
        }
    }
}
