//
//  PopoverEntryViewController.swift
//  Weight Tracker
//
//  Created by Alex Potter on 03/10/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import Cocoa

class PopoverEntryViewController: NSViewController {
    
    // Connecting IB objects
    @IBOutlet weak var EntryField: NSTextField!
    @IBAction func DoneButtonPressed(sender: NSButton) {
        if !(EntryField.stringValue.isEmpty) {
            let currentProfileName = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as! String
            let profileInfoDictionary: NSMutableDictionary = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(currentProfileName)")!.mutableCopy() as! NSMutableDictionary
            
            let weightValueArray = profileInfoDictionary.objectForKey("weightValues")!.mutableCopy() as! NSMutableArray
            let weightDateArray = profileInfoDictionary.objectForKey("weightValueDates")!.mutableCopy() as! NSMutableArray
            
            // Get current system date
            let date = NSDate()
            /* NSDateFormatter outputs the time from NSDate (in seconds since January 1 2000) as a human readable format */
            let dateFormatter = NSDateFormatter()
            
            /* FullStyle formats this in the form 'Name of Day, Date, Month, Year' - e.g. "Sunday, 4 October 2015" */
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            let localDateRightNow: String = dateFormatter.stringFromDate(date) 
            
            weightDateArray.addObject(localDateRightNow)
            weightValueArray.addObject(EntryField.stringValue)
            
            // Saving the user's entered weight value and current date back to NSUserDefaults
            profileInfoDictionary.setObject(weightDateArray, forKey: "weightValueDates")
            profileInfoDictionary.setObject(weightValueArray, forKey: "weightValues")
            NSUserDefaults.standardUserDefaults().setObject(profileInfoDictionary, forKey: "profileInfo\(currentProfileName)")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            // Sends a notification through the first responder chain to the first class that implements a method that matches the selector ("updateWeightTable")
            // In this case, it should be MainWindowController
            NSApplication.sharedApplication().sendAction("updateWeightTable", to: nil, from: nil)
            
        }
        // We want to return to the main window after pressing 'Done'
        self.view.window!.close()
        
    }

    @IBAction func numberPressed(sender: NSButton) {
        let number = sender.title
        EntryField.stringValue += number
    }
    
    @IBAction func ClearButtonPressed(sender: NSButton) {
        EntryField.stringValue = ""
    }
    

    override func viewDidLoad() {
        if #available(OSX 10.10, *) {
            super.viewDidLoad()
        } else {
            // Fallback on earlier versions
        }
        // Do view setup here.
    }
    
}
