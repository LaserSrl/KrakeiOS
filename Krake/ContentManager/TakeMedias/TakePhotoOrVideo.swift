
//
//  TakePhotoOrVideo.swift
//  CitizenDemo
//
//  Created by Patrick on 09/07/15.
//  Copyright (c) 2015 Laser Group. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import FDTake
import IQAudioRecorderController

public enum ReportMedia: Int {
    case photo = 0
    case video // 1
    case audio // 2
}

public enum MediaType: NSNumber {
    case image, audio, video
}

open class UploadableMedia: Media {
    open var completed: Bool = false
    
    override public init(content: Data? = nil, url: URL? = nil, type: MediaType) {
        super.init(content: content, url: url, type: type)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        completed = aDecoder.decodeBool(forKey: "completed")
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(completed, forKey: "completed")
    }
    
    open override var description: String {
        let baseDescription = generateDescription()
        return baseDescription
            .replacingOccurrences(of: "}",
                                  with: "\t" + "Completed: \(completed)" + "\n" + "}")
    }
    
}

public struct Watermark {
    var image: AnyObject!
    var position: WatermarkPosition
    var fill: AspectToFill
    
    /**
     Inizializzazoine del Watermark
     
     - parameter image:    immagine / url / MediaPartID dell'immagine che si vuole utilizzare come watermark
     - parameter position: la posizione rispetto all'immagine scelta
     - parameter fill:   AspectToFill se si vuole adattare il watermark alla larghezza o all'altezza dell'immagine
     
     - returns: struttura Watermark
     */
    public init(image _image: AnyObject!, position _position: WatermarkPosition = .topLeft, fill _fill: AspectToFill = .none) {
        image = _image
        position = _position
        fill = _fill
    }
}

open class Media: NSObject, NSCoding {
    open var identifier: Int?
    open var url: URL?
    open var content: Data?
    public let type: MediaType
    
    public init(content: Data? = nil, url: URL? = nil, type: MediaType) {
        self.content = content
        self.url = url
        self.type = type
    }
    
    required public init(coder aDecoder: NSCoder) {
        identifier = aDecoder.decodeInteger(forKey: "id")
        url = aDecoder.decodeObject(forKey: "url") as? URL
        content = aDecoder.decodeObject(forKey: "content") as? Data
        type = MediaType(rawValue: aDecoder.decodeInteger(forKey: "type") as NSNumber)!
    }
    
    open func encode(with aCoder: NSCoder) {
        if identifier != nil {
            aCoder.encode(identifier!, forKey: "id")
        }
        if url != nil {
            aCoder.encode(url!, forKey: "url")
        }
        if content != nil {
            aCoder.encode(content!, forKey: "content")
        }
        aCoder.encode(type.rawValue.intValue, forKey: "type")
    }
    
    func generateDescription() -> String {
        return "{" + "\n" +
            "\t" + "Identifier: \(identifier ??? "nil")" + "\n" +
            "\t" + "Local path: \(url ??? "nil")" + "\n" +
            "\t" + "Type: \(type == .image ? "Image" : type == .video ? "Video" : "Audio")" + "\n" +
        "}"
    }
    
    open override var description: String {
        return generateDescription()
    }
    
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    fileprivate var imageView: UIImageView!
    fileprivate var button: UIButton!
    fileprivate var mainCompletion: ((NSInteger) -> Void)?
    fileprivate var namedPlaceholder = KTheme.current.placeholder(.photo)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView.image = namedPlaceholder
        imageView.contentMode = .scaleAspectFit
        for view in contentView.subviews{
            view.removeFromSuperview()
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(0)-[imageView]-(0)-|", options: .directionLeftToRight, metrics: nil, views: ["imageView": imageView!]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[imageView]-(0)-|", options: .directionLeftToRight, metrics: nil, views: ["imageView": imageView!]))
        
        button = UIButton(type: .system)
        button.setImage(KAssets.Images.delete.image, for: .normal)
        KTheme.current.applyTheme(toButton: button, style: .fabButton)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(ImageCollectionViewCell.deleteButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        contentView.addSubview(button)
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[button(40)]-(4)-|", options: .directionLeftToRight, metrics: nil, views: ["button": button!]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(4)-[button(40)]", options: .directionLeftToRight, metrics: nil, views: ["button": button!]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(_ image: UIImage?, completion: ((NSInteger) -> Void)?) {
        imageView.image = image
        button.isHidden = false
        mainCompletion = completion
    }
    
    func restoreCell() {
        imageView.image = namedPlaceholder
        button.isHidden = true
    }
    
    @objc func deleteButton() {
        mainCompletion!(((superview! as! UICollectionView).indexPath(for: self)! as NSIndexPath).row)
    }
}

