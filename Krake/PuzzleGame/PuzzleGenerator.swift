//
//  PuzzleGenerator.swift
//  Krake
//
//  Created by Marco Zanino on 15/03/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import CoreImage

class PuzzleGenerator: NSObject {

    /// Compone lo URL dell'immagine del tile alle coordinate date sulla
    /// base dello URL della cartella. Se la cartella non fosse presente,
    /// tale funzione si prende in carico di crearla.
    ///
    /// - Parameters:
    ///   - coordinates: Le coordinate del tile per cui si sta richiedendo il
    /// path dell'immagine.
    ///   - directory: La cartella che dovrebbe contenere le immagini dei tiles.
    /// - Returns: Lo URL dell'immagine su file system.
    /// - Throws: Solamente nel caso in cui la cartella di destinazione non è
    /// stata trovata e non può essere creata.
    public static func tileURL(for coordinates: Coordinates, relativeTo directory: URL) throws -> URL {
        let fileManager = FileManager.default
        // Controllo che la cartella di destinazione sia presente.
        if !fileManager.fileExists(atPath: directory.path) {
            // La cartella di destinazione non è presente, cerco di crearla.
            try fileManager.createDirectory(
                at: directory,
                withIntermediateDirectories: false,
                attributes: nil)
        }
        // Costruisco il nome del file sulla base delle coordinate.
        let fileName = String(format: "Tile%lu-%lu.jpg", coordinates.x, coordinates.y)
        // Restituisco lo URL del tile.
        return directory.appendingPathComponent(fileName)
    }

    // MARK: - Tile generation

    /// Inizializza un nuovo Puzzle sulla base dell'originale.
    /// Il nuovo puzzle conterrà l'immagine originale, e le immagini della stessa
    /// spezzettata in tile.
    ///
    /// - Parameters:
    ///   - originalPuzzle: Il puzzle utilizzato per prelevare la configurazione
    /// che verrà sfruttata per configurare il nuovo puzzle.
    ///   - viewSize: La dimensione della view che andrà a contenere l'immagine
    /// del puzzle suddivisa in tile.
    ///   - completion: Funzione che verrà richiamata sul main thread una volta
    /// che il nuovo puzzle sarà disponibile.
    public static func generateTiles(for originalPuzzle: Puzzle,
                                      sized viewSize: CGSize,
                                      with completion: @escaping (Puzzle) -> Void) {
        // Dal momento che saranno generate immagini e salvate in locali,
        // spostiamo tutto il lavoro su di un altro thread.
        DispatchQueue.global(qos: .default).async {
            let puzzleSideLength = originalPuzzle.numberOfTilesInARowOrColumn
            let puzzleImage = originalPuzzle.image
            let originalPositions = fifteenGameOriginalPositions(
                for: UInt(puzzleSideLength))
            // Creazione di un nuovo puzzle utilizzando i parametri di quello di
            // partenza.
            let puzzle = Puzzle(
                image: puzzleImage,
                numberOfRows: puzzleSideLength)
            puzzle.tilePositions = originalPositions
            puzzle.numberOfMoves = originalPuzzle.numberOfMoves
            // Creazione delle immagini relative ai vari tiles.
            if let puzzleCgImage = puzzleImage.cgImage {
                var originalImage = CIImage(cgImage: puzzleCgImage)

                let originalSize = originalImage.extent.size
                if originalSize.width != viewSize.width {
                    let scale = viewSize.width / originalSize.width
                    #if swift(>=4.0)
                        originalImage = originalImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
                    #else
                        originalImage = originalImage.applying(CGAffineTransform(scaleX: scale, y: scale))
                    #endif
                }

                for x in (0..<puzzleSideLength) {
                    for y in (0..<puzzleSideLength) {
                        let coordinates = Coordinates(x: x, y: y)
						// Creazione dell'immagine per il tile alle
                        // coordinate correnti.
                        let tileImage = tile(
                            of: originalImage,
                            for: coordinates,
                            in: puzzle)
                        // Salvataggio in cache dell'immagine generata.
                        save(
                            tileImage: tileImage,
                            at: coordinates,
                            into: originalPuzzle.tileCacheURL)
                    }
                }
            }
            // Ritorno il puzzle generato al chiamante tramite la completion.
            DispatchQueue.main.async {
                completion(puzzle)
            }
        }
    }

