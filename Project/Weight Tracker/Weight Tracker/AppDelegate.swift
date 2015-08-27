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
    
    /* Keeps a reference to the window controllers that we're gonna switch to, so that it doesn't get deallocated (otherwise, errors) */
    // In Cocoa, windows/views are loaded lazily instead of all at once (better performance)
    let newUserVC = NewUserWindowController(windowNibName: "NewUserWindow")
    let mainWindowVC = MainWindowController(windowNibName: "MainWindow")

    @IBAction func NewUserButtonClicked(sender: NSButton) {
        /* Begins the modal sheet animation when the New User button is clicked;
        this presents the new window on top of the previous window, sliding down
        into focus */
        self.window.beginSheet(newUserVC.window!, completionHandler: nil)
    }
    
    @IBAction func ContinueButtonClicked(sender: NSButton) {
        print("loading MainWindowController")
        // Loads the main window from the xib file (so that the user interface for that controller is loaded)
        mainWindowVC.loadWindow()
        mainWindowVC.windowDidLoad()
        mainWindowVC.showWindow(mainWindowVC.window) // The argument to this function is the target window we want to show
    }
    
    func populateNSComboBoxWhenAppLaunches() {
        print("Populating combo box initially")
        
        /* The reason why this line exists more than once is that 
        we want it to reload the NSUserDefaults object to get new names */
        let names = NSUserDefaults.standardUserDefaults().objectForKey("NewUserNames")
        
        // Checking if the object that stores the names is empty in NSUserDefaults
        if names != nil {
            // Adding all elements in array because we initially want every name on startup
            
            /* as! forces downcast to array of Strings from array of AnyObject, for type safety
            The app will crash though if this doesn't exist, but this function should only be called
            if this array exists in NSUserDefaults */
            let nameArray = names as! [String]
            
            // Loops through all the names in the array to make sure all are added to the NSComboBox
            for name in nameArray {
                UserComboBox.addItemWithObjectValue(name)
            }
        }
    }
    
    // Function that will fill the NSComboBox with users from persistent storage (NSUserDefaults)
    // This will run when a NSNotification is received from the function that saves the data
    func populateNSComboBox(notification: NSNotification) {
        print("Populating combo box")
        
        /* The reason why this line exists more than once is that
        we want it to reload the NSUserDefaults object to get new names */
        let names = NSUserDefaults.standardUserDefaults().objectForKey("NewUserNames")
        
        /* as! forces downcast to array of Strings from array of AnyObject, for type safety
        The app will crash though if this doesn't exist, but this function should only be called
        if this array exists in NSUserDefaults */
        UserComboBox.addItemWithObjectValue((names as! [String]).last!)
    }
    
    // Function that runs when the user selects something in the NSComboBox
    func comboBoxSelectionDidChange(notification: NSNotification) {
        // Enable Continue Button
        ContinueButton.enabled = true
        // Get selected name
        let savedString: String = UserComboBox.objectValueOfSelectedItem as! String
        
        // Save to NSUserDefaults under a key of currentUser
        // This will be the identity of the current user that the program will use
        //NSUserDefaults.standardUserDefaults().setObject(savedString, forKey: "currentUser")
        
        // for debugging
        print("\(savedString) saved to NSUserDefaults")
        
    }
    // This will tell the first window to close after the main window has opened
    // Listening for notification name "FirstWindowCloseNotification"
    func notInFocusAnymore(notification: NSNotification) {
        self.window?.close()
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        // debug code
        //NSUserDefaults.standardUserDefaults().removeObjectForKey("NewUserNames")
        
        // Disabling the continue button initially as no user would be selected
        ContinueButton.enabled = false
        
        /* Setting up notification listeners to populate the dropdown box of users and to 
        check if the user selected something in the NSComboBox */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "populateNSComboBox:", name: "NameDataSavedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "comboBoxSelectionDidChange:", name: "NSComboBoxSelectionDidChangeNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notInFocusAnymore:", name: "FirstWindowCloseNotification", object: nil)
        
        // Initial population of NSComboBox
        populateNSComboBoxWhenAppLaunches()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        
        /* Removing listeners to all notifications created by this app so that other apps can't
        use them (for stability reasons, less potential crashing in other apps) */
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NameDataSavedNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NSComboBoxSelectionDidChangeNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "FirstWindowCloseNotification", object: nil)
    }


}

