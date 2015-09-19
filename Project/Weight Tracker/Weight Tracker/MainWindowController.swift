//
//  MainWindowController.swift
//  Weight Tracker
//
//  Created by Alex Potter on 27/08/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    // Keep an optional reference to window controllers
    var initVC: InitialWindowController? = nil
    var SettingsController: SettingsWindowController? = nil
    
    
    // Connecting IB objects to code
    @IBOutlet weak var HelloLabel: NSTextField!
    @IBOutlet weak var LatestWeightLabel: NSTextField!
    @IBOutlet weak var SettingsButton: NSButton!
    
    @IBAction func UsersButtonClicked(sender: NSButton) {
        // Creating a new reference to window controller, and loading
        initVC = InitialWindowController(windowNibName: "InitialWindow")
        initVC?.loadWindow()
        initVC?.windowDidLoad()
        initVC?.showWindow(self)
        
        self.window?.close()
    }
    
    @IBAction func SettingsButtonClicked(sender: NSButton) {
        SettingsController = SettingsWindowController(windowNibName: "SettingsWindow")
        self.window!.beginSheet(SettingsController!.window!, completionHandler: nil)
    }
    
    // Loads the user's information and greeter (the two sentences at the top of the window)
    func setupUser(notification: NSNotification) {
        let profileName = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as! String
        let profileInfo = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(profileName)")
        
        // Customises the greeter
        HelloLabel.stringValue = "Hi, \(profileName)"
        
        // Displays tracked weight
        if profileInfo == nil { // shouldn't be nil
            LatestWeightLabel.stringValue = "No weight goal set yet..."
        } else {
            // Get values from user's dictionary
            let profileInfoDictionary = profileInfo as! NSMutableDictionary
            let weightUnitValue = profileInfoDictionary.valueForKey("weightUnit") as! String
            let lastWeightValueArray: [String] = ((profileInfoDictionary.valueForKey("latestPredictedWeightLoss") as! [String]).last?.componentsSeparatedByString(";"))!
            let stoneValue = lastWeightValueArray.last!.componentsSeparatedByString(".")
            let weightGainOrLoss = profileInfoDictionary.valueForKey("latestPredictedGain/Loss") as! Int
            var LatestWeightLabelValueSet: Bool = false
            var LatestWeightLabelString: String = ""
    
            switch weightUnitValue {
            case "kg":
                LatestWeightLabelString = "You're on track for \(lastWeightValueArray[0])kg weight "
            case "lbs":
                LatestWeightLabelString = "You're on track for \(lastWeightValueArray[0])lbs weight "
            case "st lbs":
                LatestWeightLabelString = "You're on track for \(stoneValue[0])st \(lastWeightValueArray[1])lbs weight "
            default:
                LatestWeightLabel.stringValue = "You're on track for 0kg weight loss"
                LatestWeightLabelValueSet = true
            }
            
            if LatestWeightLabelValueSet == false {
                if weightGainOrLoss == 0 { // 0 = loss, anything else = gain
                    LatestWeightLabel.stringValue = LatestWeightLabelString + "loss"
                } else {
                    LatestWeightLabel.stringValue = LatestWeightLabelString + "gain"
                }
            }
        }
        
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        // Posts notification to shutdown the other window, as we don't need it anymore
        NSNotificationCenter.defaultCenter().postNotificationName("FirstWindowCloseNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupUser:", name: "MainWindowSetupUserNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().postNotificationName("MainWindowSetupUserNotification", object: nil)
    }
    
}
