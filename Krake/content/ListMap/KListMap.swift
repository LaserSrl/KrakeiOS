//
//  ListaMappa.swift
//  Carlino130
//
//  Created by Patrick on 16/07/15.
//  Copyright (c) 2015 Laser Group. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import MBProgressHUD
import Segmentio
import LaserSwippableCell
import Cluster

@objc(KListMapViewController)
open class KListMapViewController : UIViewController, KExtendedMapViewDelegate
{
    //parametri
    open var listMapDelegate : KListMapDelegate!
    open var lastDisplayCache : DisplayPathCache!
    
    fileprivate var listMapOptions: KListMapOptions!
    
    fileprivate var task: OMLoadDataTask?
    fileprivate var supplementaryHeaderView: UIView? = nil
    private var isLoadingObjects = false
    public var detailDelegate: KDetailPresenterDelegate? = nil
    public var analyticsExtras: [String: Any]?
    public var extras: [String : Any]
    {
        set
        {
            listMapOptions.data.extras.update(other: newValue)
            KLog(listMapOptions.data.extras.description)
        }
        get
        {
            return listMapOptions.data.extras
        }
    }
    
    //dati
    fileprivate var currentPage: UInt = 1
    fileprivate let calendar = KCalendar()
    fileprivate var categoriesTabManager: KTabManager!
    fileprivate var elements: NSMutableOrderedSet?
    {
        didSet{
            // Applying the sort function, if needed.
            if elementsSortOrder != nil
            {
                elements?.sort(comparator: elementsSortOrder!)
            }
            if let search = searchFilterManager, let text = !search.searchOptions.onlineSearch ? search.text : nil, !text.isEmpty
            {
                filterElements(text)
            }
            else
            {
                filteredElements = elements
            }
        }
    }
    
    /// Function that will be used to sort filteredElements.
    fileprivate var elementsSortOrder: ((Any, Any) -> ComparisonResult)?
    fileprivate var filteredElements: NSOrderedSet?{
        didSet{
            refreshAllData()
        }
    }
    fileprivate var searchFilterManager: KSearchFilterManager? = nil
    fileprivate var dateFilterManager: KDateFilterManager?
    fileprivate var defaultCollectionInset: UIEdgeInsets?
    fileprivate var heightTabView: CGFloat = 44.0
    
    public let noElementCelIdentifier = "kNoElemCell"
    
    //MARK: - IBOUTLET
    
    @IBOutlet weak public fileprivate(set) var heightTopView: NSLayoutConstraint?
    @IBOutlet weak public fileprivate(set) var collectionView: UICollectionView!
    @IBOutlet weak public fileprivate(set) var topView: UIView?
    @IBOutlet weak public fileprivate(set) var headerView: UIView?
    @IBOutlet weak public fileprivate(set) var segmentedControl: Segmentio!{
        didSet{
            if listMapOptions.tabManagerOptions?.tabsEndPoint != nil && segmentedControl != nil{
                categoriesTabManager = KTabManager(segmentedControl: segmentedControl, tabManagerOptions: listMapOptions.tabManagerOptions!, delegate: self)
            }
        }
    }
    @IBOutlet weak public fileprivate(set) var searchBar: UISearchBar?
    @IBOutlet weak public fileprivate(set) var searchButton: UIButton?
    @IBOutlet weak public fileprivate(set) var mapView: KExtendedMapView?
    @IBOutlet weak public fileprivate(set) var toggleButton: UIButton?
    
    @IBOutlet weak public fileprivate(set) var toggleButtonCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak public fileprivate(set) var toggleButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak public fileprivate(set) var toggleButtonTrailingConstraint: NSLayoutConstraint!
    
    fileprivate var searchController: UISearchController?
    fileprivate let refreshControl = UIRefreshControl()

    fileprivate var clusterManager: ClusterManager? = nil
    
    @available(*, deprecated, renamed: "init(listMapOptions:)")
    public static func prepareViewController(_ endPoint: String? = nil,
                                           loginRequired: Bool = false,
                                           taxCategoryEndPoint: String? = nil,
                                           elements: NSOrderedSet? = nil,
                                           extras: [String : Any]? = nil,
                                           listMapDelegate: KListMapDelegate? = KDefaultListMapDelegate(),
                                           isMapVisible: Bool = false,
                                           useCluster: Bool = true,
                                           isSearchVisible: Bool = true,
                                           filterableKeys: [String]! = ["titlePartTitle"],
                                           onlineSearch: Bool = false,
                                           isCalendarVisible: Bool = false,
                                           stringDateFormat: String? = "dd/MM/yyyy",
                                           selectionType: KDatePickerSelectionType = .single,
                                           tabs: [TabBarItem]? = nil,
                                           tabTheme: KSegmentioTheme? = nil,
                                           tabViewHeight: CGFloat = 44.0,
                                           supplementaryHeaderView: UIView? = nil,
                                           detailDelegate: KDetailPresenterDelegate? = nil,
                                           elementsSortOrder: ((Any, Any) -> ComparisonResult)? = nil,
                                           analyticsExtras: [String: Any]? = nil) -> KListMapViewController
    {
        
        var data = KListMapData(endPoint: endPoint, loginRequired: loginRequired, elements: elements, extras: extras ?? [:])
        data.elementsSortOrder = elementsSortOrder
        var options = KListMapOptions(data: data)
        options.tabManagerOptions = KTabManagerOptions(tabsEndPoint: taxCategoryEndPoint, tabs: tabs, tabTheme: tabTheme ?? KTheme.segmentio, showAllInFirstTab: true)
        options.mapOptions = isMapVisible ? KMapOptions(useCluster: useCluster) : nil
        options.searchFilterOptions = isSearchVisible ? KSearchFilterOptions(filterableKeys: filterableKeys, onlineSearch: onlineSearch) : nil
        options.dateFilterOptions = isCalendarVisible ? KDateFilterOptions(stringDateFormat: stringDateFormat, selectionType: selectionType) : nil
        options.listMapDelegate = listMapDelegate
        options.detailDelegate = detailDelegate
        options.supplementaryHeaderView = supplementaryHeaderView
        options.analyticsExtras = analyticsExtras
        options.tabViewHeight = tabViewHeight
        return KListMapViewController(listMapOptions: options)
    }
    
