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
    
    // Connecting IB objects to code
    @IBOutlet weak var HelloLabel: NSTextField!
    @IBOutlet weak var LatestWeightLabel: NSTextField!
    
    @IBAction func UsersButtonClicked(sender: NSButton) {
        // Creating a new reference to window controller, and loading
        initVC = InitialWindowController(windowNibName: "InitialWindow")
        initVC?.loadWindow()
        initVC?.windowDidLoad()
        initVC?.showWindow(self)
        
        self.window?.close()
    }
    
    // Loads the user's information and greeter (the two sentences at the top of the window)
    func setupUser() {
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
            let weightValueArray = profileInfoDictionary.valueForKey("latestPredictedWeightLoss")
            let weightGainOrLoss = profileInfoDictionary.valueForKey("latestPredictedGain/Loss") as! Int
            var LatestWeightLabelValueSet: Bool = false
            var LatestWeightLabelString: String = ""
    
            switch weightUnitValue {
            case "kg":
                LatestWeightLabelString = "You're on track for \((weightValueArray as! [String]).last)kg weight "
            case "lbs":
                LatestWeightLabelString = "You're on track for \((weightValueArray as! [String]).last)lbs weight "
            case "stlbs":
                var stlbsArray: [String] = ((weightValueArray as! [String]).last?.componentsSeparatedByString(";"))!
                LatestWeightLabelString = "You're on track for \(stlbsArray[0])st \(stlbsArray[1])lbs weight "
            default:
                LatestWeightLabel.stringValue = "You're on track for 0kg weight loss"
                LatestWeightLabelValueSet = true
            }
            
            if LatestWeightLabelValueSet == false {
                if weightGainOrLoss == 0 { // 0 = loss, anything else = gain
                    HelloLabel.stringValue = LatestWeightLabelString + "loss"
                } else {
                    HelloLabel.stringValue = LatestWeightLabelString + "gain"
                }
            }
        }
        
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        // Posts notification to shutdown the other window, as we don't need it anymore
        NSNotificationCenter.defaultCenter().postNotificationName("FirstWindowCloseNotification", object: nil)
        
        setupUser()
    }
    
}
