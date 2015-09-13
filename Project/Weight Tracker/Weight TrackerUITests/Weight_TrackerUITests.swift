//
//  Weight_TrackerUITests.swift
//  Weight TrackerUITests
//
//  Created by Alex Potter on 27/08/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import XCTest
import Cocoa

class Weight_TrackerUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        NSUserDefaults.standardUserDefaults().removeObjectForKey("NewUserNames")
        super.tearDown()
    }
    
    func testUICreateUser() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // Code created by Xcode's UI Test Record Feature
        let weightTrackerWindow = XCUIApplication().windows["Weight Tracker"]
        weightTrackerWindow.buttons["Create a new user"].click()
        
        let sheetsQuery = weightTrackerWindow.sheets
        sheetsQuery.textFields["Type the new user's name here..."].typeText("Test123")
        weightTrackerWindow.click()
        sheetsQuery.buttons["Done"].click()
        weightTrackerWindow.comboBoxes["Select a user..."].childrenMatchingType(.Button).element.click()
        weightTrackerWindow.scrollViews.otherElements.childrenMatchingType(.TextField).elementBoundByIndex(0).click()
        weightTrackerWindow.buttons["Continue"].click()
        
    }
    
    func testUISetUpUserSettings() {
        // Code created by Xcode's UI Test Record feature
        let weightTrackerWindow = XCUIApplication().windows["Weight Tracker"]
        weightTrackerWindow.comboBoxes["Select a user..."].childrenMatchingType(.Button).element.click()
        weightTrackerWindow.scrollViews.otherElements.childrenMatchingType(.TextField).element.click()
        weightTrackerWindow.buttons["Continue"].click()
        weightTrackerWindow.buttons["Settings..."].click()
        
        let popoversQuery = weightTrackerWindow.popovers
        popoversQuery.childrenMatchingType(.PopUpButton).element.click()
        weightTrackerWindow.popovers.menuItems["Kilograms (kg)"].click()
        popoversQuery.buttons["Done"].click()
        weightTrackerWindow.buttons[XCUIIdentifierCloseWindow].click()
        
        
    }
    
}
