//
//  OCQuestionnaire.swift
//  OCQuestionnaire
//
//  Created by Patrick on 23/12/15.
//  Copyright © 2015 Laser Group. All rights reserved.
//

import UIKit
import AudioToolbox
import MBProgressHUD

public protocol KQuestionnaireDelegate: NSObjectProtocol
{
    func viewDidLoad(_ viewController: QuestionnaireViewController)

    func viewWillAppear(_ viewController: QuestionnaireViewController)
    func viewDidAppear(_ viewController: QuestionnaireViewController)


    func viewWillDisappear(_ viewController: QuestionnaireViewController)
    func viewDidDisappear(_ viewController: QuestionnaireViewController)

    func questionnaire(questionnaire: QuestionnaireProtocol, willSendWith params: inout [QuestionAnswer])

    func questionnaireViewController(_ vc: QuestionnaireViewController, didSendQuestionnaire quesitonnaire: QuestionnaireProtocol)
}

public extension KQuestionnaireDelegate
{
    func questionnaire(questionnaire: QuestionnaireProtocol, willSendWith params: inout [QuestionAnswer]){
        
    }

    func questionnaireViewController(_ vc: QuestionnaireViewController, didSendQuestionnaire quesitonnaire: QuestionnaireProtocol)
    {

    }

    func viewDidLoad(_ viewController: QuestionnaireViewController) { }

    func viewWillAppear(_ viewController: QuestionnaireViewController) { }
    func viewDidAppear(_ viewController: QuestionnaireViewController) { }

    func viewWillDisappear(_ viewController: QuestionnaireViewController) { }
    func viewDidDisappear(_ viewController: QuestionnaireViewController) { }
}

public struct KQuestionnaireInfos {
    var endPoint: String
    var sendApiPath: String
    var theme: KQuestionnaireTheme
    var dateFormatter: DateFormatter? = nil
    var dateTimeFormatter: DateFormatter? = nil
    
    init(_ endPoint: String, sendApiPath: String = KAPIConstants.questionnairesResponse, theme: KQuestionnaireTheme = KQuestionnaireDefaultTheme()) {
        self.endPoint = endPoint
        self.sendApiPath = sendApiPath
        self.theme = theme
    }
}

open class KQuestionnaires: NSObject{
    
    
    public static func questionnaireViewController(_ questionaireInfos: KQuestionnaireInfos, delegate: KQuestionnaireDelegate? = nil) -> UIViewController{
        let OCBundle = Bundle(for: QuestionnaireViewController.self)
        let bundle = Bundle(url: OCBundle.url(forResource: "Questionnaires", withExtension: "bundle")!)
        let story = UIStoryboard(name: "KrakeQuestionnaires", bundle: bundle)
        let vc = story.instantiateInitialViewController() as! QuestionnaireViewController
        vc.questionnaireInfos = questionaireInfos
        vc.questionnaireDelegate = delegate
        return vc
    }
}

