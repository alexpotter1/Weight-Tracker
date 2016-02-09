
## Design Progression

### Initial design and storyboard
The design started out with a single window, with a sidebar for user management and a tab bar to switch between two views.

The first design storyboard looked like this:
<br></br>
![Design Storyboard 1](Diagrams/design_diagram_1.jpeg?raw=true "Design Storyboard 1")

The initial design conforms to the following requirements defined in the specification:
* **1**: Weight table in first screen
* **3**: Graph in second screen, presents weight
* **4**: User sidebar in both windows
* **6**: Text notifying user of their progress with respect to their goal in first screen

#### Source List
The shaded left area of the window would be what is known as the "NSOutlineView" or a "Source List" - a sidebar that lets users navigate or select objects. In this case it would be users. An example of the Source List (in Yosemite) is shown below:
<br></br>
![Yosemite Source List](https://developer.apple.com/library/mac/documentation/UserExperience/Conceptual/OSXHIGuidelines/Art/finder_sidebar_2x.png "Yosemite Source List: Apple OS X Human Interface Guidelines")

Note, on Yosemite, the Source List sidebar would be translucent. On the client's operating system (Mavericks, which is older), it would not have translucency.

#### Tabs

The rest of the window would consist of a Tab View (NSTabView). On one tab, the Weight Table would be shown, where the user could input their weight and save it to the table (along with the current system date and time).

In addition to the table, extra information would be presented in terms of whether the user is on track for their desired weight goal.

On the other tab, a graph would be shown of the user's progress (weight loss/gain over time), and the application also has the potential to extrapolate data already on the graph or Weight Table to construct predictions of when the user will reach their goal (or if they won't)

### Second design and storyboard
#### Issues with the first design
Unfortunately, just after the project was created I realised that the first design would not be able to create a working application on the client's computer.

I physically attempted to run a prototype on the client's computer, and it loaded but it didn't show an interface.
This would have not met the following requirement in the specification:
* **5**: Application must load, function effectively and not hang or crash

By default, a "Storyboard" is created to handle the UI design, and this only functions on a newer OS than the client is running. I had two solutions to this problem:
* Advise the user to upgrade their operating system - I did not want to have to do this
* Create a new application with legacy "XIB" user interface files that function on the target OS

In addition, the Source List was becoming particularly problematic to have in the design, due to differences in the target OS and the development OS, which are different.

Thus, I spoke with my client to tell him that the design would be moving in a different direction. The client, as before, didn't explicitly express any preferences to how the design will function. Despite this, the objectives of the app were still desired, so the new design must still accommodate them.

<div class="page-break"></div>

I subsequently came up with the following design:
![Design Storyboard 2](Diagrams/design_diagram_2.jpeg?raw=true "Design Storyboard 2")

This subsequent design explicitly conforms to the following requirements in the specification:

* **1**: Weight table in window 3
* **2**: Dialog box for choosing weight unit in window 5
* **3**: Graph in window 4, showing user progress
* **4**: Multiple users, windows 1 and 2
* **6**: Text informing user of progress in window 3

In addition, the following requirements were confirmed to be met when this design was made functional with an early prototype:
* **5**: The application launches and displays a functional interface on OS X Mavericks.

#### Profile management
The new design requires the user to "log in" to their profile as soon as the app starts. This is so that the user is guided into doing so, and it prevents the user from forgetting to create a user when using the application.

The first screen (parts **1** and **2**) manages profiles. There is text that greets the user, and a NSComboBox that allows the user to select from a list of profiles. The app will initially start with no profiles on the first run, so the user can create a profile by clicking on a button.

Clicking on this button will open a new window that is presented as a _"sheet"_ - the sheet slides down on top of the previous window; this establishes a new context for the user without them losing track of the previous window. In addition to this, the user cannot exit the sheet until they either click the _"Done"_ or _"Cancel"_ buttons.

