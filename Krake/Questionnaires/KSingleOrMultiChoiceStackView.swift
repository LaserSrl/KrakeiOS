//
//  SingleChoiceStackView.swift
//  Krake
//
//  Created by Patrick on 28/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation

public class KSingleOrMultiChoiceStackView : UIView, KQuestionViewProtocol {

    @IBOutlet weak var titleQuestion: UILabel!{
        didSet{
            titleQuestion.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var questImageView: UIImageView!
    @IBOutlet weak public var answersStackView: UIStackView!
    @IBOutlet weak var titleQuestionWidth: NSLayoutConstraint!
    @IBOutlet weak var answersStackViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var questImageWidth: NSLayoutConstraint!
    
    weak var delegate: KQuestionnaireProtocol?
    var theme: KQuestionnaireTheme!
    
    var questionRecord: QuestionRecordProtocol!{
        didSet{
            if questionRecord != nil {
                
                let verticalOrientation = theme.isVerticalOrientation(questionRecord)
                if let images = questionRecord.images {
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(KSingleOrMultiChoiceStackView.touchImage(_:)))
                    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(KSingleOrMultiChoiceStackView.longPressImage(_:)))
                    questImageView.addGestureRecognizer(longPress)
                    questImageView.addGestureRecognizer(gesture)
                    questImageView.isUserInteractionEnabled = true
                    questImageView.setImage(media: images.first, placeholderImage: nil, options:  KMediaImageLoadOptions(size: CGSize(width:3000,height: 3000), mode: .Pan))
                    questImageView.isHidden = false
                    theme.applyTheme(toImageView: questImageView, withQuestion: questionRecord)
                }else{
                    questImageView.isHidden = true
                }
                
                
                for v in answersStackView.arrangedSubviews {
                    answersStackView.removeArrangedSubview(v)
                }
                
                if verticalOrientation {
                    answersStackView.axis = KLayoutConstraintAxis.vertical
                }
                else if questionRecord.answers!.count > 0 {
                    let heightInTheme = theme.answerHeightStackView(for: questionRecord)
                    let heightContraint = NSLayoutConstraint(item: answersStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: heightInTheme)
                    heightContraint.priority = UILayoutPriority(rawValue: 999)
                    answersStackView.addConstraint(heightContraint)
                }
                
                for resp in questionRecord.answers!{
                    if let risp = resp as? AnswerRecordProtocol, let published = risp.published , published.boolValue{
                        let button = ResizableButton()
                        button.tag = risp.identifier.intValue
                        button.setTitle(risp.answer, for: .normal)
                        button.clipsToBounds = true
                        if questionRecord!.questionTypeEnum == .MultiChoice{
                            button.addTarget(self, action: #selector(KSingleOrMultiChoiceStackView.chooseButtonMultiChoice(_:)), for: .touchUpInside)
                        }else {
                            button.addTarget(self, action: #selector(KSingleOrMultiChoiceStackView.chooseButton(_:)), for: .touchUpInside)
                        }
                        
                        
                        button.translatesAutoresizingMaskIntoConstraints = false
                        if let image = risp.images?.first {
                            UIImage.downloadImage(KMediaImageLoader.generateURL(forMediaPath: String(format:"%d", image), mediaImageOptions: KMediaImageLoadOptions(),imageView: UIImageView()) , completed: { (image, error,  cache, url) in
                                if image != nil{
                                    button.setImage(image, for: .normal)
                                    button.setTitle(nil, for: .normal)
                                    self.theme.applyTheme(toAnswerButton: button, withQuestion: self.questionRecord, andAnswer: risp)
                                }
                            })
                        }else{
                            theme.applyTheme(toAnswerButton: button, withQuestion: questionRecord, andAnswer: risp)
                        }
                        
                        answersStackView.addArrangedSubview(button)
                    }
                }
                if !((questionRecord.condition?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "").isEmpty)
                {
                    isHidden = questionRecord.conditionType == "Show"
                }
            }
        }
    }
    var response: NSMutableDictionary!
    
    public static func loadFromNib() -> KSingleOrMultiChoiceStackView {
        let OCBundle = Bundle(for: KSingleOrMultiChoiceStackView.self)
        let bundle = Bundle(url: OCBundle.url(forResource: "Questionnaires", withExtension: "bundle")!)
        return bundle!.loadNibNamed("KSingleOrMultiChoiceStackView", owner: self, options: nil)!.first as! KSingleOrMultiChoiceStackView
    }
    
    public func setContent(withThisQuestion question: QuestionRecordProtocol, withResponse response: NSMutableDictionary, withThisMAxSize maxWidth: CGFloat)
    {
        questionRecord = question
        self.response = response
        titleQuestion.text = question.question
        
        setTitleWidth(constant: maxWidth-36)

    }
    
    @objc func chooseButton(_ button: UIButton){
        var transform: CGAffineTransform!
        var ans: AnswerRecordProtocol?
        var index = 0
        if button.isSelected
        {
            transform = CGAffineTransform(scaleX: 1.0,y: 1.0)
            button.isSelected = false
            UIView.beginAnimations("ScaleButton", context: nil)
            UIView.setAnimationDuration(0.5)
            button.transform = transform
            UIView.commitAnimations()
        }
        else
        {
            //choosing a response, any previously given response will be canceled
            for case let but as UIButton in answersStackView.subviews
            {
                if but != button{
                    transform = CGAffineTransform(scaleX: 1.0,y: 1.0)
                    but.isSelected = false
                }else{
                    ans = (questionRecord.answers![index] as! AnswerRecordProtocol)
                    let zoom = theme.zoomLevel(for: ans!, in: questionRecord)
                    transform = CGAffineTransform(scaleX: zoom,y: zoom)
                    but.isSelected = true
                    
                }
                
                UIView.beginAnimations("ScaleButton", context: nil)
                UIView.setAnimationDuration(0.5)
                but.transform = transform
                UIView.commitAnimations()
                
                index = index + 1
            }
        }
        if let ans = ans {
            delegate?.responseChanged(questionRecordIdentifier: questionRecord.identifier,
                                  answer: QuestionAnswer(QuestionRecord_Id: questionRecord.identifier.intValue,
                                                         AnswerText: nil,
                                                         Id: ans.identifier.intValue))
        }else{
            delegate?.responseChanged(questionRecordIdentifier: questionRecord.identifier,
                                      answer: nil)
            
        }
    }
    
    @objc func chooseButtonMultiChoice(_ button: UIButton){
        var transform: CGAffineTransform!
        var currentAnswerInQuestionToSave: QuestionAnswer
        var arrayOfAnswersInQuestion: [QuestionAnswer] = [QuestionAnswer]()
        
        if response[questionRecord.identifier.stringValue] != nil {
            arrayOfAnswersInQuestion = response[questionRecord.identifier.stringValue] as! [QuestionAnswer]
        }
        currentAnswerInQuestionToSave = QuestionAnswer(QuestionRecord_Id: questionRecord.identifier.intValue,
        AnswerText: nil,
        Id:  (button.tag as NSNumber).intValue)

        //check if the answer was already selected
        let answerAlreadySelected = arrayOfAnswersInQuestion.filter({ $0 == currentAnswerInQuestionToSave}).first
        
        //if the answer was not already selected, it will be selected
        if answerAlreadySelected == nil {
            let ans: AnswerRecordProtocol = questionRecord.answers!.filter({ (answer) -> Bool in
                return (answer as! AnswerRecordProtocol).identifier.intValue == button.tag
            }).first as! AnswerRecordProtocol
            let zoom = theme.zoomLevel(for: ans, in: questionRecord)
            transform = CGAffineTransform(scaleX: zoom,y: zoom)
            button.isSelected = true
            arrayOfAnswersInQuestion.append(currentAnswerInQuestionToSave)
        }
        else {//if the answer was already selected, it will be deselected
            transform = CGAffineTransform(scaleX: 1.0,y: 1.0)
            button.isSelected = false
            var index = 0
            for item in arrayOfAnswersInQuestion{
                if item.Id == (button.tag as NSNumber).intValue{
                    arrayOfAnswersInQuestion.remove(at: index)
                }
                index = index + 1
            }
        }
        UIView.beginAnimations("ScaleButton", context: nil)
        UIView.setAnimationDuration(0.5)
        button.transform = transform
        UIView.commitAnimations()
        if arrayOfAnswersInQuestion.count > 0
        {
            delegate?.responseChanged(questionRecordIdentifier: questionRecord.identifier, answer: arrayOfAnswersInQuestion)
        }
        else
        {
            delegate?.responseChanged(questionRecordIdentifier: questionRecord.identifier, answer: nil)
        }
    }
    
    @objc func touchImage(_ gesture: UITapGestureRecognizer){
        if let nav = (UIApplication.shared.delegate as! OGLAppDelegate).window!.rootViewController,
            let array = questionRecord.images {

            nav.present(galleryController: array, target: gesture.view as? UIImageView)
        }
    }
    
    @objc func longPressImage(_ gesture: UILongPressGestureRecognizer){
        if questionRecord.images?.count ?? 0 > 1{
            let image = gesture.view as! UIImageView
            
            if gesture.state == .began {
                image.setImage(media: questionRecord.images![1], placeholderImage: nil, options: KMediaImageLoadOptions(size: CGSize(width: 3000,height: 3000), mode: .Pan))
            }
            if gesture.state == .ended {
                image.setImage(media: questionRecord.images![0], placeholderImage: nil, options: KMediaImageLoadOptions(size: CGSize(width:3000,height: 3000), mode: .Pan))
            }
        }
    }
    
    public func setTitleWidth(constant: CGFloat = 40){
        
        if titleQuestionWidth == nil{
            let constraint = NSLayoutConstraint(item: titleQuestion, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: constant)
            constraint.priority = UILayoutPriority.priority(999)
            titleQuestion.addConstraint(constraint)
            titleQuestionWidth = constraint
        }else{
            titleQuestionWidth.constant = constant
        }
    }
    
    public func refreshUI()
    {
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

class ResizableButton: UIButton {
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.lineBreakMode = .byWordWrapping
        self.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
    
    // MARK: - Overrides
    
    override var intrinsicContentSize: CGSize {
        return titleLabel?.intrinsicContentSize ?? imageView?.intrinsicContentSize ?? CGSize.zero
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = titleLabel?.frame.size.width ?? imageView?.frame.size.width ?? 0
    }
    
}

