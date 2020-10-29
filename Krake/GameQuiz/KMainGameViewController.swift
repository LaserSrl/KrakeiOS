//
//  KMainGameViewController.swift
//  Pods
//
//  Created by Patrick on 29/06/17.
//
//

import GameKit
import Foundation
import libPhoneNumber_iOS
import SwiftyJSON

class KMainGameViewController: UIViewController, GameControllerDelegate{
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var gameTitleLabel: UILabel!
    @IBOutlet weak var gameTimingLabel: UILabel!
    @IBOutlet weak var timeImageView: UIImageView!
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var totalPointLabel: UILabel!
    @IBOutlet weak var partialPointLabel: UILabel!
    @IBOutlet weak var pointsImageView: UIImageView!
    
    
    var selectedGame: GameProtocol!
    var parentVC: KMainGameBoardViewController?
    
    fileprivate var mainParams: String?
    fileprivate var totalPoint: Float = 0.0{
        didSet{
            totalPointLabel.text = String(format: "%.0f", totalPoint)
        }
    }
    fileprivate var startTimeQuestion: Float = 0.0
    fileprivate var endTimeQuestion: Float = 0.0
    fileprivate var indexQuestion: Int = 0
    fileprivate var coefPoint: Float = 0.0
    fileprivate var userPointsForAnswers: [Float] = [Float]()
    fileprivate var vcContainer: UIViewController?
    fileprivate var mainTimer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = KGameQuizAssets.background.image
        view.backgroundColor = UIColor(patternImage: image)
        
        headerView.backgroundColor = KGameQuiz.theme.color(.tint)
        footerView.backgroundColor = KGameQuiz.theme.color(.tint)
        exitButton.tintColor = KGameQuiz.theme.color(.tintText)
        gameTitleLabel.textColor = KGameQuiz.theme.color(.tintText)
        gameTimingLabel.textColor = KGameQuiz.theme.color(.tintText)
        totalPointLabel.textColor = KGameQuiz.theme.color(.tintText)
        partialPointLabel.textColor = KGameQuiz.theme.color(.tintText)
        
        timeImageView.image = KGameQuizAssets.icAlarm.image.withRenderingMode(.alwaysTemplate)
        timeImageView.tintColor = KGameQuiz.theme.color(.tintText)
        
        pointsImageView.image = KGameQuizAssets.icStarBorder.image.withRenderingMode(.alwaysTemplate)
        pointsImageView.tintColor = KGameQuiz.theme.color(.tintText)
        
        exitButton.setImage(KGameQuizAssets.icClose.image.withRenderingMode(.alwaysTemplate), for: .normal)
        exitButton.tintColor = KGameQuiz.theme.color(.tintText)
        
        hideComponents(true)
        
        totalPoint = 0.0
        
        gameTitleLabel.text = selectedGame.titlePartTitle
        let media = selectedGame.galleryMediaParts?.firstObject as? MediaPartProtocol
        gameImageView.setImage(media: media)
        if let part = selectedGame.gamePartReference{
            coefPoint = ((part.answerPoint ?? 0.0).floatValue/(part.answerTime ?? 0.0).floatValue)
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return (presentingViewController?.supportedInterfaceOrientations ?? .all)
    }
    
    func currentQuestionnaire() -> QuestionnaireProtocol{
        return selectedGame.questionariContentItems!.firstObject as! QuestionnaireProtocol
    }
    
    func currentQuestion() -> QuestionRecordProtocol{
        return currentQuestionnaire().questionnairePartReference!.questions![indexQuestion] as! QuestionRecordProtocol
    }
    
    func hideComponents(_ hide: Bool){
        timeImageView.isHidden = hide
        gameTimingLabel.isHidden = hide
        partialPointLabel.isHidden = hide
        totalPointLabel.isHidden = hide
        pointsImageView.isHidden = hide
        
    }
    
    func nextQuestion(){
        indexQuestion = indexQuestion + 1
        if indexQuestion < (currentQuestionnaire().questionnairePartReference?.questions?.count ?? 0){
            didStartGame()
        }else{
            gameIsFinished()
        }
    }
    
