//
//  UIImage+GameQuiz.swift
//  Krake
//
//  Created by Patrick on 24/09/2020.
//

import UIKit

extension UIImage{
    
    public convenience init?(gameQuizNamed: String){
        guard let bundlePath = Bundle(for: KGameQuiz.self).path(forResource: "GameQuiz", ofType: "bundle") else { return nil }
        self.init(named: gameQuizNamed, in: Bundle(path: bundlePath), compatibleWith: nil)
    }
}
