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
    
    let initVC = InitialWindowController(windowNibName: "InitialWindow")
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        // debug code
        //NSUserDefaults.standardUserDefaults().removeObjectForKey("NewUserNames")
        
        initVC.loadWindow()
        initVC.windowDidLoad()
        initVC.showWindow(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        
        /* Removing listeners to all notifications created by this app so that other apps can't
        use them (for stability reasons, less potential crashing in other apps) */
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NameDataSavedNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NSComboBoxSelectionDidChangeNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "FirstWindowCloseNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NSMenuDidSendActionNotification", object: nil)
    }


}

