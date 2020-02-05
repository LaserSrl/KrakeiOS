//
//  KSocialView.swift
//  Krake
//
//  Created by Marco Zanino on 02/03/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import UIKit

open class KSocialView: UIStackView, KDetailViewProtocol {

    public weak var detailPresenter: KDetailPresenter?
    public var detailObject: AnyObject? {
        didSet {
            updateSocialViews()
        }
    }
    open override var backgroundColor: UIColor? {
        get {
            return backgroundView?.backgroundColor
        }
        set {
            applyBackgroundColor(newValue)
        }
    }

    private weak var backgroundView: UIView?

    private var socials: [KButtonItem]?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        socials = nil
        KTheme.current.applyTheme(toStackView: self, style: .social)
    }

    // MARK: - Background coloring

    private func applyBackgroundColor(_ color: UIColor?) {
        guard let backgroundColor = color else {
            // Visto che il colore di sfondo non è più necessario,
            // rimuovo la view di sfondo.
            backgroundView?.removeFromSuperview()
            return
        }
        // Controllo che la backgroundView non sia già stata creata.
        if backgroundView == nil {
            // Creo la view che verrà utilizzata per permettere di avere
            // un colore di sfondo.
            let backgroundView = UIView()
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            let viewRefs = [ "bg" : backgroundView ]
            insertSubview(backgroundView, at: 0)
            addConstraints([
                NSLayoutConstraint.constraints(
                    withVisualFormat: "|-0-[bg]-0-|",
                    options: .directionLeftToRight,
                    metrics: nil,
                    views: viewRefs),
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-0-[bg]-0-|",
                    options: .directionLeftToRight,
                    metrics: nil,
                    views: viewRefs)
                ].flatMap { $0 })
            self.backgroundView = backgroundView
        }
        backgroundView?.backgroundColor = backgroundColor
    }

    // MARK: - Social conversion

    private func updateSocialViews() {
        // Rimozione le subviews che erano state aggiunte in precedenza.
        for view in arrangedSubviews {
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        // Aggiunta le nuove view relative ad i nuovi socials.
        if let detailViewController = detailPresenter as? UIViewController,
            let socials = detailPresenter?.detailDelegate?
                .createSocialButtons(detailViewController, element: detailObject), !socials.isEmpty {
            // Aggiornamento dell'array degli item che corrispondono ai social del dettaglio.
            self.socials = socials
            // Generazione dei bottoni per i primi 10 social.
            var index = 10
            for elem in socials {
                let button = UIButton(type: .system)
                button.contentVerticalAlignment = .center
                button.contentHorizontalAlignment = .center
                button.frame = CGRect(x: 0,y: 0,width: 44,height: 44)
                button.addTarget(self,
                                 action: #selector(KSocialView.openSocial(_:)),
                                 for: .touchUpInside)
                button.setImage(elem.image, for: .normal)
                if elem.showTitle {
                    button.setTitle(elem.title, for: .normal)
                }
                button.tag = index
                button.titleLabel?.lineBreakMode = .byTruncatingTail
                KTheme.current.applyTheme(toButton: button, style: .social)
                button.alignImageAndTitleVertically()
                addArrangedSubview(button)

                index = index+1
            }
            hiddenAnimated = false
        } else {
            hiddenAnimated = true
        }
    }

    // MARK: - Social openings

    @objc dynamic func openSocial(_ sender: UIView?){
        guard let selectedView = sender,
            let socials = socials else {

                return
        }

        let selectedSocialIndex = selectedView.tag - 10
        let social = socials[selectedSocialIndex]
        if let stringURL = social.mediaUrl, let url = URL(string: stringURL) {
            if let containerViewController = selectedView.containingViewController() {
                if UIApplication.shared.canOpenURL(url) {
                    if social.title == "Sito web"{
                        if let navigationController = containerViewController.navigationController {
                            navigationController
                                .pushBrowserViewController(url,
                                                           title: containerViewController.title)
                        } else {
                            containerViewController
                                .present(
                                    browserViewController: url,
                                    title: containerViewController.title)
                        }
                    }else{
                        UIApplication.shared.open(url)
                    }
                } else {
                    var string = stringURL
                    if url.scheme != "" {
                        string = string.replacingOccurrences(of: url.scheme ?? "" + "://", with: "")
                        string = string.replacingOccurrences(of: url.scheme ?? "" + ":", with: "")
                    }
                    let alert = UIAlertController(
                        title: KInfoPlist.appName,
                        message: (social.title + ": " + string),
                        preferredStyle: .alert)
                    alert.addAction(UIAlertAction(
                        title: "Ok".localizedString(),
                        style: .default,
                        handler: nil))
                    containerViewController.present(alert,
                                                    animated: true,
                                                    completion: nil)
                }
            }
        } else if let target = social.target, let selector = social.selector {
            _ = target.perform(selector, with:sender)
        } else {
            KLog(type: .error, social.title)
        }
    }
    
}
