//
//  MainWindowController.swift
//  Weight Tracker
//
//  Created by Alex Potter on 27/08/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSTableViewDelegate, NSTableViewDataSource, NSTabViewDelegate {
    
    // Keep an optional reference to window controllers
    var initVC: InitialWindowController? = nil
    var SettingsController: SettingsWindowController? = nil
    var WeightEntryPopover: NSPopover? = nil
    var PopoverEntryController: PopoverEntryViewController? = nil
    
    let devSettings = DeveloperSettings(DebugPrintingEnabled: false, DebugDeleteDBEnabled: false)
    
    // Connecting IB objects to code
    @IBOutlet weak var HelloLabel: NSTextField!
    @IBOutlet weak var LatestWeightLabel: NSTextField!
    @IBOutlet weak var SettingsButton: NSButton!
    @IBOutlet weak var WeightTable: NSTableView!
    @IBOutlet weak var WeightTableAddButton: NSButton!
    @IBOutlet weak var WeightGoalLabel: NSTextField!
    @IBOutlet weak var ExpectedWeightLabel: NSTextField!
    @IBOutlet weak var WeightTableDeleteAllButton: NSButton!
    @IBOutlet weak var WeightTableEditButton: NSButton!
    @IBOutlet weak var WindowTabView: NSTabView!
    
    // From the Graph tab
    @IBOutlet weak var WindowGraphTab: NSTabViewItem!
    @IBOutlet weak var GraphView: CPTGraphHostingView!
    
    let profileName = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as! String
    var profileInfo: NSMutableDictionary? = nil
    var weightTableArray: NSMutableArray? = nil
    var weightTableDateArray: NSMutableArray? = nil
    let dateFormatter = NSDateFormatter()
    
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
        // Initialise popover, and display inside the main window bounds
        WeightEntryPopover = NSPopover()
        WeightEntryPopover?.contentViewController = PopoverEntryViewController(nibName: "PopoverEntryView", bundle: nil)
        WeightEntryPopover?.showRelativeToRect(WeightTableAddButton.bounds, ofView: WeightTableAddButton, preferredEdge: NSRectEdge.MaxY)
        
        // This sets the popover window to close when the user interacts with anything that isn't the popover
        WeightEntryPopover?.behavior = NSPopoverBehavior.Semitransient

    }
    
    @IBAction func WeightTableDeleteButtonClicked(sender: NSButton) {
        // Mode 2 of updating the table (delete selected row)
        self.updateUserWeightData(2)
    }
    
    @IBAction func WeightTableDeleteAllButtonClicked(sender: NSButton) {
        // Mode 3 of updating the table (delete all rows)
        self.updateUserWeightData(3)
    }
    
    @IBAction func WeightTableEditButtonClicked(sender: NSButton) {
        // First, update data and set date format for date formatter
        self.getProfileData()
        dateFormatter.dateFormat = "EEE, d MMM yyyy"
        
        // Get selected index of record
        let selectedRecordIndex: Int = WeightTable.selectedRow
        
        // The record index *shouldn't* be larger than the array, but check if it is anyway
        if (selectedRecordIndex < self.weightTableArray?.count) || (selectedRecordIndex < self.weightTableDateArray?.count) {
            // Grab weight/date values from persistent storage corresponding to that selected record
            let recordWeight = self.weightTableArray?.objectAtIndex(selectedRecordIndex)
            let recordDate: NSDate! = dateFormatter.dateFromString((self.weightTableDateArray?.objectAtIndex(selectedRecordIndex))! as! String)
            
            // Initialise popover for weight entry; mark record as editable (setup fields accordingly)
            WeightEntryPopover = NSPopover()
            PopoverEntryController = PopoverEntryViewController(nibName: "PopoverEntryView", bundle: nil)
            WeightEntryPopover?.contentViewController = PopoverEntryController
            WeightEntryPopover?.showRelativeToRect(WeightTableEditButton.bounds, ofView: WeightTableEditButton, preferredEdge: NSRectEdge.MaxY)
            
            PopoverEntryController?.setupEditableRecord(recordWeight!.doubleValue, editableDate: recordDate)
        }
    }
    
    func updateGraph() {
        // Initialise graph and data source
        self.getProfileData()
        let graph = CPTXYGraph(frame: self.GraphView.bounds)
        graph.plotAreaFrame?.masksToBorder = true
        self.GraphView.hostedGraph = graph
        self.GraphView.allowPinchScaling = true
        
        let graphSource = GraphDataSource(_dateArray: self.weightTableDateArray!, _weightArray: self.weightTableArray!)
        
        // Configure graph
        graph.applyTheme(CPTTheme(named: kCPTPlainWhiteTheme))
        graph.paddingBottom = 0.0
        graph.paddingTop = 0.0
        graph.paddingLeft = 0.0
        graph.paddingRight = 0.0
        
        graph.plotAreaFrame?.paddingLeft = -45.0
        
        // Set text, axis styles and configure graph's axis
        let titleStyle: CPTMutableTextStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.blackColor()
        titleStyle.fontName = "HelveticaNeue-Light"
        titleStyle.fontSize = 14.0
        
        let axisTitleStyle: CPTMutableTextStyle = CPTMutableTextStyle()
        axisTitleStyle.color = CPTColor.blackColor()
        axisTitleStyle.fontName = "HelveticaNeue-Bold"
        axisTitleStyle.fontSize = 12.0
        
        let axisSet = self.GraphView.hostedGraph?.axisSet!
        
        let xAxis: CPTXYAxis = (axisSet!.axes! as! [CPTXYAxis])[0]
        xAxis.title = "date"
        xAxis.titleTextStyle = axisTitleStyle
        xAxis.titleOffset = 8.0
        xAxis.labelingPolicy = CPTAxisLabelingPolicy.None
        xAxis.axisConstraints = CPTConstraints.constraintWithLowerOffset(30.0)
        
        let yAxis: CPTXYAxis = (axisSet!.axes! as! [CPTXYAxis])[1]
        yAxis.title = "weight"
        yAxis.titleTextStyle = axisTitleStyle
        yAxis.titleOffset = 30.0
        yAxis.labelingPolicy = CPTAxisLabelingPolicy.None
        yAxis.orthogonalPosition = 0.0
        //yAxis.axisConstraints = CPTConstraints.constraintWithLowerOffset(40.0)
        
        // Set title of graph
        let title = "Weight Graph"
        graph.title = title
        graph.titleTextStyle = titleStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchor.Top
        graph.titleDisplacement = CGPointMake(0.0, -8.0)
        
        // Create plot and set line style
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor.blueColor()
        lineStyle.lineWidth = 1.8
        
        // Create scatter graph and set data source
        let scatter = CPTScatterPlot(frame: self.GraphView.bounds)
        scatter.dataSource = graphSource
        scatter.identifier = "actual"
        scatter.dataLineStyle = lineStyle
        
        graph.addPlot(scatter)
        
        // Set plot space
        let plotSpace: CPTXYPlotSpace = graph.defaultPlotSpace! as! CPTXYPlotSpace
        
        // Explicitly not allowing the user to scroll through the graph
        plotSpace.allowsUserInteraction = false
        
        plotSpace.scaleToFitPlots(graph.allPlots())
        
        let xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
        let yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange
        
        xRange.expandRangeByFactor(1.4)
        yRange.expandRangeByFactor(1.4)
        
        plotSpace.xRange = xRange
        plotSpace.yRange = yRange
        
    }
    
    // This function is called whenever a tab is clicked.
    /* This runs a function to update the graph whenever the user clicks on the 'Graph' tab.
    The graph is only initialised when the user clicks the tab, so potentially this is more efficient? */
    func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {
        if ((tabViewItem?.isEqualTo(WindowGraphTab)) != nil) {
            self.updateGraph()
        }
    }
    
    // Publicly accessible notification function (to modify the table view)
    func updateUserNotification(notification: NSNotification) {
        // Reload data in table
        self.updateUserWeightData(0)
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
        
        self.getProfileData()
        
        /* Modes:
        1 = Reload Data only, don't delete anything
        2 = Delete item at selected row 
        3 = Delete all rows 
        */
        
        if mode == 1 {
            self.WeightTable.reloadData()
        } else if mode == 2 {
            print("hi")
            
            if WeightTable.numberOfSelectedRows == 0 {
                return
            }
            
            rowIndex = WeightTable.selectedRow
            
            // Fade out the deleted rows
            WeightTable.removeRowsAtIndexes(NSIndexSet(index: rowIndex), withAnimation: NSTableViewAnimationOptions.EffectFade)
            
        } else if mode == 3 {
            
            // There's nothing to delete if there isn't anything in the table...
            if WeightTable.numberOfRows == 0 {
                return
            } else {
                // Fade out all rows from table
                    WeightTable.removeRowsAtIndexes(NSIndexSet(indexesInRange: NSMakeRange(0, WeightTable.numberOfRows)), withAnimation: NSTableViewAnimationOptions.EffectFade)
                
            }
            
            
        }
        
        if mode == 2 { // deleting row's value in array
            self.weightTableArray?.removeObjectAtIndex(rowIndex)
            self.weightTableDateArray?.removeObjectAtIndex(rowIndex)
            
        } else if mode == 3 {
            // Remove all objects from the weight and weight date arrays
            self.weightTableArray?.removeAllObjects()
            self.weightTableDateArray?.removeAllObjects()
            
        }
        
        // Saving back to persistent storage
        self.profileInfo?.setObject(weightTableArray!, forKey: "weightValues")
        self.profileInfo?.setObject(weightTableDateArray!, forKey: "weightValueDates")
        NSUserDefaults.standardUserDefaults().setObject(self.profileInfo, forKey: "profileInfo\(self.profileName)")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // Finally, post notification to update the labels on screen (expected weight, on track to meet goal, etc...)
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
                    ExpectedWeightLabel.stringValue = String(format: "%.1f", nextValue) + self.weightUnit!
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
            dateFormatter.dateFormat = "EEE, d MMM yyyy"
            let goalDate: NSDate! = dateFormatter.dateFromString(weightGoalArray?.objectAtIndex(1) as! String)
            
            // The function in Statistical Analysis accepts a String, so convert whatever type of the weight goal value in the array to Swift's primitive type String
            let goalStringValue: String = String(weightGoalArray!.objectAtIndex(0))
            
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
