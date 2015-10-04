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
            var profileInfoDictionary: NSMutableDictionary = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(currentProfileName)")!.mutableCopy() as! NSMutableDictionary
            
            var weightValueArray = profileInfoDictionary.objectForKey("weightValues")!.mutableCopy() as! NSMutableArray
            var weightDateArray = profileInfoDictionary.objectForKey("weightValueDates")!.mutableCopy() as! NSMutableArray
            
            // Get current system date
            let date = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            let localDateRightNow: String = dateFormatter.stringFromDate(date) 
            
            weightDateArray.addObject(localDateRightNow)
            weightValueArray.addObject(EntryField.stringValue)
            
            profileInfoDictionary.setObject(weightDateArray, forKey: "weightValueDates")
            profileInfoDictionary.setObject(weightValueArray, forKey: "weightValues")
            NSUserDefaults.standardUserDefaults().setObject(profileInfoDictionary, forKey: "profileInfo\(currentProfileName)")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            // Sends a notification through the first responder chain to the first class that implements a method that matches the selector ("updateWeightTable")
            // In this case, it should be MainWindowController
            NSApplication.sharedApplication().sendAction("updateWeightTable", to: nil, from: nil)
            
        }
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
