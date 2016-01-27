# Test Plan

Afterwards, in order to test the program post-development, I propose to test the following
parts of the program to make sure that:

* There are as few bugs as possible in the final versions of the program
* The program functions correctly in the scope of the design, and requirement specifications.

The test plan will contain all of the tests that will be run after each cycle, as well as whether each test passes in the debug environment (my computer, OS X 10.11 El Capitan) and the target environment (client's computer, OS X 10.9 Mavericks).

## Cycle 1
### Initial design of Test Plan
| Aspect to be tested | Module | Comments | Pass/Fail (debug) | Pass/Fail (target) |
| :------------- | :------------- | :----------- | :------- | :-------- |
| Application launches and first window opens | AppDelegate/NSApplication (UNIX exec()) | This test checks that the application runs on the target machine | N/A | N/A |
| Create new user button loads new user window | InitialWindowController/NewUserWindowController | This test checks that the 'Create new user' button loads the new user window | N/A | N/A |
| User name validation - Normal | NewUserWindowController | This test checks that the user name is set as "Alex123". This test uses only alphanumeric characters. | N/A | N/A |
| User name validation - Invalid | NewUserWindowController | This test checks if a new user will be created with the same name as another user/profile | N/A | N/A |
| User name validation - Extreme | NewUserWindowController | This test checks if these non-alphanumeric Unicode characters (U+26F1 ⛱, U+26F3 ⛳, U+26F5 ⛵) are accepted as a user name. | N/A | N/A |
| Selection of user profiles | InitialWindowController/MainWindowController | This test checks whether the correct profile is loaded when selected. | N/A | N/A |

## Alpha test
**Note: If a test fails that is integral to the program's execution flow, the remaining tests in the plan are skipped.**

| Aspect to be tested | Module | Comments | Pass/Fail (debug) | Pass/Fail (target) |
| :------------- | :------------- | :----------- | :------- | :-------- |
| Application launches and first window opens | AppDelegate/NSApplication (UNIX exec()) | This test checks that the application runs on the target machine | Pass | **Fail** |
| Create new user button loads new user window | InitialWindowController/NewUserWindowController | This test checks that the 'Create new user' button loads the new user window | Pass | -- |
| User name validation - Normal | NewUserWindowController | This test checks that the user name is set as "Alex123". This test uses only alphanumeric characters. | **Fail** | -- |
| User name validation - Invalid | NewUserWindowController | This test checks if a new user will be created with the same name as another user/profile | -- | -- |
| User name validation - Extreme | NewUserWindowController | This test checks if these non-alphanumeric Unicode characters (U+26F1 ⛱, U+26F3 ⛳, U+26F5 ⛵) are accepted as a user name. | -- | -- |
| Selection of user profiles | InitialWindowController/MainWindowController | This test checks whether the correct profile is loaded when selected. | -- | -- |

In this testing phase, all the tests in the plan failed on the target because I had decided (provisionally) to use a 'storyboard' for creating the interface - OS X Mavericks does not support 'storyboard'-based UI design and the application simply crashes when launching. I had to resort to the legacy 'XIB'-based UI design method, which would now work perfectly.

#### Alpha test 1 (re-run)
After changing the application, I re-ran Alpha test 1:

| Aspect to be tested | Module | Comments | Pass/Fail (debug) | Pass/Fail (target) |
| :------------- | :------------- | :----------- | :------- | :-------- |
| Application launches and first window opens | AppDelegate/NSApplication (UNIX exec()) | This test checks that the application runs on the target machine | Pass | Pass |
| Create new user button loads new user window | InitialWindowController/NewUserWindowController | This test checks that the 'Create new user' button loads the new user window | Pass | Pass |
| User name validation - Normal | NewUserWindowController | This test checks that the user name is set as "Alex123". This test uses only alphanumeric characters. | Pass | Pass |
| User name validation - Invalid | NewUserWindowController | This test checks if a new user will be created with the same name as another user/profile | Pass | Pass |
| User name validation - Extreme | NewUserWindowController | This test checks if these non-alphanumeric Unicode characters (U+26F1 ⛱, U+26F3 ⛳, U+26F5 ⛵) are accepted as a user name. | Pass | Pass |
| Selection of user profiles | InitialWindowController/MainWindowController | This test checks whether the correct profile is loaded when selected. | Pass | Pass |

## Cycle 2
### Test Plan Extension
| Aspect to be tested | Module | Comments | Pass/Fail (debug) | Pass/Fail (target) |
| :------- | :------- | :------- | :------ | :--------|
| Setting a weight goal | SettingsWindowController | This test checks whether the weight goal value and date can be entered properly and are stored properly. | N/A | N/A |
| Setting weight unit | SettingsWindowController | This test checks if the user can select all three weight units without any problems. | N/A | N/A |
| Deleting user | SettingsWindowController | This test checks if the user can delete their profile without errors. | N/A | N/A |

### Alpha test 2

| Aspect to be tested | Module | Comments | Pass/Fail (debug) | Pass/Fail (target) |
| :------- | :------- | :------- | :------ | :--------|
| Setting a weight goal | SettingsWindowController | This test checks whether the weight goal value and date can be entered properly and are stored properly. | Pass | **Fail** |
| Setting weight unit | SettingsWindowController | This test checks if the user can select all three weight units without any problems. | Pass | Pass |
| Deleting user | SettingsWindowController | This test checks if the user can delete their profile without errors. | Pass | Pass |

### App crash 1
* The first application crash was when setting the weight goal:
![App Crash 1](https://raw.githubusercontent.com/alexpotter1/WeightTracker/master/Development/Screenshots/exc_bad_inst_crash1.png?raw=true App Crash 1)
This is due to the program determining the weight value (when stones and pounds weight unit is selected) by using the decimal point to break the weight value down into the "stones" and "pounds" values respectively by using an array.
If the user doesn't enter a decimal point, then there is only one value in this array, not two, and the code runs into an out-of-bounds error. In addition, this also makes the profile permanently inaccessible to the user.

  To fix this, I would need to:
  * Either create an alternative interface when the "st lbs" unit is selected
  * To perform some data validation on the text field to only allow values containing a decimal point to be entered.

## Cycle 3
### Test Plan Extension 2

| Aspect to be tested | Module | Comments | Pass/Fail (debug) | Pass/Fail (target) |
| :------- | :------- | :------- | :------- | :------- |
| Add weight value | MainWindowController/PopoverEntryViewController | This test checks if the 'add weight value' button works and that the value and date are displayed properly in the table. | N/A | N/A |
| Remove selected weight value | MainWindowController | This test checks if the table can handle a random selected record being removed without error. | N/A | N/A |
| Expected weight | MainWindowController/StatisticalAnalysis | This test checks whether the expected weight calculation functions and displays correctly | N/A | N/A |

### Alpha test 3
| Aspect to be tested | Module | Comments | Pass/Fail (debug) | Pass/Fail (target) |
| :------- | :------- | :------- | :------- | :------- |
| Add weight value | MainWindowController/PopoverEntryViewController | This test checks if the 'add weight value' button works and that the value and date are displayed properly in the table. | Pass | Pass |
| Remove selected weight value | MainWindowController | This test checks if the table can handle a random selected record being removed without error. | Pass | Pass |
| Expected weight | MainWindowController/StatisticalAnalysis | This test checks whether the expected weight calculation functions and displays correctly | Pass | Pass |

#### Alpha test 2 (re-run)
After running alpha test 3, I went back and re-ran Alpha test 2 once I had fixed the weight goal input:

| Aspect to be tested | Module | Comments | Pass/Fail (debug) | Pass/Fail (target) |
| :------- | :------- | :------- | :------ | :--------|
| Setting a weight goal | SettingsWindowController | This test checks whether the weight goal value and date can be entered properly and are stored properly. | Pass | Pass |
| Setting weight unit | SettingsWindowController | This test checks if the user can select all three weight units without any problems. | Pass | Pass |
| Deleting user | SettingsWindowController | This test checks if the user can delete their profile without errors. | Pass | Pass |

## Cycle 4
### Test Plan Extension 3

| Aspect to be tested | Module | Comments | Pass/Fail (debug) | Pass/Fail (target) |
| :------- | :------- | :------- | :------- | :------- |
| Delete All records | MainWindowController | This test checks if all of the weight table records are removed when pressing this button. | N/A | N/A |
| CorePlot framework integration | CorePlot.framework | This tests whether the CorePlot framework (drawing graphs) is properly added to Xcode. | N/A | N/A |
| Graph initialisation | MainWindowController/GraphDataSource | This tests whether the graph initialises properly on the 'Graph' tab | N/A | N/A |
| Graph display values | GraphDataSource | This tests whether the graph can get data points from the weight table and display them properly. | N/A | N/A |
| Edit a weight value | MainWindowController/PopoverEntryViewController | This tests whether a random selected record can be edited without error. | N/A | N/A |
| Weight goal validation - Normal | SettingsWindowController | This tests whether "12.7" can be input as a weight goal value | N/A | N/A |
| Weight goal validation - Invalid | SettingsWindowController | This tests whether "abc" can be input as a weight goal value | N/A | N/A |

### Alpha test 4

| Aspect to be tested | Module | Comments | Pass/Fail (debug) | Pass/Fail (target) |
| :------- | :------- | :------- | :------- | :------- |
| Delete All records | MainWindowController | This test checks if all of the weight table records are removed when pressing this button. | Pass | Pass |
| CorePlot framework integration | CorePlot.framework | This tests whether the CorePlot framework (drawing graphs) is properly added to Xcode. | Pass | Pass |
| Graph initialisation | MainWindowController/GraphDataSource | This tests whether the graph initialises properly on the 'Graph' tab | Pass | Pass |
| Graph display values | GraphDataSource | This tests whether the graph can get data points from the weight table and display them properly. | Pass | Pass |
| Edit a weight value | MainWindowController/PopoverEntryViewController | This tests whether a random selected record can be edited without error. | Pass | Pass |
| Weight goal validation - Normal | SettingsWindowController | This tests whether "12.7" can be input as a weight goal value | Pass | Pass |
| Weight goal validation - Invalid | SettingsWindowController | This tests whether "abc" can be input as a weight goal value | Pass | Pass |
