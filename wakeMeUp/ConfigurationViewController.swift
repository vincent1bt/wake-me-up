//
//  ConfigurationViewController.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 3/30/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import UIKit
import TwitterKit

class ConfigurationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var session: String?
    
    @IBOutlet weak var tableView: UITableView!
    let config = ["Inicia sesión con Twitter", "Inicia sesion con Facebook"]
    let alreadyConfig = ["Sesión de Twitter iniciada"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = Twitter.sharedInstance().sessionStore.session()?.userID
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Inicia sesión para ver tu timeline"
        } else {
            return "Facebook"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("configCell", forIndexPath: indexPath)
        if indexPath.section == 0 {
            if session != nil {
              cell.textLabel?.text = alreadyConfig[0]
              cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
              cell.textLabel?.text = config[0]
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            if session != nil {
                let store = Twitter.sharedInstance().sessionStore
                let userID = store.session()?.userID
                store.logOutUserID(userID!)
            } else {
                Twitter.sharedInstance().logInWithCompletion() {
                    session, error in
                    if session != nil {
                        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
                    }
                }
            }
        }
    }
}
