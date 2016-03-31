//
//  Core.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 3/29/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation
import TwitterKit

struct API {
    struct Notifications {
        static let newsUpdated = "newsUpdated"
        static let tweetsUpdated = "tweetsUpdated"
    }
}

struct Data {
    static let sharedInstance = Data()
    
    func getDataFromNews() {
        Request.sharedInstance.getNews() { (json, error) in
            let results = json["results"].arrayValue
            News.sharedInstance.news = results
            NSNotificationCenter.defaultCenter().postNotificationName(API.Notifications.newsUpdated, object: nil)
        }
    }
    
    func getDataFromTweets() {
        Request.sharedInstance.getTweets() { (json, error) in
            News.sharedInstance.tweets = TWTRTweet.tweetsWithJSONArray((json.object as! [AnyObject])) as! [TWTRTweet]
            NSNotificationCenter.defaultCenter().postNotificationName(API.Notifications.tweetsUpdated, object: nil)
        }
    }
    
}