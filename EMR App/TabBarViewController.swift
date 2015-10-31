//  TabBarViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/15/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Handles passing of information from VC -> VC. Handles segue from DEM -> PCM if keyboard is not detected. Try routing movement to login & patientSelection VC through this too!

import UIKit
import CoreBluetooth

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    //Keyboard Detection:
    var keyboardSizeArray: [CGFloat] = []
    var keyboardAppearedHasFired: Bool?
    var bluetoothKeyboardAttached: Bool = true //true = BT keyboard, false = no BT keyboard. Default is true b/c any segue to this view would require that the BT keyboard is attached.
    var alertController: UIAlertController? //ensures only 1 alert is presented @ a time
    var currentVC: String = "DataEntryMode"
    var pcmIsOpen: Bool? //if false, then PCM is NOT open; if true, PCM is open. The variable is set to false when the view loads (as soon as the app opens). If no BT keyboard is detected & we segue -> PCM, we need to set this to true. If we segue -> PCM from DEM, then this variable will also be set to true. When we return, the variable should be set to false.
    
    override func viewDidLoad() {
        //Set the delegate of the TabBarController to itself:
        self.delegate = self
        
        //Add notifications the first time this view loads:
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChangedFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardAppeared:", name: UIKeyboardWillShowNotification, object: nil)
        self.pcmIsOpen = false
    }
    
    //MARK: - Keyboard Tracking
    
    func keyboardChangedFrame(notification: NSNotification) { //fires when keyboard changes
        if (pcmIsOpen == false) { //call only when PCM is not open
            let userInfo: NSDictionary = notification.userInfo!
            let keyboardFrame: CGRect = (userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue)!
            let keyboard: CGRect = self.view.convertRect(keyboardFrame, fromView: self.view.window)
            let sum = keyboard.origin.y + keyboard.size.height
            keyboardSizeArray.append(sum)
        }
    }
    
    func keyboardAppeared(notification: NSNotification) {
        if (pcmIsOpen == false) { //call only when PCM is not open
            let dataEntryModeVC = (self.viewControllers![0] as! DataEntryModeViewController)
            let dataExtractionModeVC = (self.viewControllers![1] as! DataExtractionModeViewController)
            let entryModeLoggedIn = dataEntryModeVC.loggedIn
            let extractionModeLoggedIn = dataExtractionModeVC.loggedIn
            let entryModePatient = dataEntryModeVC.currentPatient
            let extractionModePatient = dataExtractionModeVC.currentPatient
            
            let lastKeyboardSize = keyboardSizeArray.last
            let height: CGFloat = self.view.frame.size.height
            if (lastKeyboardSize > height) {
                bluetoothKeyboardAttached = true
            } else {
                if (currentVC == "DataEntryMode") { //current VC is dataEntryMode
                    if ((entryModeLoggedIn == true) && (entryModePatient != nil)) { //make sure login & patientSelection screens aren't open
                        NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "delayKeyboardCheck:", userInfo: nil, repeats: false) //create time delay for checking if keyboard is attached
                        print("currentVC: DataEntryMVC")
                        transitionToPCM()
                    } else {
                        print("DataEntryMVC: Not Logged In or Patient Not Set")
                    }
                } else { //current VC is dataExtractionMode
                    if ((extractionModeLoggedIn == true) && (extractionModePatient != nil)) {
                        NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "delayKeyboardCheck:", userInfo: nil, repeats: false)
                        print("currentVC: DataExtractionMVC")
                        transitionToPCM()
                    } else {
                        print("DataExtractMVC: Not Logged In or Patient Not Set")
                    }
                }
                bluetoothKeyboardAttached = false
            }
            keyboardSizeArray = [] //clear for next sequence
        }
    }
    
    func delayKeyboardCheck(timer: NSTimer) { //Fires [] seconds after being called by keyboardAppeared()
        //The longer the delay, the longer the normal keyboard is visible to the user; but it also gives time for the system to recognize the BT keyboard if the OK button is pressed. As time decreases, the keyboard disappears faster but the BT keyboard is recognized too slowly, so additional popups appear.
        if (bluetoothKeyboardAttached == false) {
            transitionToPCM()
        }
    }
    
    func transitionToPCM() { //Handles changes in bluetooth keyboard status
        if (alertController == nil) {
            alertController = UIAlertController(title: "Connection to bluetooth keyboard lost!", message: "If you wish to remain in Data Entry Mode, please pair your keyboard and press 'OK'. If you wish to transition to Patient Care Mode, press 'Redirect'.", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                self.alertController = nil //clear alertController for next display cycle
            })
            let redirect = UIAlertAction(title: "Redirect", style: .Default, handler: { (action) -> Void in
                self.performSegueWithIdentifier("showPCM", sender: self) //segue -> PCM
                self.alertController = nil //clear alertController for next display cycle
            })
            alertController!.addAction(ok)
            alertController!.addAction(redirect)
            presentViewController(alertController!, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {//Function called BEFORE the transition takes place
        //TabBarController does NOT have a traditional segue between its tabs, so you must use this & the next delegate protocols to handle passing data between your VCs in the controller.
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        // When the user taps a button (on the bottom nav bar) to move between views, we will pass the currentPatient & currentUser from the previous VC -> current VC.
        let dataEntryModeViewController = tabBarController.viewControllers![0] as! DataEntryModeViewController
        let dataExtractionModeViewController = tabBarController.viewControllers![1] as! DataExtractionModeViewController
        
        if (viewController == dataEntryModeViewController) { //Transition: Data Extraction -> Data Entry
            currentVC = "DataEntryMode" //set the current VC variable
            (viewController as! DataEntryModeViewController).currentPatient = dataExtractionModeViewController.currentPatient
            (viewController as! DataEntryModeViewController).currentUser = dataExtractionModeViewController.currentUser
            (viewController as! DataEntryModeViewController).loggedIn = true
        }
        
        if (viewController == dataExtractionModeViewController) { //Transition: Data Entry -> Extraction
            currentVC = "DataExtractionMode" //set the current VC variable
            (viewController as! DataExtractionModeViewController).currentPatient = dataEntryModeViewController.currentPatient
            (viewController as! DataExtractionModeViewController).currentUser = dataEntryModeViewController.currentUser
            (viewController as! DataExtractionModeViewController).loggedIn = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Set currentPatient & currentUser for the PCMVC.
        let dataEntryModeViewController = self.viewControllers![0] as! DataEntryModeViewController
        let dataExtractionModeViewController = self.viewControllers![1] as! DataExtractionModeViewController
        let patientCareModeViewController = segue.destinationViewController as! PatientCareModeViewController
        
        if (currentVC == "DataEntryMode") {
            patientCareModeViewController.currentPatient = dataEntryModeViewController.currentPatient
            patientCareModeViewController.currentUser = dataEntryModeViewController.currentUser
        } else if (currentVC == "DataExtractionMode") {
            patientCareModeViewController.currentPatient = dataExtractionModeViewController.currentPatient
            patientCareModeViewController.currentUser = dataEntryModeViewController.currentUser
        }
        patientCareModeViewController.loggedIn = true
        self.pcmIsOpen = true //set indicator that the current view is PCM
    }
    
}

extension UITabBarController {
    //Tells the TabBarController to respond to the supportedInterfaceOrientations & shouldAutorotate functions from the children VCs. 
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if let selected = selectedViewController {
            return selected.supportedInterfaceOrientations()
        }
        return super.supportedInterfaceOrientations()
    }
    public override func shouldAutorotate() -> Bool {
        if let selected = selectedViewController {
            return selected.shouldAutorotate()
        }
        return super.shouldAutorotate()
    }
}
