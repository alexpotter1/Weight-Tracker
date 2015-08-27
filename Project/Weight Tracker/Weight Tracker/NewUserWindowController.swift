//
//  NewUserViewController.swift
//  Weight Tracker
//
//  Created by Alex Potter on 27/08/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import Cocoa

class NewUserWindowController: NSWindowController {
    
    // Connecting Interface Builder objects to code
    @IBOutlet weak var NewUserTextField: NSTextField!
    @IBOutlet weak var DoneButton: NSButton!
    
    @IBAction func DoneButtonClicked(sender: NSButton) {
        
    }
    
    @IBAction func CancelButtonClicked(sender: NSButton) {
        // Tells everyone we want to return to the previous window, exits smoothly
        self.window?.close()
    }

    override func windowDidLoad() {
        // Initialisation call to the superclass to say that the window was loaded
        super.windowDidLoad()
    }
    
}
