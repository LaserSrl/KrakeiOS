//
//  OpenAnswerStackView.swift
//  Krake
//
//  Created by Patrick on 28/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import LaserFloatingTextField

public protocol KQuestionViewProtocol: NSObject
{
    func refreshUI()
}


 public class KOpenAnswerStackView : UIView, KQuestionViewProtocol, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var titleQuestion: UILabel!{
        didSet{
            titleQuestion.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var answerTextView: UITextView!{
        didSet{
            answerTextView.delegate = self
        }
    }
    @IBOutlet weak var answerTextField: EGFloatingTextField!{
        didSet{
            answerTextField.delegate = self
        }
    }
    @IBOutlet weak var questImageView: UIImageView!
    @IBOutlet weak var titleQuestionWidth: NSLayoutConstraint!
    @IBOutlet weak var questImageWidth: NSLayoutConstraint!
    
    var theme: KQuestionnaireTheme!
    var dateFormatter: DateFormatter!
    var dateTimeFormatter: DateFormatter!
    weak var delegate: KQuestionnaireProtocol?
    
    var questionRecord: QuestionRecordProtocol!{
        didSet{
            if questionRecord != nil {
                switch questionRecord.answerTypeEnum
                {
                case .Datetime:
                    let picker = UIDatePicker()
                    picker.date = Date.networkTime()
                    picker.addTarget(self, action: #selector(changeDate(_:)), for: .valueChanged)
                    answerTextField.inputView = picker
                    answerTextField.inputAccessoryView = defaultToolbar()
                    answerTextField.isHidden = false
                    answerTextView.isHidden = true
                case .Date:
                    let picker = UIDatePicker()
                    picker.date = Date.networkTime()
                    picker.addTarget(self, action: #selector(changeDate(_:)), for: .valueChanged)
                    picker.datePickerMode = .date
                    answerTextField.inputView = picker
                    answerTextField.inputAccessoryView = defaultToolbar()
                    answerTextField.isHidden = false
                    answerTextView.isHidden = true
                case .Url:
                    answerTextField.validationType = .WebURL
                    answerTextField.isHidden = false
                    answerTextView.isHidden = true
                case .Email:
                    answerTextField.validationType = .Email
                    answerTextField.isHidden = false
                    answerTextView.isHidden = true
                case .Number:
                    answerTextField.validationType = .Integer
                    answerTextField.isHidden = false
                    answerTextView.isHidden = true
                case .None:
                    answerTextField.isHidden = true
                    answerTextView.isHidden = false
                }
                
                if let images = questionRecord.images {
                    
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(KOpenAnswerStackView.touchImage(_:)))
                    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(KOpenAnswerStackView.longPressImage(_:)))
                    questImageView.addGestureRecognizer(longPress)
                    questImageView.addGestureRecognizer(gesture)
                    questImageView.isUserInteractionEnabled = true
                    
                    questImageView.setImage(media: images.first, placeholderImage: nil, options:  KMediaImageLoadOptions(size: CGSize(width:3000,height: 3000), mode: .Pan))
                    questImageView.isHidden = false
                    theme.applyTheme(toImageView: questImageView, withQuestion: questionRecord)
                }else{
                    questImageView.isHidden = true
                }
                theme.applyTheme(toAnswerTextView: answerTextView, withQuestion: questionRecord)
                theme.applyTheme(toQuestionLabel: titleQuestion, forQuestion: questionRecord)
                if !((questionRecord.condition?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "").isEmpty)
                {
                    isHidden = questionRecord.conditionType == "Show"
                }
            }
        }
    }
    
    private func defaultToolbar() -> UIToolbar{
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44.0))
        let items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                     target: nil,
                                     action: nil),
                     UIBarButtonItem(barButtonSystemItem: .done,
                                     target: self,
                                     action: #selector(endEditing(_:)))]
        toolbar.setItems(items, animated: false)
        return toolbar
    }
    
    public static func loadFromNib(dateFormatter: DateFormatter? = nil, dateTimeFormatter: DateFormatter? = nil) -> KOpenAnswerStackView {
        let OCBundle = Bundle(for: KOpenAnswerStackView.self)
        let bundle = Bundle(url: OCBundle.url(forResource: "Questionnaires", withExtension: "bundle")!)
        
        let vc =  bundle!.loadNibNamed("KOpenAnswerStackView", owner: self, options: nil)!.first as! KOpenAnswerStackView
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        vc.dateFormatter = dateFormatter ?? formatter
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .short
        timeFormatter.timeStyle = .short
        vc.dateTimeFormatter = dateTimeFormatter ?? timeFormatter
        return vc
    }
        
    public func setContent(withThisQuestion question: QuestionRecordProtocol, withThisMAxSize maxWidth: CGFloat)
    {
        questionRecord = question
        titleQuestion.text = question.question
        
        setTitleWidth(constant: maxWidth-36)
        
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        delegate?.responseChanged(questionRecordIdentifier: questionRecord.identifier,
                                  answer: QuestionAnswer(QuestionRecord_Id: questionRecord.identifier?.intValue ?? 0,
                                                         AnswerText: answerTextView.text,
                                                         Id: nil))
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.responseChanged(questionRecordIdentifier: questionRecord.identifier,
                                  answer: QuestionAnswer(QuestionRecord_Id: questionRecord.identifier?.intValue ?? 0,
                                                         AnswerText: answerTextField.text,
                                                         Id: nil))
    }
    
    @objc private func changeDate(_ sender: UIDatePicker?) {
        
        if let sender = sender {
        switch questionRecord.answerTypeEnum {
        case .Date:
            answerTextField.text = dateFormatter.string(from: sender.date)
        case .Datetime:
            answerTextField.text = dateTimeFormatter.string(from: sender.date)
        default:
            break
        }
        }
    }
    
    @objc func touchImage(_ gesture: UITapGestureRecognizer){
        if let nav = (UIApplication.shared.delegate as! OGLAppDelegate).window!.rootViewController,
            let  array = questionRecord.images {

            nav.present(galleryController: array, target: gesture.view as? UIImageView)
        }
    }
    
    @objc func longPressImage(_ gesture: UILongPressGestureRecognizer) {
        if (questionRecord.images?.count ?? 0) > 1{
            let image = gesture.view as! UIImageView
            var mediaImage : Int? = nil

            if gesture.state == .began { mediaImage =  questionRecord.images![1]  }
            else if gesture.state == .ended { mediaImage =  questionRecord.images![0]  }


            if mediaImage != nil {
                image.setImage(media: mediaImage , placeholderImage: nil, options: KMediaImageLoadOptions(size: CGSize(width: 3000, height: 3000), mode: .Pan))
            }
        }
    }
    
    func setTitleWidth(constant: CGFloat = 40){
        
        if titleQuestionWidth == nil{
            let constraint = NSLayoutConstraint(item: titleQuestion, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: constant)
            constraint.priority = UILayoutPriority.priority(999)
            titleQuestion.addConstraint(constraint)
            titleQuestionWidth = constraint
        }else{
            titleQuestionWidth.constant = constant
        }
    }
    
    public func refreshUI() {
        if !((questionRecord.condition?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "").isEmpty)
        {
            if delegate?.answerInResponse(with: questionRecord.condition!) ?? false
            {
                isHidden = questionRecord.conditionType != "Show"
            }else{
                isHidden = questionRecord.conditionType == "Show"
            }
        }
    }
}
