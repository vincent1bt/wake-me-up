//
//  Weather.swift
//  wakeMeUp
//
//  Created by vicente rodriguez on 4/10/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation

enum TypeOfImage: String {
    case Clouds = "02"
    case ScatteredClouds = "03"
    case BrokenClouds = "04"
    case ShowerRain = "09"
    case Rain = "10"
    case Thunderstorm = "11"
    case Snow = "13"
    case Mist = "50"
}

struct Weather {
    static var degrees: String?
    static var description: String?
    static var imageName: String?
    static var date: String?
}