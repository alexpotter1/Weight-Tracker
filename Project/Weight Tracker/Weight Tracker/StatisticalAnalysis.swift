//
//  LinearRegression.swift
//  Weight Tracker
//
//  Created by Alex Potter on 03/11/2015.
//  Copyright © 2015 Alex Potter. All rights reserved.
//
//  Using the Least Squares method to construct a line of best fit from the data points.

import Cocoa

public class StatisticalAnalysis {
    private typealias ValueTuple = (date: NSTimeInterval, weight: Double)
    private var values: [ValueTuple] = []
    private var m: Double = 0.0
    private var a: Double = 1.0
    private var b: Double = 2.0
    private var c: Double = 0.0
    
    public init(dateArray: NSMutableArray, weightArray: NSMutableArray) {
        // Creating NSDateFormatter object to convert the date strings to NSDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM yyyy"
        
        // First, convert the dates to NSDate
        // The map function performs a transformation on all the elements of an array (rather than using a for loop)
        let adjustedDateArray = dateArray.map( {dateFormatter.dateFromString($0 as! String)} )
        
        // Have to convert values to match the tuple types of the values array (NSTimeInterval and Double)
        let correctedDateArray = adjustedDateArray.map( {$0!.timeIntervalSinceReferenceDate} )
        let adjustedWeightArray = weightArray.map( {($0 as! NSString).doubleValue} )
        
        // Using zip to combine both arrays together into an array of tuples
        self.values = [ValueTuple]((zip(correctedDateArray, adjustedWeightArray)))
    }
    
    public func RegressionAnalysis() {
        /* To obtain the line of best fit gradient for a set of data points:
        *  
        *  m = (Σ(current x - mean x)(current y - mean y)) / (Σ(current x - mean x)^2)
        *  where Σ means 'sum of'
        *
        */
        
        // x = dates, y = weights
        
        // reduce() combines all values into an array into one value - in this case {$0 + $1} means to get the sum of the array's values
        let dateMean = self.values.reduce(0) { $0 + $1.date } / Double(values.count)
        let weightMean = self.values.reduce(0) { $0 + $1.weight } / Double(values.count)
        
        self.a = self.values.reduce(0) { $0 + (($1.date - dateMean) * ($1.weight - weightMean)) }
        self.b = self.values.reduce(0) { $0 + pow(($1.date - dateMean), 2) }
        
        self.m = self.a / self.b
        self.c = weightMean - self.m * dateMean
        
    }
    
    public func RegressionNextValue(date: Double) -> Double {
       // y = mx + c
        return (self.m * date) + self.c
    }
    

}

