//
//  KGameStartViewController.swift
//  Pods
//
//  Created by Patrick on 29/06/17.
//
//

import Foundation

class KGameStartViewController: UIViewController {
    
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    weak var gameDelegate: KMainGameViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLabel.textColor = KGameQuiz.theme.color(.text)
        startLabel.text = "ready".localizedString()
        
        startButton.setTitle("start".localizedString(), for: .normal)
        startButton.layer.cornerRadius = 50.0
        startButton.layer.shadowColor = UIColor.black.cgColor
        startButton.layer.shadowRadius = 5.0
        startButton.layer.shadowOpacity = 0.8
        startButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        
        KGameQuiz.theme.applyTheme(toButton: startButton, style: .default)
    }
    
    @IBAction func startButton(_ sender: Any){
        gameDelegate?.didStartGame()
    }
    
}
