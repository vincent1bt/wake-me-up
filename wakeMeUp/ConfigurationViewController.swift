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
    let config = ["Inicia sesion con Twitter", "Inicia sesion con Facebook"]
    let alreadyConfig = ["Sesion de Twitter iniciada"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = Twitter.sharedInstance().sessionStore.session()?.userID
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Para poder ver tu timeline se necesita iniciar sesion con twitter"
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
        } else if indexPath.section == 1 {
            cell.textLabel?.text = config[1]
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