class TakePhotoOrVideo : ContentModificationViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, IQAudioRecorderViewControllerDelegate{
    
    fileprivate lazy var fileCopyQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.name = "com.krake.contentManager.MediaCopy"
        return queue
    }()
    
    var fdTakeController: FDTakeController!
    @IBOutlet weak var imagesCollectionView : UICollectionView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var titleLabel: UILabel!
    
    fileprivate var namedPlaceholder = KTheme.current.placeholder(.default){
        didSet{
            imagesCollectionView.reloadData()
        }
    }
    var takePhotoButton: UIBarButtonItem!
    var takeAudioButton: UIBarButtonItem!
    var takeVideoButton: UIBarButtonItem!
    
    lazy var documentsDirectory: URL? = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }()
    
    var audioRec: IQAudioRecorderViewController?
    var media : [ReportMedia]!{
        didSet{
            var array = [UIBarButtonItem]()
            array.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            if media.contains(ReportMedia.photo) == true{
                takePhotoButton = UIBarButtonItem(image: KAssets.Images.icCamera.image, style: .plain, target: self, action: #selector(TakePhotoOrVideo.takePhoto(_:event:)))
                takePhotoButton.isEnabled = !(fields.first?.visibleOnly ?? false)
                array.append(takePhotoButton)
                array.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            }
            if media.contains(ReportMedia.video) == true{
                takeVideoButton = UIBarButtonItem(image: KAssets.Images.icVideocam.image, style: .plain, target: self, action: #selector(TakePhotoOrVideo.takeVideo(_:event:)))
                takeVideoButton.isEnabled = !(fields.first?.visibleOnly ?? false)
                array.append(takeVideoButton)
                array.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            }
            if media.contains(ReportMedia.audio) == true{
                takeAudioButton = UIBarButtonItem(image: KAssets.Images.icMic.image, style: .plain, target: self, action: #selector(TakePhotoOrVideo.takeAudio(_:)))
                takeAudioButton.isEnabled = !(fields.first?.visibleOnly ?? false)
                array.append(takeAudioButton)
                array.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            }
            switch media.first! {
            case ReportMedia.video:
                namedPlaceholder = KTheme.current.placeholder(.video)
                break
            case ReportMedia.audio:
                namedPlaceholder = KTheme.current.placeholder(.audio)
                break
            default:
                break
            }
            toolbar.items = array
            toolbar.barTintColor = KTheme.current.color(.tint)
            toolbar.tintColor = KTheme.current.color(.textTint)
        }
    }
    var watermark: Watermark?{
        didSet{
            if watermark != nil {
                if watermark!.image is UIImage{
                    watermarkImage = watermark!.image as? UIImage
                }else{
                    let imageView = UIImageView()
                    imageView.setImage(media: watermark!.image, placeholderImage: nil, options: KMediaImageLoadOptions(size: CGSize(width: 3000, height: 3000), mode: .Pan), completed: { (image, error, cache, url) -> Void in
                        self.watermarkImage = image
                    })
                }
                media = [.photo]
            }
        }
    }
    fileprivate var watermarkImage: UIImage? = nil
    override var title: String?{
        didSet{
            titleLabel.text = title
        }
    }
    
    var maxNumberOfMedias: UInt!
    
    fileprivate var medias: [Media] = [] {
        didSet{
            if fields != nil && params != nil {
                params[fields.first!.key] = medias
                containerViewController.isChanged = true
            }
            imagesCollectionView.reloadData()
            imagesCollectionView.layoutIfNeeded()
            imagesCollectionView.scrollRectToVisible(CGRect(x: 0, y: imagesCollectionView.contentSize.height-10, width: 1, height: imagesCollectionView.frame.height), animated: true)
        }
    }
    
    deinit{
        KLog("RELEASED")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagesCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        (imagesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        imagesCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        (imagesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 10
        (imagesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = 10
        
        toolbar.barTintColor = KTheme.current.color(.tint)
        toolbar.tintColor = KTheme.current.color(.textTint)
        
        titleLabel.backgroundColor = KTheme.current.color(.tint)
        titleLabel.textColor = KTheme.current.color(.textTint)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        imagesCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func reloadAllDataFromParams() {
        guard let storedMedias = params[fields.first!.key] as? Array<Media> else {
            return
        }
        medias = storedMedias
        imagesCollectionView.reloadData()
    }
    
    override func setInitialData(_ item: AnyObject) {
        if let coreDataKeyPath = fields.first!.coreDataKeyPath, let value = item.value(forKeyPath: coreDataKeyPath){
            if let orderedSet = value as? NSOrderedSet, let array = orderedSet.array as? [MediaPartProtocol]{
                var immagini = [Media]()
                for elem in array{
                    let media = Media(content: nil, url: nil , type: .image)
                    media.identifier = (elem.identifier ?? 0).intValue
                    immagini.append(media)
                }
                params[fields.first!.key] = immagini
            }
        }
    }
    
    func isAvailableUpload() -> Bool {
        if maxNumberOfMedias == 0 {
            return true
        } else {
            if medias.count < Int(maxNumberOfMedias) {
                return true
            } else {
                KMessageManager.showMessage(KLocalization.ContentModification.mediaMaxNumberOfElem, type: .error, fromViewController: parentParentViewController)
                return false
            }
        }
    }
    
    fileprivate func resetFDTakeController (_ isVideo: Bool) -> Void {
        fdTakeController = FDTakeController()
        fdTakeController.allowsPhoto = !isVideo
        fdTakeController.allowsVideo = isVideo
        fdTakeController.allowsTake = true
        fdTakeController.allowsSelectFromLibrary = true
        fdTakeController.allowsEditing = true
        fdTakeController.defaultsToFrontCamera = false
        fdTakeController.iPadUsesFullScreenCamera = true
        fdTakeController.presentingView = view
        fdTakeController.didDeny = {
            
        }
        fdTakeController.didCancel = {
            
        }
        fdTakeController.didFail = {
            
        }
        fdTakeController.didGetPhoto = { (photo, info) in
            
            var photoUpdated = photo
            if let watermark = self.watermarkImage {
                photoUpdated = photo.addWatermark(watermark, fill: self.watermark!.fill, position: self.watermark!.position)
            }
            let dataBin = photoUpdated.resizeImage(2000).jpegData(compressionQuality: 0.5)
            if let dataBin = dataBin{
                self.medias.append(UploadableMedia(content: dataBin, url: info[UIImagePickerController.InfoKey.imageURL] as? URL, type: .image))
            }
        }
        
        fdTakeController.didGetVideo = { (videoURL, infos) in
            // Copying the file to a session-safe location.
            do {
                if let videosDirectory = self.documentsDirectory?.appendingPathComponent("Videos") {
                    try self.copyMedia(videoURL, intoFolder: videosDirectory) { [weak self] (newFilePath, error) in
                        if let strongSelf = self {
                            if error != nil {
                                // An error has occurred while copying the file to
                                // the new location.
                                // Presenting the alert with info to the user.
                                
                                KMessageManager.showMessage("Errore in apertura del video, selezionarne un altro.",
                                                            type: .error,
                                                            fromViewController: strongSelf.parentParentViewController)
                            } else {
                                strongSelf.medias.append(UploadableMedia(url: newFilePath, type: .video))
                            }
                        }
                    }
                }
            } catch {
                // Presenting an alert with the error description.
                // This should never appen.
                KMessageManager.showMessage("Errore in apertura del video, selezionarne un altro.",
                                            type: .error,
                                            fromViewController: self.parentParentViewController)
            }
        }
    }
    
    @IBAction func takeVideo(_ sender: UIBarButtonItem, event: UIEvent) {
        if isAvailableUpload(){
            resetFDTakeController(true)
            if let buttonView = sender.value(forKey: "view") as? UIView{
                let rect = CGRect(x: buttonView.frame.origin.x + toolbar.frame.origin.x, y: buttonView.frame.origin.y + toolbar.frame.origin.y, width: buttonView.frame.width, height: buttonView.frame.height)
                fdTakeController.presentingRect = rect
            }
            fdTakeController.presentingBarButtonItem = sender
            fdTakeController.present()
        }
    }
    
    @IBAction func takePhoto(_ sender: UIBarButtonItem, event: UIEvent) {
        if isAvailableUpload(){
            resetFDTakeController(false)
            if let buttonView = sender.value(forKey: "view") as? UIView{
                let rect = CGRect(x: buttonView.frame.origin.x + toolbar.frame.origin.x, y: buttonView.frame.origin.y + toolbar.frame.origin.y, width: buttonView.frame.width, height: buttonView.frame.height)
                fdTakeController.presentingRect = rect
            }
            fdTakeController.presentingBarButtonItem = sender
            fdTakeController.present()
        }
    }
    
    @IBAction func takeAudio(_ sender: UIBarButtonItem) {
        if isAvailableUpload(){
            audioRec = IQAudioRecorderViewController()
            audioRec!.barStyle = .black
            audioRec!.delegate = self
            presentBlurredAudioRecorderViewControllerAnimated(audioRec!)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return medias.count > 0 ? medias.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
        cell.namedPlaceholder = namedPlaceholder
        
        if medias.count > 0 {
            let removeMediaCompletionHandler: ((NSInteger) -> Void) = { (index) in
                self.imagesCollectionView.performBatchUpdates({
                    let removedMedia = self.medias.remove(at: index)
                    // Deleting the file from file system.
                    self.removeMedia(removedMedia.url)
                    
                    if self.medias.count > 0 {
                        self.imagesCollectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                    }else{
                        self.imagesCollectionView.reloadItems(at: [IndexPath(row: 0, section: 0)])
                    }
                }, completion: nil)
            }
            
            let media = medias[(indexPath as NSIndexPath).row]
            switch media.type {
            case .video, .audio:
                let named = media.type == .audio ? KTheme.current.placeholder(.audio) : KTheme.current.placeholder(.video)
                cell.configureCell(named, completion: removeMediaCompletionHandler)
                cell.backgroundColor = UIColor ( red: 0.8691, green: 0.8691, blue: 0.8691, alpha: 1.0 )
                cell.imageView.tintColor = UIColor.darkGray
            case .image:
                if let mediaContent = media.content {
                    let image = UIImage(data: mediaContent)
                    cell.configureCell(image, completion: removeMediaCompletionHandler)
                    cell.backgroundColor = UIColor.clear
                } else if let mediaIdentifier = media.identifier {
                    cell.configureCell(nil, completion: removeMediaCompletionHandler)
                    cell.imageView.setImage(media: mediaIdentifier)
                    cell.backgroundColor = UIColor.clear
                }
            }
            cell.button.isEnabled = !(fields.first?.visibleOnly ?? false)
        } else {
            cell.backgroundColor = UIColor ( red: 0.8691, green: 0.8691, blue: 0.8691, alpha: 1.0 )
            cell.imageView.tintColor = UIColor.darkGray
            cell.restoreCell()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if medias.count > 0 {
            let rightMedias = NSOrderedSet(array:
                medias
                    .filter { media in
                        if media.type == MediaType.image{
                            return (media.content != nil)
                        }else{
                            return (media.url != nil)
                        }
                    }
                    .map { media in
                        if media.type == MediaType.image{
                            return media.content!
                        }else{
                            return media.url!
                        }
            })
            navigationController!.present(galleryController: rightMedias.array,
                                          selectedIndex: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if medias.count == 0{
            return CGSize(width: imagesCollectionView.frame.width-20, height: imagesCollectionView.frame.height-40)
        }
        return CGSize(width: collectionView.frame.width-20, height: (collectionView.frame.width-20) * (2/3))
    }
    
    //MARK: - Audio Recorder Delegate
    
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        if let audioURL = URL(string: "file://" + filePath) {
            // Copying the file to a session-safe location.
            do {
                if let audiosDirectory = self.documentsDirectory?.appendingPathComponent("Audios") {
                    try self.copyMedia(audioURL, intoFolder: audiosDirectory) { [weak self] (newFilePath, error) in
                        if let strongSelf = self {
                            if error != nil {
                                // An error has occurred while copying the file to
                                // the new location.
                                // Presenting the alert with info to the user.
                                KMessageManager.showMessage("Errore in apertura dell'audio, selezionarne un altro.",
                                                            type: .error,
                                                            fromViewController: strongSelf.parentParentViewController)
                            } else {
                                strongSelf.medias.append(UploadableMedia(url: newFilePath, type: .audio))
                            }
                        }
                    }
                }
            } catch _ as NSError {
                // Presenting an alert with the error description.
                // This should never appen.
                KMessageManager.showMessage("Errore in apertura dell'audio, selezionarne un altro.",
                                            type: .error,
                                            fromViewController: parentParentViewController)
            }
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - File managing
    
    func copyMedia(_ mediaUrl: URL, intoFolder folder: URL, withCompletion completion: @escaping ((URL?, NSError?) -> Void)) throws {
        let mediaName = mediaUrl.lastPathComponent
        fileCopyQueue.addOperation {
            if let mediaContent = try? Data(contentsOf: mediaUrl) {
                let fileManager = FileManager.default
                // Checking if the directory for the current media exists.
                if !(fileManager.fileExists(atPath: folder.absoluteString)) {
                    // The directory does not exist, creating it.
                    do {
                        try fileManager.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
                    } catch let error as NSError {
                        OperationQueue.main.addOperation {
                            completion(nil, error)
                        }
                    }
                }
                
                do {
                    // Creating the file.
                    let filePath = folder.appendingPathComponent(mediaName)
                    // Copying the old file content into the new file.
                    if (try? mediaContent.write(to: filePath, options: [])) != nil {
                        // Excluding the path from backup.
                        try (filePath as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
                        // Deleting the old file.
                        do {
                            try fileManager.removeItem(at: mediaUrl)
                        } catch {
                            // Ignoring error from deletion of the old file
                            // because this file will be deleted at the next
                            // restart of the app.
                        }
                    }
                    
                    OperationQueue.main.addOperation {
                        completion(filePath, nil)
                    }
                } catch let error as NSError {
                    OperationQueue.main.addOperation {
                        completion(nil, error)
                    }
                }
            } else {
                // Cannot read the content of the file, returning the appropriate error.
                let openFileError = NSError(domain: NSURLErrorDomain,
                                            code: URLError.cannotOpenFile.rawValue,
                                            userInfo: [kCFErrorDescriptionKey as String : "The file at \(mediaUrl) cannot be used."])
                
                OperationQueue.main.addOperation {
                    completion(nil, openFileError)
                }
            }
        }
    }
    
    func removeMedia(_ mediaUrl: URL?) {
        guard let mediaUrl = mediaUrl else {
            return
        }
        
        fileCopyQueue.addOperation {
            do {
                let fileManager = FileManager.default
                if mediaUrl.resourceReachable() {
                    try fileManager.removeItem(at: mediaUrl)
                }
            } catch let error as NSError {
                KLog(type: .error, "When removing the media. The error is %@", error.localizedDescription)
            }
        }
    }
    
}