    @available(*, deprecated, renamed: "init(listMapOptions:)")
    public static func prepareViewController(listMapOptions: KListMapOptions) -> KListMapViewController
    {
        return KListMapViewController(listMapOptions: listMapOptions)
    }
    
    public convenience init(listMapOptions: KListMapOptions)
    {
        self.init()
        self.listMapOptions = listMapOptions
        self.listMapDelegate = listMapOptions.listMapDelegate
        self.heightTabView = listMapOptions.tabViewHeight
        self.supplementaryHeaderView = listMapOptions.supplementaryHeaderView
        self.elements = listMapOptions.data.elements?.mutableCopy() as? NSMutableOrderedSet
        self.detailDelegate = listMapOptions.detailDelegate
        self.analyticsExtras = listMapOptions.analyticsExtras
    }
    
    open override func loadView() {
        let bundle = Bundle(url: Bundle(for: KListMapViewController.self).url(forResource: "Content", withExtension: "bundle")!)!
        bundle.loadNibNamed("KListMap", owner: self, options: nil)
    }
    
    deinit
    {
        if task != nil
        {
            task!.cancel()
            task = nil
        }
        // Releasing header view.
        supplementaryHeaderView = nil
        KLog("RELEASED")
    }
    
    /// This method add the calendar custom button item in the rightBurButtonItems.
    open func addCalendarButtonToNavigationBar() {
        let customButton = defaultCalendarButton()
        let calendarButton = UIBarButtonItem(customView: customButton)
        navigationItem.rightBarButtonItems == nil ? navigationItem.rightBarButtonItems = [calendarButton] : navigationItem.rightBarButtonItems?.append(calendarButton)
    }
    
    /// This method return the default calendar button with image on rigth and multiline text on the left side
    ///
    /// - Returns: the UIButton
    public func defaultCalendarButton() -> UIButton
    {
        let customButton = UIButton(type: .custom)
        customButton.frame = CGRect(x: 0, y: 0, width: 82, height: 44.0)
        customButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        customButton.titleLabel?.numberOfLines = 2
        customButton.titleLabel?.textAlignment = .right
        customButton.titleLabel?.minimumScaleFactor = 0.8
        customButton.titleLabel?.adjustsFontSizeToFitWidth = true
        customButton.setImage(UIImage(krakeNamed: "calendar"), for: .normal)
        
        customButton.addTarget(self, action: #selector(KListMapViewController.changeDate), for: KControlEvent.touchUpInside)
        
        customButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        customButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        customButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        customButton.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -5.0, bottom: 0.0, right: 5.0)
        KTheme.current.applyTheme(toButton: customButton, style: .calendar)
        dateFilterManager?.generateAndSaveDateTextOnButton(customButton)
        return customButton
    }
    
