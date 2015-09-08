//
//  SettingsPopoverViewController.swift
//  Weight Tracker
//
//  Created by Alex Potter on 08/09/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import Cocoa

class SettingsPopoverViewController: NSViewController {
    
    // Set up Interface Builder actions and outlets
    @IBOutlet weak var WeightUnitBox: NSPopUpButton!
    @IBAction func DoneButtonClicked(sender: NSButton){
        self.view.window!.close()
    }
    
    func weightUnitSelectionDidChange(notification: NSNotification) {
        var selectedItem = WeightUnitBox.titleOfSelectedItem
        if selectedItem != nil {
            print(selectedItem!)
            NSUserDefaults.standardUserDefaults().setObject(selectedItem!, forKey: "SettingsWeightUnitItem")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    override func viewDidLoad() {
        if #available(OSX 10.10, *) {
            super.viewDidLoad()
        } else {
            // Fallback on earlier versions
        }
        // Do view setup here.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "weightUnitSelectionDidChange:", name: NSMenuDidSendActionNotification, object: self.WeightUnitBox.menu)
    }
    
}
