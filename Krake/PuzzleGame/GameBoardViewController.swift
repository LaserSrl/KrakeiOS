//
//  GameBoardViewController.swift
//  Krake
//
//  Created by Marco Zanino on 15/03/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import UIKit

public protocol GameBoardDelegate: NSObjectProtocol {
    // MARK: - Game completion
    func gameCompleted(with option: GameBoardViewController.GameOption, at time: TimeInterval)
    // MARK: - Countdown information
    func isTimeCountdown() -> Bool
    func timeCountdown() -> TimeInterval
    // MARK: - Help usage
    func canUseHelp(for state: GameBoardViewController.GameState) -> Bool
    func didUseHelp(for state: GameBoardViewController.GameState)
    // MARK: - Game status change
    func gamePaused(with option: GameBoardViewController.GameState)
    func gameRestarted(with option: GameBoardViewController.GameState)
}

public extension GameBoardDelegate {
    func timeCountdown() -> TimeInterval {
        return 0.0
    }
}

open class GameBoardViewController: UIViewController, UIGestureRecognizerDelegate {

    public enum GameOption: UInt8 {
        case timeExpired
        case completed
    }

    public enum GameState: UInt8 {
        case help
        case pause
        case number
    }

    public struct Constants {
        static let PhaseTwoHelpTime: TimeInterval = 2
        static let EmptyTileCode = 999
    }

    @IBOutlet weak var boardView: UIView!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var numberOfMovesLabel: UILabel!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var showNumbersButton: UIButton!
    private weak var pauseView: UIView?
    private weak var completeImageView: UIImageView?

    public private(set) var puzzle: Puzzle?
    public weak var delegate: GameBoardDelegate?

    private var timeCounter: TimeInterval!
    private var secondTimer: Timer?
    private var isPaused: Bool = false
    private var helpTimeLeft: TimeInterval = 0
    private var isNumberVisible: Bool = false
    private var fifteenGameTilePositions: [Int]!
    private var emptyTileCoordinates: Coordinates!
    private var isMovingTiles = false
    private var cachedSideLenght: CGFloat!
    private var isPuzzleLoaded = false

    // MARK: - View controller lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        scoreLabel.text = ""
        pauseButton
            .setImage(KPuzzleGameAssets.pGpause.image,
                      for: .normal)
        helpButton
            .setImage(KPuzzleGameAssets.pGhelp.image,
                      for: .normal)
        showNumbersButton
            .setImage(KPuzzleGameAssets.pGnumtiles.image,
                      for: .normal)
        // Applico il tema alle view che ne hanno bisogno.
        let theme = KTheme.current
        theme.applyTheme(toLabel: timeLeftLabel, style: .subtitle)
        theme.applyTheme(toButton: pauseButton, style: .default)
        theme.applyTheme(toButton: helpButton, style: .default)
        theme.applyTheme(toButton: showNumbersButton, style: .default)
        theme.applyTheme(toView: view, style: .default)
        theme.applyTheme(toView: boardView, style: .social)
        // Richiedo al delegate il valore del countdown, se necessario.
        if delegate?.isTimeCountdown() ?? false {
            timeCounter = delegate?.timeCountdown() ?? 0
        } else {
            timeCounter = 0
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startObservingNotifications()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isPuzzleLoaded {
            evaluateSideLenght()
            startTimers()
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopObservingNotifications()
        stopTimers()
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            return .portrait
        }
    }

    // MARK: - UI actions

    @IBAction func resume(_ sender: UIButton) {
        resumeGame()
    }

    @IBAction func pause(_ sender: UIButton) {
        pauseGame()
    }

