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
    @IBOutlet weak var WeightGoalLabel: NSTextField!
    @IBOutlet weak var ExpectedWeightLabel: NSTextField!
    
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
    
    @IBAction func WeightTableDeleteButtonClicked(sender: NSButton) {
        self.updateUserWeightData(2)
    }
    
    func updateWeightTable() {
        self.updateUserWeightData(0)
        let rowIndex = self.weightTableArray!.count - 1
        self.WeightTable.insertRowsAtIndexes(NSIndexSet(index: rowIndex), withAnimation: NSTableViewAnimationOptions.EffectGap)
        
    }
    
    func updateUserNotification(notification: NSNotification) {
        self.updateUserWeightData(1)
    }
    
    func updateUserWeightData(mode: Int) {
        var rowIndex = 0
        
        if mode == 1 {
            WeightTable.reloadData()
        } else if mode == 2 { // delete selected row in table
            
            if WeightTable.numberOfSelectedRows == 0 {
                return
            }
            
            rowIndex = WeightTable.selectedRow
            WeightTable.removeRowsAtIndexes(NSIndexSet(index: rowIndex), withAnimation: NSTableViewAnimationOptions.EffectGap)
            
        }
        self.profileInfo = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(self.profileName)")!.mutableCopy() as? NSMutableDictionary
        
        // Getting weight table values from profileInfo dictionary as soon as the window loads, putting into array
        self.weightTableArray = profileInfo?.objectForKey("weightValues")!.mutableCopy() as? NSMutableArray
        self.weightTableDateArray = profileInfo?.objectForKey("weightValueDates")!.mutableCopy() as? NSMutableArray
        
        // Getting weight unit to redisplay in table
        self.weightUnit = profileInfo?.objectForKey("weightUnit") as? String
        
        if mode == 2 { // deleting row's value in array
            self.weightTableArray?.removeObjectAtIndex(rowIndex)
            self.weightTableDateArray?.removeObjectAtIndex(rowIndex)
            
            // Saving back to persistent storage
            self.profileInfo?.setObject(weightTableArray!, forKey: "weightValues")
            self.profileInfo?.setObject(weightTableDateArray!, forKey: "weightValueDates")
            NSUserDefaults.standardUserDefaults().setObject(self.profileInfo, forKey: "profileInfo\(self.profileName)")
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("MainWindowSetupUserNotification", object: nil)
        
        // debugging
        if devSettings.DebugPrintingEnabled == true {
            print(self.profileInfo)
            print(self.weightTableArray)
            print(self.weightTableDateArray)
        }
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
            let weight = self.weightTableArray![row] as! String
            // We have to do some extra processing on the displayed weight if the weight unit is stones and pounds...
            if self.weightUnit! == "st lbs" {
                // Splitting the weight value into two components (before and after the decimal point)
                let weight = weight.componentsSeparatedByString(".")
                
                // Doing a similar thing with the unit, except it's separated by a space (st lbs)
                let unit = self.weightUnit!.componentsSeparatedByString(" ")
                
                // Finally, combining everything to fix the displayed weight value in st lbs;
                tableCellView.textField!.stringValue = weight[0] + unit[0] + " "  + weight[1] + unit[1]
                return tableCellView
            }
             tableCellView.textField!.stringValue = weight + self.weightUnit!
            return tableCellView
        }
        
        
        return tableCellView
        
    }
    
    // This closes the main window after the sheet has closed so that only the initial screen is shown
    func UserDeletedResetState(notification: NSNotification) {
        self.window?.close()
    }
    
    func calculateWeightDelta(weight1: AnyObject, weight2: AnyObject) -> Double {
        let dWeight1: Double = (weight1 as! NSString).doubleValue
        let dWeight2: Double = (weight2 as! NSString).doubleValue
        
        // Percentage difference formula: (| V1 - V2 | / (V1 + V2)/2) * 100
        
        let difference = dWeight2 - dWeight1
        let average = (dWeight1 + dWeight2)/2
        
        return (difference/average) * 100
    }
    
    func expectedWeight() {
        self.weightTableArray = (self.profileInfo?.valueForKey("weightValues")?.mutableCopy() as! NSMutableArray)
        self.weightTableDateArray = (self.profileInfo?.valueForKey("weightValueDates")?.mutableCopy() as! NSMutableArray)
        
        var timeDelta = 0.0
        var weightDelta = 0.0
        
        if self.weightTableDateArray!.count < 2 || self.weightTableArray!.count < 2 {
            ExpectedWeightLabel.stringValue = "Not enough weight values yet..."
            
        } else if self.weightTableDateArray!.count % 2 == 0 {
            for (var i = 0; i <= (self.weightTableDateArray!.count - 1)/2; i++) {
                timeDelta += self.calculateTimeDelta(self.weightTableDateArray![i] as! String, date2: self.weightTableDateArray![i+1] as! String)
            }
            
            for (var i = 0; i <= (self.weightTableArray!.count - 1)/2; i++) {
                weightDelta += self.calculateWeightDelta(self.weightTableArray![i], weight2: self.weightTableArray![i+1])
            }
            
        } else {
            for (var i = 0; i <= (self.weightTableDateArray!.count - 2)/2; i++) {
                timeDelta += self.calculateTimeDelta(self.weightTableDateArray![i] as! String, date2: self.weightTableDateArray![i+1] as! String)
            }
            
            for (var i = 0; i <= (self.weightTableArray!.count - 2)/2; i++) {
                weightDelta += self.calculateWeightDelta(self.weightTableArray![i], weight2: self.weightTableArray![i+1])
            }
            
        }
        
        if self.weightTableArray!.count > 1 {
            timeDelta /= Double(self.weightTableDateArray!.count - 1)
            weightDelta /= Double(self.weightTableArray!.count - 1)
            
            let adjustedWeightDelta = weightDelta / 100 // because weightDelta is a percentage
            let expectedWeight = ((self.weightTableArray?.lastObject)!.doubleValue * adjustedWeightDelta) + (self.weightTableArray?.lastObject)!.doubleValue
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE, d MMM yyyy"
            let date = dateFormatter.dateFromString(self.weightTableDateArray!.lastObject as! String)
            
            let expectedDate: NSDate = (date?.dateByAddingTimeInterval(timeDelta))!
            let expectedDateString = dateFormatter.stringFromDate(expectedDate)
            
            // Display next expected weight, format to 2 decimal places
            ExpectedWeightLabel.stringValue = String(format: "%.2f", expectedWeight) + self.weightUnit! + " by \(expectedDateString)"
        } else {
            ExpectedWeightLabel.stringValue = "Not enough weight values yet..."
        }
        
    }
    
    // Use date format 'EEE, d MMM yyyy' otherwise this procedure returns garbage out
    // date2 always > date1 (date2 is more recent than date1)
    func calculateTimeDelta(date1: String, date2: String) -> NSTimeInterval {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM yyyy"
        
        // Converting human-readable date strings to NSDates
        let dateTimestamp1: NSDate = dateFormatter.dateFromString(date1)!
        let dateTimestamp2: NSDate = dateFormatter.dateFromString(date2)!
        
        // Getting absolute value of the time delta between the dates (in seconds)
        let timeDelta: NSTimeInterval = fabs(dateTimestamp2.timeIntervalSinceDate(dateTimestamp1))
        
        return timeDelta
    }
    
    // Loads the user's information
    func setupUser(notification: NSNotification) {
        
        // Customises the greeter
        HelloLabel.stringValue = "Hi, \(self.profileName)"
        
        // Displays tracked weight
        if profileInfo == nil { // shouldn't be nil
            LatestWeightLabel.stringValue = "No weights to track yet..."
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
            
            // Display weight goal
            let weightGoalArray: NSArray? = self.profileInfo!.valueForKey("weightGoal") as? NSArray
            if weightGoalArray != nil {
                
                if weightUnitValue == "st lbs" {
                    // Separating stone and pounds values by decimal point
                    let values: [String] = (weightGoalArray![0]).componentsSeparatedByString(".")
                    WeightGoalLabel.stringValue = "\(values[0])st \(values[1])lbs by \(weightGoalArray![1])"
                } else {
                    WeightGoalLabel.stringValue = "\(weightGoalArray![0])\(weightUnitValue) by \(weightGoalArray![1])"
                }
            } else {
                // Just display something to tell the user the weight goal needs to be set
                WeightGoalLabel.stringValue = "No weight goal set yet, set one in Settings"
            }
            
            // Calculate expected weight
            self.expectedWeight()
            
        }
        
    }
 
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        self.updateUserWeightData(0)
        // Setting up notifications that will be triggered on certain events to run other classes etc
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupUser:", name: "MainWindowSetupUserNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "UserDeletedResetState:", name: "ResetToInitialWindowNotification", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("MainWindowSetupUserNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUserNotification:", name: "UpdateUserData", object: nil)
        
        
    }
    
}
