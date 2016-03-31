//
//  ViewController.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 3/28/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//
import MapKit
import UIKit
import TwitterKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TWTRTweetViewDelegate {

    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var showMap = false
    var map: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        putData()
        map = MKMapView()
        map.frame = CGRect(x: 0, y: 115, width: self.view.frame.height, height: 0)
        self.view.addSubview(map)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.navigationController?.hidesBarsOnSwipe = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureTableView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: "tweetsCell")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
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
        switch section {
        case 0:
            label.text =  "New york times"
        case 1:
            label.text = "Twitter"
        default:
            label.text = "None"
        }
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 60))
        view.addSubview(label)//rgba(243, 156, 18,1.0)
        
        view.backgroundColor = UIColor(red: 243.0/255, green: 156.0/255, blue: 18.0/255, alpha: 0.98)
        return view
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return News.sharedInstance.news.count
        } else if section == 1{
            return News.sharedInstance.tweets.count
        } else {
            return 10
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("newsCell", forIndexPath: indexPath)
            let new = News.sharedInstance.getDataFromNewsById(indexPath.row)
            cell.textLabel!.text = new["title"]
            cell.detailTextLabel?.text = new["date"]
            return cell
            
        } else if indexPath.section == 1 {
            let tweet = News.sharedInstance.tweets[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("tweetsCell", forIndexPath: indexPath) as! TWTRTweetTableViewCell
            cell.configureWithTweet(tweet)
            cell.tweetView.delegate = self
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("newsCell", forIndexPath: indexPath)
            return cell
        }
    }
    
    func putData() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onNewsUpdated(_:)), name: API.Notifications.newsUpdated, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onTweetsUpdated(_:)), name: API.Notifications.tweetsUpdated, object: nil)
        
        Data.sharedInstance.getDataFromTweets()
        Data.sharedInstance.getDataFromNews()
        
    }
    
    @IBAction func changeTypeOfTable(sender: UISegmentedControl) {
        let num = sender.selectedSegmentIndex
        switch num {
        case 0:
            hideMap()
        case 1:
            hideMap()
        case 2:
           getMap()
        default:
            break
        }
    }
    
    func getMap() {
        UIView.animateWithDuration(0.8, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.map.frame = CGRect(x: 0, y: 115, width: self.view.frame.height, height: 250)
            self.tableViewTopConstraint.constant += self.map.frame.height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func hideMap() {
        UIView.animateWithDuration(0.8, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.tableViewTopConstraint.constant -= self.map.frame.height
            self.map.frame = CGRect(x: 0, y: 115, width: self.view.frame.height, height: 0)
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func onNewsUpdated(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            [unowned self] in
            self.tableView.reloadData()
            self.tableView.reloadSections(NSIndexSet(index: 0) , withRowAnimation: .Fade)
        }
    }
    
    func onTweetsUpdated(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            [unowned self] in
            self.tableView.reloadData()
            self.tableView.reloadSections(NSIndexSet(index: 1) , withRowAnimation: .Fade)
        }
    }
    
    @IBAction func unwindForSegue(unwindSegue: UIStoryboardSegue) {
    }
}

