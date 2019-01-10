//
//  KQuestionViewController.swift
//  Krake
//
//  Created by joel on 05/09/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

open class KQuestionViewController : UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    open var question : QuestionRecordProtocol? = nil{
        didSet{
            if let ans = question?.answers?.array as? [AnswerRecordProtocol] {
                answers = [AnswerRecordProtocol]()
                for answer in ans where (answer.published ?? false).boolValue {
                    answers?.append(answer)
                }
                tableView?.reloadData()
            }
        }
    }
    
    open weak var questionDelegate : GameControllerDelegate? = nil
    
    @IBOutlet weak var coverView : UIView?
    @IBOutlet weak var baloonCoverView : UIView?
    @IBOutlet weak var firstLabelCoverView : UILabel?
    @IBOutlet weak var secondLabelCoverView : UILabel?
    @IBOutlet weak var baloonCoverImageView : UIImageView?
    @IBOutlet weak var questionLabel : UILabel?
    @IBOutlet weak var questionImageView : UIImageView?
    @IBOutlet weak var tableView : UITableView?
    
    fileprivate var answers : [AnswerRecordProtocol]?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if let questionLabel = self.questionLabel {
            questionLabel.text = self.question!.question
            questionLabel.textColor = KGameQuiz.theme.color(.text)
            questionLabel.adjustsFontSizeToFitWidth = true
            coverView?.alpha = 0.1
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let image = question?.images?.first, let url = KMediaImageLoader.generateURL(forMediaPath: String(format:"%d", image), mediaImageOptions: KMediaImageLoadOptions(mode: ImageResizeMode.Max)){
            questionImageView?.sd_setImage(with: url, completed: { (image, error, cache, url) in
                if image != nil {
                    self.presentQuestion()
                }
            })
        }else {
            presentQuestion()
        }
    }
    
    fileprivate func presentQuestion()
    {
        UIView.animate(withDuration: 0.3, animations: {
            self.coverView?.alpha = 0
            self.questionDelegate?.controllerDidPresentQuestion(self)
        })
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let rowHeight = tableView!.frame.size.height / CGFloat((answers?.count ?? 1))
        tableView?.rowHeight = rowHeight > 80 ? 80 : rowHeight
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers?.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let label = cell.viewWithTag(100) as! UILabel
        let answer = answers![indexPath.row]
        label.text = answer.answer
        label.backgroundColor = KGameQuiz.theme.color(.cellBackground)
        label.textColor = KGameQuiz.theme.color(.cellText)
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let answer = answers![indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        let backgroundColorView = UIView()
        let correct = answer.correctResponse!.boolValue
        backgroundColorView.backgroundColor = KGameQuiz.theme.color(correct ? .correct : .wrong)
        cell?.selectedBackgroundView = backgroundColorView
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isUserInteractionEnabled = false
        self.questionDelegate?.controller(self, didSelectResponseAtIndex: indexPath.row, isCorrect: correct)
        updateUserInterface(correctAnswer: correct)
    }
    
    open func updateUserInterface(correctAnswer correct: Bool)
    {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            if let sSelf = self
            {
                sSelf.baloonCoverView?.layer.cornerRadius = sSelf.baloonCoverView!.frame.size.width / 2.0
                sSelf.baloonCoverView?.backgroundColor = KGameQuiz.theme.color(correct ? .correct : .wrong)
                let imageName = correct ? "correct" : "wrong"
                sSelf.baloonCoverImageView!.image = UIImage(named: imageName, in: Bundle(for: KQuestionViewController.self), compatibleWith: nil)
                sSelf.firstLabelCoverView?.text = (correct ? "bravo" : "ops").localizedString()
                sSelf.secondLabelCoverView?.text = (correct ? "risposta_corretta" : "risposta_errata").localizedString()
                sSelf.coverView?.alpha = 1
            }
            AudioServicesPlaySystemSound(correct ? 1057 : kSystemSoundID_Vibrate)
        })
    }
}


@objc public protocol GameControllerDelegate
{
    func didStartGame()
    func partecipaAlContest()
    
    func controllerDidPresentQuestion(_ controller : KQuestionViewController)
    
    func controller(_ controller : KQuestionViewController, didSelectResponseAtIndex: Int, isCorrect : Bool)
}
