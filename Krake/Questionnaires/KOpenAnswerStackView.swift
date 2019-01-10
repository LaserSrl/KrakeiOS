//
//  OpenAnswerStackView.swift
//  Krake
//
//  Created by Patrick on 28/07/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation



 public class KOpenAnswerStackView : UIView, UITextViewDelegate {
    
    
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
    @IBOutlet weak var questImageView: UIImageView!
    
    var theme: KQuestionnaireTheme!
    var arrayImages: [String]? = nil
    @IBOutlet weak var titleQuestionWidth: NSLayoutConstraint!
    @IBOutlet weak var questImageWidth: NSLayoutConstraint!
    
    
    var questionRecord: QuestionRecordProtocol!{
        didSet{
            if questionRecord != nil {
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
            }
        }
    }
    var response: NSMutableDictionary!{
        didSet{
            if response != nil {
                if let dic = response[questionRecord.identifier.stringValue] as? [String: String] {
                    answerTextView.text = dic["AnswerText"]
                }
            }
        }
    }
    
    public static func loadFromNib() -> KOpenAnswerStackView {
        let OCBundle = Bundle(for: KOpenAnswerStackView.self)
        let bundle = Bundle(url: OCBundle.url(forResource: "Questionnaires", withExtension: "bundle")!)
        
        return bundle!.loadNibNamed("KOpenAnswerStackView", owner: self, options: nil)!.first as! KOpenAnswerStackView
        
    }
        
    public func setContent(withThisQuestion question: QuestionRecordProtocol, withResponse response: NSMutableDictionary, withThisMAxSize maxWidth: CGFloat)
    {
        questionRecord = question
        self.response = response
        titleQuestion.text = question.question
        
        setTitleWidth(constant: maxWidth-36)
        
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        response[questionRecord.identifier.stringValue] = ["QuestionRecord_Id" : questionRecord.identifier ?? 0, "AnswerText" : answerTextView.text]
    }
    
    
    
    @objc func touchImage(_ gesture: UITapGestureRecognizer){
        if let nav = (UIApplication.shared.delegate as! OGLAppDelegate).window!.rootViewController as? UINavigationController {
            var array = [Int]()
            for img in arrayImages!{
                array.append(Int(img)!)
            }
            nav.present(galleryController: array, target: gesture.view as? UIImageView)
        }
    }
    
    @objc func longPressImage(_ gesture: UILongPressGestureRecognizer){
        if (arrayImages?.count ?? 0) > 1{
            let image = gesture.view as! UIImageView
            var mediaImage : String? = nil

            if gesture.state == .began { mediaImage =  arrayImages![1]  }
            else if gesture.state == .ended { mediaImage =  arrayImages![0]  }


            if mediaImage != nil {
                image.setImage(media: Int(mediaImage!) , placeholderImage: nil, options: KMediaImageLoadOptions(size: CGSize(width: 3000, height: 3000), mode: .Pan))
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
    
}
