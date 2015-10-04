//
//  MainWindowController.swift
//  Weight Tracker
//
//  Created by Alex Potter on 27/08/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSTableViewDelegate, NSTableViewDataSource {
    
    // Keep an optional reference to window controllers
    var initVC: InitialWindowController? = nil
    var SettingsController: SettingsWindowController? = nil
    var WeightEntryPopover: NSPopover? = nil
    
    let devSettings = DeveloperSettings(DebugPrintingEnabled: false, DebugDeleteDBEnabled: false)
    
    // Connecting IB objects to code
    @IBOutlet weak var HelloLabel: NSTextField!
    @IBOutlet weak var LatestWeightLabel: NSTextField!
    @IBOutlet weak var SettingsButton: NSButton!
    @IBOutlet weak var WeightTable: NSTableView!
    @IBOutlet weak var WeightTableAddButton: NSButton!
    
    let profileName = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as! String
    var profileInfo: NSMutableDictionary? = nil
    var weightTableArray: NSMutableArray? = nil
    var weightTableDateArray: NSMutableArray? = nil
    
    var weightUnit: String? = nil
    
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
    
    @IBAction func WeightTableAddButtonClicked(sender: NSButton) {
        WeightEntryPopover = NSPopover()
        WeightEntryPopover?.contentViewController = PopoverEntryViewController(nibName: "PopoverEntryView", bundle: nil)
        WeightEntryPopover?.showRelativeToRect(WeightTableAddButton.bounds, ofView: WeightTableAddButton, preferredEdge: NSRectEdge.MaxY)

    }
    
    func updateWeightTable() {
        
        self.profileInfo = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(self.profileName)")!.mutableCopy() as? NSMutableDictionary
        
        // Getting weight table values from profileInfo dictionary as soon as the window loads, putting into array
        self.weightTableArray = profileInfo?.objectForKey("weightValues")!.mutableCopy() as? NSMutableArray
        self.weightTableDateArray = profileInfo?.objectForKey("weightValueDates")!.mutableCopy() as? NSMutableArray
        
        // Getting weight unit
        self.weightUnit = profileInfo?.objectForKey("weightUnit") as? String
        
        // debugging
        if devSettings.DebugPrintingEnabled == true {
            print(self.profileInfo)
            print(self.weightTableArray)
            print(self.weightTableDateArray)
        }
        let rowIndex = self.weightTableArray!.count - 1
        
        self.WeightTable.insertRowsAtIndexes(NSIndexSet(index: rowIndex), withAnimation: NSTableViewAnimationOptions.EffectGap)
        
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if self.weightTableArray!.count != 0 {
            return self.weightTableArray!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let tableCellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        
        if tableColumn!.identifier == "weightDates" {
            let date = self.weightTableDateArray![row]
            tableCellView.textField!.stringValue = date as! String
            return tableCellView
        }
        
        if tableColumn!.identifier == "weightValues" {
            let weight = self.weightTableArray![row]
            tableCellView.textField!.stringValue = weight as! String + weightUnit!
            return tableCellView
        }
        
        
        return tableCellView
        
    }
    
    // This closes the main window after the sheet has closed so that only the initial screen is shown
    func UserDeletedResetState(notification: NSNotification) {
        self.window?.close()
    }
    
    // Loads the user's information and greeter (the two sentences at the top of the window)
    func setupUser(notification: NSNotification) {
        
        // Customises the greeter
        HelloLabel.stringValue = "Hi, \(self.profileName)"
        
        // Displays tracked weight
        if profileInfo == nil { // shouldn't be nil
            LatestWeightLabel.stringValue = "No weight goal set yet..."
        } else {
            // Get values from user's dictionary
            let weightUnitValue = self.profileInfo!.valueForKey("weightUnit") as! String
            let lastWeightValueArray: [String] = ((self.profileInfo!.valueForKey("latestPredictedWeightLoss") as! [String]).last?.componentsSeparatedByString(";"))!
            
            let stoneValue = lastWeightValueArray.last!.componentsSeparatedByString(".")
            let weightGainOrLoss = self.profileInfo!.valueForKey("latestPredictedGain/Loss") as! Int
            var LatestWeightLabelValueSet: Bool = false
            var LatestWeightLabelString: String = ""
            
            // Modifies sentence to correspond to user's weight unit
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
        self.profileInfo = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(self.profileName)")!.mutableCopy() as? NSMutableDictionary
        
        // Getting weight table values from profileInfo dictionary as soon as the window loads, putting into array
        self.weightTableArray = profileInfo?.objectForKey("weightValues")!.mutableCopy() as? NSMutableArray
        self.weightTableDateArray = profileInfo?.objectForKey("weightValueDates")!.mutableCopy() as? NSMutableArray
        
        // Getting weight unit
        self.weightUnit = profileInfo?.objectForKey("weightUnit") as? String
        
        
    
        // Setting up notifications that will be triggered on certain events to run other classes etc
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupUser:", name: "MainWindowSetupUserNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "UserDeletedResetState:", name: "ResetToInitialWindowNotification", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("MainWindowSetupUserNotification", object: nil)
    }
    
}
