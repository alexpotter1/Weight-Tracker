# Test Plan

Afterwards, in order to test the program post-development, I propose to test the following
parts of the program to make sure that:

* There are as few bugs as possible in the final versions of the program
* The program functions correctly in the scope of the design, and requirement specifications.

### Initial design of Test Plan
| Aspect to be tested | Module being tested | Input | Output |
|-----------|----------|---------|-----|------|
| Length of user name | NewUserWindowController.swift | *Valid* String data | Should create the user correctly
| | | *Invalid* String data (long string) | Shouldn't work |
| | | *Extreme* Unicode string (this is technically a string but it is unicode, and a lot of languages don't support it) | Unknown - Swift does technically support Unicode strings, but it is unknown how the persistent storage database will handle it.
| Creating a profile that already exists | NewUserWindowController.swift | *Valid* String ( a profile that does not already exist) | Should create the user with no issues
| | | *Invalid* String (a user that does exist) | Should return an error saying that the user already exists.
| Setting Weight Goal | SettingsWindowController.swift | *Valid* String (normal, properly formatted decimal) | Should work properly
|||*Valid* String (normal integer) | Should work properly
|||*Invalid* String (improperly formatted decimal, e.g. "19;67") | This will be displayed, but any calculation done with this value should return garbage values (or crash upon casting to Double/floating point)
| Entering weight value | PopoverEntryViewController.swift | *Valid* String (properly formatted decimal) | Should work
| | | *Invalid* String (improperly formatted decimal) | Will probably still be displayed in the table (as the table will accept Strings), but any calculation should return garbage values.

### Actual results in test phase 1
| Aspect to be tested | Module being tested | Input | Output | Pass/Fail |
| ------------------- | ----------- | --------- | ----- |
| Length of user name | NewUserWindowController.swift | "Alex" (String) | As expected - creates profile, no error, name "Alex" | Pass |
|  |  |"a" character repeated 100 times | The profile is created with the name, but it doesn't display properly in the main window (probably clipping, too long) | Pass |
|  |  | Unicode character U+1F603 "😃" (Unicode string) | Works, creates profile with name "😃" | Pass |
| Creating a profile that already exists | NewUserWindowController.swift | "😃" (Unicode string) | As expected - pop-up displays saying that a profile already exists with the same name | Pass |
| Setting weight goal value | SettingsWindowController.swift | "11,6" (String) | The setting of the weight goal works, but it breaks the expected weight calculations | Fail |
|  |  | "10" (String) with weight unit selected as Stones and Pounds ("st lbs") | **Unexpected App crash** - lldb reports EXC_BAD_INSTRUCTION (Array index out of bounds) | Fail |
| Entering weight value | PopoverEntryViewController.swift | "85.2" (String) | As expected - displays correctly with "85.2kg" shown (weight unit is kg) | Pass |
|  |  | "85..2" (String) | Unexpected - displays correctly, probably because the weight table displays values as Strings not Doubles (breaks the expected weight though) | Fail |
|  |  | "10" (String) with weight unit as Stones and Pounds ("st lbs") | **Unexpected App crash** - lldb reports EXC_BAD_INSTRUCTION (Array index out of bounds) | Fail |

* The first application crash:
![App Crash 1](https://raw.githubusercontent.com/alexpotter1/WeightTracker/master/Development/Screenshots/exc_bad_inst_crash1.png?raw=true App Crash 1)
This is due to the program determining the weight value (when stones and pounds weight unit is selected) by using the decimal point to break the weight value down into the "stones" and "pounds" values respectively by using an array.
If the user doesn't enter a decimal point, then there is only one value in this array, not two, and the code runs into an out-of-bounds error. In addition, this also makes the profile permanently inaccessible to the user.

  To fix this, I would need to:
  * Either create an alternative interface when the "st lbs" unit is selected
  * To perform some data validation on the text field to only allow values containing a decimal point to be entered.

* The second application crash is very similar to the first, except that it occurs when the user enters a weight value to be stored, and don't put a decimal point into their value (and the weight unit is "st lbs"). The same error is reported, albeit in another place.

### Actual results in test phase 2
After refining the application in accordance with client feedback, I have modified the way that the user enters weight data. This is shown in the software development log.

| Aspect to be tested | Module being tested | Input | Output | Pass/Fail
| ------------------- | ----------- | --------- | ----- |
| Length of user name | NewUserWindowController.swift | "Alex" (String) | As expected - creates profile, no error, name "Alex" | Pass |
|  |  |"a" character repeated 100 times | The profile is created with the name, but it doesn't display properly in the main window (probably clipping, too long) | Pass |
|  |  | Unicode character U+1F603 "😃" (Unicode string) | Works, creates profile with name "😃" | Pass |
| Creating a profile that already exists | NewUserWindowController.swift | "😃" (Unicode string) | As expected - pop-up displays saying that a profile already exists with the same name | Pass |
| Setting weight goal value | SettingsWindowController.swift | "11,6" (String) | *Now impossible to input after changes* | Pass |
|  |  | "10" (String) with weight unit selected as Stones and Pounds ("st lbs") | *As expected - weight goal displays as "10 st 0 lbs"* | Pass |
| Entering weight value | PopoverEntryViewController.swift | "85.2" (String) | As expected - displays correctly with "85.2kg" shown (weight unit is kg) | Pass |
|  |  | "85..2" (String) | *Now impossible to input this value after changes* | Pass |
|  |  | "10" (String) with weight unit as Stones and Pounds ("st lbs") | *As expected - displays in weight table as "10 st 0 lbs"* | Pass |
