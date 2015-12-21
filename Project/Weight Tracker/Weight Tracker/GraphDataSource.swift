//
//  GraphDataSource.swift
//  Weight Tracker
//
//  Created by Alex Potter on 10/12/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//
//  This class will hold all of the data points for the graph to show.

import Cocoa

class GraphDataSource: NSObject, CPTPlotDataSource {
    private var shortDateArray: NSArray
    private var dateArray:  NSArray
    private var dateArrayIntervals: NSArray = []
    private var weightArray: NSMutableArray
    private var recordCount: Int
    
    init(_dateArray: NSMutableArray, _weightArray: NSMutableArray) {
        recordCount = _weightArray.count
        weightArray = _weightArray
        
        // Translate the string values of the dates to NSDate
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE, d MMM yyyy"
        dateArray = NSArray(array: _dateArray.map( {formatter.dateFromString($0 as! String)!} ))
        
        formatter.dateFormat = "dd/MM/yyyy"
        shortDateArray = NSArray(array: dateArray.map( {formatter.stringFromDate($0 as! NSDate)} ))
        
        // For some reason, superclass init has to go here, I don't know why
        super.init()
        
        dateArrayIntervals = dateArray.map( {$0.timeIntervalSinceDate!(dateArray.firstObject as! NSDate)} ) as NSArray
    }
    
    @objc func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        // Making sure date and weight arrays are of equal length, and they should be.
        if dateArray.count == weightArray.count {
            print(dateArray.count)
            return UInt(dateArray.count)
        } else {
            return 0
        }
    }
    
    @objc func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
        var x: NSNumber = idx
        var y: NSNumber = 0
        
        if plot.identifier?.description == "actual" {
            if dateArray.count == 0 {
                return 0
            }
            
            x = dateArrayIntervals.objectAtIndex(Int(idx)).doubleValue.roundToDecimalPlaces(3) as NSNumber
            y = weightArray.objectAtIndex(Int(idx)).doubleValue.roundToDecimalPlaces(3) as NSNumber
            
            return (fieldEnum == UInt(CPTScatterPlotField.X.rawValue) ? x : y)
            
        } else {
            return 0
        }
            
    }
    
    @objc func dataLabelForPlot(plot: CPTPlot, recordIndex idx: UInt) -> CPTLayer? {
        var x: AnyObject = idx
        var y: Double = 0.0
        
        if plot.identifier?.description == "actual" {
            if dateArray.count == 0 {
                return nil
            }
            
            x = shortDateArray.objectAtIndex(Int(idx)) as! String
            y = weightArray.objectAtIndex(Int(idx)).doubleValue
            
            let layer = CPTLayer(frame: CGRectMake(0, 0, 200, 25))
            let textLayer = CPTTextLayer(text: "\(x), \(y)")
            layer.addSublayer(textLayer)
            return layer
        } else {
            return nil
        }
    }
}

