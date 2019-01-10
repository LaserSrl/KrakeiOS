//
//  TWTRAPIClient+Krake.swift
//  Krake
//
//  Created by Patrick on 10/07/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation
import TwitterKit

extension TWTRAPIClient{
    
    public func downloadTweets(endPoint: String, completion: @escaping DownloadTweetsBlock) {
        var tweetsCached: [TWTRTweet]? = nil
        
        if let tweetsDataCached = UserDefaults.standard.object(forKey: "tweets-cache") as? Data{
            tweetsCached = NSKeyedUnarchiver.unarchiveObject(with: tweetsDataCached) as? [TWTRTweet]
            completion(false, tweetsCached, nil)
        }
        
        OGLCoreDataMapper.sharedInstance().loadData(withDisplayAlias: endPoint, extras: nil) { (parsedObject, error, completed) in
            if completed && parsedObject != nil{
                let cache = OGLCoreDataMapper.sharedInstance().displayPathCache(from: parsedObject!)
                if let configurazioneTweet = cache.cacheItems.firstObject as? TweetsConfiguration{
                    self.parseAndSplit(string: configurazioneTweet.filtroValue!, completion: completion)
                }else{
                    completion(true, nil, error)
                }
            }
            if completed && (error != nil || parsedObject == nil){
                completion(true, nil, error)
            }
        }
    }
    
    func parseAndSplit(string: String, completion: @escaping DownloadTweetsBlock){
        
        let arrayElem = string.replacingOccurrences(of: " ", with: "")
            .components(separatedBy: CharacterSet(charactersIn: ",;"))
        
        let user = NSMutableString()
        let hashtag = NSMutableString()
        let otherFilter = NSMutableString()
        for filter in arrayElem {
            switch filter.first {
            case "@":
                if user.length>0{
                    user.append(" OR ")
                }
                user.append("from:" + filter.dropFirst())
            case "#":
                if hashtag.length>0{
                    hashtag.append(" OR ")
                }
                hashtag.append("%23" + filter.dropFirst())
            case "-":
                otherFilter.append(filter + " ")
            default:
                break;
            }
        }
        let params = ["q" : String(format: "%@ %@ %@", hashtag, user, otherFilter), "count" : "20", "result_type" : "recent"]
        sendRequest(params: params, completion: completion)
    }
    
    func sendRequest(params: [String : Any], completion: @escaping DownloadTweetsBlock){
        
        let statusesShowEndpoint = "https://api.twitter.com/1.1/search/tweets.json"
        let request = urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: nil)
        
        self.sendTwitterRequest(request) { (response, data, error) in
            if error != nil{
                completion(true, nil, error)
            }else if data != nil{
                
                do{
                    let responseObject = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                    let tweets = TWTRTweet.tweets(withJSONArray: responseObject["statuses"] as? [AnyObject])
                    if tweets.count > 0 {
                        let data = NSKeyedArchiver.archivedData(withRootObject: tweets)
                        UserDefaults.standard.set(data, forKey: "tweets-cache")
                        UserDefaults.standard.synchronize()
                        completion(true, tweets as? [TWTRTweet], nil)
                    }else{
                        completion(true, nil, nil)
                    }
                }catch let error as NSError{
                    completion(true, nil, error)
                }
            }
        }
    }
}
