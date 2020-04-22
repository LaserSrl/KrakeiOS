//
//  KUserDisplayView.swift
//  Krake
//
//  Created by joel on 02/08/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import SwiftMessages

public class KUserDisplayView: UIView {

    public enum LabelStyle {
        case name
        case nameAndSurname
    }

    @IBOutlet weak var topLogoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var topImageConstraint: NSLayoutConstraint!
    @IBOutlet weak public var userNameLabel: UILabel!
    @IBOutlet weak public var userImageView: UIImageView!
    @IBOutlet weak public var logoutButton: UIButton!
    @IBOutlet weak public var nameFirstLettersButton: UIButton!

    public var labelStyle :LabelStyle = .name
    public var prefixLabel: String? = nil
    public var contentDisplayAlias: String! = KCommonDisplayAlias.userInfo {
        didSet{
            if KLoginManager.shared.isKrakeLogged {
                reloadUserInfos()
            }
            else {
                user = nil
            }
        }
    }
    public var topInset: CGFloat!{
        didSet{
            topImageConstraint.constant = 30.0 + topInset
            topLogoutConstraint.constant = topInset + 20.0
        }
    }
    private var task: OMLoadDataTask?
    private var showUserInfoBlock: ((UserProtocol?)-> Void)?
    private var loginObserver: Any?
    private var logoutObserver: Any?
    private var user: UserProtocol?{
        didSet{
            updateUI()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        task?.cancel()
        removeObservers()
        KLog(type: .debug, "RELEASED")
    }
    
    @IBAction func logout(_ sender: Any) {
        KLoginManager.shared.userLogout()
    }
    
    public static func loadUserView(contentDisplayAlias: String = KCommonDisplayAlias.userInfo, showUserInfo block: ((UserProtocol?)-> Void)? = nil) -> KUserDisplayView {
        let bundle =  Bundle(for: KUserDisplayView.self)
        let vc = bundle.loadNibNamed("KUserDisplayView", owner: nil, options: nil)?.first as! KUserDisplayView
        vc.translatesAutoresizingMaskIntoConstraints = false
        vc.contentDisplayAlias = contentDisplayAlias
        vc.showUserInfoBlock = block
        return vc
    }
    
    public override func awakeFromNib() {
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userNameLabel.text = "on_loading".localizedString()
        nameFirstLettersButton.setTitle("", for: .normal)
        
        KTheme.current.applyTheme(toUserDisplay: self)

        registerObservers()
        
        if #available(iOS 11.0, *) {
            topInset = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0.0
        }
    }
    
    public func registerObservers()
    {
        if loginObserver == nil {
            
            loginObserver = NotificationCenter.default.addObserver(forName: KLoginManager.UserLoggedIn,
                                                                   object: KLoginManager.shared,
                                                                   queue: nil,
                                                                   using: { (note) in
                                                                    self.reloadUserInfos()
                                                                    KTheme.current.applyTheme(toUserDisplay: self)
            })
            
            logoutObserver = NotificationCenter.default.addObserver(forName: KLoginManager.UserLoggedOut,
                                                                    object: KLoginManager.shared,
                                                                    queue: nil,
                                                                    using: { (note) in
                                                                        self.user = nil
                                                                        KTheme.current.applyTheme(toUserDisplay: self)
            })
        }
    }
    
    public func removeObservers()
    {
        if let loginObserver = loginObserver {
            NotificationCenter.default.removeObserver(loginObserver)
            self.loginObserver = nil
        }
        if let logoutObserver = logoutObserver{
            NotificationCenter.default.removeObserver(logoutObserver)
            self.logoutObserver = nil
        }
    }
    
    public func reloadUserInfos()
    {
        task?.cancel()
        task = OGLCoreDataMapper.sharedInstance().loadData(withDisplayAlias: contentDisplayAlias,
                                                    extras: KRequestParameters.parametersNoCache(), loginRequired: true,
                                                    completionBlock: { (objectId, error, completed) in
                                                        if completed {
                                                            if objectId != nil {
                                                                let cache = OGLCoreDataMapper.sharedInstance().managedObjectContext.object(with: objectId!) as! DisplayPathCache
                                                                self.user = cache.cacheItems.firstObject as? UserProtocol
                                                            }
                                                            else {
                                                                
                                                                
                                                                KMessageManager.showMessage("LoadingOfUserInfoFailed".localizedString(), title: KInfoPlist.appName, type: KMessageManager.Mode.error, layout: KMessageManager.Layout.statusLine, position: KMessageManager.Position.top, duration: KMessageManager.Duration.automatic, windowLevel: KWindowLevelStatusBar, fromViewController: nil)
                                                            }
                                                        }
        })
    }
    
    @IBAction func loginOrEdit(_ sender: UIButton) {
        if KLoginManager.shared.isKrakeLogged {
            showUserInfoBlock?(user) ?? reloadUserInfos()
        }
        else {
            KLoginManager.shared.presentLogin(completion: { (logged, roles, services, error) in
                
            })
        }
    }
    
    private func updateUI()
    {
        nameFirstLettersButton.setTitle("", for: .normal)
        if let user = user {
            let remoteImg = user.imageGallery?.firstObject
            userImageView.setImage(media: remoteImg, placeholderImage: UIImage(omNamed: "user_placeholder"))
            
            logoutButton.hiddenAnimated = KInfoPlist.Login.canUserLogout ? false : true
            
            let name : String = !(user.name?.isEmpty ?? true) ? user.name! : "Anonymous".localizedString()
            let surname : String? = !(user.surname?.isEmpty ?? true) ? user.surname! : nil

            if labelStyle == .name || surname == nil
            {
                userNameLabel.text = String(format: "%@%@", prefixLabel ?? "", name)
            }
            else
            {
                userNameLabel.text = String(format:"%@%@ %@", prefixLabel ?? "",name,surname!)
            }

            if remoteImg == nil, !name.isEmpty
            {
                var buttonTitle = String(name[..<name.index(after: name.startIndex)])

                if let surname = surname
                {
                    buttonTitle.append(String(surname[..<surname.index(after: surname.startIndex)]))
                }
                nameFirstLettersButton.setTitle(buttonTitle, for: .normal)
            }
        }
        else {
            userImageView.image = KTheme.current.placeholder(.people)
            logoutButton.hiddenAnimated = true
            userNameLabel.text = "Login".localizedString()
        }
    }
}
