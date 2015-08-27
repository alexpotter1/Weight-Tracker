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
    let newUserVC = NewUserWindowController(windowNibName: "NewUserWindow")

    @IBAction func NewUserButtonClicked(sender: NSButton) {
        /* Begins the modal sheet animation when the New User button is clicked;
        this presents the new window on top of the previous window, sliding down
        into focus */
        self.window.beginSheet(newUserVC.window!, completionHandler: nil)
    }
    
    @IBAction func ContinueButtonClicked(sender: NSButton) {
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        // Disabling the continue button initially as no user would be selected
        ContinueButton.enabled = false
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

