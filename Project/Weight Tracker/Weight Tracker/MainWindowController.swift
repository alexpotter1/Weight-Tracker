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
    
    func getProfileData() {
        self.profileInfo = NSUserDefaults.standardUserDefaults().objectForKey("profileInfo\(self.profileName)")!.mutableCopy() as? NSMutableDictionary
        
        // Getting weight table values from profileInfo dictionary as soon as the window loads, putting into array
        self.weightTableArray = profileInfo?.objectForKey("weightValues")!.mutableCopy() as? NSMutableArray
        self.weightTableDateArray = profileInfo?.objectForKey("weightValueDates")!.mutableCopy() as? NSMutableArray
        
        // Getting weight unit to redisplay in table
        self.weightUnit = profileInfo?.objectForKey("weightUnit") as? String
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

        self.getProfileData()
        
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
        self.getProfileData()
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
    
    func expectedWeight(statClassReference: StatisticalAnalysis) {
        // Calculate expected weight
        let stat = StatisticalAnalysis(_dateArray: self.weightTableDateArray!, _weightArray: self.weightTableArray!)
        stat.RegressionAnalysis()
        
        // Get last date from array
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM yyyy"
        
        // Checking if there are any values in the array first (otherwise it doesn't compile)
        if self.weightTableArray!.count != 0 {
            let lastDate = dateFormatter.dateFromString(self.weightTableDateArray!.lastObject as! String)
            let nextValue = stat.RegressionNextValue((lastDate!.timeIntervalSinceReferenceDate) + 604800) // 604800 seconds in one week
            
            if nextValue.isNaN {
                ExpectedWeightLabel.stringValue = "More time is needed for prediction"
            } else {
                // Check weight unit so that weight value displays properly (for st lbs)
                // In addition, format to one decimal place.
                
                if self.weightUnit! == "st lbs" {
                    let separatedValueArray: [String] = String(format: "%.1f", nextValue).componentsSeparatedByString(".")
                    ExpectedWeightLabel.stringValue = "\(separatedValueArray[0])st \(separatedValueArray[1])lbs"
                    
                } else {
                    
                    // Display expected weight value, round to 2 decimal places
                    ExpectedWeightLabel.stringValue = String(format: "%.2f", nextValue) + self.weightUnit!
                }
            }
        } else {
            ExpectedWeightLabel.stringValue = "No weight values yet..."
        }
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
            
            // Display weight goal
            let weightGoalArray: NSArray? = self.profileInfo!.valueForKey("weightGoal") as? NSArray
            if weightGoalArray != nil {
                
                if weightUnitValue == "st lbs" {
                    // Separating stone and pounds values by decimal point
                    let values: [String] = String(weightGoalArray!.objectAtIndex(0).doubleValue!).componentsSeparatedByString(".")
                    WeightGoalLabel.stringValue = "\(values[0])st \(values[1])lbs by \(weightGoalArray![1])"
                } else {
                    WeightGoalLabel.stringValue = "\(weightGoalArray![0])\(weightUnitValue) by \(weightGoalArray![1])"
                }
            }
            
            // If the weight goal date is the default date (Unix timestamp)
            if (weightGoalArray?.objectAtIndex(1))! as! String == "Thu, 1 Jan 1970" {
                // Just display something to tell the user the weight goal needs to be set
                WeightGoalLabel.stringValue = "Set a weight goal in Settings"
            }
            
            // Will the user reach their goal?
            let st = StatisticalAnalysis(_dateArray: self.weightTableDateArray!, _weightArray: self.weightTableArray!)
            
            // Convert string to date first
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE, d MMM yyyy"
            let goalDate: NSDate! = dateFormatter.dateFromString(weightGoalArray?.objectAtIndex(1) as! String)
            
            // The function in Statistical Analysis accepts a String, so convert whatever type of the weight goal value in the array to Swift's primitive type String
            let goalStringValue: String = String(weightGoalArray?.objectAtIndex(0))
            
            // Let the user know if they're gonna meet their goal, and then calculate everything else that's needed (expected weight)
            if st.willMeetTarget(goalStringValue, weightGoalDate: goalDate) == true {
                LatestWeightLabel.stringValue = "You're on target to obtain your weight goal"
            } else {
                LatestWeightLabel.stringValue = "You're not on target to obtain your weight goal"
            }
        
        self.expectedWeight(st)
            
            
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
