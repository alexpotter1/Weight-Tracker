//
//  NewUserViewController.swift
//  Weight Tracker
//
//  Created by Alex Potter on 27/08/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import Cocoa

class NewUserWindowController: NSWindowController, NSTextFieldDelegate {
    
    // Connecting Interface Builder objects to code
    @IBOutlet weak var NewUserTextField: NSTextField!
    @IBOutlet weak var DoneButton: NSButton!
    
    @IBAction func DoneButtonClicked(sender: NSButton) {
        // Check if array exists in NSUserDefaults (persistent storage)
        if NSUserDefaults.standardUserDefaults().objectForKey("NewUserNames") == nil {
            // Create new array of users and add the user to the list
            var textArray: [String] = []
            textArray.append(NewUserTextField.stringValue)
            
            // Save to persistent storage
            NSUserDefaults.standardUserDefaults().setObject(textArray, forKey: "NewUserNames")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        // Appending text input to the end of the user array stored in NSUserDefaults
        var textArrayDefaults = NSUserDefaults.standardUserDefaults().objectForKey("NewUserNames") as! [String]
        textArrayDefaults.append(NewUserTextField.stringValue)
        
        // For debugging purposes
        print("\(NewUserTextField.stringValue) saved to NSUserDefaults")
        
        // Saving back to NSUserDefaults
        NSUserDefaults.standardUserDefaults().setObject(textArrayDefaults, forKey: "NewUserNames")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        /* Sending a notification to the other view controller that
        the data has been saved to NSUserDefaults. As a result, it can be
        used to populate the NSComboBox so that the user can choose a user */
        NSNotificationCenter.defaultCenter().postNotificationName("NameDataSavedNotification", object: nil)
        
        // Prevents modal sheet from blocking the app from exiting
        self.window?.close()
    }
    
    override func controlTextDidChange(notification: NSNotification) {
        /* Checking if the NSTextField is empty, as this would resolve a bug where
        the user could type, delete their input and still save an empty string */
        
        if !NewUserTextField.stringValue.isEmpty {
            DoneButton.enabled = true
        } else {
            DoneButton.enabled = false
        }
    }
    
    @IBAction func CancelButtonClicked(sender: NSButton) {
        // Tells everyone we want to return to the previous window, exits smoothly
        self.window?.close()
    }

    override func windowDidLoad() {
        // Initialisation call to the superclass to say that the window was loaded
        super.windowDidLoad()
        
        // Setting this view controller as the delegate for the New User text field
        NewUserTextField.delegate = self
        
        /* Initially set the Done button to be disabled as we don't want to create
        a user with no name. The button will be re-enabled when text is entered.
        Since this code is in the windowDidLoad function, it is immediately executed when the
        view loads. */
        
        if NewUserTextField.stringValue.isEmpty {
            DoneButton.enabled = false
        }
    }
    
}