    /// Crea l'immagine per il tile corrispondente alle coordinate richieste
    /// sulla base dell'immagine totale del puzzle.
    ///
    /// - Parameters:
    ///   - image: L'immagine totale del puzzle.
    ///   - coordinates: Le coordinate del tile corrente.
    ///   - puzzle: Il puzzle.
    /// - Returns: L'immagine per il tile.
    private static func tile(of image: CIImage, for coordinates: Coordinates, in puzzle: Puzzle) -> CIImage {
        let tileSize = image.extent.width / CGFloat(puzzle.numberOfTilesInARowOrColumn)
        let tileRect = CGRect(
            origin: CGPoint(
                x: tileSize * CGFloat(coordinates.x),
                y: tileSize * CGFloat(puzzle.numberOfTilesInARowOrColumn - 1 - coordinates.y)),
            size: CGSize(width: tileSize, height: tileSize))
        #if swift(>=4.0)
            return image.cropped(to: tileRect)
        #else
            return image.cropping(to: tileRect)
        #endif
    }

    /// Salva il JPEG costruito a partire dall'immagine del tile.
    ///
    /// - Parameters:
    ///   - image: L'immagine del tile.
    ///   - coordinates: Le coordinate del tile.
    ///   - directory: Lo URL della cartella che conterrà l'immagine salvata.
    private static func save(tileImage image: CIImage, at coordinates: Coordinates, into directory: URL) {
        let tileImage = UIImage(ciImage: image)
        UIGraphicsBeginImageContext(image.extent.size)
        tileImage.draw(at: .zero)
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let renderedImage = renderedImage{
            #if swift(>=4.2)
            let jpgData = renderedImage.jpegData(compressionQuality: 1.0)
            #else
            let jpgData = UIImageJPEGRepresentation(renderedImage, 1.0)
            #endif
            if let jpgData = jpgData{
                
                do {
                    try jpgData.write(
                        to: try tileURL(for: coordinates, relativeTo: directory),
                        options: [.atomic])
                } catch {}
            }
        }
    }

    // MARK: - Fifteen Game generation

    private static func fifteenGameOriginalPositions(for sideLenght: UInt) -> [Int] {
        var generatedPositions: [Int]
        // Creazione delle posizioni per il nuovo gioco.
        // Tali posizioni vengono generate fintanto che il gioco non è risolvibile.
        repeat {
            generatedPositions = generateRandomPositions(for: sideLenght)
        } while !isGameSolvable(with: generatedPositions)
        // Aggiunta dell'elemento vuoto.
        generatedPositions.append(Puzzle.EmptyTileCode)
        return generatedPositions
    }

    private static func generateRandomPositions(for sideLength: UInt) -> [Int] {
        // Calcolo il numero totale di tile che saranno presenti.
        let numberOfTiles = Int(sideLength * sideLength)
        // Inizializzazione dell'array di valori dei tile.
        var tileNumbers = [Int]()
        for value in (1..<numberOfTiles) {
			tileNumbers.append(value)
        }
        // Creazione di un array in cui saranno presenti le posizioni dei tile
        // distribuite randomicamente.
        var randomNumbers = [Int]()
        while tileNumbers.count > 0 {
            let remainingTilesCount = tileNumbers.count
            let indexToExtract = Int(arc4random_uniform(UInt32(remainingTilesCount)))
            let tileNumber = tileNumbers[indexToExtract]
            randomNumbers.append(tileNumber)
            tileNumbers.remove(at: indexToExtract)
        }
        return randomNumbers
    }

    private static func isGameSolvable(with positions: [Int]) -> Bool {
        var totalPermutationsCount = 0
        for index in (0..<positions.count) {
            let numberToExamine = positions[index]
            var numberOfPermutations = numberToExamine - 1
            var permutationIndex = 0
            while permutationIndex < index && numberOfPermutations > 0 {
                let permutatedNumber = positions[permutationIndex]
                if permutatedNumber < numberToExamine {
                    numberOfPermutations -= 1
                }
                permutationIndex += 1
            }
            totalPermutationsCount += numberOfPermutations
        }
        return (totalPermutationsCount&1) == 0
    }
    
}
