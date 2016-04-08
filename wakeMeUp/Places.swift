//
//  Places.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 3/31/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation
import MapKit

struct Places {
    static var places = [Place]()
}

struct Place {
    var id: String?
    var name: String?
    var longitude: Float?
    var latitude: Float?
    var adress: String?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(self.latitude!), longitude: Double(self.longitude!))
    }
}