An example of a modal sheet is shown below:
![Modal Sheet](https://developer.apple.com/library/mac/documentation/UserExperience/Conceptual/OSXHIGuidelines/Art/sheet_example_2x.png "Modal Sheet")

As shown in the design, the user enters a string of text of their desired user name, and the Done button closes the sheet and returns to the previous window. Once at the previous window, the user can select their newly created user and continue to the main window of the application.

#### Main window
This encompasses parts **3** and **4** of the design.
In the design storyboard, the top of the screen presents the user with information regarding their progress with respect to their set goal.

The main functionality of this window is divided into two tabs, which are discussed in the initial design above. However, this design also states the user's current goal, and their average weight delta per week.

In the information tab, the Weight Table (NSTableView) will present the user's weight next to a date and time supplied by the system. This is the same as the initial design except for the method of input of the weight.

##### Weight entry view
To input the data, the client expressed a desire for a _"calculator"_ or _"keypad"_ type interface. To minimise UI disruption with respect to the main window, I have provisionally decided to use a _"popover"_, which is shown to the right of the main window on the design storyboard.

A popover is a small window that appears within a specific action or context; in this case, that is the creation of a new row of the user's new weight. They appear when the user needs them and should disappear as soon as possible when they are not needed.

Examples are shown below:
<br></br>

![Popover 1](https://developer.apple.com/library/mac/documentation/UserExperience/Conceptual/OSXHIGuidelines/Art/popover_unattached_2x.png "Popover 1")
<br></br>
![Popover 2](https://developer.apple.com/library/mac/documentation/UserExperience/Conceptual/OSXHIGuidelines/Art/popover_dictionary_2x.png "Popover 2")

##### Profile settings
The window to customise the profile's preferences is located at point **5** on the design storyboard, above the main window. This is a small window, presented as a modal sheet that has several actions.

One such action is to customise the weight unit for the profile. One of the client's main needs is that the app doesn't just have weight units of kilograms (kg) and pounds (lbs), but also the mixed unit of stone pounds (st lbs) that is used commonly in the UK to express weight, especially that of people. Thus, there will be a dropdown box to select either of the three weight units.

Another action is the goal that the user wants to achieve, and what date that they want to achieve it by. This will link to the graph view to _potentially_ extrapolate data to predict if the user will reach their goal.

The last action that the settings window will do initially is to delete the current user. This may be useful to the user if they do not wish to proceed with their user; they may instead wish to start anew. The _"Delete User"_ button would be placed far enough away from the other UI elements in the window so that it cannot be pressed accidentally - in addition, an alert will display to warn the user so that they can confirm if they want to delete the user. An alert is most often presented as a sheet, but is sometimes presented modally (as a new window).

An example of an alert is shown below:
<br></br>
![Modal Alert](https://developer.apple.com/library/mac/documentation/UserExperience/Conceptual/OSXHIGuidelines/Art/alert_example_2x.png "Modal Alert")

### Third design and storyboard
#### Changes from the second design

After testing the application with the user, they responded with these comments:
> * In the new user window, instead of going back to the previous window after clicking Done it should move to the main window
> * The user selection screen needs validation to make sure that two users can not share the same name - otherwise there is no way of differentiating between them.

I subsequently came up with the following revised design:
![Design Storyboard 3](Diagrams/design_diagram_3.jpeg?raw-true)

The major difference on this diagram is how the app transitions from the first screen to the next - when the 'Done' button is pressed in the New User window it now moves straight away to the main window as the arrow represents.

Validation is also present at this stage, however it isn't on the diagram. This is because the validation function on the user name box does not have a design that I create - rather it is created by code only, and has only one visual style.

Also in this stage, I plan to implement the designs present in the last two storyboards about the weight goal and prediction functions into the actual program.


### Fourth design
### Changes from third design
Again, after testing, the client gave these design-oriented comments:
> * On the weight table, it would be a good idea to have a 'Delete All' button and an 'Edit' button in addition to 'Add' and 'Remove'
> * Allow the entry of another date when adding a new weight record (so that I can go back and add missing records)

The new design now looks like this:
![Design Storyboard 4](Diagrams/design_diagram_4.jpeg?raw=true)

The major changes here are:

* Edit button and Delete All buttons in the weight table on the main window
* Weight entry window now has two boxes to prevent weight input errors with decimal points, etc.
* Weight entry window now has custom date input
* New validation screen on the weight goal input (presents error if user doesn't type a decimal value)
* Weight goal input is split into two boxes (prevents errors with input)
* Graph labels instead of crowded data points on axes

##### Edit/Delete All button
This was added at the client's request.
This button is placed, as per the diagram, on the bottom row of the weight table.

The Edit button opens the weight entry screen with the selected record's values already loaded. The idea is that the user can then delete what is there and type in a new value if they so wish.

The Delete All button, as the name suggests, removes **all** the records in the table and from persistent storage.

##### Weight entry window - two boxes
The purpose of this is to prevent application crashes that existed within the testing phase of the third cycle when the user doesn't type a decimal point into their weight value, *or* if they type non-numeric values that produce garbage values with the expected weight calculations.

The way that I intend for this to work is to have the user type the first part of their value into the box and then click the "NEXT" button to input their second part of the weight value. Then they can press Done when they are finished, or AC if they make a mistake.

This ensures that the values in the table are both purely numeric and uniform, so the expected weight class and graph knows what to expect when taking these values as input parameters.

##### Weight entry window - custom date input
This was added at the client's request.
This allows the user to add a weight value but without the date defaulting to the current system date. This is useful if, for example, the user wants to add values that they already have stored somewhere other than the program.

The date format is the UK standard format of DD/MM/YYYY.

##### Weight goal validation
I think that this would be a good idea to implement if the user does not type a numeric value into the weight goal boxes - for example if they type "abc". The weight goal is intended to be stored as a Double, and "abc" is not convertible to a double so the application will crash. Thus, this validation box will not let the user save the value until they enter a numeric value.

This validation screen is an *NSAlert*, and is created programmatically.
Thus, the validation screens/alert dialog boxes in my application all follow one visual style, as discussed earlier.

##### Weight goal input - two boxes
As with the weight entry window, the weight goal 


**All images used are from Apple's OS X Human Interface Guidelines. Copyright © Apple Inc. 2015** http://developer.apple.com/library/mac/documentation/UserExperience/Conceptual/OSXHIGuidelines/index.html