    open func registerNoElemCell(){
        let bundle = Bundle(url: Bundle(for: KListMapViewController.self).url(forResource: "Content", withExtension: "bundle")!)
        collectionView.register(UINib(nibName: "KNoElemCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: "kNoElemCell")
    }
    
    //MARK: - View Loading
    
    open override func viewDidLoad()
    {
        super.viewDidLoad()
        UIView.setAnimationsEnabled(false)

        mapView?.extendedDelegate = self

        if let mapOptions = listMapOptions.mapOptions, mapOptions.useCluster {
            clusterManager = ClusterManager()
        }
        
        //Sposto il pulsante di switch lista/mappa nella posizione corretta in base al settaggio in listmapoptions
        switch listMapOptions.toggleButtonPosition {
        case .bottomLeading:
            toggleButtonCenterConstraint.priority = UILayoutPriority.defaultLow
            toggleButtonTrailingConstraint.priority = UILayoutPriority.defaultLow
            toggleButtonLeadingConstraint.priority = UILayoutPriority.defaultHigh
        case .bottomCenter:
            toggleButtonLeadingConstraint.priority = UILayoutPriority.defaultLow
            toggleButtonTrailingConstraint.priority = UILayoutPriority.defaultLow
            toggleButtonCenterConstraint.priority = UILayoutPriority.defaultHigh
        case .bottomTrailing:
            toggleButtonLeadingConstraint.priority = UILayoutPriority.defaultLow
            toggleButtonCenterConstraint.priority = UILayoutPriority.defaultLow
            toggleButtonTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
        view.layoutIfNeeded()
        
        if let navBar = navigationController?.navigationBar
        {
            KTheme.current.applyTheme(toNavigationBar: navBar, style: .default)
        }
        KTheme.current.applyTheme(toView: view, style: .default)
        
        toggleButton?.setImage(UIImage(krakeNamed: "OCmap"), for: .normal)
        toggleButton?.setTitle(nil, for: KControlState.normal)
        if toggleButton != nil
        {
            KTheme.current.applyTheme(toButton: toggleButton!, style: .fabButton)
        }
        toggleButton?.layer.cornerRadius = 23
        
        if let hView = supplementaryHeaderView
        {
            hView.translatesAutoresizingMaskIntoConstraints = false
            headerView?.addSubview(hView)
            headerView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(0)-[hView]-(0)-|", options: .directionLeftToRight, metrics: nil, views: ["hView" : hView]))
            headerView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[hView]-(0)-|", options: .directionLeftToRight, metrics: nil, views: ["hView" : hView]))
            let heightConstraint = NSLayoutConstraint(item: hView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: hView.bounds.height)
            heightConstraint.priority = UILayoutPriority.priority(999)
            headerView?.addConstraint(heightConstraint)
        }
        
        
        collectionView.alwaysBounceVertical = true
        registerNoElemCell()
        listMapDelegate.registerCell(collectionView)

        //iOS 11 the refresh control could be on navigation bar, on the other cases it will be on top of the collectionView
        var refreshControlColor = UIColor.black
        if #available(iOS 11.0, *)
        {
            navigationItem.largeTitleDisplayMode = .always
            refreshControlColor = listMapOptions.searchFilterOptions != nil || (navigationController?.navigationBar.prefersLargeTitles ?? false) ? KTheme.current.color(.textTint) : .black
        }
        else
        {
            extendedLayoutIncludesOpaqueBars = true
            edgesForExtendedLayout = .left
        }
        refreshControl.tintColor = refreshControlColor
        refreshControl.addTarget(self, action: #selector( refreshContent ), for: .valueChanged)
        
        if #available(iOS 10.0, *)
        {
            collectionView.refreshControl = refreshControl
        }
        else
        {
           collectionView.addSubview(refreshControl)
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        if let searchOptions = listMapOptions.searchFilterOptions, searchOptions.isValid()
        {
            
            if #available(iOS 11.0, *)
            {
                searchController = UISearchController(searchResultsController: nil)
                searchController?.obscuresBackgroundDuringPresentation = false
                searchController?.hidesNavigationBarDuringPresentation = false
                searchFilterManager = KSearchFilterManager(searchBar: searchController?.searchBar, delegate: self, searchOptions: searchOptions)
                if let searchBar = searchController?.searchBar
                {
                    KTheme.current.applyTheme(toSearchBar: searchBar, style: .listMap)
                }
                navigationItem.searchController = searchController
            }
            else
            {
                searchButton?.backgroundColor = KTheme.current.color(.alternate)
                searchButton?.setImage(UIImage(krakeNamed: "search"), for: .normal)
                searchButton?.tintColor = KTheme.current.color(.textTint)
                searchButton?.setTitle(nil, for: KControlState.normal)
                searchFilterManager = KSearchFilterManager(searchBar: searchBar, delegate: self, searchOptions: searchOptions)
                if let searchBar = searchBar
                {
                    KTheme.current.applyTheme(toSearchBar: searchBar, style: .listMap)
                }
            }
        }
        
        if isOnLargeView() && listMapOptions.mapOptions != nil
        {
            mapView?.isHidden = false
        }
        else
        {
            mapView?.isHidden = true
        }
        
        if listMapOptions.tabManagerOptions?.tabs != nil
        {
            categoriesTabManager = KTabManager(segmentedControl: segmentedControl, tabManagerOptions: listMapOptions.tabManagerOptions!, delegate: self)
        }
        
        if let calendarOptions = listMapOptions.dateFilterOptions
        {
            dateFilterManager = KDateFilterManager(delegate: self, dateFilterOptions: calendarOptions)
            listMapDelegate.setInitialDateValues(&listMapOptions.data.extras, dateFilterManager: dateFilterManager!)
            
            addCalendarButtonToNavigationBar()
        }
        
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        {
            defaultCollectionInset = flow.sectionInset
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5)
        {
            if self.listMapOptions.mapOptions == nil
            {
                self.mapView?.delegate = nil
                self.mapView?.removeFromSuperview()
                self.collectionView?.collectionViewLayout.invalidateLayout()
            }
        }
        
        headerView?.isHidden = supplementaryHeaderView == nil
        
        topBarRefreshObject()
        
        UIView.setAnimationsEnabled(true)
        
        if categoriesTabManager != nil
        {
            categoriesTabManager!.setupInViewDidLoad(logged: listMapOptions.data.loginRequired)
        }
        else if listMapOptions.data.endPoint != nil
        {
            loadFromWS()
        }
        else
        {
            filteredElements = elements
            refreshAllData()
        }

        listMapDelegate.viewDidLoad(self)
        
    }
    
    @objc func refreshContent()
    {
        if lastDisplayCache != nil
        {
            lastDisplayCache.date = Date(timeIntervalSince1970: 0)
            loadFromWS()
            refreshControl.beginRefreshing()
        }
        else
        {
            refreshControl.endRefreshing()
            navigationController?.navigationBar.setNeedsDisplay()
            navigationController?.navigationBar.layoutIfNeeded()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            if self.listMapOptions.mapOptions == nil
            {
                self.mapView?.delegate = nil
                self.mapView?.removeFromSuperview()
                self.collectionView?.collectionViewLayout.invalidateLayout()
            }
        }
        listMapDelegate.viewWillAppear(self)
    }
    
    open override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        if title != nil
        {
            AnalyticsCore.shared?.log(itemList: title!, parameters: analyticsExtras)
        }
        refreshMainViewHierarchy()
        listMapDelegate.viewDidAppear(self)
    }
    
    open override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        listMapDelegate.viewWillDisappear(self)
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        var isMapHidden = mapView?.isHidden ?? true
        DispatchQueue.main.async {
            if self.listMapOptions.mapOptions == nil
            {
                self.mapView?.delegate = nil
                self.mapView?.removeFromSuperview()
                isMapHidden = true
            }
        }
        
        if collectionView != nil
        {
            collectionView.collectionViewLayout.invalidateLayout()
            coordinator.animate(alongsideTransition: nil) { [weak self] (_) in
                if let mySelf = self
                {
                    mySelf.refreshMainViewHierarchy()
                    
                    if mySelf.isOnLargeView()
                    {
                        mySelf.mapView?.hiddenAnimated = false
                        mySelf.collectionView?.hiddenAnimated = false
                        if let flow = mySelf.collectionView.collectionViewLayout as? UICollectionViewFlowLayout, let inset = mySelf.defaultCollectionInset
                        {
                            flow.sectionInset = inset
                        }
                    }
                    else
                    {
                        if !isMapHidden
                        {
                            mySelf.toggleListMap(nil)
                        }
                        if let flow = mySelf.collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
                            let button = mySelf.toggleButton,
                            let inset = mySelf.defaultCollectionInset ,
                            mySelf.listMapOptions.mapOptions != nil
                        {
                            flow.sectionInset = UIEdgeInsets(top: inset.top, left: inset.left, bottom: inset.bottom + button.bounds.height+24.0, right: inset.right)
                        }
                    }
                    mySelf.collectionView.reloadData()
                    mySelf.collectionView.collectionViewLayout.invalidateLayout()
                }
            }
        }
    }
    
    fileprivate func refreshMainViewHierarchy()
    {
        if !isOnLargeView() && listMapOptions.mapOptions != nil
        {
            if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, let button = toggleButton, let inset = defaultCollectionInset
            {
                flow.sectionInset = UIEdgeInsets(top: inset.top, left: inset.left, bottom: inset.bottom + button.bounds.height+24.0, right: inset.right)
            }
        }
    }
    
    // MARK: - Load data from WS
    
    open func loadFromWS()
    {
        if listMapOptions.data.endPoint != nil
        {
            MBProgressHUD.showAdded(to: view, animated: true)
            if listMapOptions.data.loginRequired
            {
                KLoginManager.shared.presentLogin(completion: { [weak self] (logged, registeredService, roles, error) -> Void in
                    if let mySelf = self
                    {
                        if logged
                        {
                            mySelf.requestObjects()
                        }
                        else
                        {
                            MBProgressHUD.hide(for: mySelf.view, animated: true)
                            mySelf.lastDisplayCache = nil
                            mySelf.elements = nil
                            if let error = error
                            {
                                KMessageManager.showMessage(error, type: .error)
                            }
                        }
                    }
                })
            }
            else
            {
                requestObjects()
            }
        }
    }
    
    func requestObjects(atPage page: UInt = 1)
    {
        currentPage = page
        var params = listMapOptions.data.extras
        params.update(other: KRequestParameters.parameters(currentPage: page, pageSize: listMapOptions.data.pageSize))
        isLoadingObjects = true
        task?.cancel()
        
        task = OGLCoreDataMapper.sharedInstance().loadData(withDisplayAlias: listMapOptions.data.endPoint!, extras: params, loginRequired: listMapOptions.data.loginRequired) { [weak self] (parsedObject, error, completed) -> Void in
            if let mySelf = self
            {
                mySelf.isLoadingObjects = false
                if parsedObject != nil
                {
                    let cache = OGLCoreDataMapper.sharedInstance().managedObjectContext.object(with: parsedObject!) as! DisplayPathCache
                    mySelf.lastDisplayCache = cache
                    mySelf.elements = cache.cacheItems.mutableCopy() as? NSMutableOrderedSet
                    if let totaleElem = cache.cacheItems?.count, let extrasParam = cache.extrasParameters, let page = extrasParam[REQUEST_PAGE_KEY] as? UInt
                    {
                        let pageSize = mySelf.listMapOptions.data.pageSize
                        if (page * pageSize) != 0 {
                            if UInt(totaleElem) < (page * pageSize) || mySelf.listMapOptions.mapOptions == nil
                            {
                                MBProgressHUD.hide(for: mySelf.view, animated: true)
                            }
                            else if UInt(totaleElem) > (page * pageSize)
                            {
                                let pag = UInt(UInt(totaleElem) / pageSize)
                                mySelf.requestObjects(atPage: pag + 1)
                            }
                            else
                            {
                                mySelf.requestObjects(atPage: page + 1)
                            }
                        }
                    }
                }
                else if completed, mySelf.lastDisplayCache == nil
                {
                    mySelf.elements = NSMutableOrderedSet()
                }

                if completed
                {
                    MBProgressHUD.hide(for: mySelf.view, animated: true)
                    mySelf.refreshControl.endRefreshing()
                    mySelf.collectionView.setContentOffset(CGPoint(x: 0, y: -0.3), animated: false)
                    //TODO: chiamare delegate per il completamento del caricamento.
                }
            }
        }
    }
    
    private func isOnLargeView() -> Bool
    {
        return (collectionView.traitCollection.verticalSizeClass == .regular ||
            collectionView.traitCollection.verticalSizeClass == .compact) &&
            traitCollection.horizontalSizeClass == .regular
    }
    
    private func topBarRefreshObject()
    {
        topView?.isHidden = false
        //Set hidden if the number of tabs on segmented control is lower or equal than 1
        segmentedControl.alpha = (categoriesTabManager?.numberOfTabs() ?? 0) <= 1 ? 0 : 1.0
        //segmentedControl.hiddenAnimated = false//
        
        if #available(iOS 11.0, *)
        {
            searchButton?.hiddenAnimated = true
            searchBar?.hiddenAnimated = true
        }
        else
        {
            if listMapOptions.searchFilterOptions?.isValid() ?? false
            {
                // Fallback on earlier versions
                searchButton?.hiddenAnimated = segmentedControl.isHidden
                searchBar?.hiddenAnimated = !segmentedControl.isHidden
            }
            else
            {
                searchButton?.hiddenAnimated = true
                searchBar?.hiddenAnimated = true
            }
        }
        let isHidden = searchButton?.isHidden ?? true && searchBar?.isHidden ?? true && segmentedControl.isHidden
        if let heightTopView = heightTopView
        {
            if isHidden
            {
                heightTopView.constant = 0
            }
            else
            {
                heightTopView.constant = heightTabView
            }
        }
        categoriesTabManager?.segmentedControl?.reloadSegmentio()
    }
    
    open func refreshAllData()
    {
        let mapIsVisible = listMapOptions.mapOptions != nil
        if filteredElements != nil
        {
            if mapView != nil && mapIsVisible
            {
                var overlays = [MKOverlay]()
                for over in mapView!.overlays
                {
                    if !(over is MKTileOverlay)
                    {
                        overlays.append(over)
                    }
                }
                
                mapView?.removeOverlays(overlays)
                
                var array = [MKAnnotation]()
                if currentPage == 1
                {
                    removeAllAnnotations()
                }
                else
                {
                    let ps = listMapOptions.data.pageSize
                    let start = (ps * (currentPage-1))
                    let end = UInt(filteredElements!.count)
                    if start < end
                    {
                        for i in start..<end
                        {
                            if let annotation = filteredElements![Int(i)] as? MKAnnotation
                            {
                                if annotation.coordinate.latitude != 0 && annotation.coordinate.longitude != 0
                                {
                                    array.append(annotation)
                                }
                            }
                        }
                    }
                    else
                    {
                        removeAllAnnotations()
                    }
                }
                if (array.count == 0 )
                {
                    for elem in filteredElements!
                    {
                        if let annotation = elem as? MKAnnotation
                        {
                            if annotation.coordinate.latitude != 0 && annotation.coordinate.longitude != 0
                            {
                                array.append(annotation)
                            }
                        }
                    }
                }
                addAnnotations(array)

            }
            reloadElementsOnCollectionView()
            collectionView?.collectionViewLayout.invalidateLayout()
        }
        else
        {
            removeAllAnnotations()
            reloadElementsOnCollectionView()
            collectionView?.collectionViewLayout.invalidateLayout()
        }
        if filteredElements == nil || filteredElements?.count == 0 || !mapIsVisible
        {
            if mapView != nil &&
                !mapView!.isHidden &&
                !isOnLargeView()
            {
                toggleListMap(toggleButton!)
            }
            toggleButton?.hiddenAnimated = true
        }
        else
        {
            toggleButton?.hiddenAnimated = false
        }
    }

    public func addAnnotations(_ annotations: [MKAnnotation]) {
        if let cluster = clusterManager {

            cluster.add(annotations)
            cluster.reload(mapView: mapView!) {
                finished in
                if finished {
                    if let mapOpt = self.listMapOptions.mapOptions
                    {
                        self.mapView!.centerMap(defaultArea: mapOpt.defaultCenterOfMap)
                    }
                }
            }
        }
        else
        {
            mapView!.addAnnotations(annotations)
            if let mapOpt = listMapOptions.mapOptions
            {
                mapView!.centerMap(defaultArea: mapOpt.defaultCenterOfMap)
            }
        }
    }

    public func removeAllAnnotations() {
        if let cluster = clusterManager {
            cluster.removeAll()
            cluster.reload(mapView: mapView!)
        }
        else if let annotations = mapView?.annotations {
            mapView?.removeAnnotations(annotations)
        }
    }

    public func removeAnnotations(_ annotations: [MKAnnotation]) {
        if let cluster = clusterManager {
            cluster.remove(annotations)
            cluster.reload(mapView: mapView!)
        }
        else {
            mapView?.removeAnnotations(annotations)
        }
    }
    
    func reloadElementsOnCollectionView()
    {
        let numberOfSection = collectionView?.numberOfSections ?? 0
        if numberOfSection > 0 && (searchFilterManager?.text ?? "").isEmpty
        {
            let numberOfCurrentElements = filteredElements?.count ?? 0
            let numberOfObjectsInCollectionView = collectionView?.numberOfItems(inSection: 0) ?? 0
            let isNoElementsCellVisible =
                numberOfObjectsInCollectionView == 1 && collectionView?.cellForItem(at: IndexPath(row: 0, section: 0))?.reuseIdentifier == noElementCelIdentifier
            let numberOfObjectsChanged = isNoElementsCellVisible && numberOfCurrentElements == 0 ? 0 : numberOfCurrentElements - numberOfObjectsInCollectionView
            
            if numberOfObjectsChanged == 0
            {
                if let items = collectionView?.indexPathsForVisibleItems, items.count > 0
                {
                    collectionView?.reloadItems(at: items)
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
                        if isNoElementsCellVisible && numberOfCurrentElements > 0
                        {
                            self.collectionView?.deleteItems(at: [IndexPath(row: 0, section: 0)])
                            self.collectionView?.insertItems(at: [IndexPath(row: 0, section: 0)])
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
                        if !isNoElementsCellVisible && numberOfCurrentElements == 0 && filteredElements == nil
                        {
                            self.collectionView?.insertItems(at: [IndexPath(row: 0, section: 0)])
                        }
                    }
                }, completion: { (finished) in
                    if let items = self.collectionView?.indexPathsForVisibleItems, finished
                    {
                        self.collectionView?.reloadItems(at: items)
                    }
                })
            }
        }
        else
        {
            self.collectionView?.reloadData()
        }
    }
    
    func filterElements(_ text: String?)
    {
        if text != nil && !text!.isEmpty
        {
            filteredElements = elements?.filtered(using: NSPredicate(block: { (elment, params) -> Bool in
                let elem = elment as AnyObject
                for key in self.listMapOptions.searchFilterOptions?.filterableKeys ?? []
                {
                    if elem.responds(to: Selector(key))
                    {
                        let value = elem.value(forKey: key)
                        if value is String{
                            if (value as! String).lowercased().contains(text!.lowercased())
                            {
                                return true
                            }
                        }
                        else
                        {
                            KLog("ERRORE - LISTAMAPPA - FILTERABLE KEYS: la chiave '\(key)' non è di tipo 'String'")
                        }
                    }
                    else
                    {
                        KLog("ERRORE - LISTAMAPPA - FILTERABLE KEYS: la chiave '\(key)' non esiste nel content type '\(NSStringFromClass(type(of: elem)))'")
                    }
                }
                
                return false
            }))
        }
        else
        {
            filteredElements = elements
        }
    }
    
    // MARK: - Other function
    
    func scrollToTop()
    {
        UIView.animate(withDuration: 0.5, animations: { [weak self] () -> Void in
            self?.collectionView.scrollRectToVisible(CGRect(x: 0,y: 0,width: 1,height: 1), animated: false)
            self?.view.layoutIfNeeded()
        })
    }
    
    @objc func openNavigatorAtIndex(_ sender : UIButton, mapView: KExtendedMapView)
    {
        listMapDelegate.didSelectNavigatorButton(filteredElements!.object(at: sender.tag) as AnyObject, mapView: mapView, fromViewController: self)
    }
    
    @objc func openShareAtIndex(_ sender : UIButton)
    {
        listMapDelegate.didSelectShareButton(filteredElements!.object(at: sender.tag) as AnyObject, sender: sender, fromViewController: self)
    }
    
    @objc func openAddToCalendarAtIndex(_ sender : UIButton)
    {
        listMapDelegate.didSelectAddToCalendarButton(filteredElements!.object(at: sender.tag) as AnyObject, fromNavigationController: navigationController!, calendar: calendar)
    }
    
    @objc func changeDate()
    {
        view.endEditing(true)
        dateFilterManager!.showDatePicker(tabBarController ?? navigationController ?? self)
    }

    @IBOutlet weak var topConstraint: NSLayoutConstraint?
    @IBOutlet weak var collectionViewTop: NSLayoutConstraint?
    public func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView.contentOffset.y < 0
        {
            topConstraint?.constant = -scrollView.contentOffset.y
            collectionViewTop?.constant = scrollView.contentOffset.y
        }
        else
        {
            topConstraint?.constant = 0
            collectionViewTop?.constant = 0
        }
        if listMapOptions.mapOptions == nil,
            let lastIndex = collectionView.indexPathsForVisibleItems.last,
            lastIndex.row == collectionView(collectionView, numberOfItemsInSection: lastIndex.section) - 1
        {
            let totaleElem = elements?.count ?? 0
            let pageSize = listMapOptions.data.pageSize
            let page = currentPage
            
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
        if let scrollDelegate = listMapDelegate as? UIScrollViewDelegate
        {
            scrollDelegate.scrollViewDidScroll?(scrollView)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        if let scrollDelegate = listMapDelegate as? UIScrollViewDelegate
        {
            scrollDelegate.scrollViewDidEndDecelerating?(scrollView)
        }
    }

    //MARK: - IBAction

    @IBAction func touchSearchButton(_ sender: UIButton)
    {
        searchBar?.becomeFirstResponder()
        self.searchBar?.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.searchButton?.isHidden = true
            self.segmentedControl.isHidden = true
        })
    }
    
    @IBAction open func toggleListMap(_ sender: UIButton?)
    {
        if !collectionView.isHidden
        {
            self.toggleButton?.setImage(UIImage(krakeNamed: "OClist"), for: .normal)
            UIView.transition(from: collectionView, to: mapView!, duration: 0.5, options: [KViewAnimationOptions.showHideTransitionViews, KViewAnimationOptions.curveEaseInOut, KViewAnimationOptions.transitionCrossDissolve], completion: nil)
            mapView?.expandedMap = true
        }
        else
        {
            self.toggleButton?.setImage(UIImage(krakeNamed: "OCmap"), for: .normal)
            
            UIView.transition(from: mapView!, to: collectionView, duration: 0.5, options: [KViewAnimationOptions.showHideTransitionViews, KViewAnimationOptions.curveEaseInOut, KViewAnimationOptions.transitionCrossDissolve], completion: nil)
        }
    }
    
    // MARK: - MKMapView delegate
    
    open func openAnnotationWithOTPViewController(_ viewController: UIViewController?)
    {
        if viewController != nil
        {
            navigationController?.pushViewController(viewController!, animated: true)
        }
    }
    
    open func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if let annotation = annotation as? ClusterAnnotation {
            if let view = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster") {
                view.annotation = annotation
                (view as? KClusterAnnotationView)?.configure()
                return view
            }
            return KClusterAnnotationView(annotation: annotation, reuseIdentifier: "cluster")
        }
        else if annotation is MKUserLocation
        {
            return nil
        }
        else {
             return listMapDelegate.viewForAnnotation(annotation, mapView: mapView as! KExtendedMapView )
        }
    }
    
    open func extendedMapView(_ mapView: KExtendedMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl, fromViewController: UIViewController) -> Bool
    {
        if control.tag == KAnnotationView.CalloutDetailButtonTag
        {
            selectObject(view.annotation!)
            return true
        }
        else
        {
            return listMapDelegate.extendedMapView(mapView, annotationView: view, calloutAccessoryControlTapped: control)
        }
    }
    
    open func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        let polylineRender = MKPolylineRenderer(overlay: overlay)
        polylineRender.lineWidth = 4.0
        polylineRender.strokeColor = UIColor.blue
        return polylineRender
    }

    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        clusterManager?.reload(mapView: mapView)
    }

    open func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }

        if let cluster = annotation as? ClusterAnnotation {
            var zoomRect = MKMapRect.null
            for annotation in cluster.annotations {
                let annotationPoint = MKMapPoint(annotation.coordinate)
                let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
                if zoomRect.isNull {
                    zoomRect = pointRect
                } else {
                    zoomRect = zoomRect.union(pointRect)
                }
            }
            mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30), animated: true)
        }
    }
    
}

