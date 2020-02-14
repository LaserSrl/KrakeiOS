//
//  OCTabManger.swift
//  OrchardCore
//
//  Created by joel on 09/03/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import Segmentio
import SDWebImage

public struct KTabManagerOptions
{
    /// Use .default for a default struct settings, by default
    /// - tabsEndPoint is nil
    /// - tabs is nil
    /// - tabTheme is DefaultSegmentioOptions(.onlyLabel)
    /// - showAllInFirstTab is true
    public static let `default` = KTabManagerOptions()
    
    public var tabsEndPoint: String? = nil
    public var tabs: [TabBarItem]? = nil
    public var tabTheme: KSegmentioTheme! = KTheme.segmentio
    public var showAllInFirstTab: Bool = true
    public var allTabTermId: String? = nil
    
    public init(tabsEndPoint: String? = nil,
                tabs: [TabBarItem]? = nil,
                tabTheme: KSegmentioTheme? = nil,
                showAllInFirstTab: Bool = true,
                allTabTermId: String? = nil)
    {
        self.tabsEndPoint = tabsEndPoint
        self.tabs = tabs
        if let tabTheme = tabTheme
        {
            self.tabTheme = tabTheme
        }
        self.showAllInFirstTab = showAllInFirstTab
        self.allTabTermId = allTabTermId
    }
}

public struct TabBarItem {
    public var title : String!
    public var endPoint : String!
    public var policyEndPoint : String?
    public var loginRequired : Bool = false
    public var addEnabled : Bool = false
    public var extras: [String : Any]? = nil
    public init(title : String!, endPoint : String!, extras: [String : Any]? = nil, policyEndPoint: String? = nil, isLogged : Bool = false, addEnabled : Bool = false) {
        self.title = title
        self.endPoint = endPoint
        self.policyEndPoint = policyEndPoint
        self.loginRequired = isLogged
        self.addEnabled = addEnabled
        self.extras = extras
    }
}

public protocol KTabManagerDelegate: NSObjectProtocol{
    func tabManager(_ manager: KTabManager , setup segmentio: Segmentio, with tabs: [SegmentioItem], and style: KSegmentioTheme)
    func tabManager(_ manager: KTabManager, didLoadTerms terms: [TermPartProtocol])
    func tabManager(_ manager: KTabManager , didSelectTab tab: TabBarItem )
    func tabManager(_ manager: KTabManager , defaultSelectedIndex tabs: [Any]) -> UInt?
    func tabManager(_ manager: KTabManager , didSelectTermPart termPart: TermPartProtocol? )
    func tabManager(_ manager: KTabManager , generatedSegmentedControl: Segmentio )
}

public extension KTabManagerDelegate{
    func tabManager(_ manager: KTabManager , generatedSegmentedControl: Segmentio ) {
        generatedSegmentedControl.reloadSegmentio()
       // generatedSegmentedControl.isHidden = manager.numberOfTabs() <= 1
    }
    
    func tabManager(_ manager: KTabManager , defaultSelectedIndex tabs: [Any]) -> UInt? {
        return nil
    }

    func tabManager(_ manager: KTabManager, setup segmentio: Segmentio, with tabs: [SegmentioItem], and theme: KSegmentioTheme) {
        segmentio.setup(
            content: tabs,
            style: theme.style,
            options: theme.segmentioOptions
        )
    }

    func tabManager(_ manager: KTabManager, didSelectTermPart termPart: TermPartProtocol?) {
    }

    func tabManager(_ manager: KTabManager, didSelectTab tab: TabBarItem) {
    }
    func tabManager(_ manager: KTabManager, didLoadTerms terms: [TermPartProtocol]) { }
}

open class KTabManager: NSObject{
    
    let tabManagerOptions: KTabManagerOptions
    
    var loadedCategories: [TermPartProtocol]?
    weak var delegate: KTabManagerDelegate?
    weak var segmentedControl : Segmentio?
    var currentIndex: Int = 0
    var task: OMLoadDataTask?

    public var currentTabIndex : Int
    {
        get { return segmentedControl?.selectedSegmentioIndex ?? -1 }

        set { segmentedControl?.selectedSegmentioIndex = newValue }
    }
    
    public init(segmentedControl : Segmentio? = nil, tabManagerOptions: KTabManagerOptions, delegate: KTabManagerDelegate){
        self.tabManagerOptions = tabManagerOptions
        self.segmentedControl = segmentedControl
        self.delegate = delegate
        segmentedControl?.isHidden = false
        super.init()
    }
    
    deinit {
        task?.cancel()
        task = nil
        KLog("RELEASED")
    }
    
