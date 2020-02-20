//
//  Detail.swift
//
//  Created by Patrick on 16/07/15.
//  Copyright (c) 2015 Laser Group. All rights reserved.
//

import UIKit
import MBProgressHUD

/// Protocol used by `KDetailViewController` to know which views have to be notified
/// when it receives `viewWillTransition(to:with:)`.
public protocol KDetailViewSizeChangesListener: NSObjectProtocol {
    func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
}

/// Protocol used by `KDetailViewController` to know which views have to be notified
/// about detail content updates.
@available(iOS 9.0, *)
public protocol KDetailViewProtocol: NSObjectProtocol {
    /// Reference to the object that has the role to present the detail, that
    /// usually is the `KDetailViewController` that has created that view.
    var detailPresenter: KDetailPresenter? { get set }
    /// The object that is displayed by the `KDetailViewController`.
    var detailObject: AnyObject? { get set }
}

/**
 `UIViewController` subclass that represent visually the content of an object,
 supporting content loading starting from an endpoint, direct content representation
 when the object is specified, or both.

 The logic of which attribute will be shown by the UI is delegate to the views;
 each subview contained into `detailSubviews` that conforms to protocol `KDetailViewProtocol`
 handles the representation of the detail object. This view controller uses the detail
 object to load the `UIBarButtonItem`s of its `navigationItem` and to set its `title`.
 
 SubClasses can't override viewDidLoad, to access and eventually modifiy the loaded view right 
 before displaying the current object subclasses need to overrider viewLoadedWillRefreshObject()
 */
open class KDetailViewController: UIViewController, UIScrollViewDelegate, KDetailPresenter {

    @IBOutlet weak var mainScrollView : UIScrollView? {
        didSet {
            mainScrollView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
            mainScrollView?.delegate = self
        }
    }
    @IBOutlet weak var mainStackView: UIStackView?
    @IBOutlet open var detailSubviews: [UIView]?
    @available(*, unavailable, message: "Integrated in detailSubviews.")
    @IBOutlet open var viewSizeListener: [UIView]?
    /// Endpoint used to load the content from Krake. This is usefull if you don't
    /// have access to the object or if you want to update the displayed object.
    open var endPoint : String?
    /// Dictionary of parameters sent to Krake during the download of the information
    /// about the detail. Now, those parameters will be sent as query.
    open var extraDictionary = KRequestParameters.parameters(currentPage: 1, pageSize: 1)
    open var analyticsExtras: [String : Any]?
    /// Object representing the detail that has to be showed.
    open var detailObject: AnyObject? = nil{
        didSet {
            didReceiveUpdatedDetail(detailObject)
        }
    }
    public var loginRequired: Bool = false
    /// The object that acts as delegate of the KDetailViewController.
    open var detailDelegate: KDetailPresenterDelegate? = KDetailPresenterDefaultDelegate()
    /// Object that handles the creation of the button used to fast scrolling to
    /// the top of the scrollview.
    var scrollToTopButton: KScrollToTopButton?
    /// Object used to populate the `rightBarButtonItems` of the view controller.
    lazy var mixedBarButton: KMixedBarButton = KMixedBarButton()

    public var sentAnalytics = false
    private var task: OMLoadDataTask?

    deinit {
        // Cancelling the current task, if any.
        if task != nil {
            task!.cancel()
            task = nil
        }
    }
    
    public convenience init(listMapOptions: KListMapOptions)
    {
        self.init()
    }
    
    open override func loadView()
    {
        if storyboard != nil
        {
            super.loadView()
        }
        else
        {
            let bundle = Bundle(url: Bundle(for: KListMapViewController.self).url(forResource: "Content", withExtension: "bundle")!)!
            bundle.loadNibNamed("KDetail", owner: self, options: nil)
        }
    }
    