    func notResponded(){
        userPointsForAnswers.insert(0, at: indexQuestion)
        mainTimer?.invalidate()
        mainTimer = nil
        let vcQuestion = vcContainer as! KQuestionViewController
        vcQuestion.updateUserInterface(correctAnswer: false)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0) { 
            let alert = UIAlertController(title: KInfoPlist.appName,
                                          message: "r_u_ready".localizedString(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "leave".localizedString(), style: .cancel, handler: { (action) in
                self.closeGame(self)
            }))
            alert.addAction(UIAlertAction(title: "continua".localizedString(), style: .default, handler: { (alert) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0, execute: { 
                    self.nextQuestion()
                })
            }))
            DispatchQueue.main.async(execute: { 
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    func gameIsFinished(){
        mainTimer?.invalidate()
        mainTimer = nil
        footerView.removeFromSuperview()
        if let evc = storyboard?.instantiateViewController(withIdentifier: "EndViewController") as? KGameEndViewController
        {
            evc.totalPoints = totalPoint
            evc.gameDelegate = self
            evc.gameType = selectedGame.gamePartReference!.gameType!
            changeContainerViewController(evc)
        }
        hideComponents(true)
        if (selectedGame.gamePartReference?.gameType ?? "").hasPrefix("NoRanking"){
            gameCenterAuthenticationChanged()
        }
        
    }
    
    @objc func gameCenterAuthenticationChanged(){
        let localPlayer = GKLocalPlayer.local
        if localPlayer.isAuthenticated{
            sendPointsToGameCenter()
        }else{
            let alert = UIAlertController(title: "game_center_request".localizedString(),
                                           message: "game_center_login_now".localizedString(),
                                           preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "UNDO".localizedString(),
                                          style: .cancel,
                                          handler: nil))
            alert.addAction(UIAlertAction(title: "login".localizedString(),
                                          style: .default,
                                          handler: { (action) in
                                            UIApplication.shared.open(URL(string: "gamecenter:")!)
                                            let notificationName = NSNotification.Name(rawValue: "") //TODO: "" sostituire con GKPlayerAuthenticationDidChangeNotificationName
                                            assertionFailure("\"\" sostituire con GKPlayerAuthenticationDidChangeNotificationName")
                                            NotificationCenter.default.addObserver(self, selector: #selector(self.gameCenterAuthenticationChanged), name: notificationName, object: nil)
            }))
            DispatchQueue.main.async(execute: { 
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    func sendPointsToGameCenter(){
        if let idGameCenter = selectedGame.gamePartReference?.rankingIOSIdentifier{
            let score = GKScore(leaderboardIdentifier: idGameCenter)
            score.value = Int64(totalPoint)
            GKScore.report([score], withCompletionHandler: { (error) in
                if let error = error {
                    KMessageManager.showMessage(error.localizedDescription, type: .error, layout: .tabView)
                }else{
                    KMessageManager.showMessage("contest_participate".localizedString(), type: .success, layout: .tabView)
                }
            })
            NotificationCenter.default.removeObserver(self)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0, execute: {
                self.closeGameAfterPartecipate()
            })
        }
        
    }
    
    func askForUserTelephone(){
        let alert = UIAlertController(title: KInfoPlist.appName,
                                      message: "insert_phone_number".localizedString(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "UNDO".localizedString(),
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: "Ok".localizedString(),
                                      style: .default,
                                      handler: { (action) in
                                        let phoneUtil = NBPhoneNumberUtil()
                                        if var textValue = alert.textFields?[0].text{
                                            if textValue.hasPrefix("00"){
                                                let index1 = textValue.index(textValue.startIndex, offsetBy: 2)
                                                textValue = "+" + textValue[index1...]
                                            }
                                            if !textValue.hasPrefix("+"){
                                                textValue = "+39" + textValue
                                            }
                                            do {
                                                let myNumber = try phoneUtil.parse(withPhoneCarrierRegion: textValue)
                                                if phoneUtil.isValidNumber(myNumber){
                                                    var nationalNumber: NSString?
                                                    let countryCode = phoneUtil.extractCountryCode(textValue, nationalNumber: &nationalNumber)
                                                    self.mainParams = "+" + (countryCode ?? 0).stringValue + (nationalNumber ?? "").replacingOccurrences(of: " ", with: "")
                                                    
                                                    let alert = UIAlertController(title: KInfoPlist.appName,
                                                                                  message: String(format: "%@ +%@ %@", "check_your_number".localizedString(), (countryCode ?? 0).stringValue, (nationalNumber ?? "")), preferredStyle: .alert)
                                                    alert.addAction(UIAlertAction(title: "UNDO".localizedString(), style: .cancel, handler: nil))
                                                    alert.addAction(UIAlertAction(title: "Ok".localizedString(), style: .default, handler: { (action) in
                                                        UserDefaults.standard.setStringAndSync(self.mainParams!, forConstantKey: .userPhoneNumber)
                                                        self.sendGamePointsToWS(phoneNumber: self.mainParams!)
                                                        self.mainParams = nil
                                                    }))
                                                    DispatchQueue.main.async(execute: { 
                                                        self.present(alert, animated: true, completion: nil)
                                                    })
                                                }else{
                                                    KMessageManager.showMessage("sms_not_valid".localizedString(), type: .error, layout: .tabView)
                                                }
                                            }catch{
                                                KMessageManager.showMessage("sms_not_valid".localizedString(), type: .error, layout: .tabView)
                                            }
                                        }
                                        
        }))
        alert.addTextField { (textField) in
            textField.text = UserDefaults.standard.string(forConstantKey: .userPhoneNumber)
        }
        present(alert, animated: true, completion: nil)
    }
    
    func sendGamePointsToWS(phoneNumber: String)
    {
        if GKLocalPlayer.local.isAuthenticated
        {
            let manager = KNetworkManager.default(true, false, .http)

            let params: KParamaters = ["Point" : Int64(totalPoint), "Identifier": phoneNumber, "UsernameGameCenter": GKLocalPlayer.local.playerID,
            "Device": "Apple", "ContentIdentifier": selectedGame.identifier ?? 0]

            _ = manager.request(KAPIConstants.questionnairesGameRanking,
                                method: .post,
                                parameters: params,
                                query: [],
                                successCallback: { (task, responseObject) in
                                    if let object = responseObject{
                                        let obj = JSON(object)
                                        if let boolean = obj["Success"].bool, boolean{
                                            self.sendPointsToGameCenter()
                                        }else{
                                            KMessageManager.showMessage(obj["Message"].string ?? "", type: .error, layout: .tabView)
                                        }
                                    }else{
                                        KMessageManager.showMessage("Generic error".localizedString(), type: .error)
                                    }
            },
                                failureCallback: { (task, error) in
                                    KMessageManager.showMessage(error.localizedDescription, type: .error, layout: .tabView)
            })
            
        }else{
            KMessageManager.showMessage("Non puoi partecipare perchè non hai effettuato l'accesso al GameCenter".localizedString(), type: .error, layout: .tabView)
        }
    }
    
    @objc func refreshTimer(){
        var isValidTiming = true
        let diffTime = endTimeQuestion-Float(LBClock.shared().absoluteTime())
        if diffTime > 0 {
            gameTimingLabel.text = String(format: "%.1f", diffTime)
        }else{
            isValidTiming = false
        }
        
        let partialPoint = coefPoint*diffTime
        if partialPoint > 0 {
            partialPointLabel.text = String(format: "%.0f %@", partialPoint, "punti".localizedString())
        }else{
            partialPointLabel.text = ""
            isValidTiming = false
        }
        
        if !isValidTiming{
            notResponded()
            gameTimingLabel.text = "0.0"
            partialPointLabel.text = "0"
        }
    }
    
    func changeContainerViewController(_ vc: UIViewController){
        for view in containerView.subviews{
            view.removeFromSuperview()
        }
        containerView.addSubview(vc.view)
        let subview = vc.view!
        subview.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(0)-[subview]-(0)-|", options: .directionLeftToRight, metrics: nil, views: ["subview": subview]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[subview]-(0)-|", options: .directionLeftToRight, metrics: nil, views: ["subview": subview]))
        vcContainer?.removeFromParent()
        addChild(vc)
        vcContainer = vc
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? KGameStartViewController, segue.identifier == "startView"{
            destination.gameDelegate = self
            vcContainer = destination
        }
    }
    
    func closeGameAfterPartecipate(){
        dismiss(animated: true) { 
            self.parentVC?.showLeaderBoards(sender: self.selectedGame!)
        }
    }
    
    @IBAction func closeGame(_ sender: Any){
        mainTimer?.invalidate()
        mainTimer = nil
        vcContainer?.removeFromParent()
        vcContainer = nil
        dismissViewController()
    }
    
    //MARK: - GameControllerDelegate
    
    func didStartGame() {
        let qvc = storyboard!.instantiateViewController(withIdentifier: "QuestionViewController") as! KQuestionViewController
        qvc.questionDelegate = self
        qvc.question = currentQuestion()
        changeContainerViewController(qvc)
    }
    
    func partecipaAlContest() {
        AnalyticsCore.shared?.log(event: "game_completed", parameters: ["content_type" : "Game", "item_id" : selectedGame.identifier ?? 0])
        askForUserTelephone()
    }
    
    func controllerDidPresentQuestion(_ controller: KQuestionViewController) {
        hideComponents(false)
        mainTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refreshTimer), userInfo: 0, repeats: true)
        startTimeQuestion = Float(LBClock.shared().absoluteTime())
        endTimeQuestion = startTimeQuestion + selectedGame.gamePartReference!.answerTime!.floatValue
    }
    
    func controller(_ controller: KQuestionViewController, didSelectResponseAtIndex: Int, isCorrect: Bool) {
        let diffTime = endTimeQuestion-Float(LBClock.shared().absoluteTime())
        let pointsAssigned = diffTime*coefPoint
        mainTimer?.invalidate()
        mainTimer = nil
        partialPointLabel.text = String(format: "%.0f %@", pointsAssigned, "punti".localizedString())
        if isCorrect{
            userPointsForAnswers.insert(pointsAssigned, at: indexQuestion)
            totalPoint = totalPoint + pointsAssigned
        }else{
            userPointsForAnswers.insert(0, at: indexQuestion)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) { 
            self.nextQuestion()
        }
    }
    
}