    open func setupInViewDidLoad(logged: Bool = false){

        segmentedControl?.isHidden = false
        if tabManagerOptions.tabsEndPoint != nil {

            let extras = KRequestParameters.parametersToLoadCategorySubTerms()

            task = OGLCoreDataMapper.sharedInstance().loadData(withDisplayAlias: tabManagerOptions.tabsEndPoint!, extras: extras, loginRequired: logged) { [weak self](parsedObject , error, completed) -> Void in
                guard let mySelf = self else {return}
                if parsedObject != nil
                {
                    let cache = OGLCoreDataMapper.sharedInstance().managedObjectContext.object(with: parsedObject!) as! DisplayPathCache
                    var tmpTerms: NSOrderedSet? = nil
                    if cache.cacheItems!.array.first is TaxonomyProtocol {
                        tmpTerms = (cache.cacheItems!.array.first as! TaxonomyProtocol).taxonomyPartTerms
                    }else if cache.cacheItems!.array.first is TermPartProtocol{
                        tmpTerms = cache.cacheItems!
                    }
                    mySelf.loadedCategories = [TermPartProtocol]()
                    if let term =  tmpTerms?.firstObject as? TermPartProtocol, let path = term.fullPath {
                        let termLevel = path.components(separatedBy:"/").count
                        for termine in tmpTerms!{
                            if let term = termine as? TermPartProtocol {
                                if term.fullPath!.components(separatedBy:"/").count == termLevel{
                                    mySelf.loadedCategories!.append(term)
                                }
                            }
                        }
                    }
                }
                if completed == true {

                    mySelf.delegate?.tabManager(mySelf, didLoadTerms: mySelf.loadedCategories ?? [])

                    if mySelf.loadedCategories?.count ?? 0 > 1 {

                        var arrayTitles = [SegmentioItem]()
                        if mySelf.tabManagerOptions.showAllInFirstTab {
                            arrayTitles.append(SegmentioItem(title: "Tutti".localizedString(), image: UIImage(named:"termicon_all")?.withRenderingMode(.alwaysTemplate) ?? UIImage(krakeNamed:"termicon_all")?.withRenderingMode(.alwaysTemplate)))
                        }
                        for elem in mySelf.loadedCategories! {
                            var image : UIImage? = nil
                            if mySelf.tabManagerOptions.tabTheme?.style.isWithImage() ?? false{
                                if let media = elem.iconMediaParts?.firstObject as? MediaPartProtocol
                                {
                                    let termIconIdentifier = "termicon_" + (media.identifier ?? 0).stringValue
                                    image = SDImageCache.shared.imageFromDiskCache(forKey: termIconIdentifier)
                                    if image == nil{
                                        image = UIImage(named: termIconIdentifier)
                                        if let url = KMediaImageLoader.generateURL(forMediaPath: (media.identifier ?? 0).stringValue, mediaImageOptions: KMediaImageLoadOptions(size: CGSize(width: 2000, height: 2000),mode: ImageResizeMode.Pan))
                                        {
                                            KTermPinImageDownloader.sharedDownloader.startImageDownload(url, identifier: termIconIdentifier)
                                        }
                                    }
                                }
                            }
                            arrayTitles.append(SegmentioItem(title: elem.name!, image: image?.withRenderingMode(.alwaysTemplate)))
                        }
                        mySelf.uploadDataInSegmentedControl(arrayTitles)
                    }else{
                        mySelf.segmentedControl?.isHidden = true
                        mySelf.delegate?.tabManager(mySelf, didSelectTermPart: nil)
                    }
                }
            }
        }
        else
        {
            var arrayTitles = [SegmentioItem]()
            for elem in tabManagerOptions.tabs! {
                arrayTitles.append(SegmentioItem(title: elem.title, image: nil))
            }
            uploadDataInSegmentedControl(arrayTitles)
        }
    }
    
    /// Method return the number of elements on Segmented Control with or without the first tab.
    ///
    /// - Parameter includeTabAllIfVisible: if true include the "All" first tab. Default is false
    /// - Returns: the number of elements
    public func numberOfTabs(includeTabAllIfVisible: Bool = false) -> Int
    {
        if let tabs = tabManagerOptions.tabs
        {
            return tabs.count
        }
        let numberOfTabsOnSegmentio = segmentedControl?.segmentioItems.count ?? 0
        if !includeTabAllIfVisible && tabManagerOptions.showAllInFirstTab && numberOfTabsOnSegmentio > 0
        {
            return numberOfTabsOnSegmentio - 1
        }
        return numberOfTabsOnSegmentio
    }
    
    func uploadDataInSegmentedControl(_ tabs: [SegmentioItem])
    {
        if let segmentedControl = segmentedControl{
            delegate?.tabManager(self, setup: segmentedControl, with: tabs, and: tabManagerOptions.tabTheme)
            segmentedControl.valueDidChange = { segmentio, segmentIndex in
                if self.loadedCategories != nil
                {
                    self.currentIndex = segmentIndex
                    if segmentIndex == 0 && self.tabManagerOptions.showAllInFirstTab{
                        self.delegate?.tabManager(self, didSelectTermPart: nil)
                    }
                    else {
                        let selectedIndex: Int
                        if self.tabManagerOptions.showAllInFirstTab {
                            selectedIndex = segmentIndex-1
                        }else {
                            selectedIndex = segmentIndex
                        }
                        self.delegate?.tabManager(self, didSelectTermPart: self.loadedCategories![selectedIndex])
                    }
                }
                else
                {
                    let newTabBar = self.tabManagerOptions.tabs![segmentIndex]
                    if !newTabBar.loginRequired {
                        self.currentIndex = segmentIndex
                        self.delegate?.tabManager(self, didSelectTab: newTabBar)
                    }
                    else {
                        self.currentIndex = segmentIndex
                        self.delegate?.tabManager(self, didSelectTab: newTabBar)
                    }
                }
            }
            DispatchQueue.main.async {
                segmentedControl.selectedSegmentioIndex = 0
                if let tabs: [Any] = self.loadedCategories != nil ? self.loadedCategories : self.tabManagerOptions.tabs{
                    if let selectedIndex = self.delegate?.tabManager(self, defaultSelectedIndex: tabs){
                        if self.tabManagerOptions.showAllInFirstTab {
                            segmentedControl.selectedSegmentioIndex = Int(selectedIndex) + 1
                        }else{
                            segmentedControl.selectedSegmentioIndex = Int(selectedIndex)
                        }
                    }
                }
            }
            self.delegate?.tabManager(self, generatedSegmentedControl: segmentedControl)
        }
    }
}

