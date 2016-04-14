//
//  Request.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 3/29/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//
import Foundation
import TwitterKit
import QuadratTouch
import MapKit

typealias JSONResponse = (JSON, NSError?) -> Void
typealias DataResponse = ([[String : AnyObject]]) -> Void

struct Request {
    var session: Session?
    static let sharedInstance = Request()
    
    private let keyMostPopular = "df44537e748f15225473138a13a01619:14:74524472"
    private let weatherKey = "5ad09f42d5b07b43301d02ac54ef499f"
    
    init() {
        let client = Client(clientID: Keys.Foursquare.clientId , clientSecret: Keys.Foursquare.clientSecret , redirectURL: "")
        let configuration = Configuration(client: client)
        Session.setupSharedSessionWithConfiguration(configuration)
        self.session = Session.sharedSession()
    }
    
    //openweather api
    func getWeather(lat: CLLocationDegrees, lon: CLLocationDegrees, onCompletion: JSONResponse) {
        let endPoint = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&APPID=\(weatherKey)&units=metric&lang=es"
        makeHTTPRequest(endPoint) { (json, error) in
            onCompletion(json, error)
        }
    }
    
    //new york times api
    func getNews(onCompletion: JSONResponse) {
        let urlString = "mostpopular/v2/mostviewed/all-sections/1?api-key=\(keyMostPopular)"
        let endPoint = "http://api.nytimes.com/svc/" + urlString
        makeHTTPRequest(endPoint) { (json, error) in
            onCompletion(json, error)
        }
    }
    
    //twitter api
    func getTweets(onCompletion: JSONResponse) {
        makeTwitterRequest() {
            (json, error) in
            onCompletion(json, nil)
        }
    }
    
    //forsquare api
    func getPlaces(location: CLLocation, onCompletion: DataResponse) {
        var parameters = location.parameters()
        parameters += [Parameter.categoryId: "4d4b7105d754a06374d81259"]
        parameters += [Parameter.radius: "2000"]
        parameters += [Parameter.limit: "50"]
        makeFoursquareRequest(parameters) {
            (venues) in
            onCompletion(venues)
        }
    }
    
    private func makeHTTPRequest(url: String, onCompletion: JSONResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            let json: JSON = JSON(data: data!)
            onCompletion(json, error)
        }
        task.resume()
    }
    
    private func makeTwitterRequest(onCompletion: JSONResponse) {
        let userID = Twitter.sharedInstance().sessionStore.session()?.userID
        let client = TWTRAPIClient(userID: userID)
        let endPoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count": "10", "trim_user":"false"]
        var clientError: NSError?
        
        let request = client.URLRequestWithMethod("GET", URL: endPoint, parameters: params, error: &clientError)
        
        guard clientError == nil else {
            return
        }
        
        client.sendTwitterRequest(request) {
            (response, data, connectionError) -> Void in
            
            if connectionError == nil {
                let json: JSON = JSON(data: data!)
                onCompletion(json, nil)
            }
        }
        
    }
    
    private func makeFoursquareRequest(parameters: Parameters, onCompletion: DataResponse) {
        let searchTask = session?.venues.search(parameters) {
            (result) -> Void in
            
            guard let response = result.response else {
                return
            }
            guard let venues = response["venues"] as? [[String: AnyObject]] else {
                return
            }
            onCompletion(venues)
        }
        searchTask?.start()
    }
}



