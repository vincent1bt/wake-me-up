//
//  ReminderViewController.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 4/12/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import UIKit
import RealmSwift

class ReminderViewController: UIViewController {

    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textFieldLabel: UITextField!

    var reminder: Reminder?
    var date: NSDate?
    var reminderTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textFieldLabel.text = reminder!.title
        if let passDate = reminder!.stringDate {
            self.dateLabel.text = passDate
            self.datePicker.date = reminder!.date!
        }
    }
    
    func dateExits() -> NSDate? {
        if let passDate = reminder!.date {
            return passDate
        } else {
            return nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func endEditingTitle(sender: UITextField) {
        if sender.text != reminder!.title {
            reminderTitle = sender.text
        }
    }
    
    @IBAction func deleteNotification(sender: UIButton) {
        deleteBtn.enabled = false
        deleteBtn.hidden = true
    }

    @IBAction func getDate(sender: UIDatePicker) {
        date = sender.date
        dateLabel.text = Data.sharedInstance.dateToString(date!)
        deleteBtn.enabled = true
        deleteBtn.hidden = false
    }
    
    @IBAction func makeNotification(sender: UIBarButtonItem) {
        if self.date == nil && self.reminderTitle == nil {
            self.performSegueWithIdentifier("backToReminders", sender: self)
            return
        }
        Data.sharedInstance.realm.beginWrite()
        let updateReminder = self.reminder!
        
        if reminderTitle != nil && reminderTitle != reminder!.title {
            updateReminder.title = reminderTitle!
        }
        
        if self.date != nil {
            if reminder!.date == nil || self.date! != reminder!.date {
                updateReminder.date = self.date
                updateReminder.stringDate = Data.sharedInstance.dateToString(self.date!)
            }
        }
        
        Data.sharedInstance.realm.add(updateReminder, update: true)
        do {
            try Data.sharedInstance.realm.commitWrite()
            print("guardando")
        } catch (let e) {
            print("Error \(e)")
        }
        NSNotificationCenter.defaultCenter().postNotificationName(API.Notifications.updateTable, object: nil)
        self.performSegueWithIdentifier("backToReminders", sender: self)
    }
}






