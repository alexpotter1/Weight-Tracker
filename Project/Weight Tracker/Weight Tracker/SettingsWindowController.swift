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
        self.window!.close()
    }
    
    func weightUnitSelectionDidChange(notification: NSNotification) {
        let selectedItem = WeightUnitBox.titleOfSelectedItem
        // selectedItem is of type String?, so checking if nil first
        if selectedItem != nil {
            print(selectedItem!) // debug
            // Saving shortened value to NSUserDefaults
            switch selectedItem! {
            case "Kilograms (kg)":
                NSUserDefaults.standardUserDefaults().setObject("kg", forKey: "SettingsWeightUnitItem")
                NSUserDefaults.standardUserDefaults().synchronize()
            case "Pounds (lbs)":
                NSUserDefaults.standardUserDefaults().setObject("lbs", forKey: "SettingsWeightUnitItem")
                NSUserDefaults.standardUserDefaults().synchronize()
            case "Stone & Pounds (st lbs)":
                NSUserDefaults.standardUserDefaults().setObject("st lbs", forKey: "SettingsWeightUnitItem")
                NSUserDefaults.standardUserDefaults().synchronize()
            default: break
            }
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        // Launching function when user clicks item in selection box
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "weightUnitSelectionDidChange:", name: NSMenuDidSendActionNotification, object: self.WeightUnitBox.menu)

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
}
