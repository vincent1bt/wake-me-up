//
//  News.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 3/29/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation
import TwitterKit

struct News {
    static var sharedInstance = News()
    var news: Array<JSON> = [JSON]()
    var tweets = [TWTRTweet]()
    
    func getDataFromNewsById(id: Int) -> [String: String] {
        if news == [] || !(news.indices).contains(id) {
            return ["title": "", "url": "", "date": ""]
        }
        
        let new = news[id]
        let title = new["title"].stringValue
        let url = new["url"].stringValue
        let date = (new["published_date"].stringValue).componentsSeparatedByString("T")[0]
        let newDic = ["title": title, "url": url, "date": date]
        return newDic
    }
}