//
//  ContentModificationContainer.swift
//  Krake
//
//  Created by Marco Zanino on 01/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import UIKit
import MBProgressHUD
import Segmentio

//MARK: - ContentModificationContainerViewControllerDelegate

public protocol ContentModificationContainerViewControllerDelegate: NSObjectProtocol {
    func contentModificationViewController(_ controller: ContentModificationContainerViewController, shouldBackupParams params:NSMutableDictionary?) -> Bool
    func contentModificationViewController(_ controller: ContentModificationContainerViewController, didCloseAfterSendingOfElementCompleted sentCorrectly: Bool, params : NSMutableDictionary)
    func contentModificationViewController(_ controller: ContentModificationContainerViewController, shouldCloseAfterSendingOfElementCompleted sentCorrectly: Bool) -> Bool
    func contentModificationViewController(_ controller: ContentModificationContainerViewController, taskForMedia media: UploadableMedia, atPath keyPath: String) -> URLSessionTask?
}

public extension ContentModificationContainerViewControllerDelegate{


    func contentModificationViewController(_ controller: ContentModificationContainerViewController, shouldBackupParams params:NSMutableDictionary?) -> Bool {
        return controller.aliasContentModification == nil
    }

    func contentModificationViewController(_ controller: ContentModificationContainerViewController, didCloseAfterSendingOfElementCompleted sentCorrectly: Bool, params : NSMutableDictionary){
        
    }
    
    func contentModificationViewController(_ controller: ContentModificationContainerViewController, shouldCloseAfterSendingOfElementCompleted sentCorrectly: Bool) -> Bool{
        return true
    }
    
    func contentModificationViewController(_ controller: ContentModificationContainerViewController, taskForMedia media: UploadableMedia, atPath keyPath: String) -> URLSessionTask? {
        return controller.uploadMediaContentToKrake(media, forKeyPath: keyPath)
    }
}

//MARK: - ContentModificationContainerViewController

open class ContentModificationContainerViewController : UIViewController, UIPageViewControllerDelegate, MBProgressHUDDelegate{

    //Analytics Key
    static private let EventNameNewContent = "ContentSubmitted"
    static private let EventNameUpdateContent = "ContentModified"

    static private let ContentSelectNewItem = "NewItem"
    static private let ContentSelectUpdateItem = "UpdateItem"

    static private let PropertyKeyContentType = "ContentType"

    fileprivate var uploadMediaTasks: [URLSessionTask] = [URLSessionTask]()
    open var isChanged = false{
        didSet{
            if navigationItem.rightBarButtonItem?.isEnabled != isChanged {
                navigationItem.rightBarButtonItem?.isEnabled = isChanged && (aliasContentModification == nil || originalObjectValues != nil)
                && contentTypeSelectionFields != nil
            }
        }
    }
    
    fileprivate var params: NSMutableDictionary = NSMutableDictionary()
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageControlHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var reloadDataButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!

    public var segmentioTheme : KSegmentioTheme = KTheme.segmentio
    open weak var modificationDelegate : ContentModificationContainerViewControllerDelegate?
    fileprivate var indexController : NSInteger = 0{
        didSet{
            pageControl!.currentPage = indexController
        }
    }
    fileprivate var hud: MBProgressHUD!
    fileprivate var timer : Timer!
    fileprivate var aliasContentModification: String?
    fileprivate var contentTypeDefinition: ContentTypeDefinition!
    fileprivate var contentTypeSelectionFields: [ContentTypeSelectionField]? = nil
    fileprivate var originalObjectValues: Any? = nil
    fileprivate var valuesContentType: [String : AnyObject]? = nil{
        didSet{
            if valuesContentType != nil{
                contentTypeSelectionFields = [ContentTypeSelectionField]()
                for key in valuesContentType!.keys{
                    KLog(contentTypeDefinition.contentType + " - key: " + key)
                    
                    let content = ContentTypeSelectionField(keyPath: key, object: valuesContentType![key] as! [String : AnyObject])
                    if content.settings.required {
                        var trovato = false
                        for vc in contentTypeDefinition.viewControllers{
                            for i in 0 ..< vc.fields.count {
                                if vc.fields[i].key == key && vc.fields[i].required == false{
                                    vc.fields[i].required = true
                                    trovato = true
                                    break
                                }
                            }
                            if trovato{
                                break
                            }
                        }
                    }
                    contentTypeSelectionFields?.append(content)
                }
                for vc in  self.contentTypeDefinition.viewControllers{
                    vc.contentTypeSelectionFields = contentTypeSelectionFields
                    vc.reloadAllDataFromParams()
                }

                if aliasContentModification == nil || originalObjectValues != nil {
                    blurView.hiddenAnimated = true
                }

            }else{
                contentTypeSelectionFields = nil
            }
        }
    }
    weak var pageViewController: UIPageViewController!
    @IBOutlet weak var segmented: Segmentio!