//MARK: - KDateFilterManager delegate
extension KListMapViewController: KDateFilterManagerDelegate
{
    public func dateFilterManager(_ manager : KDateFilterManager, selectedDates : [Date])
    {
        listMapOptions.data.extras.update(other: [REQUEST_DATE_START : manager.serviceDateFormatter.string(from: selectedDates.first!)])
        listMapOptions.data.extras.update(other: [REQUEST_DATE_END : manager.serviceDateFormatter.string(from: selectedDates.last!)])
        loadFromWS()
    }
}

//MARK: - KSearchFilterManagerDelegate
extension KListMapViewController: KSearchFilterManagerDelegate
{
    func searchFilterDidEndEditing(_ manager: KSearchFilterManager, searchBar: UISearchBar)
    {
        if manager.searchOptions.onlineSearch
        {
            updateRemoteFilterKeysWithSearchText(searchBar.text, filterableKeys: manager.searchOptions.filterableKeys)
        }
        else
        {
            filterElements(searchBar.text)
        }
        if (searchBar.text! as NSString).length == 0  && categoriesTabManager != nil
        {
            self.topBarRefreshObject()
            searchBar.endEditing(true)
        }
    }
    
    func searchFilter(_ manager: KSearchFilterManager, textDidChange newText: String?)
    {
        
    }
    
    
    func updateRemoteFilterKeysWithSearchText(_ text: String?, filterableKeys: [String])
    {
        for key in filterableKeys
        {
            if text != nil && text!.startIndex != text!.endIndex {
                listMapOptions.data.extras[key] = text!
            }
            else {
                listMapOptions.data.extras.removeValue(forKey: key)
            }
        }
        loadFromWS()
    }
}

