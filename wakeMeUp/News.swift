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
    static var newsItems = [NewsItem]()
    static var tweets = [TWTRTweet]()
}

struct NewsItem {
    var title: String?
    var url: String?
    var date: String?
    var image: UIImage?
    var content: String?
}