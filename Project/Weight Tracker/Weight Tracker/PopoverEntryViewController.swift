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
    @IBOutlet weak var DatePicker: NSDatePicker!
    
    @IBAction func DoneButtonPressed(sender: NSButton) {
        if !(EntryField.stringValue.isEmpty) {
            let currentProfileName = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as! String
            let profileInfoDictionary: NSMutableDictionary = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(currentProfileName)")!.mutableCopy() as! NSMutableDictionary
            
            let weightValueArray = profileInfoDictionary.objectForKey("weightValues")!.mutableCopy() as! NSMutableArray
            let weightDateArray = profileInfoDictionary.objectForKey("weightValueDates")!.mutableCopy() as! NSMutableArray
            
            /* NSDateFormatter outputs the time from NSDate (in seconds since January 1 2000) as a human readable format */
            let dateFormatter = NSDateFormatter()
            
            /* FullStyle formats this in the form 'Name of Day, Date, Month, Year' - e.g. "Sunday, 4 October 2015" */
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            
            // Save the date that the user entered, or the default date value (of the current date)
            let formattedDate: String = dateFormatter.stringFromDate(DatePicker.dateValue)
            
            weightDateArray.addObject(formattedDate)
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
        
        // When view loads, set the date value in the date box to the current date
        DatePicker.dateValue = NSDate()
    }
    
}
