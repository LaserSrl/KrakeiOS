//
//  KGameEndViewController.swift
//  Pods
//
//  Created by Patrick on 29/06/17.
//
//

import Foundation

class KGameEndViewController: UIViewController {
    
    weak var gameDelegate: KMainGameViewController?
    
    @IBOutlet weak var backgroundStar: UIView!
    @IBOutlet weak var scorePointsImageView: UIImageView!
    @IBOutlet weak var scorePointsLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var partecipaButton: UIButton!
    
    var totalPoints: Float! = 0.0
    var gameType: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bundle = Bundle(for: KGameEndViewController.self)
        scorePointsImageView.image = UIImage(named: "star", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        scorePointsImageView.tintColor = KGameQuiz.theme.color(.starTint)
        
        endLabel.textColor = KGameQuiz.theme.color(.text)
        scorePointsLabel.textColor = KGameQuiz.theme.color(.text)
        backgroundStar.backgroundColor = KGameQuiz.theme.color(.starBackground)
        
        endLabel.text = "your_score_is".localizedString()
        partecipaButton.setTitle("partecipate".localizedString(), for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(rotatePoints(_:)))
        scorePointsImageView.addGestureRecognizer(tap)
        scorePointsImageView.isUserInteractionEnabled = true
        KGameQuiz.theme.applyTheme(toButton: partecipaButton, style: .default)
        
        scorePointsLabel.text = String(format: "%.0f", totalPoints)
        
        rotatePoints(self)
        if gameType.hasPrefix("NoRanking"){
            partecipaButton.removeFromSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rotatePoints(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundStar.layer.cornerRadius = backgroundStar.frame.size.width/2
    }
    
    @IBAction func rotatePoints(_ sender: Any){
        let keyPath = "transform"
        
        let transform = CATransform3DIdentity
        let finalValue = NSValue(caTransform3D: transform)
        let bounceAnimation = SKBounceAnimation(keyPath: keyPath)!
        bounceAnimation.fromValue = NSValue(caTransform3D: CATransform3DMakeRotation(.pi/4, 0, 0, 1))
        bounceAnimation.toValue = finalValue
        bounceAnimation.duration = 0.5
        bounceAnimation.numberOfBounces = 4
        bounceAnimation.shouldOvershoot = true
        
        scorePointsImageView.layer.add(bounceAnimation, forKey: "someKey")
        scorePointsImageView.layer.setValue(finalValue, forKey: keyPath)
        
    }
    
    @IBAction func partecipaAlContest(_ sender: Any){
        gameDelegate?.partecipaAlContest()
    }
    
    
}
