//
//  KMainGameBoardViewController.swift
//  Pods
//
//  Created by Patrick on 29/06/17.
//
//

import Foundation
import GameKit
import MBProgressHUD
import SDWebImage

public class KMainGameBoardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GKGameCenterControllerDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var localPlayer: GKLocalPlayer?
    fileprivate var games: [GameProtocol]?{
        didSet{
            collectionView.reloadData()
        }
    }
    fileprivate var isOnBackgroundScreenVisibile: Bool = (UIApplication.shared.delegate as? OGLAppDelegate)?.isOnBackgroundScreenVisibile ?? true
    var endPoint: String!
    var policyEndPoint: String?
    
    deinit {
        (UIApplication.shared.delegate as? OGLAppDelegate)?.isOnBackgroundScreenVisibile = isOnBackgroundScreenVisibile
    }
    
    //MARK: - View
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        KGameQuiz.theme.applyTheme(toView: view, style: .default)
        
        var params = KRequestParameters.parameters(currentPage: 0, pageSize: 0, fieldsFilter: "game,gamepart,gallery,activitypart,autoroutepart,titlepart")
        params[REQUEST_NO_CACHE] = KRequestParameters.parametersNoCache()[REQUEST_NO_CACHE]
        OGLCoreDataMapper.sharedInstance().loadData(withDisplayAlias: endPoint, extras: params) { (object, error, completed) in
            if let object = object, completed{
                let cache = OGLCoreDataMapper.sharedInstance().displayPathCache(from: object)
                self.games = cache.cacheItems.array as? [GameProtocol]
            }else if let error = error{
                KMessageManager.showMessage(error.localizedDescription, type: .error, layout: .tabView)
            }
        }
        
        #if swift(>=4.2)
        localPlayer = GKLocalPlayer.local
        #else
        localPlayer = GKLocalPlayer.localPlayer()
        #endif
        localPlayer?.authenticateHandler = {[weak self](viewController, error) in
            if let vc = viewController, let weakSelf = self{
                vc.modalPresentationStyle = .formSheet
                weakSelf.present(vc, animated: true, completion: nil)
            }
        }
        
        //sizing collection view cell
        var width = view.bounds.width
        var sizeItem = CGSize(width: width, height: width/2)
        if UIDevice.current.userInterfaceIdiom == .pad{
            collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            width = min(view.bounds.width, view.bounds.height)/8*3
            sizeItem = CGSize(width: width, height: width)
        }
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = sizeItem
        
        //button to access at gamecenter leaderboards & privacy
        var buttons = [UIBarButtonItem]()
        
        let leaderboards = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 32.0, height: 32.0))
        leaderboards.setImage(UIImage(krakeNamed:"game_center"), for: .normal)
        leaderboards.layer.cornerRadius = 5
        leaderboards.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        leaderboards.addTarget(self, action: #selector(showLeaderBoards(sender:)), for: .touchUpInside)
        let leaderboardsBarButton = UIBarButtonItem(customView: leaderboards)
        buttons.append(leaderboardsBarButton)
        
        if policyEndPoint != nil {
            let image = UIImage(krakeNamed: "license")
            let policyBarButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(openPolicy))
            buttons.append(policyBarButton)
        }
        
        navigationItem.rightBarButtonItems = buttons
        
        
    }
    
    //MARK: - Miscellaneus func
    
    @objc func showLeaderBoards(sender: Any){
        let gkViewController = GKGameCenterViewController()
        gkViewController.viewState = .leaderboards
        gkViewController.gameCenterDelegate = self
        if let game = sender as? GameProtocol{
            gkViewController.leaderboardIdentifier = game.gamePartReference?.rankingIOSIdentifier
        }
        gkViewController.modalPresentationStyle = .formSheet
        present(gkViewController, animated: true, completion: nil)
    }
    
    @objc func openPolicy(){
        presentPolicyViewController(policyEndPoint: policyEndPoint, largeMargin: false)
    }
    
    //MARK: - UICollectionViewDataSource & Delegate
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games?.count ?? 0
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! KMainBoardCollectionViewCell
        let game = games![indexPath.row]
        if let media = game.galleryMediaParts?.firstObject as? MediaPartProtocol{
            cell.gameImageView.setImage(media: media)
        }
        cell.gameOverImageView.layer.contentsRect = CGRect(x: -0.15, y: -0.05, width: 1.3, height: 1.3)
        if let gamePart = game.gamePartReference{
            cell.gameOverImageView.image = nil
            if let status = gamePart.state{
                switch status.intValue {
                case 0:
                    cell.gameOverImageView.backgroundColor = KGameQuiz.theme.color(.past).withAlphaComponent(0.4)
                case 2:
                    cell.gameOverImageView.backgroundColor = KGameQuiz.theme.color(.future).withAlphaComponent(0.4)
                default:
                    break
                }
            }
        }
        
        cell.gameTitleLabel.text = game.titlePartTitle
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let game = games![indexPath.row]
        if let part = game.gamePartReference, let state = part.state{
            if state == 1{
                MBProgressHUD.showAdded(to: view, animated: true)
                var extras = KRequestParameters.parametersNoCache()
                extras[REQUEST_DEEP_LEVEL] = "13"
                OGLCoreDataMapper.sharedInstance().loadData(withDisplayAlias: game.autoroutePartDisplayAlias ?? "", extras: extras, completionBlock: { (object, error, completed) in
                    if completed{
                        if let object = object {
                            let cache = OGLCoreDataMapper.sharedInstance().displayPathCache(from: object)
                            let game = cache.cacheItems.firstObject as? GameProtocol
                            self.performSegue(withIdentifier: "startGame", sender: game)
                        }
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                })
            }else if state == 2{
                var error = "available_soon".localizedString()
                if let date = game.activityPartReference?.dateTimeStart{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .long
                    error = error + " " + dateFormatter.string(from: date as Date)
                }
                KMessageManager.showMessage(error, type: .message, layout: .tabView)
            }else{
                showLeaderBoards(sender: game)
            }
        }else{
            showLeaderBoards(sender: game)
        }
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "startGame"{
            (UIApplication.shared.delegate as? OGLAppDelegate)?.isOnBackgroundScreenVisibile = false
            if let destination = segue.destination as? KMainGameViewController{
                destination.selectedGame = sender as? GameProtocol
                destination.parentVC = self
            }
        }
    }
    
    //MARK: - GKGameCenterControllerDelegate
    
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
}

public class KMainBoardCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var gameOverImageView: UIImageView!
    @IBOutlet weak var gameTitleLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 2.0
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        selectedBackgroundView = selectedView
    }
}
