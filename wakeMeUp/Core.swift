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
import RealmSwift

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
        static let weatherUpdated = "weatherUpdated"
        static let updateTable = "updateTable"
    }
}

struct Data {
    static let sharedInstance = Data()
    let realm = try! Realm()
    
    func saveReminder(title: String) {
        let reminder = Reminder()
        reminder.title = title
        reminder.editing = true
        try! realm.write({
            realm.add(reminder)
        })
    }
    
    func updateReminder(reminder: Reminder, text: String) {
        try! realm.write({ 
            reminder.title = text
        })
    }
    
    func completeReminder(reminder: Reminder) {
        try! realm.write({
            reminder.end = true
        })
    }
    
    func deleteReminder(reminderToDelete: Reminder) {
        try! realm.write({ 
            realm.delete(reminderToDelete)
        })
    }
    
    func dateToString(date: NSDate) -> String {
       return NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
    }
    
    func getDataFromNews() {
        Request.sharedInstance.getNews() { (json, error) in
            let results = json["results"].arrayValue
            for new in results {
                var newItem = NewsItem()
                newItem.title = new["title"].stringValue
                newItem.url = new["url"].stringValue
                newItem.date = (new["published_date"].stringValue).componentsSeparatedByString("T")[0]
                newItem.content =  new["abstract"].stringValue
                
                if let imagesArray = ((new["media"].arrayValue).first)?["media-metadata"].arrayValue {
                    if imagesArray.count > 7 {
                        let imageUrl = imagesArray[7]["url"].string
                        if let url =  NSURL(string: imageUrl!) {
                            if let data = NSData(contentsOfURL: url) {
                                let image = UIImage(data: data)
                                newItem.image = image
                            }
                        }
                    }
                }
                
                News.newsItems.append(newItem)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(API.Notifications.newsUpdated, object: nil)
        }
    }
    
    func getDataFromTweets() {
        Request.sharedInstance.makeTwitterRequest() { (json, error) -> Void in
            News.tweets = TWTRTweet.tweetsWithJSONArray((json.object as! [AnyObject])) as! [TWTRTweet]
            NSNotificationCenter.defaultCenter().postNotificationName(API.Notifications.tweetsUpdated, object: nil)
        }
    }
    
    func getDataFromWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        Request.sharedInstance.getWeather(lat, lon: lon) { (json, error) in
            let degrees = (json["main"].dictionaryValue)["temp"]?.numberValue
            let description = (json["weather"].arrayValue.first)?.dictionaryValue["description"]?.stringValue
            let icon = (json["weather"].arrayValue.first)?.dictionaryValue["icon"]?.stringValue
            if degrees != nil {
                Weather.degrees = "\(Int(degrees!))°c"
            }
            if description != nil {
                Weather.description = description!.capitalizedString
            }
            if icon != nil {
                if icon == "01d" {
                    Weather.imageName = "sunHd"
                } else if icon == "01n" {
                    Weather.imageName = "nightHd"
                } else {
                    let image = (icon! as NSString).substringWithRange(NSMakeRange(0, 2))
                    if let possibleIcon = TypeOfImage(rawValue: image) {
                        switch possibleIcon {
                        case .Clouds, .BrokenClouds, .ScatteredClouds:
                            Weather.imageName = "cloudsHd"
                        case .Rain, .ShowerRain:
                            Weather.imageName = "rainHd"
                        case .Mist:
                            Weather.imageName = "mistHd"
                        case .Thunderstorm:
                            Weather.imageName = "thunderstormHd"
                        case .Snow:
                            Weather.imageName = "snowHd"
                        }
                    }
                }
            }
            let date = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateStyle = .LongStyle
            Weather.date = formatter.stringFromDate(date)

            NSNotificationCenter.defaultCenter().postNotificationName(API.Notifications.weatherUpdated, object: nil)
        }
    }
    
    func getDataFromPlaces(location: CLLocation) {
        Request.sharedInstance.getPlaces(location) {
            (venues) in
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
                    let annotation = FoodAnnotation(title: newPlace.name, subtitle: newPlace.adress, coordinate: newPlace.coordinate)
                    FoodAnnotations.annotations.append(annotation)
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

