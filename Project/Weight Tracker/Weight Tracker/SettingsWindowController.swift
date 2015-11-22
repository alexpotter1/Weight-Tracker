//
//  SettingsWindowController.swift
//  Weight Tracker
//
//  Created by Alex Potter on 19/09/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import Cocoa

class SettingsWindowController: NSWindowController, NSTextFieldDelegate {
    
    var InitialWC: InitialWindowController? = nil
    
    let devSettings = DeveloperSettings(DebugPrintingEnabled: false, DebugDeleteDBEnabled: false)
    
    // Connecting IB objects to code
    @IBOutlet weak var WeightUnitBox: NSPopUpButton!
    @IBOutlet weak var WeightGoalUnit: NSTextField!
    @IBOutlet weak var WeightGoalValue: NSTextField!
    @IBOutlet weak var WeightGoalDate: NSDatePicker!
    
    var currentUser: String!
    var profileInfoDictionary: NSMutableDictionary!
    var weightGoalArray: NSMutableArray!
    
    @IBAction func DeleteUserButtonClicked(sender: NSButton) {
        // Confirmation dialog - we don't want the user to accidentally delete their own profile
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.CriticalAlertStyle
        alert.messageText = "Are you sure?"
        alert.informativeText = "Are you sure that you want to delete the current user? This action cannot be undone."
        alert.addButtonWithTitle("Delete")
        alert.addButtonWithTitle("Return")
        alert.beginSheetModalForWindow(self.window!, completionHandler: self.DeleteUserAlertHandler)
        
    }
    @IBAction func DoneButtonClicked(sender: NSButton) {
        
        self.currentUser = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as! String
        self.profileInfoDictionary = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(self.currentUser)")?.mutableCopy() as! NSMutableDictionary
        
        /* Checking first that the zeroth value in the weight goal array (the weight goal value) is initialised (by default it is 0)
           This helps to prevent a runtime crash if the user doesn't type anything in the weight goal box.
           If the user didn't type anything, then just exit the window. */
        
        if (self.weightGoalArray[0].stringValue != "0.0") {
            // Obtaining NSDate value in weight goal date box (time in seconds since January 1, 2001)
            let date: NSDate = WeightGoalDate.dateValue
            // Making date value look nice (formatted e.g. Fri, 15 Jan 2016)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE, d MMM yyyy"
            let formattedDate = dateFormatter.stringFromDate(date)
            
            // Saving date to weight goal array, and then to persistent storage
            self.weightGoalArray.replaceObjectAtIndex(1, withObject: formattedDate)
            
            self.profileInfoDictionary?.setObject(self.weightGoalArray!, forKey: "weightGoal")
            NSUserDefaults.standardUserDefaults().setObject(self.profileInfoDictionary, forKey: "profileInfo\(self.currentUser)")
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
        
        // Reloads the window below the settings sheet
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateUserData", object: nil)
        self.window!.close()
    }
    
    // Handles the possible return values of the delete user dialog (which button the user pressed)
    func DeleteUserAlertHandler(choice: NSModalResponse) {
        switch choice {
        case NSAlertFirstButtonReturn:
            // We're deleting the user...
            let userArray = NSUserDefaults.standardUserDefaults().objectForKey("NewUserNames")!.mutableCopy() as! NSMutableArray
            let currentUser = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as! String
            userArray.removeObjectIdenticalTo(currentUser)
            
            // Save new user array back to NSUserDefaults
            NSUserDefaults.standardUserDefaults().removeObjectForKey("NewUserNames")
            NSUserDefaults.standardUserDefaults().setObject(userArray, forKey: "NewUserNames")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            NSNotificationCenter.defaultCenter().postNotificationName("ResetToInitialWindowNotification", object: nil)
            self.window!.close()
            
            InitialWC = InitialWindowController(windowNibName: "InitialWindow")
            InitialWC!.showWindow(self)
            
        case NSAlertSecondButtonReturn:
            // Return (Cancel) button
            if devSettings.DebugPrintingEnabled == true {
                print("return")
            }
        default: break
        }
    }
    
    // Detects if the user typed anything in the Weight Goal box; overriding from NSTextFieldDelegate protocol
    override func controlTextDidChange(obj: NSNotification) {
        // Set first object at index of weight goal array to whatever the user types
        self.weightGoalArray.replaceObjectAtIndex(0, withObject: WeightGoalValue.stringValue)
    }
    
    func weightUnitSelectionDidChange(notification: NSNotification) {
        print("hi")
        let selectedItem = WeightUnitBox.titleOfSelectedItem
        let currentUser = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as! String
        self.profileInfoDictionary = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(currentUser)")?.mutableCopy() as! NSMutableDictionary
        // selectedItem is of type String?, so checking if nil first
        if selectedItem != nil {
            if devSettings.DebugPrintingEnabled == true {
                print(selectedItem!) // debug
            }
            // Saving shortened value to NSUserDefaults
            profileInfoDictionary!.removeObjectForKey("weightUnit")
            switch selectedItem! {
                case "Kilograms (kg)":
                    self.profileInfoDictionary!.setValue("kg", forKey: "weightUnit")
                case "Pounds (lbs)":
                    self.profileInfoDictionary!.setValue("lbs", forKey: "weightUnit")
                case "Stone & Pounds (st lbs)":
                    self.profileInfoDictionary!.setValue("st lbs", forKey: "weightUnit")
                default: break
            }
            
            // Updating weight goal unit value
            WeightGoalUnit.stringValue = self.profileInfoDictionary!.valueForKey("weightUnit") as! String + " by"
            print(WeightGoalUnit.stringValue)
            
            NSUserDefaults.standardUserDefaults().setObject(self.profileInfoDictionary, forKey: "profileInfo\(currentUser)")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            NSNotificationCenter.defaultCenter().postNotificationName("UpdateUserData", object: nil)
            
        }
    
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        // Launching function when user clicks item in selection box
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "weightUnitSelectionDidChange:", name: NSMenuDidSendActionNotification, object: self.WeightUnitBox.menu)

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        // Set NSPopUpButton to show correct menu item on top
        self.currentUser = (NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as! String)
        self.profileInfoDictionary = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(currentUser)")?.mutableCopy() as? NSMutableDictionary
        
        // Loading this once to avoid performance penalty of fetching this array every time a key is pressed
        self.weightGoalArray = self.profileInfoDictionary?.valueForKey("weightGoal")!.mutableCopy() as! NSMutableArray
        
        // Load weight goal data (value and date)
        // Have to convert the stored date into the type NSDate
        
        WeightGoalValue.stringValue = String(self.weightGoalArray[0])
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM yyyy"
        let NSDatePickerDate: NSDate! = dateFormatter.dateFromString(String(self.weightGoalArray[1]))
        WeightGoalDate.dateValue = NSDatePickerDate
        
        // Setting Weight Goal Value (label) based upon user's weight unit selection choice
        WeightGoalUnit.stringValue = self.profileInfoDictionary?.valueForKey("weightUnit") as! String + " by"
        
        switch profileInfoDictionary?.valueForKey("weightUnit") as! String {
            // Selecting default menu item based on string in profile info
            case "kg":
                WeightUnitBox.selectItemAtIndex(0)
            case "lbs":
                WeightUnitBox.selectItemAtIndex(1)
            case "st lbs":
                WeightUnitBox.selectItemAtIndex(2)
            default: break
        }
    }
    
}
