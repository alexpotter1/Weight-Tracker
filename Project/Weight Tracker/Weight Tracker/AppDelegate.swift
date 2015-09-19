//
//  AppDelegate.swift
//  Weight Tracker
//
//  Created by Alex Potter on 27/08/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import Cocoa

public class DeveloperSettings {
    var DebugPrintingEnabled: Bool
    var DebugDeleteDBEnabled: Bool
    
    init(DebugPrintingEnabled: Bool, DebugDeleteDBEnabled: Bool) {
        self.DebugPrintingEnabled = DebugPrintingEnabled
        self.DebugDeleteDBEnabled = DebugDeleteDBEnabled
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let initVC = InitialWindowController(windowNibName: "InitialWindow")
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        // debug
        let devSettings = DeveloperSettings(DebugPrintingEnabled: false, DebugDeleteDBEnabled: false)
        
        if devSettings.DebugDeleteDBEnabled == true {
            let appDomain: String! = NSBundle.mainBundle().bundleIdentifier
            NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
        }
        
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
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "MainWindowSetupUserNotification", object: nil)
    }


}

