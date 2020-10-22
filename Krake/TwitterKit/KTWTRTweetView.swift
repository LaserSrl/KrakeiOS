//
//  KTWTRTweetView.swift
//  Krake
//
//  Created by Patrick on 10/07/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation
import TwitterKit

public class KTWTRTweetView: UIView {
    
    var imageTweet: UIImageView!
    var tweetImage: UIImageView!
    var authorTweet: UILabel!
    var subAuthorTweet: UILabel!
    var textTweet: UILabel!
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc public convenience init(style: KTWTRTweetViewStyle){
        self.init()
        imageTweet = UIImageView()
        imageTweet.translatesAutoresizingMaskIntoConstraints = false
        
        imageTweet.contentMode = UIView.ContentMode.scaleAspectFill
        
        imageTweet.clipsToBounds = false
        self.addSubview(imageTweet)
        
        tweetImage = UIImageView()
        tweetImage.translatesAutoresizingMaskIntoConstraints = false
        
        tweetImage.contentMode = UIView.ContentMode.scaleAspectFill
        
        tweetImage.clipsToBounds = false
        tweetImage.image = UIImage(krakeNamed: "twitter_logo")
        self.addSubview(tweetImage)
        
        textTweet = UILabel()
        textTweet.translatesAutoresizingMaskIntoConstraints = false
        textTweet.numberOfLines = 3
        textTweet.textAlignment = NSTextAlignment.justified
        textTweet.font = UIFont(name: "HelveticaNeue-Light", size: 12.0)
        self.addSubview(textTweet)
        
        authorTweet = UILabel()
        authorTweet.translatesAutoresizingMaskIntoConstraints = false
        authorTweet.font = UIFont(name: "HelveticaNeue-Medium", size: 13.0)
        self.addSubview(authorTweet)
        
        subAuthorTweet = UILabel()
        subAuthorTweet.translatesAutoresizingMaskIntoConstraints = false
        subAuthorTweet.font = UIFont(name: "HelveticaNeue-Light", size: 11.0)
        subAuthorTweet.textAlignment = NSTextAlignment.right
        subAuthorTweet.adjustsFontSizeToFitWidth = true
        subAuthorTweet.minimumScaleFactor = 0.8
        subAuthorTweet.textColor = UIColor ( red: 0.5315, green: 0.5315, blue: 0.5315, alpha: 1.0 )
        self.addSubview(subAuthorTweet)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(8)-[imageTweet]", options: NSLayoutConstraint.FormatOptions.directionLeftToRight, metrics: nil, views: ["imageTweet": imageTweet!]))
        self.addConstraint(NSLayoutConstraint(item: imageTweet!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: imageTweet, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[imageTweet(70@750)]-(>=8)-|", options: NSLayoutConstraint.FormatOptions.directionLeftToRight, metrics: nil, views: ["imageTweet": imageTweet!]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[tweetImage(20)]-(2)-|", options: NSLayoutConstraint.FormatOptions.directionLeftToRight, metrics: nil, views: ["tweetImage": tweetImage!]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(2)-[tweetImage(20)]", options: NSLayoutConstraint.FormatOptions.directionLeftToRight, metrics: nil, views: ["tweetImage": tweetImage!]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[imageTweet]-[textTweet]-(8)-|", options: NSLayoutConstraint.FormatOptions.directionLeftToRight, metrics: nil, views: ["imageTweet": imageTweet!, "textTweet" : textTweet!]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(6)-[authorTweet(14)]-(2)-[textTweet]-(6)-|", options: NSLayoutConstraint.FormatOptions.directionLeftToRight, metrics: nil, views: ["textTweet": textTweet!, "authorTweet" : authorTweet!]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[imageTweet]-[authorTweet]-(4)-[subAuthorTweet]-(4)-[tweetImage]", options: NSLayoutConstraint.FormatOptions.directionLeftToRight, metrics: nil, views: ["imageTweet": imageTweet!, "authorTweet" : authorTweet!, "subAuthorTweet" : subAuthorTweet!, "tweetImage" : tweetImage!]))
        self.addConstraint(NSLayoutConstraint(item: subAuthorTweet!, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: authorTweet, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: subAuthorTweet!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: authorTweet, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0))
        
        self.backgroundColor = UIColor.white
        
        if style == KTWTRTweetViewStyle.Dark {
            self.backgroundColor = UIColor.black
            authorTweet.textColor = UIColor.white
            textTweet.textColor = UIColor ( red: 0.8821, green: 0.8821, blue: 0.8821, alpha: 1.0 )
            subAuthorTweet.textColor = UIColor ( red: 0.6823, green: 0.6823, blue: 0.6823, alpha: 1.0 )
        }
    }
    
    public func configureWithTweet(tweet: TWTRTweet){
        imageTweet.sd_setImage(with: URL(string: tweet.author.profileImageLargeURL)!)
        textTweet.text = tweet.text
        authorTweet.text = tweet.author.name
        var tempo: Int = Int(abs(tweet.createdAt.timeIntervalSinceNow)/60)
        var tempString = String(format: "%dm", arguments: [tempo])
        if tempo >= 60{
            tempo = tempo / 60
            tempString = String(format: "%dh", arguments: [tempo])
            if tempo >= 24{
                let dateForm = DateFormatter()
                dateForm.dateFormat = "dd MMM"
                tempString = dateForm.string(from: tweet.createdAt)
            }
        }
        subAuthorTweet.text = "@" + tweet.author.screenName + " • " + tempString
    }
    
}
