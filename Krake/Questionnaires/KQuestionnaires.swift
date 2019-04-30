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

    func questionnaire(questionnaire: QuestionnaireProtocol, willSendWith params: inout [Any])

    func questionnaireViewController(_ vc: QuestionnaireViewController, didSendQuestionnaire quesitonnaire: QuestionnaireProtocol)
}

public extension KQuestionnaireDelegate
{
    func questionnaire(questionnaire: QuestionnaireProtocol, willSendWith params: inout [Any]){
        
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

open class KQuestionnaires: NSObject{
    
    public static func questionnaireViewController(_ endPoint: String, sendApiPath: String = KAPIConstants.questionnairesResponse, theme: KQuestionnaireTheme = KQuestionnaireDefaultTheme(), delegate: KQuestionnaireDelegate? = nil) -> UIViewController{
        let OCBundle = Bundle(for: QuestionnaireViewController.self)
        let bundle = Bundle(url: OCBundle.url(forResource: "Questionnaires", withExtension: "bundle")!)
        let story = UIStoryboard(name: "KrakeQuestionnaires", bundle: bundle)
        let vc = story.instantiateInitialViewController() as! QuestionnaireViewController
        vc.endPoint = endPoint
        vc.theme = theme
        vc.questionnaireDelegate = delegate
        vc.apiPath = sendApiPath
        return vc
    }
}

public class QuestionnaireViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var questionsStackView: UIStackView!
    @IBOutlet weak var mainScrollView: UIScrollView!

    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    
    var questionnaireDelegate: KQuestionnaireDelegate? = nil

    var endPoint: String!
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

    fileprivate var sendBarButton: UIBarButtonItem?
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
            sendBarButton = UIBarButtonItem(title: "SEND".localizedString(), style: .done, target: self, action: #selector(QuestionnaireViewController.sendQuestionnaire(_:)))
            navigationItem.rightBarButtonItem = sendBarButton
            sendBarButton?.isEnabled = false
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        loadTask = OGLCoreDataMapper.sharedInstance().loadData(withDisplayAlias: endPoint!, extras: KRequestParameters.parametersNoCache(), loginRequired: true, completionBlock: { [weak self] (parsed, error, completed) -> Void in
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

        questionnaireDelegate?.viewDidLoad(self)
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
        NotificationCenter.default.removeObserver(openObserver!)
        NotificationCenter.default.removeObserver(closeObserver!)
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        for myView in questionsStackView.subviews {
            if let singleChoiceView = myView as? KSingleOrMultiChoiceStackView {
                
                singleChoiceView.setTitleWidth(constant: size.width)
            }
        }
    }
    
    func loadQuestionsInStackView()
    {
        if let domande = questionnairePart?.questions?.array as? [QuestionRecordProtocol]{
            for question in domande{
                switch question.questionTypeEnum {
                case .OpenAnswer:
                    let openAns = KOpenAnswerStackView.loadFromNib()
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
            var risposte = [Any]()
            for key in response.allKeys {
                let resp = response[key as! String]!
                if let resps = resp as? NSArray{
                    for resp in resps{
                        risposte.append(resp)
                    }
                }else{
                    risposte.append(resp)
                }
            }
            questionnaireDelegate?.questionnaire(questionnaire: questionnaire!, willSendWith: &risposte)
            let manager = KNetworkManager.defaultManager(true)
            MBProgressHUD.showAdded(to: view, animated: true)
            _ = manager.post(apiPath, parameters: risposte, progress: nil, success: { [weak self] (task, responseObject) -> Void in
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
                            _ = mySelf.navigationController?.popViewController(animated: true)
                        }else{
                            KMessageManager.showMessage(response.message, type: .error) //Programmata
                        }
                    }else{
                        KMessageManager.showMessage("QUESTIONNAIRE_ERROR".localizedString(), type: .error)
                    }
                    
                }
                }, failure: { [weak self](task, error) -> Void in
                    if let view = self?.view{
                        MBProgressHUD.hide(for: view, animated: true)
                    }
                    KMessageManager.showMessage(error.localizedDescription, type: .error)
            })
        }
    }
}