    public static func newContentModificationContainer(contentManagerType: ContentTypeDefinition, delegate: ContentModificationContainerViewControllerDelegate, aliasContentModification _aliasContentModification: String? = nil) -> ContentModificationContainerViewController
    {
        let URLBundle : URL! = Bundle(for: object_getClass(CategoryPreferencesViewController.self)!).url(forResource: "ContentManager", withExtension: "bundle")
        let bundle = Bundle(url: URLBundle)!
        let container = UIStoryboard(name: "ContentModificationContainer", bundle: bundle).instantiateInitialViewController() as! ContentModificationContainerViewController

        container.contentTypeDefinition = contentManagerType
        container.modificationDelegate = delegate
        container.aliasContentModification = _aliasContentModification

        return container

    }

    /**
     Genera l'addReportViewController per la gestione delle immagini, video e audio.
     
     - parameter mediaKeyPath:   è la path del field KRAKE sul quale salvare il media se non impostato di default è "Gallery"
     - parameter availableMedia: è l'elenco dei possibili ReportMedia uploadabili se non impostato di default comprende ReportMedia e ReportMedia
     - parameter titolo:         è il titolo dell'elemento
     - parameter maxNumberOfMedias: è il numero massimo di elementi che l'utente può inserire, di default è 0 = infinito
     - parameter watermark:      è di tipo Watermark ed è opzionale e prende in input le informazioni del watermark da applicare alla foto
     
     - returns: ritorna un UIViewController derivato da AddReportViewController
     */
    public static func mediaViewController(_ mediaKeyPath: String! = ContentManagerKeys.GALLERY,
                                           coreDataKeyPath: String? = nil,
                                           availableMedia: [ReportMedia]! = [ReportMedia.photo, ReportMedia.video, ReportMedia.audio],
                                           titolo: String! = "CHOOSE_TAKE_PHOTO".localizedString(),
                                           maxNumberOfMedias: UInt = 0,
                                           watermark: Watermark? = nil,
                                           required: Bool = false,
                                           visibleOnly: Bool = false) -> ContentModificationViewController{
        let vc = getViewController("TakePhotoOrVideo") as! TakePhotoOrVideo
        vc.fields = [FieldItemWithoutView(key: mediaKeyPath, coreDataKeyPath: coreDataKeyPath, placeholder: titolo, required: required, visibleOnly: visibleOnly)]
        vc.media = availableMedia!
        vc.title = titolo
        vc.maxNumberOfMedias = maxNumberOfMedias
        vc.watermark = watermark
        return vc
    }
    
    /**
     Genera l'addReportViewController per la gestione delle info di base (titolo, sottotitolo, descrizione e la categoria se ve ne è più di una).
     
     - returns: ritorna un UIViewController derivato da AddReportViewController
     */
    public static func infoViewController(_ titolo: String = "RELATED_FIELDS".localizedString()) -> TakeInfo{
        let vc = getViewController("TakeInfo") as! TakeInfo
        vc.title = titolo
        return vc
    }
    
