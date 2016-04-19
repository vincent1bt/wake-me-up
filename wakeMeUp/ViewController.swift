//
//  ViewController.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 3/28/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//
//CHECAR CONSTRAINT, INTENTA ESCONDER EL MAPA CUANDO YA ESTA ESCONDIDO!!
//Los botones se ponen antes de que la vista este lista

import MapKit
import CoreLocation
import UIKit
import TwitterKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate,CLLocationManagerDelegate, TWTRTweetViewDelegate, RemindersTableViewCellDelegate {
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var reminders: Results<Reminder>!
    var showMap = false
    var rowPath: Int?
    var typeOfInfo = TypeOfTable.Reminders
    var map: MKMapView!
    var locationManager: CLLocationManager!
    let distanceSpan: Double = 500
    var configMapView: UIView!
    var viewHeight: CGFloat = 365
    var mapExpanded: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Recordatorios"
        self.reminders = Reminders.reminders
        configureTableView()
        getSize()
        configureMap()
        configButtons()
        putData()
        getWeather()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureMap() {
        map = MKMapView()
        map.delegate = self
        map.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0)
        map.showsUserLocation = true
        
        configMapView = UIView()
        configMapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0)
        //clouds color
        configMapView.backgroundColor = UIColor.init(red: 236/255, green: 240/255, blue: 241/255, alpha: 0.98)
        configMapView.addSubview(map)
        self.view.addSubview(configMapView)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
    }
    
    func configButtons() {
        let cancelBtn = createButton("Cancelar", tag: 4)
        cancelBtn.leadingAnchor.constraintEqualToAnchor(configMapView.leadingAnchor).active = true
        cancelBtn.enabled = false
        cancelBtn.alpha = 0.7
        cancelBtn.addTarget(self, action: #selector(self.cancelRoute), forControlEvents: .TouchUpInside)
        
        let positionBtn = createButton("Ubicación", tag: 5)
        positionBtn.addTarget(self, action: #selector(self.putUserLocation), forControlEvents: .TouchUpInside)
        
        let bigMapBtn = createButton("Expandir", tag: 6)
        bigMapBtn.addTarget(self, action: #selector(self.expandMap), forControlEvents: .TouchUpInside)
        bigMapBtn.trailingAnchor.constraintEqualToAnchor(configMapView.trailingAnchor).active = true
        
        cancelBtn.trailingAnchor.constraintEqualToAnchor(positionBtn.leadingAnchor).active = true
        positionBtn.trailingAnchor.constraintEqualToAnchor(bigMapBtn.leadingAnchor).active = true
        
    }
    
    func createButton(title: String, tag: Int) -> UIButton {
        let newBtnWidth = self.configMapView.frame.width / 3
        let newBtn = UIButton()
        
        newBtn.tag = tag
        newBtn.hidden = true
        newBtn.setTitle(title, forState: .Normal)
        newBtn.setTitleColor(UIColor.init(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0), forState: .Normal)
        newBtn.translatesAutoresizingMaskIntoConstraints = false
        self.configMapView.addSubview(newBtn)
        newBtn.topAnchor.constraintEqualToAnchor(map.bottomAnchor).active = true
        newBtn.widthAnchor.constraintEqualToAnchor(nil, constant: newBtnWidth).active = true
        newBtn.heightAnchor.constraintEqualToAnchor(nil, constant: 50).active = true
        return newBtn
    }
    
    func getLocation() {
    }
    
    func putUserLocation() {
        let userLocation = map.userLocation
        let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, distanceSpan, distanceSpan)
        map.setRegion(region, animated: true)
    }
    
    func cancelRoute(sender: UIButton!) {
        self.map.removeOverlays(self.map.overlays)
        sender.setTitleColor(UIColor.init(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0), forState: .Normal)
        sender.enabled = false
        for annotation in self.map.annotations {
            if annotation.isKindOfClass(FoodAnnotation.self) {
                self.map.viewForAnnotation(annotation)?.hidden = false
            }
        }
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        for annotation in self.map.annotations {
            let actualAnnotation = view.annotation!
            
            if annotation.isKindOfClass(FoodAnnotation.self) {
                self.map.viewForAnnotation(annotation)?.hidden = true
            }
            
            if actualAnnotation === annotation {
                self.map.viewForAnnotation(annotation)?.hidden = false
            }
        }
        
        self.map.removeOverlays(self.map.overlays)
        let destination = view.annotation?.coordinate
        let mark = MKPlacemark(coordinate: destination!, addressDictionary: nil)
        let destinationItem = MKMapItem(placemark: mark)
        let request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = destinationItem
        request.requestsAlternateRoutes = true
        let directions = MKDirections(request: request)
        self.expandMap(true)
        
        directions.calculateDirectionsWithCompletionHandler { (response, error) in
            if error != nil {
                print("error, ubication")
            } else {
                self.showRoute(response!)
                let cancelBtn = self.configMapView.viewWithTag(4) as! UIButton
                cancelBtn.enabled = true
                cancelBtn.alpha = 1.0
                cancelBtn.setTitleColor(UIColor.init(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0), forState: .Normal)
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.init(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
        renderer.lineWidth = 5.0
        return renderer
    }
    
    func showRoute(response: MKDirectionsResponse) {
        for route in response.routes {
            map.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            for step in route.steps {
                print(step)
            }
        }
        let userLocation = map.userLocation
        let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, 2000, 2000)
        map.setRegion(region, animated: true)
    }
    
    func expandMap(callFromRoute: Bool = false) {
        let btn = self.configMapView.viewWithTag(6) as! UIButton
        if callFromRoute && mapExpanded {
            return
        } else if callFromRoute && !mapExpanded {
            //map fullScreen
            btn.setTitle("Reducir", forState: .Normal)
            changeSizeMap(0.4, mapHeight: self.view.frame.height - 50, mapViewHeight: self.view.frame.height)
            mapExpanded = true
            return
        }
        
        if mapExpanded {
            //normal map
            btn.setTitle("Expandir", forState: .Normal)
            changeSizeMap(1.0, mapHeight: self.viewHeight - 50, mapViewHeight: self.viewHeight)
            mapExpanded = false
        } else {
            //map fullScreen
            btn.setTitle("Reducir", forState: .Normal)
            changeSizeMap(0.4, mapHeight: self.view.frame.height - 50, mapViewHeight: self.view.frame.height)
            mapExpanded = true
        }
    }
    
    func changeSizeMap(alpha: CGFloat, mapHeight: CGFloat, mapViewHeight: CGFloat) {
        self.configMapView.viewWithTag(4)?.hidden = true
        self.configMapView.viewWithTag(5)?.hidden = true
        self.configMapView.viewWithTag(6)?.hidden = true
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            self.tableView.alpha = alpha
            self.configMapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: mapViewHeight)
            self.map.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: mapHeight)
        }) { (_) in
            self.configMapView.viewWithTag(4)?.hidden = false
            self.configMapView.viewWithTag(5)?.hidden = false
            self.configMapView.viewWithTag(6)?.hidden = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, distanceSpan, distanceSpan)
        map.setRegion(region, animated: true)
        refreshPlaces(newLocation)
    }
    
    func configureTableView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch typeOfInfo {
        case .Reminders:
            if section == 0 {
                return 1
            } else {
                return reminders.count + 1
            }
        case .News:
            if section == 0 {
                return News.newsItems.count
            } else {
                return News.tweets.count
            }
        case .Places:
            return Places.places.count
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if typeOfInfo == .Reminders && indexPath.section == 0 {
            return 250.0
        } else {
            return UITableViewAutomaticDimension   
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRectMake(10, 15, tableView.frame.size.width, 30))
        label.font = UIFont.systemFontOfSize(18)
        label.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 0.98)
        
        switch typeOfInfo {
        case .Reminders:
            if section == 0 {
                label.text = "Clima"
            } else {
                label.text = "Recordatorios"
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
        view.addSubview(label)
        view.backgroundColor = UIColor.init(red: 236/255, green: 240/255, blue: 241/255, alpha: 0.98)
        return view
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if typeOfInfo == .Places {
            let place = Places.places[indexPath.row]
            let region = MKCoordinateRegionMakeWithDistance(place.coordinate, distanceSpan, distanceSpan)
            map.setRegion(region, animated: true)
            map.selectAnnotation(FoodAnnotations.annotations[indexPath.row], animated: true)
        }
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        if typeOfInfo == .Reminders && indexPath.section == 1 {
            if reminders[indexPath.row].editing {
                self.rowPath = indexPath.row
                performSegueWithIdentifier("reminderSegue", sender: self)
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch typeOfInfo {
        case .Reminders:
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("weatherCell", forIndexPath: indexPath) as! WeatherTableViewCell
                cell.firstLabel.text = Weather.degrees
                cell.secondLabel.text = Weather.description
                if let imageIcon = Weather.imageName {
                 cell.imageViewLabel.image = UIImage(named: imageIcon)
                }
                cell.thirdLabel.text = Weather.date
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("remindersCell", forIndexPath: indexPath) as! RemindersTableViewCell
                cell.textField.tag = indexPath.row
                cell.delegate = self
                cell.id = indexPath.row
                cell.maxId = reminders.count
                
                if indexPath.row == reminders.count {
                    cell.accessoryType = .None
                    cell.textField.text = ""
                    cell.dateLabel.text = ""
                } else {
                    let reminder = reminders[indexPath.row]
                    cell.textField.text = reminder.title
                    if let date = reminder.stringDate {
                        cell.dateLabel.text = date
                    } else {
                        cell.dateLabel.text = ""
                    }
                    
                    if reminder.end {
                        cell.textField.textColor = UIColor.init(red: 39/255, green: 174/255, blue: 96/255, alpha: 1.0)
                    } else {
                        cell.textField.textColor = UIColor.blackColor()
                    }
                    
                    if indexPath.row == reminders.count {
                        cell.textField.textColor = UIColor.blackColor()
                    }
                    
                    cell.accessoryType = .DetailButton
                }
                return cell
            }
        case .News:
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("news2Cell", forIndexPath: indexPath) as! NewsTableViewCell
                let new = News.newsItems[indexPath.row]
                cell.titleLabel.text = new.title
                cell.contentLabel.text = new.content
                cell.dateLabel.text = new.date
                if let image = new.image {
                    cell.imageViewLabel.image = image
                }
                return cell
                
            } else {
                let tweet = News.tweets[indexPath.row]
                let cell = tableView.dequeueReusableCellWithIdentifier("tweetsCell", forIndexPath: indexPath) as! TWTRTweetTableViewCell
                cell.configureWithTweet(tweet)
                cell.tweetView.delegate = self
                return cell
            }
        case .Places:
            let cell = tableView.dequeueReusableCellWithIdentifier("newsCell", forIndexPath: indexPath)
            let place = Places.places[indexPath.row]
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel?.text = place.name
            cell.detailTextLabel?.text = place.adress
            return cell
        }
    }
    
    @IBAction func endEditingReminder(sender: UITextField) {
        if sender.text != nil && sender.text != "" {
            if sender.tag != reminders.count {
                if reminders[sender.tag].editing {
                    self.updateReminder(sender.text!, id: sender.tag)
                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 1), atScrollPosition: .Bottom, animated: false)
                }
            } else {
                createReminder(sender.text!)
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.reminders.count - 1, inSection: 1), atScrollPosition: .Bottom, animated: false)
            }
        }
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.frame.origin.y = 0
        }, completion: nil)
    }
    
    func createReminder(text: String) {
        Data.sharedInstance.saveReminder(text)
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
    }
    
    func updateReminder(text: String, id: Int) {
        let reminder = reminders[id]
        Data.sharedInstance.updateReminder(reminder, text: text)
    }
    
    func reminderDeleted(id: Int) {
        let reminder = reminders[id]
        Data.sharedInstance.deleteReminder(reminder)
        
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: id, inSection: 1)], withRowAnimation: .Fade)
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: id + 1, inSection: 1), atScrollPosition: .Bottom, animated: false)
        self.tableView.endUpdates()
    }
    
    func completeReminder(id: Int) {
        let reminder = reminders[id]
        Data.sharedInstance.completeReminder(reminder)
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
    }

    @IBAction func beginEditReminder(sender: UITextField) {
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 1), atScrollPosition: .Bottom, animated: false)
            self.view.frame.origin.y = -171
        }, completion: nil)
    }
    
    
    func putData() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.onNewsUpdated(_:)), name: API.Notifications.newsUpdated, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.onTweetsUpdated(_:)), name: API.Notifications.tweetsUpdated, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.onPlacesUpdated(_:)), name: API.Notifications.placesUpdated, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.onWeatherUpdated(_:)), name: API.Notifications.weatherUpdated, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateTable(_:)), name: API.Notifications.updateTable, object: nil)

        Data.sharedInstance.getDataFromTweets()
        Data.sharedInstance.getDataFromNews()
    }
    
    func getWeather() {
        let lon = self.map.userLocation.coordinate.longitude
        let lat = self.map.userLocation.coordinate.latitude
        Data.sharedInstance.getDataFromWeather(lat, lon: lon)
    }
    
    @IBAction func changeTypeOfTable(sender: UISegmentedControl) {
        let num = sender.selectedSegmentIndex
        let table = TypeOfTable(rawValue: num)!
        
        switch table {
        case .Reminders:
            typeOfInfo = .Reminders
            self.tableView.reloadData()
            self.title = "Recordatorios"
            hideMap()
        case .News:
            typeOfInfo = .News
            self.tableView.reloadData()
            self.title = "Noticias"
            hideMap()
        case .Places:
            typeOfInfo = .Places
            self.tableView.reloadData()
            self.title = "Lugares"
            getMap()
            getLocation()
        }
        
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
        self.tableView.reloadSections(sections, withRowAnimation: .Fade)
    }
    
    func getSize() {
        let height = self.view.frame.height
        if height <= 480.0 {
            self.viewHeight = 255
        }
        
        if height >= 667.0 {
            self.viewHeight = 365
        }
        
        if height == 568.0 {
            self.viewHeight = 310
        }
    }
    
    func getMap() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.configMapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.viewHeight)
            self.map.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.viewHeight - 50)
            self.tableViewTopConstraint.constant += self.viewHeight - 64
            self.view.layoutIfNeeded()
            }, completion: {
                (_) in
                self.configMapView.viewWithTag(4)?.hidden = false
                self.configMapView.viewWithTag(5)?.hidden = false
                self.configMapView.viewWithTag(6)?.hidden = false
        })
    }
    
    func hideMap() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.tableViewTopConstraint.constant = -64
            self.map.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0)
            self.configMapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.height, height: 0)
            self.configMapView.viewWithTag(4)?.hidden = true
            self.configMapView.viewWithTag(5)?.hidden = true
            self.configMapView.viewWithTag(6)?.hidden = true
            self.view.layoutIfNeeded()
            }, completion: {
                (_) in
        })
    }
    
    func refreshPlaces(location: CLLocation) {
        Data.sharedInstance.getDataFromPlaces(location)
    }
    
    func onNewsUpdated(notification: NSNotification) {
    }
    
    func onTweetsUpdated(notification: NSNotification) {
    }
    
    func onPlacesUpdated(notification: NSNotification) {
        map.addAnnotations(FoodAnnotations.annotations)
    }
    
    func updateTable(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            [unowned self] in
            self.tableView.reloadSections(NSIndexSet(index: 1) , withRowAnimation: .Fade)
        }
    }
    
    func onWeatherUpdated(notification: NSNotification) {
        if typeOfInfo == .Reminders {
            dispatch_async(dispatch_get_main_queue()) {
                [unowned self] in
                self.tableView.reloadSections(NSIndexSet(index: 0) , withRowAnimation: .Fade)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "reminderSegue" {
            let view = segue.destinationViewController.childViewControllers.first as! ReminderViewController
            view.reminder = reminders[rowPath!]
        }
    }
    
    @IBAction func unwindForSegue(unwindSegue: UIStoryboardSegue) {
    }
}

