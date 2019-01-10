//
//  TWTRTweet+Krake.swift
//  Krake
//
//  Created by Patrick on 10/07/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation
import TwitterKit

extension TWTRTweet: TWTRTweetViewDelegate{
    
    public func showFullScreen(fromView: UIView){
        let visualEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: visualEffect)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.closeFullScreen(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.0
        let tweetView = TWTRTweetView(tweet: self, style: .regular)
        tweetView.translatesAutoresizingMaskIntoConstraints = false
        tweetView.showActionButtons = true
        tweetView.isUserInteractionEnabled = true
        tweetView.delegate = self
        tweetView.alpha = 0.0
        let desiredSize = tweetView.sizeThatFits(CGSize(width:280,height: CGFloat.greatestFiniteMagnitude))
        tweetView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 280, height: desiredSize.height))
        view.contentView.addSubview(tweetView)
        
        view.addConstraint(NSLayoutConstraint(item: tweetView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .leading, multiplier: 1, constant: 20))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: tweetView, attribute: .trailing, multiplier: 1, constant: 20))
        view.addConstraint(NSLayoutConstraint(item: tweetView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: tweetView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        
        fromView.addSubview(view)
        fromView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(0)-[view]-(0)-|", options: .directionLeftToRight, metrics: nil, views: ["view" : view]))
        fromView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[view]-(0)-|", options: .directionLeftToRight, metrics: nil, views: ["view" : view]))
        fromView.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5) {
            view.alpha = 1.0
            tweetView.alpha = 1.0
            fromView.layoutIfNeeded()
        }
    }
    
    @objc public func closeFullScreen(_ sender: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5, animations: {
            for subview in sender.view!.subviews{
                subview.alpha = 0.0
            }
            sender.view!.alpha = 0.0
        }) { (finished) in
            if finished{
                sender.view?.removeFromSuperview()
            }
        }
    }
    
}

