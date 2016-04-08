//
//  Core.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 3/29/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation
import TwitterKit
import MapKit
import QuadratTouch

enum TypeOfTable: Int {
    case Reminders = 0
    case News = 1
    case Places = 2
}

struct API {
    struct Notifications {
        static let newsUpdated = "newsUpdated"
        static let tweetsUpdated = "tweetsUpdated"
        static let placesUpdated = "placesUpdated"
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
    
    func getDataFromPlaces(location: CLLocation) {
        Request.sharedInstance.getPlaces(location) {
            (venues) in
            autoreleasepool() {
                for venue: [String: AnyObject] in venues {
                    var newPlace = Place()
                    
                    if let id = venue["id"] as? String {
                        newPlace.id = id
                    }
                    
                    if let name = venue["name"] as? String {
                        newPlace.name = name
                    }
                    
                    if let location = venue["location"] as? [String: AnyObject] {
                        if let longitude = location["lng"] as? Float {
                            newPlace.longitude = longitude
                        }
                        
                        if let latitude = location["lat"] as? Float {
                            newPlace.latitude = latitude
                        }
                        
                        if let adress = location["formattedAdress"] as? [String] {
                            newPlace.adress = adress.joinWithSeparator(" ")
                        }
                    }
                    Places.places.append(newPlace)
                }
            }
            NSNotificationCenter.defaultCenter().postNotificationName(API.Notifications.placesUpdated, object: nil)
        }
    }
    
}

extension CLLocation {
    func parameters() -> Parameters {
        let ll = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc = "\(self.horizontalAccuracy)"
        let alt = "\(self.altitude)"
        let altAcc = "\(self.verticalAccuracy)"
        let parameters = [
            Parameter.ll: ll,
            Parameter.llAcc: llAcc,
            Parameter.alt: alt,
            Parameter.altAcc: altAcc
        ]
        return parameters
    }
}

