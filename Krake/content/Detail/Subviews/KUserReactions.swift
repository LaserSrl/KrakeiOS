//
//  KUserReactions.swift
//  Krake
//
//  Created by Patrick on 02/08/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import UIKit

/**
 ## UserReaction
 
 Struttura delle user reactions
 
 - **orderPriority** NSNumber - livello di priorità
 - **identifier** NSNumber - identificativo della reaction
 - **typeIdentifier** NSNumber - identificativo della tipologia della reaction
 - **clicked** Bool - è selezionata
 - **typeName** String - nome (* usato per recuperare l'immagine)
 - **quantity** NSNumber - numero di utenti
 
 */
public struct UserReaction{
    /// livello di priorità
    var orderPriority: NSNumber
    /// identificativo della reaction
    var identifier: NSNumber
    /// identificativo della tipologia della reaction
    var typeIdentifier: NSNumber
    /// è selezionata
    var clicked: Bool
    /// nome (* usato per recuperare l'immagine)
    var typeName: String
    /// numero di utenti
    var quantity: NSNumber
    
    init(dictionary: [String: AnyObject]){
        orderPriority = dictionary["OrderPriority"] as? NSNumber ?? 0
        identifier = dictionary["Id"] as? NSNumber ?? 0
        typeIdentifier = dictionary["TypeId"] as? NSNumber ?? 0
        clicked = dictionary["Clicked"] as? NSNumber == 1 ? true : false
        typeName = dictionary["TypeName"] as? String ?? ""
        quantity = dictionary["Quantity"] as? NSNumber ?? 0
    }
}

extension KAPIConstants
{
    public static let userReactions = "Api/Laser.Orchard.UserReactions/ReactionApi"
}

/**
 ## KUserReactions
 
 Deriva dalla classe UIView e permette di inserire le user reactions legate ad un contenuto. Permette inoltre tutte le interazioni dell'utente occupandosi di effettuare la login nel caso in cui sia necessario.
 
 
 Inizializza la classe oppure crea una UIView e imposta KUserReactions come classe della view direttamente nel Interface Builder
 
 
 É possibile estendere o implementare la classe per modificare la grafica e la visualizzazione.
 
 - author: Patrick N.
 
 - requires: iOS 9
 
 ### Metodi
 
 `init(krakeContentIdentifier: NSNumber!)`
 
 `loadUserReactions(krakeContentIdentifier: NSNumber!)`
 
 `userTouchOnReaction(reactionIdentifier: NSNumber!)`
 
 `updateUserReactions(newUserReactions: [UserReaction])`
 
 */

@available(iOS 9.0, *)
open class KUserReactions: UIView, KDetailViewProtocol {
    
    public var detailObject: AnyObject?{
        didSet{
            if let object = detailObject as? ContentItemWithUserReactions{
                loadData(object)
            }else{
            }
        }
    }
    public weak var detailPresenter: KDetailPresenter?
    
    fileprivate var krakeContentIdentifier: NSNumber!
    fileprivate var userReactions: [UserReaction]?
    fileprivate var userAuthorized: Bool = false{
        didSet{
            reactionAuthorized = userAuthorized
        }
    }
    fileprivate var userAuthenticated: Bool = false{
        didSet{
            if !userAuthenticated{
                reactionAuthorized = true
            }
        }
    }
    fileprivate var reactionAuthorized: Bool = false
    fileprivate weak var stackView: UIStackView!
    
    @IBInspectable
    public var stringFormat: String = "%1$d"
    
