import UIKit

open class KImageCollectionViewCell: UICollectionViewCell {

    open weak var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        privateInit()
    }

    final func privateInit() {
        // Creazione dell'imageView, che sarà l'unica view figlio.
        let imageView = UIImageView(frame: bounds)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        // Aggiunta dell'imageView alla contentView.
        contentView.addSubview(imageView)
        // Aggiunta dei constraints per fare in modo che l'imageView occupi
        // esattamente lo spazio disponibile per la contentView.
        contentView.addConstraints([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
            ])
        // Salvataggio della reference alla imageView per utilizzi futuri.
        self.imageView = imageView
        commonInit()
    }
    
    open func commonInit() {
        
    }
}
/*
 KMediaCollectionView: class to display gallery of Medias

 This class has 3 way to specify what data it should display:
 - showGallery: display gallery of a ContentItemWithGallery
 - showYoutubeVideos: display videos of ContentItemWithYoutubeVideo
 - showCustomKeyPath: custom keyPath that must return ad NSOrderedSet of Medias
 #Only one field will be displayed, even if you enable more than one option.


 The class can't be subclassed.
 */
@IBDesignable public class KMediaCollectionView: UICollectionView, KDetailViewSizeChangesListener, KDetailViewProtocol {

    @IBInspectable var showGallery: Bool = true
    @IBInspectable var showYoutubeVideos: Bool = false
    @IBInspectable var showCustomKeyPath: String? = nil

    public weak var detailPresenter: KDetailPresenter?
    public var detailObject: AnyObject? {
        didSet {
            let images : NSOrderedSet?
            if showGallery {
                images = (detailObject as? ContentItemWithGallery)?.galleryMediaParts
            } else if showYoutubeVideos {
                images = (detailObject as? ContentItemWithYoutubeVideo)?.youtubeVideoContentItems
            }else if let keyPath = showCustomKeyPath {
                images = detailObject?.value(forKeyPath: keyPath) as? NSOrderedSet
            }
            else {
                images = nil
            }

            adapter.medias = images

            if images?.count ?? 0 == 0 {
                hiddenAnimated = true
            } else {
                hiddenAnimated = false
            }
            reloadData()
        }
    }

    public var adapter: KMediaCollectionViewDataSourceAndDelegate! {
        didSet {
            adapter.registerCellForReuse(inCollection: self)
            dataSource = adapter
            delegate = adapter
        }
    }

    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        adapterInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        adapterInit()
    }

    private func adapterInit()
    {
        KTheme.current.applyTheme(toView: self, style: .mediaCollectionView)
        self.adapter = KMediaAdapter()
    }

    public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
        coordinator.animate(alongsideTransition: nil) { [unowned self] (_) in
            self.reloadData()
        }
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        let label = viewWithTag(11111) as? UILabel ?? {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = .red
            label.backgroundColor = .yellow
            label.tag = 11111
            addSubview(label)
            return label
        }()
        clipsToBounds = true
        if (showGallery && showYoutubeVideos) || (showCustomKeyPath != nil && (showGallery || showYoutubeVideos)){
            label.text = "🐙 WARNING!!!   You've selected more than one properties on the IB attributes inspector.\n\nFIX IT NOW 😡"
            label.isHidden = false
        }else if !showGallery && !showYoutubeVideos && showCustomKeyPath == nil{
            label.text = "🐙 WARNING!!!   You've not selected any properties on the IB attributes inspector.\n\nFIX IT NOW 😡"
            label.isHidden = false
        }else{
            label.isHidden = true
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
}

public protocol KMediaCollectionViewDataSourceAndDelegate: UICollectionViewDelegate, UICollectionViewDataSource {
    func registerCellForReuse(inCollection collection: UICollectionView)

    var medias: NSOrderedSet? {get set}
}

open class KMediaAdapter: NSObject, KMediaCollectionViewDataSourceAndDelegate, UICollectionViewDelegateFlowLayout {

    public static let kDefaultCellReuseIdentifier = "MediaCell"

    open var medias: NSOrderedSet?

    open func registerCellForReuse(inCollection collection: UICollectionView) {
        collection.register(KImageCollectionViewCell.self,
                 forCellWithReuseIdentifier: KMediaAdapter.kDefaultCellReuseIdentifier)
    }

