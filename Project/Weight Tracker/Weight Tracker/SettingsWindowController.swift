//
//  SettingsWindowController.swift
//  Weight Tracker
//
//  Created by Alex Potter on 19/09/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import Cocoa

class SettingsWindowController: NSWindowController {
    
    var InitialWC: InitialWindowController? = nil
    
    let devSettings = DeveloperSettings(DebugPrintingEnabled: false, DebugDeleteDBEnabled: false)
    
    // Connecting IB objects to code
    @IBOutlet weak var WeightUnitBox: NSPopUpButton!
    
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
        // Reloads the window below the settings sheet
        NSNotificationCenter.defaultCenter().postNotificationName("MainWindowSetupUserNotification", object: nil)
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
            if devSettings.DebugPrintingEnabled == true {
                print("return")
            }
        default: break
        }
    }
    
    func weightUnitSelectionDidChange(notification: NSNotification) {
        let selectedItem = WeightUnitBox.titleOfSelectedItem
        let currentUser = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as! String
        let profileInfoDictionary = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(currentUser)")?.mutableCopy()
        // selectedItem is of type String?, so checking if nil first
        if selectedItem != nil {
            if devSettings.DebugPrintingEnabled == true {
                print(selectedItem!) // debug
            }
            // Saving shortened value to NSUserDefaults
            switch selectedItem! {
                case "Kilograms (kg)":
                    profileInfoDictionary!.setObject("kg", forKey: "weightUnit")
                case "Pounds (lbs)":
                    profileInfoDictionary!.setObject("lbs", forKey: "weightUnit")
                case "Stone & Pounds (st lbs)":
                    profileInfoDictionary!.setObject("st lbs", forKey: "weightUnit")
                default: break
            }
            
            NSUserDefaults.standardUserDefaults().setObject(profileInfoDictionary, forKey: "profileInfo\(currentUser)")
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
        let currentUser = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as! String
        let profileInfoDictionary = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(currentUser)")
        
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
