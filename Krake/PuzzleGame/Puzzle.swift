//
//  Puzzle.swift
//  Krake
//
//  Created by joel on 17/10/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import UIKit

open class Puzzle : NSObject {

    static public let EmptyTileCode = 999

    public var image: UIImage
    public let tileCacheURL: URL
    public let numberOfTilesInARowOrColumn: Int

    public var tilePositions: [Int] = []
    public var numberOfMoves: Int = 0

    public init(image puzzleImage: UIImage, numberOfRows: Int = 4) {
        image = puzzleImage
        tileCacheURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        numberOfTilesInARowOrColumn = numberOfRows
    }
}

public class Coordinates : NSObject {
    public var x: Int = 0
    public var y: Int = 0

    public convenience init(x: Int, y: Int) {
        self.init()
        self.x = x
        self.y = y
    }

    public override var description: String {
        return "{ x: \(x), y: \(y) }"
    }
}