    // MARK: - View controller lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        // Temporally disabling the animations.
        UIView.setAnimationsEnabled(false)
        // Applying the base theme.
        KTheme.current.applyTheme(toView: view, style: .default)
        // Adding the navigation item to close this view controller if it has
        // been presented.
        insertLeftNavigationItemToCloseModalDetail()
        // Adding the button to enable fast scroll, if scrollview is available.
        if let scrollView = mainScrollView {
            scrollToTopButton = KScrollToTopButton()
            scrollToTopButton?.generateButton(in: scrollView) { [weak self] (_, _) in
                self?.scrollToTop()
            }
        }
        viewLoadedWillRefreshObject()
        // Aggiornamento del contenuto delle subview sulla base dell'oggetto
        // ricevuto.
        refreshAllSubviews()
        // Updating the buttons of the navigationItem using the given detail
        // object.
        updateActions(for: detailObject)
        // Downloading the content from Krake, if the endpoint is available.
        if let endpoint = endPoint {
            task = OGLCoreDataMapper.sharedInstance()
                .loadData(
                    withDisplayAlias: endpoint,
                    extras: extraDictionary,
                    loginRequired: loginRequired) { [weak self] (cacheId, error, completed) in
                        guard let strongSelf = self, completed else { return }

                        if let cacheId = cacheId {
                            let cache = OGLCoreDataMapper.sharedInstance()
                                .managedObjectContext
                                .object(with: cacheId) as! DisplayPathCache

                            if cache.cacheItems.count > 0 {
                                strongSelf.detailObject = cache.cacheItems
                                    .firstObject as AnyObject?
                                strongSelf.updateActions(
                                    for: strongSelf.detailObject)
                            }
                            strongSelf.trackContentOnAnalytics()
                        }

                        if strongSelf.detailObject == nil {
                            _ = strongSelf.navigationController?
                                .popViewController(animated: true)
                        }
            }
        }
        // Enabling the animations.
        UIView.setAnimationsEnabled(true)
        detailDelegate?.viewDidLoad(self)
    }


    /// Invoked in viewDidLoad right before updating content with correct detail object
    open func viewLoadedWillRefreshObject() {

    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        detailDelegate?.viewWillAppear(self)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackContentOnAnalytics()
        detailDelegate?.viewDidAppear(self)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detailDelegate?.viewWillDisappear(self)
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Updating the content size of the scrollview.
        DispatchQueue.main.async {
            self.mainScrollView?.contentSize = CGSize(
                width: self.view.bounds.width,
                height: self.mainStackView?.bounds.height ?? 0)
        }
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Notifying the listeners about the size changes.
        detailSubviews?.forEach {
            ($0 as? KDetailViewSizeChangesListener)?.viewWillTransition(to: size, with: coordinator)
        }
    }

    // MARK: - Content update

    open func didReceiveUpdatedDetail(_ element: AnyObject?) {
        // Aggiorno il titolo del view controller.
        title = title ?? (element as? ContentItem)?.titlePartTitle
        // Aggiorno il contenuto delle view.
        if isViewLoaded {
        	refreshAllSubviews()
        }
    }

    // MARK: - Analytics

    open func trackContentOnAnalytics() {
        if let detail = detailObject as? ContentItem, !sentAnalytics {
            sentAnalytics = true
            AnalyticsCore.shared?.log(
                selectContent: String(describing: type(of: detail)),
                itemId: detail.identifier,
                itemName: detail.titlePartTitle,
                parameters: analyticsExtras)
        }
    }

    // MARK: - Scroll view delegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainScrollView {
            let scrollOffset = scrollView.contentOffset.y
            updateScrollToTopButtonVisibility(for: scrollOffset)
        }
    }

    /**
     Change the alpha of the fast scroll button based on the given scroll offset
     of the scrollview.
     
     - parameter scrollOffset: the scroll offset of the scrollview.
    */
    private func updateScrollToTopButtonVisibility(for scrollOffset: CGFloat) {
        guard let scrollToTopButton = scrollToTopButton?.scrollToTopButton else {
            return
        }
        let desiredAlpha: CGFloat = scrollOffset > 50 ? 1.0 : 0.0
        if scrollToTopButton.alpha != desiredAlpha {
            UIView.animate(withDuration: 0.25,
                           animations: {
                            scrollToTopButton.alpha = desiredAlpha
            })
        }
    }

    // MARK: - Scroll handling

    /**
     Scrolls the content of the scroll view to the top.
    */
    internal func scrollToTop(){
        mainScrollView?
            .scrollRectToVisible(CGRect(origin: .zero,
                                        size: CGSize(width: 1, height: 1)),
                                 animated: true)
    }

    // MARK: - Detail subviews notifications

    /**
     Notify all the subviews in `detailSubviews` that conform to protocol
     `KDetailViewController` that the content has changed.
    */
    open func refreshAllSubviews() {
        if let detailSubviews = detailSubviews {
            for subview in detailSubviews {
                if let detailView = subview as? KDetailViewProtocol {
                    detailView.detailPresenter = self
                    detailView.detailObject = detailObject
                }
            }
        }
    }

    /**
 	 Updates the `rightBarButtonItem` based on the given detail object.
     
      - parameter detail: The object to use to generate the new `UIBarButtonItem`.
 	*/
    open func updateActions(for detail: AnyObject?) {
        guard let detail = detail else {
            return
        }
        navigationItem.rightBarButtonItem =
            mixedBarButton.loadData(
                object: detail,
                detailDelegate: detailDelegate,
                viewController: self)
    }
    
}
