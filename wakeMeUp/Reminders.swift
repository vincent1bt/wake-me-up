//
//  Reminders.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 4/12/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation
import RealmSwift

struct Reminders {
    static var reminders: Results<Reminder>! {
        get {
            return Data.sharedInstance.realm.objects(Reminder)
        }
    }
}

class Reminder: Object {
    dynamic var id: String = NSUUID().UUIDString
    dynamic var title: String = ""
    dynamic var editing: Bool = false
    dynamic var end: Bool = false
    dynamic var date: NSDate? = nil
    dynamic var stringDate: String? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}