public class QuestionnaireViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var questionsStackView: UIStackView!
    @IBOutlet weak var mainScrollView: UIScrollView!

    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    
    public var questionnaireDelegate: KQuestionnaireDelegate? = nil

    public var questionnaireInfos: KQuestionnaireInfos!
    {
        didSet{
            endPoint = questionnaireInfos.endPoint
            apiPath = questionnaireInfos.sendApiPath
            theme = questionnaireInfos.theme
        }
    }
    public var endPoint: String!
    public var loginRequired: Bool = true
    var apiPath: String!
    var theme: KQuestionnaireTheme!
    var response = NSMutableDictionary()
    fileprivate var resultFetched: NSFetchedResultsController<NSFetchRequestResult>?
    fileprivate var loadTask: OMLoadDataTask? = nil
    fileprivate var questionnaire: QuestionnaireProtocol?{
        didSet{
            let prevTitle = parent?.tabBarItem.title
            title = questionnaire?.titlePartTitle
            if prevTitle != nil {
                parent?.tabBarItem.title = prevTitle
            }
              questionnairePart = questionnaire?.questionnairePartReference
        }
    }
    fileprivate var questionnairePart: QuestionnairePartProtocol?{
        didSet{
            loadQuestionsInStackView()
        }
    }
    fileprivate var openObserver: AnyObject?
    fileprivate var closeObserver: AnyObject?

    public var sendBarButton: UIBarButtonItem?

    deinit{
        KLog("RELEASED")
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        sendButton.setTitle("SEND".localizedString(), for: .normal)
        if navigationController == nil {
            sendView.isHidden = false
            sendButton?.isEnabled = false
        }else{
            sendView.removeFromSuperview()
            sendView.isHidden = true
            sendBarButton = createSendButtonItem()
            navigationItem.rightBarButtonItem = sendBarButton
            sendBarButton?.isEnabled = false
        }

        questionnaireDelegate?.viewDidLoad(self)

        MBProgressHUD.showAdded(to: view, animated: true)
        loadTask = OGLCoreDataMapper.sharedInstance().loadData(withDisplayAlias: endPoint!, extras: KRequestParameters.parametersNoCache(), loginRequired: loginRequired, completionBlock: { [weak self] (parsed, error, completed) -> Void in
            if let mySelf = self {
                if parsed != nil && error == nil && completed {
                    let cache = OGLCoreDataMapper.sharedInstance().displayPathCache(from: parsed!)
                    if let elem = cache.cacheItems.firstObject as? QuestionnaireProtocol{
                        mySelf.questionnaire = elem
                        mySelf.sendBarButton?.isEnabled = true
                        mySelf.sendButton?.isEnabled = true
                    }else{
                        _ = mySelf.navigationController?.popViewController(animated: true)
                        KMessageManager.showMessage("QUESTIONNAIRE_NOT_AVAILABLE".localizedString(), type: .success)
                        
                    }
                }else if error != nil{
                    KMessageManager.showMessage(error!.localizedDescription, type: .error)
                }
                MBProgressHUD.hide(for: mySelf.view, animated: true)
            }
            })
        
        theme.applyTheme(toView: view)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        questionnaireDelegate?.viewWillAppear(self)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        questionnaireDelegate?.viewDidAppear(self)
        
        openObserver = NotificationCenter.default.addObserver(forName: KKeyboardDidShowNotification, object: nil, queue: nil) { [weak self] (notification: Notification) -> Void in
            if let mySelf = self {
                let rect = ((notification as NSNotification).userInfo![KKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                mySelf.mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: rect.height, right: 0)
                mySelf.mainScrollView.scrollIndicatorInsets = mySelf.mainScrollView.contentInset
                let mio: UIView? = UIResponder.currentFirstResponder() as? UIView
                var aRect = mySelf.mainScrollView.frame
                aRect.size.height -= rect.height
                let point = CGPoint(x: 0, y: mio!.frame.origin.y+mio!.superview!.superview!.frame.origin.y+mio!.frame.size.height-aRect.size.height)
                mySelf.mainScrollView.setContentOffset(point, animated: true)
            }
        }
        closeObserver = NotificationCenter.default.addObserver(forName: KKeyboardDidHideNotification, object: nil, queue: nil) { [weak self] (notification: Notification) -> Void in
            if let mySelf = self {
                mySelf.mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
                mySelf.mainScrollView.scrollIndicatorInsets = mySelf.mainScrollView.contentInset
            }
        }
    }

    override public func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        questionnaireDelegate?.viewWillDisappear(self)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        questionnaireDelegate?.viewDidDisappear(self)
        if openObserver != nil {
            NotificationCenter.default.removeObserver(openObserver!)
            openObserver = nil
        }
        if closeObserver != nil {
            NotificationCenter.default.removeObserver(closeObserver!)
            closeObserver = nil
        }
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        for myView in questionsStackView.subviews {
            if let singleChoiceView = myView as? KSingleOrMultiChoiceStackView {
                
                singleChoiceView.setTitleWidth(constant: size.width)
            }
        }
    }

    public func createSendButtonItem()  -> UIBarButtonItem {
        return UIBarButtonItem(title: "SEND".localizedString(),
                            style: .done,
                            target: self,
                            action: #selector(QuestionnaireViewController.sendQuestionnaire(_:)))
    }
    
    func loadQuestionsInStackView()
    {
        if let domande = questionnairePart?.questions?.array as? [QuestionRecordProtocol]{
            for question in domande{
                switch question.questionTypeEnum {
                case .OpenAnswer:
                    let openAns = KOpenAnswerStackView.loadFromNib(dateFormatter: questionnaireInfos.dateFormatter, dateTimeFormatter: questionnaireInfos.dateTimeFormatter)
                    openAns.theme = theme
                    openAns.setContent(withThisQuestion: question, withResponse: response, withThisMAxSize: questionsStackView.bounds.width)
                    questionsStackView.addArrangedSubview(openAns)
                    theme.applyTheme(toView: openAns, withQuestion: question)
                    break
                case .SingleChoice, .MultiChoice:
                    let singleOrMultiChoice = KSingleOrMultiChoiceStackView.loadFromNib()
                    singleOrMultiChoice.theme = theme
                    singleOrMultiChoice.setContent(withThisQuestion: question, withResponse: response, withThisMAxSize: questionsStackView.bounds.width)
                    questionsStackView.addArrangedSubview(singleOrMultiChoice)
                    theme.applyTheme(toView: singleOrMultiChoice, withQuestion: question)
                    break
                case .Unknown:
                    KLog(type: .error, "QuestionType '%@' not supported.", question.questionType ?? "EmptyQuestionType")
                    break
                }
            }
        }
        view.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0) { 
            self.view.layoutIfNeeded()
        }
    }
  
    //MARK: - Send Questionnaire to WS
    
    @IBAction func sendQuestionnaire(_ sender: AnyObject){
        if response.allKeys.count == 0 {
            KMessageManager.showMessage("QUESTIONNAIRE_NOT_COMPILED".localizedString(), type: .error)
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }else{
            var risposte = [QuestionAnswer]()
            for key in response.allKeys {
                let resp = response[key as! String]!
                if let resps = resp as? NSArray{
                    for resp in resps{
                        risposte.append(resp as! QuestionAnswer)
                    }
                }else{
                    risposte.append(resp as! QuestionAnswer)
                }
            }
            questionnaireDelegate?.questionnaire(questionnaire: questionnaire!, willSendWith: &risposte)
            let manager = KNetworkManager.defaultManager(true)
            MBProgressHUD.showAdded(to: view, animated: true)

            let request = KCodableRequest(risposte)
            request.method = .post
            request.path = apiPath
            request.requestSerializer = .json

            _ = manager.request(codable: request,
                                successCallback: { [weak self] (task, responseObject) -> Void in
                                if let mySelf = self {
                                    MBProgressHUD.hide(for: mySelf.view, animated: true)
                                    if let responseObj = responseObject as? [String : AnyObject],
                                        let response = KrakeResponse(object: responseObj){
                                        if response.success {
                                            KMessageManager.showMessage("QUESTIONNAIRE_COMPLETED".localizedString(), type: .success)
                                            mySelf.questionnaireDelegate?.questionnaireViewController(mySelf, didSendQuestionnaire: mySelf.questionnaire!)

                                            if let classType = object_getClass(mySelf.questionnaire!) {
                                                AnalyticsCore.shared?.log(event: "survey_answered",parameters:["item_id":mySelf.questionnaire!.autoroutePartDisplayAlias!,
                                                    "content_type":classType.description()])
                                            }
                                            if (mySelf.presentingViewController != nil) {
                                                mySelf.presentingViewController?.dismissViewController()
                                            }
                                            else if (mySelf.navigationController?.viewControllers.last == self) {
                                                _ = mySelf.navigationController?.popViewController(animated: true)
                                            }
                                        }else{
                                            KMessageManager.showMessage(response.message, type: .error) //Programmata
                                        }
                                    }else{
                                        KMessageManager.showMessage("QUESTIONNAIRE_ERROR".localizedString(), type: .error)
                                    }

                                }
                                },
                                failureCallback: { [weak self](task, error) -> Void in
                                        if let view = self?.view{
                                            MBProgressHUD.hide(for: view, animated: true)
                                        }
                                        KMessageManager.showMessage(error.localizedDescription, type: .error)
                                }
            )
        
        }
    }
}


public struct QuestionAnswer: Codable, Equatable {
    let QuestionRecord_Id: Int
    let AnswerText: String?
    let Id: Int?
}
