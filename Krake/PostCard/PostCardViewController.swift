//
//  PostCardViewController.swift
//  Krake
//
//  Created by Patrick on 28/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import MBProgressHUD
import LaserFloatingTextField

class PostCardViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var immagine: UIImageView!
    @IBOutlet weak var nomeMittente: EGFloatingTextField!
    @IBOutlet weak var emailMittente: EGFloatingTextField!
    @IBOutlet weak var nomeDestinatario: EGFloatingTextField!
    @IBOutlet weak var emailDestinatario: EGFloatingTextField!
    @IBOutlet weak var messaggio: EGFloatingTextField!
    
    var postCard: PostCardProtocol!
    var openObserver: AnyObject!
    var closeObserver: AnyObject!

    var address: ContactPicker!

    let checkIsValidEmail: (String) -> Bool = { (email) in
        let emailRegex = "([A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6})?"
        let emailTest = NSPredicate(format:"SELF MATCHES %@" , emailRegex)
        return emailTest.evaluate(with: email)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 9, *) {
            address = KContactPicker()
        } else {
            address = KAddressBook()
        }
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.setImage(UIImage(krakeNamed: "person")!, for: .normal)
        button.addTarget(self, action: #selector(PostCardViewController.openContacts(_:)), for: .touchUpInside)
        nomeMittente.rightView = button
        nomeMittente.rightViewMode = .always
        button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.setImage(UIImage(krakeNamed: "person"), for: .normal)
        button.addTarget(self, action: #selector(PostCardViewController.openContacts(_:)), for: .touchUpInside)
        nomeDestinatario.rightView = button
        nomeDestinatario.rightViewMode = .always

        nomeMittente.IBPlaceholder = "YOUR_NAME".localizedString()
        emailMittente.IBPlaceholder = "YOUR_MAIL".localizedString()
        emailMittente.validationType = EGFloatingTextFieldValidationType.Email
        nomeDestinatario.IBPlaceholder = "TO_NAME".localizedString()
        emailDestinatario.IBPlaceholder = "TO_MAIL".localizedString()
        emailDestinatario.validationType = EGFloatingTextFieldValidationType.Email
        messaggio.IBPlaceholder = "MESSAGE".localizedString()

        nomeMittente.delegate = self
        emailMittente.delegate = self
        nomeDestinatario.delegate = self
        emailDestinatario.delegate = self
        messaggio.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(PostCardViewController.dismissKeyboard))
        scrollView.addGestureRecognizer(tap)

        let full = UITapGestureRecognizer(target: self, action: #selector(PostCardViewController.openFullScreen))
        immagine.addGestureRecognizer(full)
        immagine.isUserInteractionEnabled = true
        
        title = postCard.titlePartTitle
        immagine.setImage(media: postCard.galleryMediaParts?.firstObject, options: KMediaImageLoadOptions(size: CGSize.zero, mode: .Max))

        let send = UIBarButtonItem(image: UIImage(krakeNamed: "send"), style: KBarButtonItemStyle.plain, target: self, action: #selector(PostCardViewController.sendPostCard(_:)))
        navigationItem.rightBarButtonItem = send
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nomeMittente {
            UserDefaults.standard.setStringAndSync(textField.text!, forConstantKey: .userName)
        }
        if textField == emailMittente {
            UserDefaults.standard.setStringAndSync(textField.text!, forConstantKey: .userEmail)
        }
    }

    @objc func openContacts(_ sender: UIButton){

        address.presentListOfContacts(navigationController!) { (name, email) -> Void in
            if sender.superview == self.nomeMittente {
                _ = self.nomeMittente.becomeFirstResponder()
                self.nomeMittente.text = name
                _ = self.nomeMittente.resignFirstResponder()
                UserDefaults.standard.setStringAndSync(self.nomeMittente.text!, forConstantKey: .userName)
                _ = self.emailMittente.becomeFirstResponder()
                self.emailMittente.text = email
                _ = self.emailMittente.resignFirstResponder()
                UserDefaults.standard.setStringAndSync(self.emailMittente.text!, forConstantKey: .userEmail)
            }
            if sender.superview == self.nomeDestinatario {
                _ = self.nomeDestinatario.becomeFirstResponder()
                self.nomeDestinatario.text = name
                _ = self.nomeDestinatario.resignFirstResponder()
                _ = self.emailDestinatario.becomeFirstResponder()
                self.emailDestinatario.text = email
                _ = self.emailDestinatario.resignFirstResponder()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let nome = UserDefaults.standard.string(forConstantKey: .userName){
            if (nome as NSString).length > 0 {
                _ = self.nomeMittente.becomeFirstResponder()
                self.nomeMittente.text = nome
                _ = self.nomeMittente.resignFirstResponder()
            }
        }
        if let email = UserDefaults.standard.string(forConstantKey: .userEmail)  {
            if (email as NSString).length > 0 {
                _ = self.emailMittente.becomeFirstResponder()
                self.emailMittente.text = email
                _ = self.emailMittente.resignFirstResponder()
            }
        }
        openObserver = NotificationCenter.default.addObserver(forName: KKeyboardDidShowNotification, object: nil, queue: nil) { (notification: Notification) -> Void in
            let rect = (notification.userInfo![KKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: rect.height, right: 0)
            self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
            
            if let responde = UIResponder.currentFirstResponder() as? UIView{
                let cos = self.view.frame.height-rect.height
                let globalPoint = self.view.convert(CGRect.zero, from: responde)
                let y = globalPoint.origin.y + responde.frame.height + 8
                if y > cos {
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: y-cos), animated: true)
                }
            }
        }
        closeObserver = NotificationCenter.default.addObserver(forName: KKeyboardDidHideNotification, object: nil, queue: nil) { (notification: Notification) -> Void in
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(openObserver)
        NotificationCenter.default.removeObserver(closeObserver)
    }

    @objc func dismissKeyboard(){
        view.endEditing(true)
    }

    @IBAction func sendPostCard(_ sender: UIBarButtonItem){
        MBProgressHUD.showAdded(to: view, animated: true)
        sendPostCardToKrake([KParametersKeys.sendTo : self.emailDestinatario.text!,
                             KParametersKeys.messageText : self.messaggio.text!,
                             KParametersKeys.senderName : self.nomeMittente.text!,
                             KParametersKeys.recipeName : self.nomeDestinatario.text!,
                             KParametersKeys.sendFrom : self.emailMittente.text!]) { (parsedObject, error) in
                                MBProgressHUD.hide(for: self.view, animated: true)
                                if error != nil {
                                    KMessageManager.showMessage(error!.localizedDescription, type: .error)
                                }else{
                                    KMessageManager.showMessage(NSLocalizedString("La cartolina è stata inviata.", comment: ""), type: .success)

                                    NotificationCenter.default.post(name: PostCards.sentPostCard,
                                                                    object: self.parent,
                                                                    userInfo: ["item_id":self.postCard.identifier.stringValue, "content_type":"Cartolina"])
                                    
                                    AnalyticsCore.shared?.log(event:"survey_answered",parameters:["item_id":self.postCard.identifier.stringValue, "content_type":"Cartolina"])
                                    _ = self.navigationController?.popViewController(animated: true)
                                }
        }
    }

    @objc func openFullScreen(){
        navigationController!.present(galleryController: postCard.galleryMediaParts!.array, target: immagine)
    }

    func sendPostCardToKrake(_ parameters: [String : String], completion: ((_ parsedObject: [AnyHashable: Any]?, _ error: Error?) -> Void)?){
        var errori = [String : String]()
        if parameters[KParametersKeys.sendTo]?.isEmpty ?? true {
            errori[KParametersKeys.sendTo] = "Manca la E-Mail del destinatario".localizedString()
        }else if !checkIsValidEmail(parameters[KParametersKeys.sendTo]!) {
            errori[KParametersKeys.sendTo] = "E-Mail del destinatario non valida".localizedString()
        }
        if parameters[KParametersKeys.sendFrom]?.isEmpty ?? true {
            errori[KParametersKeys.sendFrom] = "Manca la E-Mail del mittente".localizedString()
        }else if !checkIsValidEmail(parameters[KParametersKeys.sendFrom]!) {
            errori[KParametersKeys.sendFrom] = "E-Mail del mittente non valida".localizedString()
        }
        if parameters[KParametersKeys.senderName]?.isEmpty ?? true {
            errori[KParametersKeys.senderName] = "Manca il nome del mittente".localizedString()
        }
        if parameters[KParametersKeys.recipeName]?.isEmpty ?? true {
            errori[KParametersKeys.recipeName] = "Manca il nome del destinatario".localizedString()
        }
        if parameters[KParametersKeys.messageText]?.isEmpty ?? true {
            errori[KParametersKeys.messageText] = "Manca il testo del messaggio".localizedString()
        }
        if errori.keys.count > 0 {
            var localError = "Mancano i seguenti campi:".localizedString()
            for key in errori.keys{
                localError = localError.appending("\n - " + errori[key]!)
            }
            errori[NSLocalizedDescriptionKey] = localError
            completion?(nil, NSError(domain: "Cards", code: 101, userInfo: errori))
        }else{
            _ = KNetworkManager.signalTriggerManager().postSignalTrigger(signalName: "SendPostCard", contentId: postCard.identifier.stringValue, params: parameters, success: { (task, object) in
                completion?(object as? [AnyHashable : Any], nil)
            }, failure: { (task, error) in
                completion?(nil, error)
            })
            
        }
    }
}
