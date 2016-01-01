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
    @IBOutlet weak var WeightMajorEntryField: NSTextField!
    @IBOutlet weak var WeightMinorEntryField: NSTextField!
    @IBOutlet weak var WeightUnitMajor: NSTextField!
    @IBOutlet weak var WeightUnitMinor: NSTextField!
    @IBOutlet weak var DatePicker: NSDatePicker!
    @IBOutlet weak var DecimalButton: NSButton!
    
    // Defining all shared variables within class as optionals so they can be initialised later
    private var profileName: String?
    private var profileInfoDictionary: NSMutableDictionary?
    private var fontManager: NSFontManager?
    
    // Using a locking mechanism to make sure that only one field in the weight input system can be accessable at a given time.
    // The use of the decimal point (.) will denote which field is being changed.
    private var MinorEntryFieldLocked: Bool?
    private var MajorEntryFieldLocked: Bool?
    
    /* This is a boolean to let the class know if the record selected is editable (that the user wants to edit it), otherwise we can just
    add/remove the record as normal.
    Initially, set this to false so that adding/deleting record code is minimally affected. */
    private var EditableRecord: Bool = false
    private var EditableWeight: Double = 0.0
    private var EditableIndex: Int = 0
    
    @IBAction func DoneButtonPressed(sender: NSButton) {
        if !(WeightMajorEntryField.stringValue.isEmpty) || !(WeightMinorEntryField.stringValue.isEmpty) {
        
            let weightValueArray = profileInfoDictionary!.objectForKey("weightValues")!.mutableCopy() as! NSMutableArray
            let weightDateArray = profileInfoDictionary!.objectForKey("weightValueDates")!.mutableCopy() as! NSMutableArray
            
            /* NSDateFormatter outputs the time from NSDate (in seconds since January 1 2000) as a human readable format */
            let dateFormatter = NSDateFormatter()
            
            /* FullStyle formats this in the form 'Name of Day, Date, Month, Year' - e.g. "Sunday, 4 October 2015" */
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            
            // Save the date that the user entered, or the default date value (of the current date)
            let formattedDate: String = dateFormatter.stringFromDate(DatePicker.dateValue)
            
            // Is the second weight box (minor box) empty? If it is, add a zero (to stop garbage values in calculations).
            if WeightMinorEntryField.stringValue.isEmpty {
                WeightMinorEntryField.stringValue = "0"
            }
        
            // Concatenating the values of both boxes
            let joinedWeightValue = WeightMajorEntryField.stringValue + "." + WeightMinorEntryField.stringValue
            
            // Replace the record if we are editing, otherwise just add to the end
            if EditableRecord == false {
                weightDateArray.addObject(formattedDate)
                weightValueArray.addObject(joinedWeightValue)
            } else {
                // Get index of record that we are replacing
                EditableIndex = weightValueArray.indexOfObject(String(EditableWeight))
                
                // Replace the record's data in both arrays at the same index (since both arrays should contain the same amount of data)
                weightValueArray.replaceObjectAtIndex(EditableIndex, withObject: joinedWeightValue)
                weightDateArray.replaceObjectAtIndex(EditableIndex, withObject: formattedDate)
            }
        
            // Saving the user's entered weight value and current date back to NSUserDefaults
            profileInfoDictionary!.setObject(weightDateArray, forKey: "weightValueDates")
            profileInfoDictionary!.setObject(weightValueArray, forKey: "weightValues")
            NSUserDefaults.standardUserDefaults().setObject(profileInfoDictionary!, forKey: "profileInfo\(profileName!)")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            if EditableRecord == false {
                // Sends a notification to reload the table
                // In this case, it should be MainWindowController
                NSNotificationCenter.defaultCenter().postNotificationName("UpdateUserData", object: nil)
            } else {
                // Post a notification to reload the data of the table view (in MainWindowController)
                NSNotificationCenter.defaultCenter().postNotificationName("UpdateUserData", object: nil)
            }
            
        }
        // We want to return to the main window after pressing 'Done'
        self.view.window!.close()
        
    }

    @IBAction func numberPressed(sender: NSButton) {
        let number = sender.title
        
        /* The idea of the locking mechanism is this:
        When the user types their first few numbers, this will be inferred as the first part of the decimal value (e.g. 12 in 12.6)
        Then, as soon as the decimal point button is pressed, the lock switches, and the next numbers will be inferred as the second part of the decimal value (e.g. .6 in 12.6)
        The system uses the lock to check which field to put the numbers into. */
        
        if MinorEntryFieldLocked == true && (number != ".") && (number != "NEXT") {
            WeightMajorEntryField.stringValue += number
        } else if number == "." || number == "NEXT" {
            MajorEntryFieldLocked = true
            MinorEntryFieldLocked = false
        } else if MajorEntryFieldLocked == true && (number != ".") && (number != "NEXT") {
            WeightMinorEntryField.stringValue += number
        }
        
    }
    
    @IBAction func ClearButtonPressed(sender: NSButton) {
        // Resetting string values in both boxes, clear all
        WeightMajorEntryField.stringValue = ""
        WeightMinorEntryField.stringValue = ""
        
        // Also, reset locking mechanism to default state (major field is editable, minor field isn't)
        MajorEntryFieldLocked = false
        MinorEntryFieldLocked = true
    }
    
    func setupEditableRecord(editableWeight: Double?, editableDate: NSDate?) {
        // Check that function parameters aren't nil to prevent crashing
        if let weight = editableWeight {
            // Set weight values in boxes to record's weight
            EditableWeight = weight
            let weightComponentArray = String(weight).componentsSeparatedByString(".")
            WeightMajorEntryField.stringValue = weightComponentArray[0]
            WeightMinorEntryField.stringValue = weightComponentArray[1]
        }
        
        if let date = editableDate {
            // Set date picker to record's date
            DatePicker.dateValue = date
        }
        
        // Mark the record as editable (so update record rather than add/remove)
        EditableRecord = true
        
    }
    

    override func viewDidLoad() {
        if #available(OSX 10.10, *) {
            super.viewDidLoad()
        } else {
            // Fallback on earlier versions
        }
        // Do view setup here.
        
        // This part of the viewDidLoad function acts as an initialiser
        profileName = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as? String
        profileInfoDictionary = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(profileName!)")?.mutableCopy() as? NSMutableDictionary
        fontManager = NSFontManager.sharedFontManager()
        
        MajorEntryFieldLocked = false
        MinorEntryFieldLocked = true
        
        
        
        // When view loads, set the date value in the date box to the current date
        DatePicker.dateValue = NSDate()
        
        // Set weight unit labels based on user's preferences
        let weightUnit = profileInfoDictionary!.valueForKey("weightUnit") as! String
        
        switch weightUnit {
            case "kg":
            WeightUnitMajor.stringValue = "  .  "
            WeightUnitMajor.font = fontManager!.convertFont(WeightUnitMajor.font!, toSize: 18)
            WeightUnitMinor.stringValue = "kg"
            
            case "lbs":
            WeightUnitMajor.stringValue = "  .  "
            WeightUnitMajor.font = fontManager!.convertFont(WeightUnitMajor.font!, toSize: 18)
            WeightUnitMinor.stringValue = "lbs"
            
            case "st lbs":
            WeightUnitMajor.stringValue = "st"
            WeightUnitMinor.stringValue = "lbs"
            
            // Also, change the decimal point button to something like 'NEXT'
            DecimalButton.title = "NEXT"
            
        default: break
        }
    }
    
}
