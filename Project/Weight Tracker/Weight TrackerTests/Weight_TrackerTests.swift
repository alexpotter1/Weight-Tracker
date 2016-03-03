//
//  Weight_TrackerTests.swift
//  Weight TrackerTests
//
//  Created by Alex Potter on 27/08/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import XCTest
@testable import Weight_Tracker

class Weight_TrackerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExpectedWeight() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // Setting up some test data...
        let weightArray = NSMutableArray(array: ["72.6", "73.4", "73.5", "73.1", "71.9", "71.9", "71.7"])
        let dateArray = NSMutableArray(array: ["Mon, 5 June 2015", "Mon, 12 June 2015", "Thu, 15 June 2015", "Sat, 17 June 2015", "Wed, 21 June 2015", "Thu, 22 June 2015", "Mon, 26 June 2015"])
        
        // This code is essentially the same as in the main class...
        let dateFormatter = NSDateFormatter()
        let stat = StatisticalAnalysis(_dateArray: dateArray, _weightArray: weightArray)
        stat.RegressionAnalysis()
        
        dateFormatter.dateFormat = "EEE, d MMM yyyy"
        let lastDate = dateFormatter.dateFromString(dateArray.lastObject as! String)
        
        // Next value in one week...
        let nextValue = stat.RegressionNextValue(lastDate!.timeIntervalSinceReferenceDate + 604800)
        
        // Regression (a+Bx) done on a Casio FX-991ES Plus
        let actualRegressionValue: Double = 71.47902132
        
        // XCTAssertEqual checks if two expressions are exactly equal in type and value
        // Rounding the value given by the code as the calculator is limited to 8 decimal places
        XCTAssertEqual(nextValue.roundToDecimalPlaces(8), actualRegressionValue)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    
}