    // MARK: - Collection view datasource

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return medias?.count ?? 0
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: KMediaAdapter.kDefaultCellReuseIdentifier,
            for: indexPath)
        if let imageCell = cell as? KImageCollectionViewCell {
            imageCell.imageView.setImage(media: medias?.object(at: indexPath.row))
        }
        return cell
    }

    // MARK: - Collection view delegate

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let imageCell = collectionView.cellForItem(at: indexPath) as? KImageCollectionViewCell,
            let presenterViewController = UIApplication.shared.keyWindow?.rootViewController else {
                return
        }
        // Apertura dell'immagine a schermo intero.
        presenterViewController.present(galleryController: medias!.array,
                                      selectedIndex: indexPath.row,
                                      target: imageCell.imageView) { [weak collectionView] (index) -> UIImageView? in
                                        guard let collectionView = collectionView else {
                                            return nil
                                        }
                                        let indexForLastSelectedImage = IndexPath(row: index, section: 0)
                                        if let cell = collectionView.cellForItem(at: indexForLastSelectedImage) as? KImageCollectionViewCell {
                                            collectionView.scrollToItem(
                                                at: indexForLastSelectedImage,
                                                at: .centeredHorizontally,
                                                animated: true)
                                            return cell.imageView
                                        }
                                        return nil
        }
    }

    // MARK: - Flow layout delegate
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {

        let count = self.collectionView(collectionView,
                                        numberOfItemsInSection: indexPath.section)
        if count == 1 {
            return collectionView.bounds.size
        } else {
            let currentRow = indexPath.row
            if currentRow == 0 || ((currentRow + 1 == count) && (count % 2) == 0){
                return CGSize(
                    width: collectionView.bounds.width - 50.0,
                    height: collectionView.bounds.height)
            } else {
                var minimumInteritemSpacing: CGFloat = 0.0
                if let flow = collectionViewLayout as? UICollectionViewFlowLayout {
                    minimumInteritemSpacing = flow.minimumInteritemSpacing
                }
                return CGSize(
                    width: collectionView.bounds.width * 0.5,
                    height: (collectionView.bounds.height - minimumInteritemSpacing) * 0.5)
            }
        }
    }
}


///Old Deprecated Classes
/*
 Replace it with the new KMediaCollectionView, no special action needed
 */
@available(*,deprecated: 1.0, message: "use KMediaCollectionView")
open class KGalleryCollectionView: UICollectionView, KDetailViewProtocol, KDetailViewSizeChangesListener {
    public weak var detailPresenter: KDetailPresenter?
    public var detailObject: AnyObject? {
        didSet {
            let images : NSOrderedSet? = imagesFromDetailObject()

            adapter.medias = images

            #if DEBUG
                hiddenAnimated = false
            #else
            if images?.count ?? 0 == 0 {
                hiddenAnimated = true
            } else {
                hiddenAnimated = false
            }
            #endif
            reloadData()
        }
    }

    func imagesFromDetailObject() -> NSOrderedSet? {
        return (detailObject as? ContentItemWithGallery)?.galleryMediaParts
    }

    var adapter: KMediaCollectionViewDataSourceAndDelegate! {
        didSet {
            adapter.registerCellForReuse(inCollection: self)
            dataSource = adapter
            delegate = adapter
        }
    }

    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        adapterInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        adapterInit()
    }

    private func adapterInit()
    {
        self.adapter = GalleryAdapter()
        #if DEBUG
            self.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.05610767772, alpha: 1)
        #endif
    }

    public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
        coordinator.animate(alongsideTransition: nil) { [unowned self] (_) in
            self.reloadData()
        }
    }
}

@available(*,deprecated: 1.0, message: "use KMediaAdapter")
open class GalleryAdapter: KMediaAdapter {
    open override func registerCellForReuse(inCollection collection: UICollectionView) {
         #if DEBUG
        collection.register(KDeprecatedImageCollectionViewCell.self, forCellWithReuseIdentifier: KMediaAdapter.kDefaultCellReuseIdentifier)
        #else
            super.registerCellForReuse(inCollection: collection)
        #endif
    }
}

@available(*,deprecated: 1.0)
public class KDeprecatedImageCollectionViewCell: KImageCollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        privateInit()
    }

    open override func commonInit() {
        let imageView = UILabel(frame: bounds)
        imageView.text = "DEPRECATED COLLECTION!! 😅😅😅😅"
        imageView.textAlignment = .center
        imageView.textColor = #colorLiteral(red: 1, green: 0, blue: 0.05610767772, alpha: 1)
        imageView.font = UIFont.boldSystemFont(ofSize: 22)
        imageView.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        // Aggiunta dell'imageView alla contentView.
        contentView.addSubview(imageView)
        // Aggiunta dei constraints per fare in modo che l'imageView occupi
        // esattamente lo spazio disponibile per la contentView.
        contentView.addConstraints([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
            ])

    }
}

/*
 Replace it with the new KMediaCollectionView, then in Interface Builder 
 set showGallery = false and showYoutubeVideos = true
 */
@available(*,deprecated: 1.0, message: "use KMediaCollectionView")
open class KVideoPlayerCollectionView: KGalleryCollectionView {

    override func imagesFromDetailObject() -> NSOrderedSet? {
        return (detailObject as? ContentItemWithYoutubeVideo)?.youtubeVideoContentItems
    }
}
