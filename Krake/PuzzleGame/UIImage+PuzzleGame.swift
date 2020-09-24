//
//  UIImage+PuzzleGame.swift
//  Krake
//
//  Created by Patrick on 24/09/2020.
//

import UIKit

extension UIImage{
    
    public convenience init?(puzzleGameNamed: String){
        guard let bundlePath = Bundle(for: GameViewController.self).path(forResource: "PuzzleGame", ofType: "bundle") else { return nil }
        self.init(named: puzzleGameNamed, in: Bundle(path: bundlePath), compatibleWith: nil)
    }
}