    @IBAction func showNumbers(_ sender: UIButton) {
        let alertController = UIAlertController(
            title: nil,
            message: "Vuoi vedere il numero delle tessere?".appLocalizedString(),
            preferredStyle: .alert)
        // Aggiunta dell'azione di conferma.
        alertController.addAction(
            UIAlertAction(
                title: KGameQuizLocalization.yes,
                style: .default,
                handler: { (_) in
                    self.isNumberVisible = true
                    self.showNumbersButton.isEnabled = false
                    self.showTileNumbers(animated: true)
                    self.delegate?.didUseHelp(for: .number)
            }))
        // Aggiunta dell'azione per cancellare l'alert.
        alertController.addAction(
            UIAlertAction(
                title: KGameQuizLocalization.no,
                style: .cancel,
                handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func showPhase2Help(_ sender: UIButton) {
        // Creazione dell'alert per chiedere conferma all'utente prima di procedere.
        let alertController = UIAlertController(
            title: nil,
            message: "Vuoi vedere l'immagine completa?".appLocalizedString(),
            preferredStyle: .alert)
        // Aggiunta dell'azione di conferma.
        alertController.addAction(
            UIAlertAction(
                title: KGameQuizLocalization.yes,
                style: .default,
                handler: { [unowned self] (_) in
                    // Disabilitazione temporanea del pulsante per la richiesta
                    // di aiuto.
                    self.helpButton.isEnabled = false
                    // Comunicazione al delegate che il puzzle si è interroto
                    // per poter mostrare l'aiuto all'utente.
                    self.delegate?.gamePaused(with: .help)
                    // Presento l'immagine completa all'utente.
                    self.updateGameBoardShowCompletedImage(
                        animated: true,
                        removingTiles: false)
                    // Aggiornamento della label che mostra il tempo rimasto
                    // all'utente.
                    self.helpTimeLeft = Constants.PhaseTwoHelpTime

                    Timer.scheduledTimer(
                        timeInterval: 1,
                        target: self,
                        selector: #selector(GameBoardViewController.showImageAndTextAlertTag(_:)),
                        userInfo: nil,
                        repeats: true)
            }))
        // Aggiunta dell'azione per cancellare l'alert.
        alertController.addAction(
            UIAlertAction(
                title: KGameQuizLocalization.no,
                style: .cancel,
                handler: nil))
        // Presentazione dell'alert.
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Game actions

    @objc dynamic func pauseGame() {
        if puzzle != nil && !isPaused {
            // Aggiorno la variabile che mantiene la rappresentazione dello
            // stato del puzzle.
            isPaused = true
            // Stoppo i timers.
            stopTimers()
            // Aggiungo la view che rappresenta lo stato di pause.
            let pauseView = preparePauseView()
            pauseView.alpha = 0
            // Aggiungo la view di pausa alla gerarchia di view.
            view.addSubview(pauseView)
            // Presento la view di pausa.
            UIView.animate(withDuration: 0.3) {
                pauseView.alpha = 1
            }
        }
    }

    @objc private dynamic func resumeGame() {
        // Nascondo la view della pausa animatamente.
        if let pauseView = pauseView, isPaused {
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    // Nascondo la view della pausa.
                    pauseView.alpha = 0
            },
                completion: { (completed) in
                    guard completed else { return }
                    // Rimuovo la view della pausa dalla gerarchia di view.
                    pauseView.removeFromSuperview()
                    // Aggiorno lo stato interno del puzzle.
                    self.isPaused = false
                    // Faccio ripartire i timers.
                    self.startTimers()
            })
        }
    }

    private func preparePauseView() -> UIView {
        // Controllo che la view relativa allo stato di pausa non sia già
        // stata creata in precedenza.
        guard self.pauseView == nil else {
            return self.pauseView!
        }
        // Creo la view.
        let pauseView = UIView(frame: view.bounds)
        pauseView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        let resumeButton = UIButton(type: .roundedRect)
        resumeButton.translatesAutoresizingMaskIntoConstraints = false
        resumeButton.addConstraints([
            resumeButton.widthAnchor.constraint(equalToConstant: 150),
            resumeButton.heightAnchor.constraint(equalToConstant: 60)
            ])
        resumeButton.tintColor = .white
        resumeButton.setTitle("Resume".appLocalizedString(), for: .normal)
        resumeButton.addTarget(self,
                               action: #selector(GameBoardViewController.resumeGame),
                               for: .touchUpInside)
        pauseView.addSubview(resumeButton)
        pauseView.addConstraints([
            resumeButton.centerXAnchor.constraint(equalTo: pauseView.centerXAnchor),
            resumeButton.centerYAnchor.constraint(equalTo: pauseView.centerYAnchor)
            ])
        // Appico il tema alle view.
        let theme = KTheme.current
        theme.applyTheme(toView: pauseView, style: .social)
        theme.applyTheme(toButton: resumeButton, style: .default)
        // Salvo una reference locale alla view creata.
        self.pauseView = pauseView

        return pauseView
    }

    // MARK: - UI loading

    public func loadPuzzle(_ puzzle: Puzzle) {
        PuzzleGenerator.generateTiles(
            for: puzzle,
            sized: boardView.bounds.size) { [weak self] (puzzle) in
                guard let strongSelf = self else { return }

                strongSelf.puzzle = puzzle
                strongSelf.isPuzzleLoaded = true
                strongSelf.evaluateSideLenght()
                strongSelf.loadGame(from: puzzle)
                strongSelf.startTimers()
        }
    }

    private func loadGame(from puzzle: Puzzle) {
        fillBoardWithTiles(for: puzzle)
        if isNumberVisible {
            showTileNumbers(animated: true)
        }
        updateAllLabelsButtonsAndBoardView()
    }

    private func updateAllLabelsButtonsAndBoardView() {
        updateTimerLabel()
        updateNumberOfMoves(0)

        let canUseNumberHelp = delegate?.canUseHelp(for: .number) ?? false
        showNumbersButton.isHidden = !canUseNumberHelp
        showNumbersButton.isEnabled = canUseNumberHelp
        helpButton.isHidden = !(delegate?.canUseHelp(for: .help) ?? false)
        pauseButton.isHidden = !(delegate?.canUseHelp(for: .pause) ?? false)
    }

    // MARK: - UI utils

    private func evaluateSideLenght() {
        if let puzzle = puzzle {
            cachedSideLenght =
                boardView.bounds.height / CGFloat(puzzle.numberOfTilesInARowOrColumn)
        } else {
            cachedSideLenght = boardView.bounds.height
        }
    }

    // MARK: - Image positions

    private func fillBoardWithTiles(for puzzle: Puzzle) {
        // Rimuovo i vecchi tile.
        boardView.subviews.forEach { $0.removeFromSuperview() }
        // Procedo con la creazione dei nuovi tiles.
        var tileIndex = 0
        var nonEmptyTileIndex = 0
        let fifteenGameTilePositions = puzzle.tilePositions
        for tilePosition in fifteenGameTilePositions {
            let tileCoordinates = coordinates(for: tileIndex)
            if tilePosition != Constants.EmptyTileCode {
                let tileView = newTileView(for: tileCoordinates,
                                           representing: tilePosition,
                                           withRepresentationVisible: true)
                boardView.addSubview(tileView)
                nonEmptyTileIndex += 1
            } else {
                emptyTileCoordinates = tileCoordinates
            }
            tileIndex += 1
        }
        self.fifteenGameTilePositions = fifteenGameTilePositions
    }

    private func coordinates(for index: Int) -> Coordinates {
        guard let puzzle = puzzle else {
            return Coordinates(x: 0, y: 0)
        }
        let puzzleSideLength = puzzle.numberOfTilesInARowOrColumn
        return Coordinates(
            x: index % puzzleSideLength,
            y: index / puzzleSideLength)
    }

    private func coordinates(for center: CGPoint) -> Coordinates {
        let tileDimension = cachedSideLenght!
        return Coordinates(
            x: Int(round((center.x - tileDimension * 0.5) / tileDimension)),
            y: Int(round((center.y - tileDimension * 0.5) / tileDimension)))
    }

    // MARK: - Tile views

    private func newTileView(
        for coordinates: Coordinates,
        representing number: Int,
        withRepresentationVisible isRepresentationVisible: Bool) -> UIView {

        let tileView = TileView(coordinates: coordinates)
        tileView.frame = tileFrame(for: coordinates)
        tileView.tag = number
        // Aggiungo il gesture recognizer per lo spostamento dei tile.
        let tileMovesGestureRecognizer =
            UIPanGestureRecognizer(target: self,
                                   action: #selector(GameBoardViewController.moveTile(_:)))
        tileMovesGestureRecognizer.delegate = self
        tileView.addGestureRecognizer(tileMovesGestureRecognizer)
        // Imposto l'immagine per il tile corrente.
        do {
            let tileImageURL = try PuzzleGenerator.tileURL(
                for: self.coordinates(for: number - 1),
                relativeTo: puzzle!.tileCacheURL)
            tileView.imageView.image = UIImage(contentsOfFile: tileImageURL.path)
        } catch {}
        // Controllo se il tile deve essere reso invisibile.
        if !isRepresentationVisible {
            tileView.hideImageView()
        }
        // Customizzo la label del tile.
        tileView.numberLabel.backgroundColor = KTheme.current.color(.tint)
        tileView.numberLabel.textColor = KTheme.current.color(.textTint)
        tileView.numberLabel.textAlignment = .center
        tileView.numberLabel.alpha = 0
        tileView.numberLabel.text = String(format: "%d", number)
        // Customizzo il layer della view.
        tileView.layer.borderColor = KTheme.current.color(.popoverBackground).cgColor
        tileView.layer.borderWidth = 1

        return tileView
    }

    private func tileFrame(for coordinates: Coordinates) -> CGRect {
        let viewDimension = cachedSideLenght!
        return CGRect(
            x: CGFloat(coordinates.x) * viewDimension,
            y: CGFloat(coordinates.y) * viewDimension,
            width: viewDimension,
            height: viewDimension)
    }

    @objc dynamic func moveTile(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let tileView = gestureRecognizer.view as? TileView else { return }

        switch gestureRecognizer.state {
        case .began, .changed:
            let tileSuperview = tileView.superview
            let translation = gestureRecognizer.translation(in: tileSuperview)
            // Verifico se il tile che è stato spostato è su di una riga
            // o colonna che presenta l'elemento vuoto.
            let additionalTilesToMove = orderedTileViewsToMove(relatedTo: tileView)
            if let additionalTilesToMove = additionalTilesToMove,
                !additionalTilesToMove.isEmpty {
                // Modifico il centro di ciascuna view.
                var tileIndex = 0
                var siblingTileView: TileView!
                repeat {
                    siblingTileView = additionalTilesToMove[tileIndex]
                    let previousTile: TileView? =
                        tileIndex == 0 ? nil : additionalTilesToMove[tileIndex - 1]
                    let tileCenter = validTranslationCenter(
                        for: siblingTileView,
                        with: translation,
                        using: previousTile?.center)
                    siblingTileView.center = tileCenter
                    tileIndex += 1
                } while tileIndex < additionalTilesToMove.count
            }
            let translatedCenter = validTranslationCenter(
                for: tileView,
                with: translation,
                using: additionalTilesToMove?.last?.center)
            tileView.center = translatedCenter
            gestureRecognizer.setTranslation(.zero, in: tileSuperview)
        case .cancelled, .ended:
            // Verifico se oltre al tile corrente altri tile devono essere spostati.
            let additionalTilesToMove = orderedTileViewsToMove(relatedTo: tileView)
            additionalTilesToMove?.forEach {
                let originalCoordinates = $0.coordinates
                let tileCoordinates = coordinates(for: $0.center)
                animate(tile: $0,
                        to: center(for: tileCoordinates))

                if tileCoordinates.x != originalCoordinates.x ||
                    tileCoordinates.y != originalCoordinates.y {
                    // Aggiorno i valori nell'array del gioco.
                    updateEmptyTilePosition(from: emptyTileCoordinates, to: originalCoordinates)
                    // Aggiorno le coordinate del tile vuoto.
                    emptyTileCoordinates = $0.coordinates
                    // Aggiorno le coordinate del tile spostato.
                    $0.coordinates = tileCoordinates
                }
            }

            let finalCoordinates = coordinates(for: tileView.center)
            animate(tile: tileView,
                    to: center(for: finalCoordinates))
            let originalCoordinates = tileView.coordinates
            if finalCoordinates.x != originalCoordinates.x ||
                finalCoordinates.y != originalCoordinates.y {
                // Aggiorno il conteggio delle mosse che sono state effettuate
                // dall'utente.
                let numberOfMoves = puzzle!.numberOfMoves + 1 +
                    (additionalTilesToMove?.count ?? 0)
                updateNumberOfMoves(numberOfMoves)
                // Aggiorno le coordinate del tile che è stato spostato
                // e del tile vuoto.
                tileView.coordinates = finalCoordinates
                emptyTileCoordinates = originalCoordinates
                // Aggiorno i valori nell'array del gioco.
                updateEmptyTilePosition(from: finalCoordinates, to: originalCoordinates)
                // Verifico se il gioco è stato completato.
                if isFifteenGameCompleted() {
                    updateGameBoardShowCompletedImage(animated: true, removingTiles: true)
                    stopTimers()
                    delegate?.gameCompleted(with: .completed, at: timeCounter)
                }
            }
            isMovingTiles = false
        default:break
        }
    }

    private func orderedTileViewsToMove(relatedTo tileView: TileView) -> [TileView]? {
        guard let tileSuperview = tileView.superview else { return nil }

        let tilesToMove: [TileView]?
        if let tileViews = tileSuperview.subviews as? [TileView] {
            if shouldMoveMultipleTilesHorizontally(startingFrom: tileView.coordinates) {
                // Determino la direzione che verrà seguita dai tiles.
                // Un valore positivo indica uno spostamento verso destra, uno
                // negativo verso sinistra.
                let translateDirection = tileView.coordinates.x > emptyTileCoordinates.x ? -1 : 1
                // Seleziono le view che dovranno essere spostate insieme al tile
                // mosso dall'utente.
                let originTileCoordinates = tileView.coordinates
                let siblingTileViews = tileViews
                    .filter {
                        let tileCoordinates = $0.coordinates
                        return
                            tileCoordinates.y == originTileCoordinates.y &&
                                ((translateDirection < 0 && tileCoordinates.x > emptyTileCoordinates.x && tileCoordinates.x < originTileCoordinates.x) ||
                                    (translateDirection > 0 && tileCoordinates.x > originTileCoordinates.x && tileCoordinates.x < emptyTileCoordinates.x))
                }
                // Ordino l'array di tile di modo che lo spostamento degli stessi
                // non causerà conflitti.
                tilesToMove = siblingTileViews.sorted(by: {
                    return (translateDirection > 0 && $0.coordinates.x > $1.coordinates.x) || (translateDirection < 0 && $0.coordinates.x < $1.coordinates.x)
                })
            } else if shouldMoveMultipleTilesVertically(startingFrom: tileView.coordinates) {
                let translateDirection =
                    tileView.coordinates.y > emptyTileCoordinates.y ? -1 : 1
                // Seleziono le view che dovranno essere spostate insieme al tile
                // mosso dall'utente.
                let originTileCoordinates = tileView.coordinates
                let siblingTileViews = tileViews
                    .filter {
                        let tileCoordinates = $0.coordinates
                        return
                            tileCoordinates.x == originTileCoordinates.x &&
                                ((translateDirection < 0 && tileCoordinates.y > emptyTileCoordinates.y && tileCoordinates.y < originTileCoordinates.y) ||
                                    (translateDirection > 0 && tileCoordinates.y > originTileCoordinates.y && tileCoordinates.y < emptyTileCoordinates.y))
                }
                // Ordino l'array di tile di modo che lo spostamento degli stessi
                // non causerà conflitti.
                tilesToMove = siblingTileViews.sorted(by: {
                    return (translateDirection > 0 && $0.coordinates.y > $1.coordinates.y) || (translateDirection < 0 && $0.coordinates.y < $1.coordinates.y)
                })
            } else {
                tilesToMove = nil
            }
        } else {
            tilesToMove = nil
        }
        return tilesToMove
    }

    private func shouldMoveMultipleTilesHorizontally(startingFrom coordinates: Coordinates) -> Bool {
        let tileX = coordinates.x
        let tileY = coordinates.y
        return
            tileY == emptyTileCoordinates.y && abs(tileX - emptyTileCoordinates.x) > 1
    }

    private func shouldMoveMultipleTilesVertically(startingFrom coordinates: Coordinates) -> Bool {
        let tileX = coordinates.x
        let tileY = coordinates.y
        return
            tileX == emptyTileCoordinates.x && abs(tileY - emptyTileCoordinates.y) > 1
    }

    private func validTranslationCenter(for tileView: TileView, with translation: CGPoint, using boundCenter: CGPoint? = nil) -> CGPoint {
        let tileCoordinates = tileView.coordinates
        var translatedCenter = tileView.center
        if tileCoordinates.x == emptyTileCoordinates.x {
            let coordinatesYDelta = abs(tileCoordinates.y - emptyTileCoordinates.y)
            if coordinatesYDelta != 0 {
                let originalCenter = center(for: tileCoordinates)
                let boundingCenter = boundCenter ?? center(for: emptyTileCoordinates)
                let centerPadding: CGFloat = boundCenter == nil ? 0 : cachedSideLenght!
                let translationY = tileView.center.y + translation.y
                if ((translationY >= originalCenter.y) && (translationY <= boundingCenter.y - centerPadding)) ||
                    ((translationY <= originalCenter.y) && (translationY >= boundingCenter.y + centerPadding)) {
                    translatedCenter.y = translationY
                }
            }
        } else if tileCoordinates.y == emptyTileCoordinates.y {
            let coordinatesXDelta = abs(tileCoordinates.x - emptyTileCoordinates.x)
            if coordinatesXDelta != 0 {
                let originalCenter = center(for: tileCoordinates)
                let boundingCenter = boundCenter ?? center(for: emptyTileCoordinates)
                let centerPadding: CGFloat = boundCenter == nil ? 0 : cachedSideLenght!
                let translationX = tileView.center.x + translation.x
                if ((translationX >= originalCenter.x) && (translationX <= boundingCenter.x - centerPadding)) ||
                    ((translationX <= originalCenter.x) && (translationX >= boundingCenter.x + centerPadding)) {
                    translatedCenter.x = translationX
                }
            }
        }
        return translatedCenter
    }

    private func center(for coordinates: Coordinates) -> CGPoint {
        let tileDimension = cachedSideLenght!
        return CGPoint(
            x: tileDimension * 0.5 + CGFloat(coordinates.x) * tileDimension,
            y: tileDimension * 0.5 + CGFloat(coordinates.y) * tileDimension)
    }

    private func animate(tile tileView: TileView, to center: CGPoint) {
        UIView.animate(withDuration: 0.2) {
            tileView.center = center
        }
    }

    // MARK: - Moves handling

    private func updateNumberOfMoves(_ movesCount: Int) {
        // Aggiorno il valore salvato nel puzzle.
        puzzle?.numberOfMoves = movesCount
        // Aggiorno il valore mostrato all'utente.
        numberOfMovesLabel.text = String(format: "%@ %d", "Moves", movesCount)
        numberOfMovesLabel.isHidden = false
    }

    // MARK: - Update match

    private func updateEmptyTilePosition(from originalCoordinates: Coordinates, to destinationCoordinates: Coordinates) {
        let originalIndex = index(for: originalCoordinates)
        let destinationIndex = index(for: destinationCoordinates)

        let tmp = fifteenGameTilePositions[originalIndex]
        fifteenGameTilePositions[originalIndex] = fifteenGameTilePositions[destinationIndex]
        fifteenGameTilePositions[destinationIndex] = tmp
    }

    private func index(for coordinates: Coordinates) -> Int {
        return coordinates.y * (puzzle?.numberOfTilesInARowOrColumn ?? 0) + coordinates.x
    }

    // MARK: - Game completion

    private func isFifteenGameCompleted() -> Bool {
        for (i, tileNumber) in fifteenGameTilePositions.enumerated() {
            // Controllo che l'elemento corrente non sia il penultimo.
            // L'ultimo dovrà essere ignorato poiché dovrebbe essere l'elemento
            // vuoto.
            if i + 2 == fifteenGameTilePositions.count {
                break
            }
            // Verifico che l'elemento successivo all'attuale sia numericamente
            // il successivo.
            if tileNumber + 1 != fifteenGameTilePositions[i + 1] {
                return false
            }
        }
        return true
    }

    // MARK: - Timer handling

    private func startTimers() {
        if secondTimer == nil {
            delegate?.gameRestarted(with: .pause)
            if delegate?.isTimeCountdown() ?? false {
                Timer.scheduledTimer(
                    timeInterval: 1,
                    target: self,
                    selector: #selector(GameBoardViewController.firstTimerCountdown),
                    userInfo: nil,
                    repeats: true)
            } else {
                secondTimer = Timer.scheduledTimer(
                    timeInterval: 1,
                    target: self,
                    selector: #selector(GameBoardViewController.timerUpdateLabel),
                    userInfo: nil,
                    repeats: true)
            }
        }
    }

    private func stopTimers() {
        delegate?.gamePaused(with: .pause)
        secondTimer?.invalidate()
        secondTimer = nil
    }

    @objc private dynamic func firstTimerCountdown() {
        timeCounter = timeCounter - 1
        updateTimerLabel()

        if timeCounter == 0 {
            stopTimers()
            matchTimeForPhase2Expired()
        }
    }

    @objc private dynamic func timerUpdateLabel() {
        timeCounter = timeCounter + 1
        updateTimerLabel()
    }

    private func updateTimerLabel() {
        timeLeftLabel.isHidden = false

        let timeLeft = max(timeCounter!, 0.0)
        let minutes = floor(timeLeft / 60)
        timeLeftLabel.text = String(
            format: "%02.0f:%02.0f", minutes, timeLeft - minutes * 60)
    }

    private func matchTimeForPhase2Expired() {
        delegate?.gameCompleted(
            with: .timeExpired,
            at: timeCounter)
    }

    // MARK: - Notifications

    private func startObservingNotifications()
    {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GameBoardViewController.pauseGame),
                         name: UIApplication.willResignActiveNotification,
                         object: UIApplication.shared)
    }

    private func stopObservingNotifications()
    {
        NotificationCenter.default
            .removeObserver(self,
                            name: UIApplication.willResignActiveNotification,
                            object: UIApplication.shared)
    }

    // MARK: - UIGestureRecognizer delegate

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if !isMovingTiles {
            isMovingTiles = true
            return true
        }
        return false
    }

