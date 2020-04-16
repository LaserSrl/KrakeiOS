//
//  KQuestionnaireTheme.swift
//  Krake
//
//  Created by Patrick on 28/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation

public protocol KQuestionnaireTheme: NSObjectProtocol{
    
    //richiamato al termine della viewDidLoad del questionnaireViewController
    func applyTheme(toView view: UIView)
    
    //richiamato dopo aver generato una KSingleChoiceStackView oppure una KOpenAnswerStackView
    func applyTheme(toView view: UIView, withQuestion: QuestionRecordProtocol)
    
    //richiamato dopo aver generato un pulsante nella KSingleChoiceStackView
    func applyTheme(toAnswerButton button: UIButton, withQuestion: QuestionRecordProtocol, andAnswer: AnswerRecordProtocol)
    
    //richiamato dopo aver generato la textview nella KOpenAnswerStackView
    func applyTheme(toAnswerTextView textView: UITextView, withQuestion: QuestionRecordProtocol)
    
    //richiamato dopo aver generato la imageView nella KOpenAnswerStackView oppure nella KSingleChoiceStackView
    func applyTheme(toImageView imageView: UIImageView, withQuestion: QuestionRecordProtocol)
    
    //per stilizzare solo la label della domanda
    func applyTheme(toQuestionLabel title: UILabel, forQuestion: QuestionRecordProtocol)
    
    //per stilizzare solo la label della section
    func applyTheme(toSectionLabel title: UILabel, forQuestion: QuestionRecordProtocol)
    
    //utilizzato per decidere nella KSingleChoiceStackView l'orientamento dello stackview delle risposte
    func isVerticalOrientation(_ question: QuestionRecordProtocol) -> Bool
    
    //in caso di KSingleChoiceStackView, in caso di orientamento orizzontale dello stackview delle risposte,
    //fornisce la dimensione del pulsante per dare un coinstraint di height allo stackview
    func answerHeightStackView(for question: QuestionRecordProtocol) -> CGFloat

    func zoomLevel(for answer: AnswerRecordProtocol, in question: QuestionRecordProtocol) -> CGFloat
}

extension KQuestionnaireTheme{
    
    public func applyTheme(toView view: UIView){
        KTheme.current.applyTheme(toView: view, style: .default)
    }
    
    //richiamato dopo aver generato ogni singola domanda
    public func applyTheme(toView view: UIView, withQuestion: QuestionRecordProtocol){
        view.backgroundColor = UIColor ( red: 0.89, green: 0.89, blue: 0.89, alpha: 1.0 )
    }
    
    //richiamato dopo aver generato un pulsante nella KSingleChoiceStackView
    public func applyTheme(toAnswerButton button: UIButton, withQuestion: QuestionRecordProtocol, andAnswer: AnswerRecordProtocol) {
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitleColor(KTheme.current.color(.tint), for: .selected)

        if !isVerticalOrientation(withQuestion)
        {
            let constraintW = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 60)
            constraintW.priority = UILayoutPriority(rawValue: 999)
            button.addConstraint(constraintW)
            let constraintH = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 60)
            constraintH.priority = UILayoutPriority(rawValue: 999)
            button.addConstraint(constraintH)
        }
    }
    
    
    //richiamato dopo aver generato la textview nella KOpenAnswerStackView
    public func applyTheme(toAnswerTextView textView: UITextView, withQuestion: QuestionRecordProtocol){
        
    }
    
    //richiamato dopo aver generato la imageView nella KOpenAnswerStackView oppure nella KSingleChoiceStackView
    public func applyTheme(toImageView imageView: UIImageView, withQuestion: QuestionRecordProtocol){
        
    }
    
    public func applyTheme(toQuestionLabel title: UILabel, forQuestion: QuestionRecordProtocol){
        title.textColor = UIColor.black
    }
    
    public func applyTheme(toSectionLabel title: UILabel, forQuestion: QuestionRecordProtocol){
        title.textColor = UIColor.black
        title.font = UIFont.preferredFont(forTextStyle: .headline)
    }
    
    public func isVerticalOrientation(_ question: QuestionRecordProtocol) -> Bool {
        if question.answers!.count > 3 {
            return true
        }
        return false
    }
    
    //fornisce la dimensione del pulsante di risposta. é usato anche per dare una dimensione allo stackview orizzontale 
    //delle risposte
    
    public func answerHeightStackView(for question: QuestionRecordProtocol) -> CGFloat{
        return 100.0
    }

    public func zoomLevel(for answer: AnswerRecordProtocol, in question: QuestionRecordProtocol) -> CGFloat
    {
        return 1.3
    }
}

public class KQuestionnaireDefaultTheme: NSObject, KQuestionnaireTheme{

    
}
