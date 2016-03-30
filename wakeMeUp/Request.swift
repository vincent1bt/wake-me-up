//
//  Request.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 3/29/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation
typealias JSONResponse = (JSON, NSError?) -> Void

struct Request {
    static let sharedInstance = Request()
    private let keyMostPopular = "df44537e748f15225473138a13a01619:14:74524472"
    
    //new york times api
    func getNews(onCompletion: JSONResponse) {
        let urlString = "mostpopular/v2/mostviewed/all-sections/1?api-key=\(keyMostPopular)"
        makeHTTPRequest(urlString) { (json, error) in
            onCompletion(json, error)
        }
    }
    
    private func makeHTTPRequest(url: String, onCompletion: JSONResponse) {
        let endPoint = "http://api.nytimes.com/svc/\(url)"
        let request = NSMutableURLRequest(URL: NSURL(string: endPoint)!)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            let json: JSON = JSON(data: data!)
            onCompletion(json, error)
        }
        task.resume()
    }
}