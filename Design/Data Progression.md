## Data Progression
### Initial ideas
The initial design for the structure of the project was influenced by the design storyboard. Once the initial design was created, I started to map out how the structure would be like. The main part of the project

Initially, the data storyboard looked like this:
![Data Storyboard 1](Diagrams/data_diagram_1.jpeg?raw=true "Data Storyboard 1")

#### Swift code and Xcode files
The middle section of the storyboard denotes the Swift source code used in the project, as well as the files that were created by Xcode when the project was initialised.

There are three Swift files:
* AppDelegate.swift
* ViewController.swift
* GraphViewController.swift

Also, there are 2 files created by Xcode:
* Main.storyboard
* Info.plist

Initially (for the first prototype at least), the AppDelegate file was not supposed to have lots of code in it; the ViewController would handle the logic of the current view that was shown (in the single window of the app). The UI elements were defined to be in the Main.storyboard file (which is essentially an XML file that allows drag-and-drop creation of an interface). The UI elements would be connected to the View Controller by _"outlets"_ so that they can be used and modified in code.

The GraphViewController defines the methods used to process the graph shown in a tab on the main window of the application (shown in *Design Progression*).

Info.plist contains information for the building and compilation process, so my application doesn't modify this at all.

### Second design
As mentioned in *Design Progression*, upon creating the project I soon realised that this design would not function because of the *Storyboard* file being incompatible with the older OS that was installed on the client's computer.

Thus, after refining the design for reasons again mentioned in *Design Progression*, I created this data storyboard:

![Data Storyboard 2](Diagrams/data_diagram_2.jpeg?raw=true "Data Storyboard 2")

#### Swift code and Xcode files
This storyboard now includes the *"XIB"* files that define a user interface for Mavericks and older OS X versions. This is confirmed to work with the client's computer.

*"XIB"* files are used in this project to be linked with one controller class; the class is set as the *"File's Owner"*, meaning that it can fully manipulate and interact with the objects in the XIB file. This means that there are a lot more XIB files as the design has changed to have multiple windows, each with their own controller classes.

Each controller is listed for a different element in the design storyboard that needs to be controlled, such as:
* The initial screen
* The New User pane
* The Main window
* The Settings window

Each controller is initialised programmatically - the initial window controller is initialised in the AppDelegate (which controls application launch and termination), and then run at a later point. This ensures that all the window controllers are not loaded when the program launches, but rather that they are lazily loaded when the user progresses - this should help for performance reasons (especially on startup).
<br>Each controller works like this.</br>  

For example, the code needed to load the initial view controller would take the form:
```swift
var initialVC: InitialWindowController? = nil


// When the controller needs to be initialised...
initialVC = InitialWindowController(windowNibName: "InitialWindow")

initialVC?.loadWindow()
initialVC?.windowDidLoad()
initialVC?.showWindow(self)
```

Each window controller is, at the moment, can trigger events such as running methods in other window controllers when they are needed, through a  notification. This way, the controllers can stay in sync if they need to be.

#### Objective-C code
Despite this project being designed to be mainly written in Swift 2.0, I decided to think about using an external library to handle the graph drawing, so that it is easier on my end. I decided to use Core Plot, a popular open-source framework that leverages Quartz and Core Animation (Apple's compositing layers for 3D and 2D graphics), so it should have good performance on the client's computer which is relatively old. The library is written in Objective-C, but since Swift and Objective-C share the same runtime it should work well.

The data storyboard describes two files - *CorePlot.m* and *CorePlot.h*. The details on these files may change, as I begin to work with Core Plot in the app, but the library is represented by those two files for the moment.

* *CorePlot.h* is an Objective-C header file defines the methods, functions, variables and properties that can later be used.
* *CorePlot.m* is an Objective-C implementation file - existing here is the logic for the methods, functions, properties and variables that are defined in the header file.

##### Objective-C to Swift Bridging header
To access the methods and properties in Core Plot, the project must have a *Bridging Header*, so that the Swift code and the Objective-C code can work together. On the design storyboard, this is shown by a box that a line runs through from *CorePlot.m* to my graph view controller.

#### Persistent storage
In my project, there are two ways of persistently storing the user's data:
* Core Data, an SQLite3 database that communicates with classes through a managed object;
* NSUserDefaults, a simple database used for storing arrays, integers, strings, etc.

I decided to use NSUserDefaults as it is easier for a small project such as mine where not much data will need to be saved. Even the weight data in the Weight Table can be stored as an array of Doubles, which NSUserDefaults can accept (and then the graph can plot this data).

At the top of the design storyboard, the initial objects stored under NSUserDefaults are made. Each object must have a key, so that it can be accessed, and the object is an optional type that must be downcast to the type that is stored.
For example, if a string is stored in an NSUserDefaults object:

```swift
import Cocoa
var string = "Hello"
NSUserDefaults.standardUserDefaults().setObject(string, forKey: "myString")
NSUserDefaults.standardUserDefaults.synchronize()

// sometime later...
var stringObject = NSUserDefaults.standardUserDefaults().objectForKey("myString")
print(stringObject as! String) // should print "Hello"
```

The object stored under the *NewUserNames* key is an array of strings that is created when the user creates a new profile; the profile name is appended to the end of the array.
The dropdown box on the first screen retrieves the list of names in this array.

Likewise, the object for key *profileInfo<user's name>* is also created when the user creates a new profile, and contains information used in the main window such as their weight goal, whether they are likely to lose or gain weight, and all the user's entered weights.

The object for key *currentUser* is written to when the user changes the selection in the dropdown box.
