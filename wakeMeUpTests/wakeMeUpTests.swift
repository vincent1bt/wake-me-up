//
//  wakeMeUpTests.swift
//  wakeMeUpTests
//
//  Created by vicente rodriguez on 3/28/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import XCTest
@testable import wakeMeUp
import CoreLocation

class wakeMeUpTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDateToString() {
        let date = NSDate()
        let dateString = Data.sharedInstance.dateToString(date)
        XCTAssertNotNil(dateString, "DateToString don't work")
    }
    
    func testWeatherAPI() {
        Request.sharedInstance.getWeather(CLLocationDegrees(40.7127837), lon: CLLocationDegrees(-74.00594130000002)) {
            (json, error) -> Void in
            XCTAssertNil(error, "Error not nil WeatherAPI")
            XCTAssertNotNil(json, "Json is nil WeatherAPI")
        }
    }
    
    func testNewYorkTimesAPI() {
        Request.sharedInstance.getNews() {
            (json, error) -> Void in
            XCTAssertNil(error, "The error is not nil NewYorkTimes")
            XCTAssertNotNil(json, "The json is nil NewYorkTimes")
        }
    }
    
    func testTwitterAPI() {
        Request.sharedInstance.makeTwitterRequest() {
            (json, error) -> Void in
            XCTAssertNil(error, "The error is not nil TwitterAPI")
            XCTAssertNotNil(json, "The json is nil TwitterAPI")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
