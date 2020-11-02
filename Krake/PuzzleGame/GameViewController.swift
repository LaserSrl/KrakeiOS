//
//  GameViewController.swift
//  Krake
//
//  Created by Marco Zanino on 15/03/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import UIKit
import MBProgressHUD

open class GameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GameBoardDelegate {
    
    public static let KGameCompletedResult = "KGameCompletedResult"
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var qaView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionsTableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    private var hasUserWin = false
    private var gameBoardController: GameBoardViewController!
    
    private var question: QuestionRecordProtocol?{
        didSet{
            answers = (question?.answers?.array as? [AnswerRecordProtocol])?
                .filter { $0.published?.boolValue ?? false }
        }
    }
    private var answers: [AnswerRecordProtocol]?
    private var medias: [MediaPartProtocol]?
    
    // MARK: - Building
    
    /// Crea e restituisce il GameViewController al quale passare il game(GameProtocol).
    ///
    /// - Returns: GameViewController
    public static func createGameController(medias: [MediaPartProtocol], question: QuestionRecordProtocol) -> GameViewController {
        let bundleURL = Bundle(for: GameViewController.self)
            .url(forResource: "PuzzleGame", withExtension: "bundle")!
        let bundle = Bundle(url: bundleURL)
        let gameViewController = UIStoryboard(name: "GamePod", bundle: bundle)
            .instantiateInitialViewController() as! GameViewController
        gameViewController.question = question
        gameViewController.medias = medias
        return gameViewController
    }
    
    // MARK: - View controller lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        qaView.isHidden = true
        // Applico il tema di base alle view.
        let theme = KTheme.current
        theme.applyTheme(toLabel: questionLabel, style: .subtitle)
        questionLabel.numberOfLines = 0
        theme.applyTheme(toView: view, style: .default)
        theme.applyTheme(toView: qaView, style: .default)
        theme.applyTheme(toView: gameView, style: .default)
        theme.applyTheme(toToolbar: toolbar, style: .default)
        
        populateGame()
    }
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "puzzle" {
            gameBoardController = (segue.destination as! GameBoardViewController)
            gameBoardController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            return .portrait
        }
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        get{
            return .portrait
        }
    }
    
    private func image(from media: MediaPartProtocol, with completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            guard let mediaURL = KMediaImageLoader.generateURL(
                forMediaPath: media.mediaUrl,
                mediaImageOptions: KMediaImageLoadOptions(
                    size: CGSize(width: 640, height: 640))) else { return }
            
            do {
                let image = UIImage(data: try Data(contentsOf: mediaURL))
                
                completion(image)
            } catch {
                completion(nil)
            }
        }
    }
    
    // MARK: - UI actions
    
    @IBAction func closeGame(_ sender: Any) {
        let alertController = UIAlertController(
            title: "PuzzleGame",
            message: KPuzzleGameLocalization.closeGame,
            preferredStyle: .alert)
        alertController.addAction(
            UIAlertAction(title: KPuzzleGameLocalization.no,
                          style: .cancel,
                          handler: nil))
        alertController.addAction(
            UIAlertAction(title: KPuzzleGameLocalization.yes,
                          style: .default,
                          handler: { (_) in self.dismiss() }))
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UI population
    
    private func populateGame() {
        // Prelevo randomicamente una immagine dal gioco per avviare il puzzle.
        MBProgressHUD.showAdded(to: view, animated: true)
        DispatchQueue.global().async { [unowned self] in
            guard let medias = self.medias, !medias.isEmpty else {
                return
            }
            
            let selectedMedia = medias[Int(arc4random_uniform(UInt32(medias.count)))]
            self.image(from: selectedMedia, with: { [weak self] (image) in
                guard let strongSelf = self else { return }
                if let image = image {
                    let puzzle = Puzzle(image: image, numberOfRows: 3)
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: strongSelf.view, animated: true)
                        strongSelf.gameBoardController.loadPuzzle(puzzle)
                        strongSelf.questionLabel.text = strongSelf.question?.question
                        strongSelf.shuffleAnswers()
                        strongSelf.questionsTableView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        strongSelf.dismiss()
                    }
                }
            })
        }
    }
    
    func shuffleAnswers() {
        let answerCount = answers?.count ?? 0
        var i = 0
        while i < answerCount {
            let remainingCount = UInt32(answerCount - i)
            let exchangeIndex = i + Int(arc4random_uniform(remainingCount))
            let tmp = answers![i]
            answers![i] = answers![exchangeIndex]
            answers![exchangeIndex] = tmp
            i += 1
        }
    }
    
    // MARK: - View controller dismissal
    
    private func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Game board delegate
    
    public func canUseHelp(for state: GameBoardViewController.GameState) -> Bool {
        return true
    }
    
    public func isTimeCountdown() -> Bool {
        return false
    }
    
    public func didUseHelp(for state: GameBoardViewController.GameState) {
        
    }
    
    public func gamePaused(with option: GameBoardViewController.GameState) {
        
    }
    
    public func gameRestarted(with option: GameBoardViewController.GameState) {
        
    }
    
    public func gameCompleted(with option: GameBoardViewController.GameOption, at time: TimeInterval) {
        switch option {
        case .completed:
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime(uptimeNanoseconds: DispatchTime.now().rawValue + UInt64(Double(NSEC_PER_SEC) * 1.5)),
                execute: { self.openQAView() })
        case .timeExpired:break
        }
    }
    
    private func openQAView() {
        UIView.transition(from: gameView,
                          to: qaView,
                          duration: 1.0,
                          options: [.transitionCrossDissolve, .showHideTransitionViews, .curveEaseInOut],
                          completion: nil)
    }
    
    // MARK: - Table view datasource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let response = answers![indexPath.row]
        if let titleLabel = cell.textLabel {
            KTheme.current.applyTheme(toLabel: titleLabel, style: .title)
            titleLabel.text = response.answer
        }
        if cell.selectedBackgroundView == nil {
            let view = UIView(frame: cell.bounds)
            view.backgroundColor = .white
            cell.selectedBackgroundView = view
        }
        return cell
    }
    
    // MARK: - Table view delegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let response = answers![indexPath.row]
        let resultView = UIView(frame: view.bounds)
        resultView.backgroundColor = KTheme.current.color(.tint)
        let messageLabel = UILabel(frame: view.bounds)
        messageLabel.font = UIFont.systemFont(ofSize: 35)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = KTheme.current.color(.textTint)
        resultView.addSubview(messageLabel)
        if response.position == 0 {
            messageLabel.text = KPuzzleGameLocalization.congrats
            messageLabel.alpha = 0
            UIView.animate(withDuration: 2.0) {
                messageLabel.alpha = 1.0
            }
            hasUserWin = true
        } else {
            messageLabel.text = KPuzzleGameLocalization.failedGame
        }
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(GameViewController.closeCurrentGame))
        DispatchQueue.main.asyncAfter(
        deadline: DispatchTime(uptimeNanoseconds: DispatchTime.now().rawValue + NSEC_PER_SEC * 2)) {
            resultView.addGestureRecognizer(tapGestureRecognizer)
        }
        resultView.alpha = 0
        view.addSubview(resultView)
        
        UIView.animate(withDuration: 1.0) {
            resultView.alpha = 1.0
        }
    }
    
    @objc dynamic func closeCurrentGame() {
        dismiss()
        NotificationCenter.default.post(
            Notification(name: .KGameCompleted,
                         object: nil,
                         userInfo: [ GameViewController.KGameCompletedResult : hasUserWin ]))
    }
    
}

public extension Notification.Name {
    static let KGameCompleted = Notification.Name(rawValue: "KGameCompletedNotification")
}