    /**
     Inizializza la classe impostando l'identifier del contenuto, non serve richiamare il metodo loadUserReactions().
     
     - parameter krakeContentIdentifier: identifier del contentType per il quale richiedere le reactions
     
     - returns: UIView con le reactions
     */
    public convenience init(object: ContentItemWithUserReactions!) {
        self.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 80))
        addStackView()
        loadData(object)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
        
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        addStackView()
    }
    
    fileprivate func addStackView(){
        isHidden = true
        let sv = UIStackView()
        sv.alignment = .center
        sv.distribution = .equalSpacing
        sv.axis = .horizontal
        sv.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sv)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(16)-[sv]-(16)-|", options: .directionLeftToRight, metrics: nil, views: ["sv": sv]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[sv]-(0)-|", options: .directionLeftToRight, metrics: nil, views: ["sv": sv]))
        stackView = sv
        KTheme.current.applyTheme(toView: self, style: .userReactions)
    }
    
    /**
     Download delle user reactions da Krake e inserimento delle stesse nella UIStackView.
     
     Al termine viene richiamato il metodo updateUserReactions() al quale viene passato un array di UserReaction. Si può sovrascrivvere il metodo per personalizzare la UI.
     
     - parameter krakeContentIdentifier: identifier del contentType per il quale richiedere le reactions
     */
    final public func loadData(_ object: ContentItemWithUserReactions){
        self.krakeContentIdentifier = object.identifier
        let manager = KNetworkManager.default(true, true)
        _ = manager.request(KAPIConstants.userReactions,
                            method: .get,
                            query: [URLQueryItem(name: "pageId", value: String(format: "%d",krakeContentIdentifier!.intValue)), URLQueryItem(name: KParametersKeys.language, value: KConstants.currentLanguage)],
                            successCallback: { (task: KDataTask, object: Any?) in
            if let response = task.response,
                let headers = response.allHeaderFields as? [String : String]{
                let array = HTTPCookie.cookies(withResponseHeaderFields: headers, for: KInfoPlist.KrakePlist.path)
                URLConfigurationCookies.shared.parse(cookies: array)
            }
            
            if let data = (object as? NSDictionary)?["Data"] as? [String: AnyObject]{
                self.userAuthorized = data["UserAuthorized"] as? Bool ?? false
                self.userAuthenticated = data["UserAuthenticated"] as? Bool ?? false
                if let reactions = data["Reactions"] as? [[String: AnyObject]]{
                    self.dictionaryToReaction(reactions)
                }
            }
        }) { (task : KDataTask?, error: Error) in
            KLog(type: .error, error.localizedDescription)
        }
    }
    
    /**
     Questo metodo permette di inviare la selezione dell'utente a Krake, è sufficiente passare l'identificativo della reaction selezionata dall'utente.
     
     - parameter reactionIdentifier: typeIdentifier della reaction
     
     */
    open func userTouchOnReaction(_ reactionIdentifier: NSNumber){
        if !userAuthenticated && !userAuthorized{
            KLoginManager.shared.presentLogin(completion: { (logged, services, roles, error) in
                if logged{
                    self.sendReactionToKrake(reactionIdentifier)
                }else{
                    if let error = error {
                        KMessageManager.showMessage(error.localizedDescription, type: .error)
                    }
                }
            })
        }else{
            sendReactionToKrake(reactionIdentifier)
        }
    }
    
    fileprivate func sendReactionToKrake(_ reactionIdentifier: NSNumber){
        let manager = KNetworkManager.default(true)

        let params =  [KParametersKeys.language : KConstants.currentLanguage,
                       "pageId" : String(format: "%d",krakeContentIdentifier!.intValue),
                       "TypeId" : String(format: "%d",reactionIdentifier.intValue)]

        _ = manager.request(KAPIConstants.userReactions,
                            method: .post,
                            parameters: params,
                            successCallback: { (task: KDataTask, object: Any?) in
                                if let response = task.response,
                                    let headers = response.allHeaderFields as? [String : String]{
                                    let array = HTTPCookie.cookies(withResponseHeaderFields: headers, for: KInfoPlist.KrakePlist.path)
                                    URLConfigurationCookies.shared.parse(cookies: array)
                                }
                                if let data = (object as? NSDictionary)?["Data"] as? [String: AnyObject],
                                    let status = data["Status"] as? [String: AnyObject],
                                    let reactions = status["Reactions"] as? [[String: AnyObject]]{
                                    self.dictionaryToReaction(reactions)
                                }
                            },
                            failureCallback: { (task : KDataTask?, error: Error) in
                                //TODO: verifica code
                                if error._code == KErrorCode.userNotHavePermission{
                                    self.userAuthorized = false
                                    self.updateUserReactions(self.userReactions!)
                                    KMessageManager.showMessage(KLocalization.Error.actionNotAuthorized, type: .error)
                                }else{
                                    KLog(type: .error, error.localizedDescription)
                                }
                            })
    }
    
    fileprivate func dictionaryToReaction(_ reactions: [[String: AnyObject]]){
        var newUserReactions = [UserReaction]()
        for reaction in reactions{
            newUserReactions.append(UserReaction(dictionary: reaction))
        }
        self.updateUserReactions(newUserReactions)
    }
    
    /**
     Gestione delle UserReactions che arrivano dopo la chiamata a Krake. Sovrascrivere questo metodo per personalizzare la UI.
     
     Di default crea un elenco di UIButton e le inserisce in una stackView. Utiliza poi il tag dei vari button per riconoscere la Reaction premuta dall'utente. Infine al touchUpInside richiama il metodo userTouchOnReaction()
     
     - parameter newUserReactions: prende in input un array di UserReaction
     */
    open func updateUserReactions(_ newUserReactions: [UserReaction]){
        for reaction in newUserReactions{
            var button = stackView.viewWithTag(reaction.typeIdentifier.intValue) as? UIButton
            if button == nil {
                button = UIButton(type: .custom)
                button?.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                button?.tag = reaction.typeIdentifier.intValue
                
                let actImage = KImageAsset(name: reaction.typeName).image
                let actSelImage = KImageAsset(name: reaction.typeName + "_sel").image
                
                button?.setImage(((!reactionAuthorized && reaction.clicked) ? actSelImage : actImage ).imageTinted(KTheme.current.reactionColor(!reactionAuthorized ? (reaction.clicked ? .disableSelected : .disableNormal) : .enableNormal)), for: .normal)
                button?.setImage(actImage.imageTinted(KTheme.current.reactionColor(.disableNormal)), for: .disabled)
                button?.setImage(actSelImage.imageTinted(KTheme.current.reactionColor(.enableSelected)), for: .selected)
                button?.setTitleColor(KTheme.current.reactionColor(!reactionAuthorized ? (reaction.clicked ? .disableSelected : .disableNormal) : .enableNormal), for: .normal)
                button?.setTitleColor(KTheme.current.reactionColor(.enableSelected), for: .selected)
                button?.setTitleColor(KTheme.current.reactionColor(.disableNormal), for: .disabled)
                button?.addTarget(self, action: #selector(KUserReactions.reactionTouchUpInside(_:)), for: .touchUpInside)
                button?.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption2)
                button?.clipsToBounds = true
                stackView.addArrangedSubview(button!)
            }
            button?.isSelected = reaction.clicked
            button?.isEnabled = reactionAuthorized
            button?.setTitle(String(format:stringFormat, reaction.quantity.intValue, KLocalization.localizable("Reactions.\(reaction.typeName)")), for: UIControl.State.normal)
            button?.setTitle(String(format:stringFormat, reaction.quantity.intValue, KLocalization.localizable("Reactions.\(reaction.typeName)")), for: .selected)
            button?.titleLabel?.numberOfLines = 2
            button?.titleLabel?.textAlignment = .center
            button?.alignImageAndTitleVertically()
        }
        userReactions = newUserReactions
        if (userReactions?.count ?? 0) > 0{
            hiddenAnimated = false
        }
    }
    
    @objc open func reactionTouchUpInside(_ sender: UIButton){
        UIView.transition(with: sender,
                                  duration: 0.5,
                                  options: [.transitionFlipFromLeft, .curveEaseIn],
                                  animations: { sender.isSelected = true },
                                  completion: nil)
        if sender.tag > 0 {
            userTouchOnReaction(sender.tag as NSNumber)
        }
    }
    
}