//MARK: - KTabManagerDelegate
extension KListMapViewController: KTabManagerDelegate
{
    open func tabManager(_ manager: KTabManager , didSelectTab term: TabBarItem )
    {
        listMapOptions.data.endPoint = term.endPoint
        listMapOptions.data.loginRequired = term.loginRequired
        if let termExtras = term.extras
        {
            listMapOptions.data.extras.update(other: termExtras)
        }
        listMapDelegate.didSelectTab(manager, fromViewController: self, object: term)
        loadFromWS()
        scrollToTop()
    }
    
    open func tabManager(_ manager: KTabManager , didSelectTermPart termPart: TermPartProtocol? )
    {
        if termPart == nil
        {
            listMapOptions.data.extras.removeValue(forKey: KParametersKeys.terms)
        }
        else
        {
            listMapOptions.data.extras[KParametersKeys.terms] = termPart!.identifier!.stringValue
        }
        listMapDelegate.didSelectTab(manager, fromViewController: self, object: termPart)
        loadFromWS()
        scrollToTop()
    }
    
    open func tabManager(_ manager: KTabManager, generatedSegmentedControl: Segmentio)
    {
        topBarRefreshObject()
        generatedSegmentedControl.isHidden = manager.numberOfTabs() <= 1
    }
    
    public func tabManager(_ manager: KTabManager, setup segmentio: Segmentio, with tabs: [SegmentioItem], and theme: KSegmentioTheme)
    {
        segmentio.setup(
            content: tabs,
            style: theme.style,
            options: theme.segmentioOptions
        )
    }
    
