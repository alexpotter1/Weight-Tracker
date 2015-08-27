//
//  AppController.swift
//  Weight Tracker
//
//  Created by Alex Potter on 27/08/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import Cocoa

class AppController: NSObject {
    // Connecting Interface Builder objects to the code so that they can be used
    // For MainMenu.xib:
    @IBOutlet weak var UserComboBox: NSComboBox!
    
    @IBAction func NewUserButtonClicked(sender: NSButton) {
        
    }
    
    @IBAction func ContinueButtonClicked(sender: NSButton) {
        
    }
    
    
    // Initialising the App Controller, where all the logic for the app is gonna happen
    override init(){
        super.init()
    }
    
}