    /**
     <#Description#>
     
     - parameter item:            <#item description#>
     - parameter vcNib:           <#vcNib description#>
     - parameter cellNib:         <#cellNib description#>
     - parameter selectedColor:   <#selectedColor description#>
     - parameter unselectedColor: <#unselectedColor description#>
     
     - returns: <#return value description#>
     */
    public static func categoryPreferencesViewController(fieldItem item: FieldItem,
                                                                   viewControllerNib vcNib: UINib? = nil,
                                                                                     tableViewCellNib cellNib: UINib? = nil,
                                                                                                      checkmarkSelectedColor selectedColor: UIColor? = nil,
                                                                                                                             checkmarkUnselectedColor unselectedColor: UIColor? = nil) -> CategoryPreferencesViewController{
        var vc: CategoryPreferencesViewController!
        if vcNib != nil {
            vc = (vcNib?.instantiate(withOwner: self, options: nil).first as! CategoryPreferencesViewController)
        }else{
            vc = (getViewController("CategoryPreferencesViewController") as! CategoryPreferencesViewController)
        }
        vc.setupParams(fieldItem: item, checkmarkSelectedColor: selectedColor, checkmarkUnselectedColor: unselectedColor, tableViewCellNib: cellNib)
        return vc
    }
    
    /**
     Genera l'addReportViewController per la gestione della posizione utente.
     
     - returns: ritorna un UIViewController derivato da AddReportViewController
     */
    public static func mapViewController(_ mapKeyPath: String! = ContentManagerKeys.MAPPART,
                                         coreDataKeyPath: String? = nil,
                                         titolo: String! = "LAMIAPOS".localizedString(),
                                         required: Bool = false) -> ContentModificationViewController{
        let vc = getViewController("MapInfo") as! MapInfo
        vc.title = titolo
        vc.fields = [FieldItemWithoutView(key: mapKeyPath, coreDataKeyPath: coreDataKeyPath, placeholder: titolo, required: required)]
        return vc
    }
    
    
    public static func policiesRegistrationViewController(_ mapKeyPath: String! = ContentManagerKeys.USERPOLICYPART,
                                       coreDataKeyPath: String? = nil,
                                       titolo: String! = "Policy".localizedString(),
                                       type: PolicyType = .all) -> ContentModificationViewController{
        let vc = getViewController("PoliciesRegistration") as! PoliciesRegistrationViewController
        vc.title = titolo
        vc.startLoadingData(policyType: type, policyEndPoint: mapKeyPath)
        return vc
    }
    
    fileprivate static func getViewController(_ titleVC : String) -> ContentModificationViewController?{
       
        let URLBundle : URL! = Bundle(for: object_getClass(self)!).url(forResource: "ContentManager", withExtension: "bundle")
        let bundle = Bundle(url: URLBundle)
        let nibTake = UINib(nibName: titleVC, bundle: bundle)
        let arrayVCs = nibTake.instantiate(withOwner: self, options: nil)
        if let vc = arrayVCs.first as? ContentModificationViewController {
            return vc
        }
        return nil
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }

        let viewWithHUD: UIView = navigationController?.view ?? view
        hud = MBProgressHUD(view: viewWithHUD)
        hud.delegate = self
        viewWithHUD.addSubview(hud)

        #if swift(>=4.2)
        pageViewController = (children.first as! UIPageViewController)
        #else
        pageViewController = (childViewControllers.first as! UIPageViewController)
        #endif
        pageViewController.delegate = self

        edgesForExtendedLayout = UIRectEdge()
        extendedLayoutIncludesOpaqueBars = true
        
        if aliasContentModification == nil {
            if let storedParams = restoreParams() {
                for key in storedParams.allKeys as! [NSCopying] {
                    params[key] = storedParams[key]
                }
            }
            
            if contentTypeDefinition.customParams != nil {
                for key in contentTypeDefinition.customParams!.keys{
                    params[key] = contentTypeDefinition.customParams![key]
                }
            }
        }
        params[ContentManagerKeys.CONTENT_TYPE] = contentTypeDefinition.contentType
        params[ContentManagerKeys.LANGUAGE] = KConstants.currentLanguage
        
        for vc in  contentTypeDefinition.viewControllers{
            vc.params = params
            vc.containerViewController = self
            vc.parentParentViewController = parent
        }
        if aliasContentModification == nil {
            for vc in  contentTypeDefinition.viewControllers{
                vc.reloadAllDataFromParams()
            }
        }
        KTheme.current.applyTheme(toView: view, style: .default)