    public func tabManager(_ manager: KTabManager, defaultSelectedIndex tabs: [Any]) -> UInt?
    {
        return listMapDelegate.defaultSelectedIndex(tabs: tabs)
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension KListMapViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    open func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        let section = 1
        listMapDelegate.collectionView(collectionView, willShowNumberOfSections: section)
        return section
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let rowsCount = filteredElements != nil ? (filteredElements!.count > 0 ? filteredElements!.count : 1) : 0
        listMapDelegate.collectionView(collectionView, willShowNumberOfItems: rowsCount, inSection: section)
        return rowsCount
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if filteredElements == nil || filteredElements?.count == 0
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noElementCelIdentifier, for: indexPath)
            if let cell = cell as? KNoElementCell
            {
                cell.textLabel?.text = "no_elements".localizedString()
            }
            return cell
        }
        else
        {
            let object = filteredElements![(indexPath as NSIndexPath).row]
            let cell = listMapDelegate.collectionView(object as AnyObject, collectionView: collectionView, cellForItemAtIndexPath: indexPath)
            if let CADRACCell = cell as? CADRACSwippableCell
            {
                CADRACCell.allowedDirection = .right
                if CADRACCell.revealView == nil
                {
                    var arrayItems = [UIButton]()
                    let elem = filteredElements![(indexPath as NSIndexPath).row]
                    if let items = listMapDelegate.collectionView(object as AnyObject, buttonItemsAtIndexPath: indexPath)
                    {
                        arrayItems = items
                    }
                    if listMapOptions.mapOptions != nil
                    {
                        let button = UIButton(type: .system)
                        button.addTarget(self, action: #selector(KListMapViewController.openNavigatorAtIndex(_:mapView:)), for: .touchUpInside)
                        button.setImage(UIImage(krakeNamed: "OCnavigaverso")!.withRenderingMode(KImageRenderingMode.alwaysTemplate), for: .normal)
                        arrayItems.append(button)
                    }
                    if elem is ContentItemWithShareLinkPart
                    {
                        let button = UIButton(type: .system)
                        button.addTarget(self, action: #selector(KListMapViewController.openShareAtIndex(_:)), for: .touchUpInside)
                        
                        button.setImage(UIImage(krakeNamed: "share_icon")!.withRenderingMode(KImageRenderingMode.alwaysTemplate), for: .normal)
                        arrayItems.append(button)
                    }
                    if let det = elem as? ContentItemWithActivityPart , let activity = det.activityPartReference(), let _ = activity.dateTimeStart{
                        let button = UIButton(type: .system)
                        button.addTarget(self, action: #selector(KListMapViewController.openAddToCalendarAtIndex(_:)), for: .touchUpInside)
                        
                        button.setImage(UIImage(krakeNamed: "add_alarm")!.withRenderingMode(KImageRenderingMode.alwaysTemplate), for: .normal)
                        arrayItems.append(button)
                    }
                    let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: (CGFloat(arrayItems.count) * 52.0) + 8.0, height: CADRACCell.bounds.height))
                    var beforeView: UIView? = nil
                    for button in arrayItems
                    {
                        button.translatesAutoresizingMaskIntoConstraints = false
                        button.tintColor = KTheme.current.color(.textAlternate).withAlphaComponent(0.95)
                        button.layer.cornerRadius = 22.0
                        button.backgroundColor = KTheme.current.color(.alternate)
                        button.contentEdgeInsets = UIEdgeInsets(top: 5.0,left: 5.0,bottom: 5.0,right: 5.0)
                        button.tag = (indexPath as NSIndexPath).row
                        bottomView.addSubview(button)
                        bottomView.addConstraint(NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1, constant: 0))
                        bottomView.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 44))
                        bottomView.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: button, attribute: .height, multiplier: 1, constant: 0))
                        if beforeView == nil
                        {
                            bottomView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(8)-[button]", options: .directionLeftToRight, metrics: nil, views: ["button" : button]))
                        }
                        else
                        {
                            bottomView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[beforeView]-(8)-[button]", options: .directionLeftToRight, metrics: nil, views: ["beforeView" : beforeView!, "button" : button]))
                        }
                        beforeView = button
                    }
                    bottomView.backgroundColor = KTheme.current.color(.tint)
                    CADRACCell.revealView = bottomView
                }
                else
                {
                    for button in (CADRACCell.revealView as UIView).subviews
                    {
                        if button is UIButton
                        {
                            button.tag = indexPath.row
                        }
                    }
                }
            }
            return cell
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if filteredElements == nil || filteredElements?.count == 0
        {
            let width = collectionView.bounds.size.width
            let sectionInset = (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset
            let margin = sectionInset.left + sectionInset.right
            return CGSize(width: width - margin, height: 150)
        }
        else if indexPath.row < filteredElements?.count ?? 0
        {
            let object = filteredElements![indexPath.row]
            return listMapDelegate.collectionView(object as AnyObject, collectionView: collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath, mapIsVisible: listMapOptions.mapOptions != nil)
        }
        else
        {
            return CGSize.zero
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return listMapDelegate.collectionView(collectionView, layout:collectionViewLayout, referenceSizeForHeaderInSection: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    {
        return listMapDelegate.collectionView(collectionView, layout:collectionViewLayout, referenceSizeForFooterInSection: section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if filteredElements != nil && (filteredElements?.count ?? 0) > 0
        {
            selectObject(filteredElements![(indexPath as NSIndexPath).row] as AnyObject)
        }
    }
    
    func selectObject(_ object: AnyObject)
    {
        listMapDelegate.didSelect(object, fromViewController: self)
    }
    
    public func isLoginRequired() -> Bool
    {
        return listMapOptions.data.loginRequired
    }
}
