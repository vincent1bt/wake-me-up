//
//  ViewController.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 3/28/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//
import MapKit
import CoreLocation
import UIKit
import TwitterKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate,CLLocationManagerDelegate, TWTRTweetViewDelegate {

    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var showMap = false
    var typeOfInfo = TypeOfTable.Reminders
    var map: MKMapView!
    var locationManager: CLLocationManager!
    let distanceSpan: Double = 500
    
    let recordatorios = ["comida", "pasear", "perro", "comida", "pasear", "perro", "comida", "pasear", "perro", "escuchar"]
    
    let masrecordatorios = ["comida", "pasear", "perro", "comida", "pasear", "perro", "comida", "pasear", "perro", "escuchar"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureMap()
        putData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.navigationController?.hidesBarsOnSwipe = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureMap() {
        map = MKMapView()
        map.delegate = self
        map.frame = CGRect(x: 0, y: 115, width: self.view.frame.width, height: 0)
        self.view.addSubview(map)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        map.showsUserLocation = true
    }
    
    func getLocation() {
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        let identifier = "annotationIdentifier"
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        view?.canShowCallout = true
        let btn = UIButton(type: .InfoLight)
        view!.rightCalloutAccessoryView = btn
        
        return view
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, distanceSpan, distanceSpan)
        map.setRegion(region, animated: true)
        refreshPlaces(newLocation)
    }
    
    func configureTableView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: "tweetsCell")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch typeOfInfo {
        case .Reminders:
            return 2
        case .News:
            return 2
        case .Places:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else if indexPath.section == 1 {
            return 150
        } else {
            return 150
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRectMake(10, 15, tableView.frame.size.width, 30))
        label.font = UIFont.systemFontOfSize(18)
        label.textColor = UIColor.whiteColor()
        switch typeOfInfo {
        case .Reminders:
            if section == 0 {
                label.text = "Recordatorios"
            } else {
                label.text = "Clima"
            }
        case .News:
            if section == 0 {
                label.text = "Noticias"
            } else {
                label.text = "Twitter"
            }
        case .Places:
            label.text =  "Lugares"
        }
        
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 60))
        view.addSubview(label)//rgba(243, 156, 18,1.0)
        
        view.backgroundColor = UIColor(red: 243.0/255, green: 156.0/255, blue: 18.0/255, alpha: 0.98)
        return view
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch typeOfInfo {
        case .Reminders:
            if section == 0 {
                return 10
            } else {
                return 10
            }
        case .News:
            if section == 0 {
                return News.sharedInstance.news.count
            } else {
                return News.sharedInstance.tweets.count
            }
        case .Places:
            return Places.places.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let place = Places.places[indexPath.row]
        let region = MKCoordinateRegionMakeWithDistance(place.coordinate, distanceSpan, distanceSpan)
        map.setRegion(region, animated: true)
        let currentLocation = MKMapItem.mapItemForCurrentLocation()

    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch typeOfInfo {
        case .Reminders:
            let cell = tableView.dequeueReusableCellWithIdentifier("newsCell", forIndexPath: indexPath)
            cell.textLabel?.text = recordatorios[indexPath.row]
            cell.detailTextLabel?.text = masrecordatorios[indexPath.row]
            return cell
            
        case .News:
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("newsCell", forIndexPath: indexPath)
                let new = News.sharedInstance.getDataFromNewsById(indexPath.row)
                cell.textLabel!.text = new["title"]
                cell.detailTextLabel?.text = new["date"]
                return cell
                
            } else {
                let tweet = News.sharedInstance.tweets[indexPath.row]
                let cell = tableView.dequeueReusableCellWithIdentifier("tweetsCell", forIndexPath: indexPath) as! TWTRTweetTableViewCell
                cell.configureWithTweet(tweet)
                cell.tweetView.delegate = self
                return cell
            }
        case .Places:
            let cell = tableView.dequeueReusableCellWithIdentifier("newsCell", forIndexPath: indexPath)
            let place = Places.places[indexPath.row]
            cell.textLabel?.text = place.name
            cell.detailTextLabel?.text = place.adress
            return cell
        }
    }
    
    func putData() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onNewsUpdated(_:)), name: API.Notifications.newsUpdated, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onTweetsUpdated(_:)), name: API.Notifications.tweetsUpdated, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onPlacesUpdated(_:)), name: API.Notifications.placesUpdated, object: nil)
        
        Data.sharedInstance.getDataFromTweets()
        Data.sharedInstance.getDataFromNews()
        
    }
    
    @IBAction func changeTypeOfTable(sender: UISegmentedControl) {
        let num = sender.selectedSegmentIndex
        let table = TypeOfTable(rawValue: num)!
        
        switch table {
        case .Reminders:
            typeOfInfo = .Reminders
            self.tableView.reloadData()
            hideMap()
        case .News:
            typeOfInfo = .News
            self.tableView.reloadData()
            hideMap()
        case .Places:
            typeOfInfo = .Places
            self.tableView.reloadData()
            getMap()
            getLocation()
        }
        
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
        self.tableView.reloadSections(sections, withRowAnimation: .Fade)
    }
    
    func getMap() {
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.map.frame = CGRect(x: 0, y: 115, width: self.view.frame.width, height: 250)
            self.tableViewTopConstraint.constant += self.map.frame.height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func hideMap() {
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.tableViewTopConstraint.constant -= self.map.frame.height
            self.map.frame = CGRect(x: 0, y: 115, width: self.view.frame.height, height: 0)
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func refreshPlaces(location: CLLocation) {
        Data.sharedInstance.getDataFromPlaces(location)
    }
    
    func onNewsUpdated(notification: NSNotification) {
    }
    
    func onTweetsUpdated(notification: NSNotification) {
    }
    
    func onPlacesUpdated(notification: NSNotification) {
        let places = Places.places
        for place in places {
            let annotation = FoodAnnotation(title: place.name, subtitle: place.adress, coordinate: place.coordinate)
            map.addAnnotation(annotation)
        }
    }
    
    
    @IBAction func unwindForSegue(unwindSegue: UIStoryboardSegue) {
    
    }
}

