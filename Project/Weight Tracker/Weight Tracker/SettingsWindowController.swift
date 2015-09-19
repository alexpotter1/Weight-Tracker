//
//  SettingsWindowController.swift
//  Weight Tracker
//
//  Created by Alex Potter on 19/09/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import Cocoa

class SettingsWindowController: NSWindowController {
    
    // Connecting IB objects to code
    @IBOutlet weak var WeightUnitBox: NSPopUpButton!
    @IBAction func DoneButtonClicked(sender: NSButton) {
        NSNotificationCenter.defaultCenter().postNotificationName("MainWindowSetupUserNotification", object: nil)
        self.window!.close()
    }
    
    func weightUnitSelectionDidChange(notification: NSNotification) {
        let selectedItem = WeightUnitBox.titleOfSelectedItem
        let currentUser = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as! String
        let profileInfoDictionary = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(currentUser)")?.mutableCopy()
        // selectedItem is of type String?, so checking if nil first
        if selectedItem != nil {
            print(selectedItem!) // debug
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
