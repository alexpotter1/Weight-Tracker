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
        if selectedItem != nil {
            print(selectedItem!)
            NSUserDefaults.standardUserDefaults().setObject(selectedItem!, forKey: "SettingsWeightUnitItem")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "weightUnitSelectionDidChange:", name: NSMenuDidSendActionNotification, object: self.WeightUnitBox.menu)

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
}
