//
//  AppDelegate.swift
//  Weight Tracker
//
//  Created by Alex Potter on 27/08/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // Connecting Interface Builder objects to the code so that they can be used
    // For MainMenu.xib:
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var ContinueButton: NSButton!
    @IBOutlet weak var UserComboBox: NSComboBox!
    
    /* Keeps a reference to the window controller that we're gonna switch to when
    we click the New User button, so that it doesn't get deallocated (otherwise, errors) */
    // In Cocoa, windows/views are loaded lazily instead of all at once (better performance)
    let newUserVC = NewUserWindowController(windowNibName: "NewUserWindow")

    @IBAction func NewUserButtonClicked(sender: NSButton) {
        /* Begins the modal sheet animation when the New User button is clicked;
        this presents the new window on top of the previous window, sliding down
        into focus */
        self.window.beginSheet(newUserVC.window!, completionHandler: nil)
    }
    
    @IBAction func ContinueButtonClicked(sender: NSButton) {
    }
    
    
    // Function that will fill the NSComboBox with users from persistent storage (NSUserDefaults)
    // This will run when a NSNotification is received from the function that saves the data
    func populateNSComboBox(notification: NSNotification) {
        print("Populating combo box")
        
        /* as! forces downcast to array of Strings from array of AnyObject, for type safety
        The app will crash though if this doesn't exist, but this function should only be called
        if this array exists in NSUserDefaults */
        let names = NSUserDefaults.standardUserDefaults().objectForKey("NewUserNames") as! [String]
        
        // Adding last element in the array, avoids duplicates
        UserComboBox.addItemWithObjectValue(names.last!)
    }
    
    // Function that runs when the user selects something in the NSComboBox
    func comboBoxSelectionDidChange(notification: NSNotification) {
        // Enable Continue Button
        ContinueButton.enabled = true
        // Get selected name
        let savedString: String = UserComboBox.objectValueOfSelectedItem as! String
        
        // Save to NSUserDefaults under a key of currentUser
        // This will be the identity of the current user that the program will use
        NSUserDefaults.standardUserDefaults().setObject(savedString, forKey: "currentUser")
        
        // for debugging
        print("\(savedString) saved to NSUserDefaults")
        
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        // Disabling the continue button initially as no user would be selected
        ContinueButton.enabled = false
        
        // Setting up notification listeners to populate the dropdown box of users and to check if the user selected something in the NSComboBox
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "populateNSComboBox:", name: "NameDataSavedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "comboBoxSelectionDidChange:", name: "NSComboBoxSelectionDidChangeNotification", object: nil)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