        segmented.setup(
            content: contentTypeDefinition.viewControllers.map({ return SegmentioItem(title: $0.title, image: nil) }),
            style: .onlyLabel,
            options: segmentioTheme.segmentioOptions)
        segmented.valueDidChange = { [weak self] segmentio, segmentIndex in
            self?.moveToVCAtIndex(segmentIndex)
        }
        segmented.selectedSegmentioIndex = 0
        
        pageControl.addTarget(self, action: #selector(ContentModificationContainerViewController.touchOnPageControl(_:)), for: KControlEvent.touchUpInside)
        pageControl.numberOfPages = contentTypeDefinition.viewControllers.count
        pageControl.currentPage = 0
        pageControl.backgroundColor = KTheme.current.color(.alternate)
        pageControl.pageIndicatorTintColor = KTheme.current.color(.textTint).withAlphaComponent(0.5)
        pageControl.currentPageIndicatorTintColor = KTheme.current.color(.textTint)


        KTheme.current.applyTheme(toButton: reloadDataButton, style: .default)

        if contentTypeDefinition.viewControllers.count <= 1 {
            pageControlHeightConstraint.constant = 0
        }
        
        let rightToLeft = UISwipeGestureRecognizer(target: self, action: #selector(ContentModificationContainerViewController.moveNext))
        rightToLeft.direction = KSwipeGestureRecognizerDirection.left
        let leftToRight = UISwipeGestureRecognizer(target: self, action: #selector(ContentModificationContainerViewController.movePrev))
        leftToRight.direction = KSwipeGestureRecognizerDirection.right
        view.addGestureRecognizer(rightToLeft)
        view.addGestureRecognizer(leftToRight)
        
        let sendButton = UIBarButtonItem(title: "SAVE".localizedString(), style: .done, target: self, action: #selector(ContentModificationContainerViewController.sendAllContentToWS))
        sendButton.isEnabled = false
        navigationItem.rightBarButtonItem = sendButton
        
        if navigationController?.presentingViewController != nil{
            let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(ContentModificationContainerViewController.prepareToCloseViewController))
            navigationItem.leftBarButtonItem = closeButton
        }
         reloadData()
    }

    @IBAction func reloadData() {

        self.reloadDataButton.hiddenAnimated = true

        if contentTypeSelectionFields == nil {
            let manager = KNetworkManager(
                baseURL: KInfoPlist.KrakePlist.path,
                auth: false)
            manager.responseSerializer = AFJSONResponseSerializer()
            _ = manager.get(KAPIConstants.contentExtension, parameters: [ContentManagerKeys.LANGUAGE : KConstants.currentLanguage, ContentManagerKeys.CONTENT_TYPE : self.contentTypeDefinition.contentType], progress: nil, success: { [weak self](task, object) in
                if object != nil{
                    self?.valuesContentType = object as? [String : AnyObject]
                }
            }) { (task, error) in
                KLog(type: .error, error.localizedDescription)
                self.reloadDataButton.hiddenAnimated = false
            }
        }

        if aliasContentModification != nil && originalObjectValues == nil {
            hud.mode = .indeterminate
            hud.label.text = "wait".localizedString()
            hud.detailsLabel.text = "on_loading".localizedString()
            hud.show(animated: true)
            let params = KRequestParameters.parametersNoCache()
            OGLCoreDataMapper.sharedInstance().loadData(withDisplayAlias: aliasContentModification!, extras: params, loginRequired: true) { [weak self] (objectId, error, completed) -> Void in
                if let mySelf = self{
                    if completed {
                        if objectId != nil{
                            if let item = OGLCoreDataMapper.sharedInstance().displayPathCache(from: objectId!).cacheItems.firstObject
                            {
                                mySelf.originalObjectValues = item
                                for vc in  mySelf.contentTypeDefinition.viewControllers{
                                    vc.setInitialData(item as AnyObject)
                                }
                                mySelf.params["Id"] = (item as AnyObject).value(forKey: "identifier")

                                if mySelf.aliasContentModification == nil || mySelf.originalObjectValues != nil {
                                    mySelf.blurView.hiddenAnimated = true
                                }
                            }
                        }
                        
                        for vc in  mySelf.contentTypeDefinition.viewControllers{
                            vc.reloadAllDataFromParams()
                        }
                        if error != nil {
                            mySelf.reloadDataButton.hiddenAnimated = false

                            KMessageManager.showMessage(error!.localizedDescription, type: .error, fromViewController: mySelf)
                        }
                        mySelf.hud.hide(animated: true)

                    }

                }

            }
        }


    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
        
    }
    
    deinit {
        hud.removeFromSuperview()
        for task in uploadMediaTasks{
            task.cancel()
        }
        uploadMediaTasks.removeAll()
        KLog("RELEASED")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        moveToVCAtIndex(pageControl!.currentPage)
        AnalyticsCore.shared?.log(selectContent: aliasContentModification == nil ? ContentModificationContainerViewController.ContentSelectNewItem : ContentModificationContainerViewController.ContentSelectUpdateItem,
                                  itemId: nil,
                                  itemName: contentTypeDefinition.contentType,
                                  parameters:nil)
    }
    
    @objc func prepareToCloseViewController(){
        view.endEditing(true)
        if isChanged {
            let alert:UIAlertController
            if aliasContentModification == nil {
                alert = UIAlertController(title: KInfoPlist.appName, message: "Vuoi chiudere e salvare il contenuto?".localizedString(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel".localizedString(), style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Si".localizedString(), style: .default, handler: { (action: UIAlertAction) in
                    self.backupParams(self.params)
                    self.closeViewController(false, userClose: true)
                }))
                alert.addAction(UIAlertAction(title: "Non salvare".localizedString(), style: .default, handler: { (action: UIAlertAction) in
                    self.backupParams(nil)
                    self.closeViewController(false, userClose: true)
                }))
            } else {
                alert = UIAlertController(title: KInfoPlist.appName, message: "Vuoi chiudere? Perderai le tue modifiche non salvate".localizedString(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel".localizedString(), style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Esci comunque".localizedString(), style: .default, handler: { (action: UIAlertAction) in
                    self.closeViewController(false, userClose: true)
                }))
            }
            
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true, completion: nil)
            })
        }else{
            closeViewController(false, userClose: true)
        }
    }
    
    func closeViewController(_ isAdded: Bool, userClose: Bool = false){
        if aliasContentModification == nil {
            if isAdded == true {
                backupParams(nil)
                // Removing stored medias from documents directory.
                for vc in contentTypeDefinition.viewControllers where vc is TakePhotoOrVideo {
                    if let documentsFolderPath = (vc as! TakePhotoOrVideo).documentsDirectory?.absoluteString {
                        let mediasKey = vc.fields.first!.key
                        // Checking if some media is present into the current view controller.
                        if let medias = params[mediasKey] as? [Media] {
                            for media in medias where media.url != nil && (media.url?.absoluteString ?? "").contains(documentsFolderPath) {
                                (vc as! TakePhotoOrVideo).removeMedia(media.url)
                            }
                        }
                    }
                }
            }
        }
        var dismiss: Bool = true
        if !userClose{
            dismiss = modificationDelegate?.contentModificationViewController(self, shouldCloseAfterSendingOfElementCompleted: isAdded) ?? true
            if dismiss {
                modificationDelegate?.contentModificationViewController(self, didCloseAfterSendingOfElementCompleted: isAdded, params: params)
            }
        }
        if dismiss {
            hud.hide(animated: false)
            if presentingViewController != nil {
                self.dismiss(animated: true, completion: nil)
            }else{
                _ = navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func touchOnPageControl(_ pageControl : UIPageControl){
        moveToVCAtIndex(pageControl.currentPage)
    }
    
    @objc func moveNext(){
        moveToVCAtIndex(indexController+1)
    }
    
    @objc func movePrev(){
        moveToVCAtIndex(indexController-1)
    }
    
    open func moveToVCAtIndex(_ passedIndex : NSInteger){
        var index = passedIndex
        if index >= contentTypeDefinition.viewControllers.count {
            index = contentTypeDefinition.viewControllers.count-1
        }
        if index < 0 {
            index = 0
        }
        
        let vc = contentTypeDefinition.viewControllers[index]
        segmented.selectedSegmentioIndex = index
        if index >= indexController{
            pageViewController.setViewControllers([vc], direction: KPageViewControllerNavigationDirection.forward, animated: true, completion : nil)
        }else{
            pageViewController.setViewControllers([vc], direction: KPageViewControllerNavigationDirection.reverse, animated: true, completion : nil)
        }
        indexController = index
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func registerContent(){
        // Making the backup of the params before removing the map part.
        backupParamsIfRequired(params)
        params.removeObject(forKey: ContentManagerKeys.MAPPART)
        
        // Substituting each media with its identifier.
        for key in params.allKeys where key is String {
            let key = key as! String
            if let value = params[key] {
                if let media = value as? Media , media.identifier != nil {
                    params[key] = media.identifier
                } else if let medias = value as? [Media] , medias.count > 0 {
                    params[key] = medias.map { return $0.identifier! }
                }
            }
        }
        hud.showAsUploadProgress()
        let manager = KNetworkManager(baseURL: KInfoPlist.KrakePlist.path, auth: true)
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer = AFJSONRequestSerializer()
        KLog(type: .info, params.description )
        
        _ = manager.post(KAPIConstants.contentExtension,
                     parameters: params,
                     progress: nil,
                     success: { [weak self] (task, responseObject) in
                        if let mySelf = self{
                            if let response = responseObject as? [String : AnyObject],
                                let error = KrakeResponse(object: response) {
                                
                                if error.errorCode > 0 {
                                    // Some error occurred.
                                    // Loading params from NSUserDefaults to restore the map part.
                                    if let storedParams = mySelf.restoreParams() {
                                        mySelf.params = storedParams
                                    }
                                    KMessageManager.showMessage(error.message, type: .error, fromViewController: mySelf)
                                    mySelf.hud.dismissAsUploadProgress(completedWithSuccess: false)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        mySelf.navigationItem.rightBarButtonItem?.isEnabled = true
                                    }
                                } else {
                                    mySelf.hud.dismissAsUploadProgress(completedWithSuccess: true)
                                    mySelf.isChanged = false

                                    AnalyticsCore.shared?.log(event:
                                        mySelf.aliasContentModification == nil ? ContentModificationContainerViewController.EventNameNewContent : ContentModificationContainerViewController.EventNameUpdateContent,
                                                              parameters: [ContentModificationContainerViewController.PropertyKeyContentType: mySelf.contentTypeDefinition.contentType])

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        mySelf.closeViewController(true)
                                    }
                                }
                            } else {
                                mySelf.hud.mode = .customView
                                mySelf.hud.customView = UIImageView(image: UIImage(krakeNamed: "error"))
                                mySelf.hud.label.text = "Error".localizedString()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    mySelf.hud.hide(animated: true)
                                    mySelf.closeViewController(false)
                                    mySelf.navigationItem.rightBarButtonItem?.isEnabled = true
                                }
                            }
                        }
        }) { [weak self] (task, error) -> Void in
            if let mySelf = self {
                // Loading params from NSUserDefaults to restore the map part.
                if let storedParams = mySelf.restoreParams() {
                    mySelf.params = storedParams
                }
                
                mySelf.hud.mode = .customView
                mySelf.hud.label.text = "Error".localizedString()
                KMessageManager.showMessage(error.localizedDescription, type: .error, fromViewController: mySelf )
                mySelf.hud.hide(animated: true)
                mySelf.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    func sendImageOrVideoToWS(_ media : UploadableMedia, keyPath: String) -> URLSessionTask? {
        return modificationDelegate?.contentModificationViewController(self, taskForMedia: media, atPath: keyPath)
    }
    
    public final func uploadMediaContentToKrake(_ media: UploadableMedia, forKeyPath path: String) -> URLSessionTask? {
        let manager = KNetworkManager(baseURL: KInfoPlist.KrakePlist.path, auth: true)
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer = AFJSONRequestSerializer()
        var httpAdditional = manager.session.configuration.httpAdditionalHeaders ?? [AnyHashable : Any]()
        httpAdditional["Content-Type"] = "multipart/form-data"

        manager.session.configuration.httpAdditionalHeaders = httpAdditional
        let ct = params[ContentManagerKeys.CONTENT_TYPE] as! String
        let uploadTask = manager
            .post(KAPIConstants.uploadFile,
                  parameters: [ContentManagerKeys.CONTENT_TYPE : ct],
                  constructingBodyWith: { [weak media] (multipartFormData) in
                    
                    if let media = media {
                        if media.type == .image {
                            multipartFormData.appendPart(withFileData: media.content!, name: "file", fileName: "image.jpg", mimeType: "image/jpeg")
                        } else {
                            let mediaContentURL = media.url!
                            if let dataBin = try? Data(contentsOf: mediaContentURL) {
                                let fileExtension = mediaContentURL.pathExtension.lowercased()
                                let type = media.type == .video ? "video" : "audio"
                                
                                multipartFormData.appendPart(withFileData: dataBin,
                                    name: "file",
                                    fileName: "media.\(fileExtension)",
                                    mimeType: "\(type)/\(fileExtension)")
                            }
                        }
                    }
                },
                  progress: nil,
                  success: { [weak self] (dataTask, responseObject) in
                    if let mySelf = self {
                        let elem = responseObject as! NSDictionary
                        
                        if let errorCode = elem["ErrorCode"] as? NSInteger , errorCode > 0 {
                            KMessageManager.showMessage(elem["Message"] as! String, type: .error, fromViewController: mySelf)
                        } else {
                            if let mediaId = (elem["Id"] as? NSNumber)?.intValue {
                                mySelf.uploadCompletedForMedia(media, atPath: path, withIdentifier: mediaId)
                            }
                        }
                    }
            }) { [weak self] (_, error) in
                if let mySelf = self {
                    KMessageManager.showMessage(error.localizedDescription, type: .error, fromViewController: mySelf )
                }
        }
        
        return uploadTask
    }
    
    open func uploadCompletedForMedia(_ media: UploadableMedia, atPath path: String, withIdentifier id: Int) {
        if id > 0 {
            media.completed = true
            media.identifier = id
            backupParamsIfRequired(params)
        }
    }
    
    open func refreshBackupedParams() {
        backupParamsIfRequired(params)
    }
    
    @objc dynamic func progressUpdate(){
        var allTasksFinished = true
        var totExpectedToSend: Int64 = 0
        var totSent: Int64 = 0
        for task in uploadMediaTasks {
            if task.state == .running {
                allTasksFinished = false
            }
            totExpectedToSend += task.countOfBytesExpectedToSend
            totSent += task.countOfBytesSent
        }
        
        hud.progress = (Float(totSent) / Float(totExpectedToSend))
        hud.detailsLabel.text = "on_loading".localizedString() + "\n\n" + String(format:"%.2f MB / %.2f MB", Double(totSent)/1024.0/1024.0, Double(totExpectedToSend)/1024.0/1024.0)
        
        if allTasksFinished {
            var allUploadFinished = true
            for key in params.allKeys {
                if let elem = params.object(forKey: key) {
                    if let media = elem as? UploadableMedia {
                        allUploadFinished = media.completed
                        break
                    } else if let list = elem as? [UploadableMedia] {
                        if list.index(where: { return !($0.completed) }) != nil {
                            allUploadFinished = false
                            break
                        }
                    }
                }
            }
            
            if allUploadFinished {
                registerContent()
            } else {
                // Presenting an error to the user because all media tasks have finished
                // but not all medias have been correctly uploaded.
                KMessageManager.showMessage("Error", type: .error, fromViewController: self)
                navigationItem.rightBarButtonItem?.isEnabled = true
                hud.hide(animated: true)
            }
            timer.invalidate()
            timer = nil
        }
    }
    
    @objc func sendAllContentToWS(){
        navigationItem.rightBarButtonItem?.isEnabled = false
        view.endEditing(true)
        for vc in contentTypeDefinition.viewControllers {
            vc.view.endEditing(true)
        }
        
        backupParamsIfRequired(params)
        
        var error = String()
        
        var isValid = true
        for vc in contentTypeDefinition.viewControllers {
            for field in vc.fields {
                do {
                    try field.isDataValid(params: params)
                }
                catch FieldItemError.notValidData(let errorMessage)
                {
                    error.append(errorMessage as String)
                    error.append("\n")
                    isValid = false
                }
                catch{}
                
            }
        }
        
        if !isValid, !error.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = true
            KMessageManager.showMessage(error, type: .error, fromViewController : self )
        } else {
            hud.mode = .determinate
            hud.label.text = "wait".localizedString()
            hud.detailsLabel.text = "on_loading".localizedString()
            hud.show(animated: true)
            
            // Removing all tasks from the list before trying to upload new medias,
            // otherwise the displayed amount of bytes to send is wrong.
            uploadMediaTasks.removeAll()
            
            var isCompleted = true
            for vc in contentTypeDefinition.viewControllers where vc is TakePhotoOrVideo {
                let mediasKey = vc.fields.first!.key
                // Checking if some media is present into the current view controller.
                if let medias = params[mediasKey] as? NSArray {
                    for media in medias where media is UploadableMedia {
                        // Looking if the media as already been uploaded.
                        if !((media as! UploadableMedia).completed) {
                            // Trying to upload current media.
                            if let task = sendImageOrVideoToWS(media as! UploadableMedia, keyPath: mediasKey) {
                                // Upload started for the current media.
                                // Adding the task to the list to monitor its state.
                                uploadMediaTasks.append(task)
                                isCompleted = false
                            }
                        }
                    }
                }
            }
            
            if isCompleted {
                registerContent()
            } else {
                timer = Timer
                    .scheduledTimer(timeInterval: 0.3,
                                                    target: self,
                                                    selector: #selector(ContentModificationContainerViewController.progressUpdate),
                                                    userInfo: nil,
                                                    repeats: true)
            }
        }
    }
    
    // MARK: - Params backup and restore
    
    func backupParamsIfRequired(_ params: NSMutableDictionary?) {

        let backup : Bool = (modificationDelegate?.contentModificationViewController(self, shouldBackupParams: params)) ?? (aliasContentModification == nil)

        if backup {
            backupParams(params)
        }
    }

    func backupParams(_ params: NSMutableDictionary?) {
        let paramsData: Data? = params == nil ? nil : NSKeyedArchiver.archivedData(withRootObject: params!)
        UserDefaults.standard.setValue(paramsData, forKey: "ContentCreation_" + contentTypeDefinition.contentType)
        UserDefaults.standard.synchronize()
    }
    
    func restoreParams() -> NSMutableDictionary? {
        if let storedParamsData = UserDefaults.standard.value(forKey: "ContentCreation_" + contentTypeDefinition.contentType) as? Data {
            if let storedParams = NSKeyedUnarchiver.unarchiveObject(with: storedParamsData) as? NSMutableDictionary {
                // Cleaning params from medias with an invalid URL.
                var hasCleaned = false
                for (_, keyValue) in storedParams.enumerated() where keyValue.key is String {
                    if let media = keyValue.value as? Media , media.content == nil && media.url != nil {
                        if !(media.url!.resourceReachable()) {
                            storedParams.removeObject(forKey: keyValue.key)
                            hasCleaned = true
                        }
                    } else if let list = keyValue.value as? NSArray {
                        if var medias = list.copy() as? [Media] {
                            for (index, media) in medias.enumerated() where media.content == nil && media.url != nil {
                                if !(media.url!.resourceReachable()) {
                                    medias.remove(at: index)
                                }
                            }
                            // Copying the modified list into params only if changes
                            // have been made on initial values.
                            if list.count != medias.count {
                                storedParams.setValue(medias, forKey: keyValue.key as! String)
                                hasCleaned = true
                            }
                        }
                    }
                }
                // Backing-up cleaned params.
                if hasCleaned {
                    backupParams(storedParams)
                }
                
                return storedParams
            }
        }
        return nil
    }
    
}
