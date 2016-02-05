# Requirement Specification

Based upon the initial problem definition and interaction with the client, the proposed requirements of the system are as follows:

1. The system must have a method of inputting weight data over a specified period of time;

    *This requirement is needed as this ability is the main function of the application*

2. The system must be able to function with weight in measurement units of pounds, kilograms, as well as stones and pounds;

    *This was the main problem that the client expressed to me with other applications*

3. The system will have a means of providing visual feedback to the user via a graphical method;

    *Again, this would be part of the main function of the application so this requirement is also arguably needed*

4. The system must be able to handle multiple users, display their own separate profiles and manage the data associated with those profiles to persist even when the application is closed;

    *The client explicitly stated that this feature was wanted*

5. The system must launch and function effectively, without significant delays, hangs or crashes;

    *This is a simple and fairly obvious requirement, but if the app does not run well then that can lead to a poor user experience*

6. The system should be able to predict the user's eventual weight after the time period specified.

    *As before, the client explicitly stated in the initial discussion that they wanted this feature*

7. The system should be well designed, easy to use and simple in terms of navigation.

    *The user requested this so that the application can be used without significant mental effort, and such that anyone can use the application if they wish without having any prior knowledge at all.*

## Hardware Requirements
The hardware requirements for this application are based upon the client's computer.

*The client's computer is a 24-inch Late 2007 iMac. System specifications are shown (from apple.com):*

*I chose these specifications as I am sure that I am developing for one machine only and that is the client's computer. If the client decides to upgrade to a newer computer at a later date then the application should still run.*

* 2.4GHz Intel Core 2 Duo with 4MB L2 cache and 800MHz FSB

* 4GB 667MHz DDR2 RAM

* 320GB Serial ATA HDD

* 8x Apple SuperDrive CD/DVD±RW drive

* 24-inch display, 1920x1200 pixels, 16M colours

* ATI Radeon HD 2600 PRO graphics processor with 256MB of GDDR3 video memory

* FireWire 800 (IEEE1394), USB 2.0

* Gigabit Ethernet & WiFi 802.11n

*I would predict though, that the actual requirements for this application to run would be much lower as it is not particularly performance intensive.*

## Software Requirements
Since the solution will be built in Apple's Xcode development environment and since it will utilise Swift as the language, the product should work on all recent Mac OS X versions above 10.9 Mavericks (when initial support for Swift was added).

Minimum OS version: *Mac OS X Mavericks or later*
