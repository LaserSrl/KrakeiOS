//
//  GameQuiz.swift
//  Pods
//
//  Created by Patrick on 29/06/17.
//
//

import Foundation

public class KGameQuiz{
    
    static public var theme: KGameQuizTheme! = KDefaultGameQuizTheme()
    
    public static func gameQuizViewController(withEndPoint: String,
                                       policyEndPoint: String? = nil) -> UIViewController?{
        
        let bundle = Bundle(url: Bundle(for: KGameQuiz.self).url(forResource: "GameQuiz", withExtension: "bundle")!)
        let story = UIStoryboard(name: "GameBoard", bundle: bundle)
        let vc = story.instantiateInitialViewController() as! KMainGameBoardViewController
        vc.endPoint = withEndPoint
        vc.policyEndPoint = policyEndPoint
        return vc
    }
}

extension UIViewController{
    
    public func present(gameQuiz endPoint: String,
                        policyEndPoint: String? = nil){
        if let vc = KGameQuiz.gameQuizViewController(withEndPoint: endPoint, policyEndPoint: policyEndPoint){
            //TODO: - capire se il .fullscreen è lo style corretto
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
}

extension UINavigationController{
    
    public func pushGameQuizViewController(_ endPoint: String,
                                           policyEndPoint: String? = nil,
                                           theme: KGameQuizTheme? = KDefaultGameQuizTheme()){
        if let vc = KGameQuiz.gameQuizViewController(withEndPoint: endPoint, policyEndPoint: policyEndPoint){
            pushViewController(vc, animated: true)
        }
    }
    
}