    // MARK: - Game board utils

    private func updateGameBoardShowCompletedImage(
        animated isAnimated: Bool,
        removingTiles needsTilesDeletion: Bool) {

        if let completeImage = puzzle?.image {
            // Prelevo l'image view per rappresentare l'immagine completa
            // del puzzle.
            let completeImageView: UIImageView = {
                // Controllo se la UIImageView era già stata creata in precedenza.
                if let completeImageView = self.completeImageView {
                    return completeImageView
                } else {
                    // Creo la UIImageView poiché il riferimento mantenuto non è
                    // più valido.
                    let newImageView = UIImageView(frame: .zero)
                    newImageView.translatesAutoresizingMaskIntoConstraints = false
                    self.boardView.addSubview(newImageView)
                    let viewRefs = [ "iv" : newImageView ]
                    self.boardView.addConstraints([
                        NSLayoutConstraint.constraints(
                            withVisualFormat: "|-0-[iv]-0-|",
                            options: .directionLeftToRight,
                            metrics: nil,
                            views: viewRefs),
                        NSLayoutConstraint.constraints(
                            withVisualFormat: "V:|-0-[iv]-0-|",
                            options: .directionLeftToRight,
                            metrics: nil,
                            views: viewRefs)
                        ].flatMap { $0 })
                    self.completeImageView = newImageView
                    return newImageView
                }
            }()
            completeImageView.image = completeImage
            completeImageView.alpha = 0
            // Presentazione della view creata.
            UIView.animate(
                withDuration: isAnimated ? 0.5 : 0,
                animations: {
                    completeImageView.alpha = 1
            }) { (completed) in
                guard completed && needsTilesDeletion else { return }

                for tileView in self.boardView.subviews {
                    tileView.removeFromSuperview()
                }
            }
        }
    }

    @objc private dynamic func showImageAndTextAlertTag(_ timer: Timer) {
        // Aggiorno il tempo a disposizione per la visualizzazione dell'aiuto.
        helpTimeLeft -= 1
        // Controllo che il tempo a disposizione non sia terminato.
        if helpTimeLeft == 0 {
            // Il tempo è scaduto. Invalido il timer.
            timer.invalidate()
            // Abilito il bottone per richiedere l'aiuto.
            helpButton.isEnabled = true
            // Nascondo l'aiuto.
            if let completeImageView = completeImageView {
                UIView.animate(
                    withDuration: 0.2,
                    animations: {
                        completeImageView.alpha = 0
                },
                    completion: { (completed) in
                        guard completed else { return }
                        
                        completeImageView.removeFromSuperview()
                        self.delegate?.gameRestarted(with: .help)
                })
            }
        }
    }
    
    private func showTileNumbers(animated isAnimated: Bool) {
        UIView.animate(withDuration: isAnimated ? 0.2 : 0) {
            self.boardView.subviews.forEach {
                ($0 as? TileView)?.numberLabel.alpha = 1
            }
        }
    }
    
}
