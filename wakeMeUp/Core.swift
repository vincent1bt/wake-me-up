//
//  Core.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 3/29/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation

struct Data {
    static let sharedInstance = Data()
    
    func getDataFromNews() {
        Request.sharedInstance.getNews() { (json, error) in
            let results = json["results"].arrayValue
            News.sharedInstance.news = results
            NSNotificationCenter.defaultCenter().postNotificationName("newsUpdated", object: nil)
        }
    }
    
}