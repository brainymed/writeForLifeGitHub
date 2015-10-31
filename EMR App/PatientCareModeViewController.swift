//  PatientCareModeViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/21/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Controls the Patient Care Mode of the app (for handwritten information input & information extraction).

import UIKit
import CoreGraphics
import CoreData

class PatientCareModeViewController: UIViewController, MLTWMultiLineViewDelegate, LoginViewControllerDelegate, PatientSelectionViewControllerDelegate {
    
    @IBOutlet weak var multiLineView: CustomMLTWView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var mltwTextLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var leftMarginView: UIView!
    @IBOutlet weak var rightMarginView: UIView!
    
    //Buttons for PCM - depending on whether the user is entering info or extracting it, the displayed buttons will be different. We need a button to switch modes & clicking on this will display different buttons (it will change the image & the associated action based on some tracker variable that notes what mode the user is in). There may be different numbers of templates, so we might also have to hide some buttons.
    @IBOutlet weak var modeSwitch: UISwitch!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var fourthButton: UIButton!
    @IBOutlet weak var fifthButton: UIButton!
    @IBOutlet weak var firstButtonLabel: UILabel!
    @IBOutlet weak var secondButtonLabel: UILabel!
    @IBOutlet weak var thirdButtonLabel: UILabel!
    @IBOutlet weak var fourthButtonLabel: UILabel!
    @IBOutlet weak var fifthButtonLabel: UILabel!
    
    @IBOutlet weak var notificationsFeed: UILabel!
    
    var currentUser: String?
    var patientFileWasJustOpened: Bool = false //checks if patient file was just opened (for notification)
    var fileWasOpenedOrCreated: String = ""
    var openScope: EMRField? //the currently open scope @ any given point in time; there can only be 1!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var newWidth: CGFloat?
    var newHeight: CGFloat?
    
    //Keyboard Detection:
    var keyboardSizeArray: [CGFloat] = []
    var bluetoothKeyboardAttached: Bool = false //true = BT keyboard, false = no BT keyboard
    var segueButtonHasBeenClicked: Bool = false //while true, it blocks further clicks of the segue button
    @IBOutlet weak var keyboardCheckTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Default View Configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardCheckTextField.hidden = true
        initializeMLTW()
        configureStylus()
        
        //Add notifications the first time this view loads:
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChangedFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        print("Current User (PCMVC): \(currentUser)")
        print("Current Patient (PCMVC): \(currentPatient?.name)")
        notificationsFeed.text = "Current Patient: \((currentPatient?.name)!)"
        fadeIn()
        fadeOut()
        modeSwitch(self) //set the template buttons according to the switch's state
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) { //Handle view rotation
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Notification Feed Animations
    
    func fadeIn() { //Fades in the twitter feed instantly
        self.view.bringSubviewToFront(notificationsFeed)
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.notificationsFeed.alpha = 1.0
            }, completion: nil)
    }
    
    func fadeOut() { //Gradually fades out the twitter feed
        UIView.animateWithDuration(1.0, delay: 3.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.notificationsFeed.alpha = 0.0
            }, completion: nil)
    }
    
    //MARK: - Jot Touch Config
    
    func configureStylus() {
        //Configure the Sync View:
        //Check how the canvas view in the example app is blocking user touches!!! App crashes if the jot is disconnected!
        let connectionStatusViewController : UIViewController = UIStoryboard.instantiateJotViewControllerWithIdentifier(JotViewControllerUnifiedStatusButtonAndConnectionAndSettingsIdentifier)
        connectionStatusViewController.view.frame = leftMarginView.bounds
        self.leftMarginView.addSubview(connectionStatusViewController.view)
        self.addChildViewController(connectionStatusViewController)
        
        let batteryIdentifierViewController : UIViewController = UIStoryboard.instantiateJotViewControllerWithIdentifier(JotViewControllerBatteryIdentifier)
        batteryIdentifierViewController.view.frame = mltwTextLabel.bounds
        self.mltwTextLabel.addSubview(batteryIdentifierViewController.view)
        self.addChildViewController(batteryIdentifierViewController)
        
        //        UIStoryboard.instantiateJotViewControllerWithIdentifier(JotViewControllerShortCutsIdentifier)
        //        UIStoryboard.instantiateJotViewControllerWithIdentifier(JotViewControllerPressToConnectIdentifier)
        //        UIStoryboard.instantiateJotViewControllerWithIdentifier(JotViewControllerWritingStyleIdentifier)
        
        //Create the Stylus Manager:
        JotStylusManager.sharedInstance().enable()
        JotStylusManager.sharedInstance().registerView(multiLineView)
        JotStylusManager.sharedInstance().palmRejectorDelegate = multiLineView
        JotStylusManager.sharedInstance().rejectMode = true
    }
    
    //MARK: - MLTW Config
    
    func initializeMLTW() {
        multiLineView.delegate = self
        
        //Configure Guidelines:
        multiLineView.guidelineFirstPosition = 70.0 //changes position of the top-most line drawn on the view (the value given is the distance from the top of the view)
        multiLineView.guidelinesHeight = 70.0 //sets distance between the guidelines
        multiLineView.guidelinesColor = UIColor.blackColor() //sets color of guidelines
        
        //Configure Interface:
        multiLineView.inputViewBackgroundColor = UIColor(red: 0.0, green: 0.33, blue: 0.75, alpha: 0.2) //Customize background for MLTW View to make the pages of the notebook light blue
        multiLineView.inkThickness = 2.0 //Thickness of pen strokes
        
        //Configure Auto-Scrolling:
        multiLineView.setWritingMode()
        multiLineView.autoScrollDisabled = false
        multiLineView.autoScrollRatio = 0.6 //Percent of view that must be filled before auto-scroll occurs
        multiLineView.scrollBackgroundColor = UIColor.lightGrayColor() //sets color of scroll bar
        
        self.configureRecognitionForLocale()
        
        //Enable or Disable Various Gestures AFTER Configuration:
        multiLineView.setGesture(.Underline, enable: false) //Disables underline
        multiLineView.setGesture(.Join, enable: false) //Disables join gesture (combines words)
        multiLineView.setGesture(.Erase, enable: false) //Disables erase (strikethrough?) gesture
        multiLineView.setGesture(.Overwrite, enable: false)
        multiLineView.setGesture(.Return, enable: false) //Disables return (enter) gesture
        multiLineView.setGesture(.Selection, enable: false) //Disables 'circle' gesture
    }
    
    func configureRecognitionForLocale() {
        //Configure MLTW w/ Resources, Certificate, & Locale:
        let cursiveResource : NSString = NSBundle.mainBundle().pathForResource("en_US-ak-cur.lite", ofType: "res")!
        let textResource : NSString = NSBundle.mainBundle().pathForResource("en_US-lk-text.lite", ofType: "res")!
        let resourceArray : [NSString] = [cursiveResource, textResource]
        let certificate = NSData(bytes: myCertificate, length: myCertificate.count)
        multiLineView.configureWithLocale("en_US", resources: resourceArray, lexicon: nil, certificate: certificate, density: 132 * 2)
    }
    
    func multiLineView(view: MLTWMultiLineView!, didChangeText text: String!) {
        //Called each time the recognition changes. Converts the writing -> text after recognition, displays in textView:
        mltwTextLabel.text = text
    }
    
    func multiLineView(view: MLTWMultiLineView!, didDetectSelectionGestureForWords words: [AnyObject]!) {
        //Called when a CIRCLE gesture is detected:
        var combinedText = ""
        for object in words {
            let word = (object as! MLTWWord).text
            combinedText += "\(word) " //Generate a combined input phrase
        }
        multiLineView.clear() //clear view after data is captured
        print(combinedText)
    }
    
    func multiLineView(view: MLTWMultiLineView!, didFailConfigurationWithError error: NSError!) {
        NSLog("Failed configuration: %@", error.localizedDescription)
    }
    
    //MARK: - Template Buttons
    
    @IBAction func modeSwitch(sender: AnyObject) { //switches from extraction -> entry mode
        if (modeSwitch.on) { //render 'Entry' mode buttons/labels
            firstButton.setImage(UIImage(named: "Template Icon - Vitals"), forState: UIControlState.Normal)
            firstButtonLabel.text = "Vitals"
            secondButton.setImage(UIImage(named: "Template Icon - Physical"), forState: UIControlState.Normal)
            secondButtonLabel.text = "Physical"
            thirdButton.setImage(UIImage(named: "Template Icon - ROS"), forState: UIControlState.Normal)
            thirdButtonLabel.text = "ROS"
            fourthButton.setImage(UIImage(named: "pencil"), forState: UIControlState.Normal)
            fourthButtonLabel.text = "Fourth"
            fifthButton.setImage(UIImage(named: "pencil"), forState: UIControlState.Normal)
            fifthButtonLabel.text = "Fifth"
        } else { //render 'Extraction' mode buttons & labels
            firstButton.setImage(UIImage(named: "Template Icon - Vitals"), forState: UIControlState.Normal)
            firstButtonLabel.text = "Latest Vitals"
            secondButton.setImage(UIImage(named: "pencil"), forState: UIControlState.Normal)
            secondButtonLabel.text = "Lab Values"
            thirdButton.setImage(UIImage(named: "pencil"), forState: UIControlState.Normal)
            thirdButtonLabel.text = "Imaging"
            fourthButton.setImage(UIImage(named: "pencil"), forState: UIControlState.Normal)
            fourthButtonLabel.text = "Progress Notes"
            fifthButton.setImage(UIImage(named: "Template Icon - Meds"), forState: UIControlState.Normal)
            fifthButtonLabel.text = "Medication List"
        }
    }
    
    @IBAction func firstButtonClick(sender: AnyObject) {
        if (modeSwitch.on) {
            //perform first entry button functionality
        } else {
            //perform first extraction button functionality
        }
    }
    
    @IBAction func secondButtonClick(sender: AnyObject) {
        if (modeSwitch.on) {
            //perform 2nd entry button functionality
        } else {
            //perform 2nd extraction button functionality
        }
    }
    
    @IBAction func thirdButtonClick(sender: AnyObject) {
        if (modeSwitch.on) {
            //perform 3rd entry button functionality
        } else {
            //perform 3rd extraction button functionality
        }
    }
    
    @IBAction func fourthButtonClick(sender: AnyObject) {
        if (modeSwitch.on) {
            //perform 4th entry button functionality
        } else {
            //perform 4th extraction button functionality
        }
    }
    
    @IBAction func fifthButtonClick(sender: AnyObject) {
        if (modeSwitch.on) {
            //perform 5th entry button functionality
        } else {
            //perform 5th extraction button functionality
        }
    }
    
    //MARK: - Side Panel Buttons*
    
    @IBAction func clearButtonClick(sender: AnyObject) {
        multiLineView.clear()
    }
    
    @IBAction func openButtonClick(sender: AnyObject) {
        //Opens a file for an existing patient - user enters a name & the Core Data object for that patient is fetched (initially). Later on, an existing file will be opened in the EMR.
        if (mltwTextLabel.text?.characters.count > 0) && (currentPatient == nil) {
            let patientName = mltwTextLabel.text
            let resultOfSearch = openPatientFile(patientName!)
            if (resultOfSearch != nil) { //Patient was found for the given name
                currentPatient = resultOfSearch
                let alertController = UIAlertController(title: "Success!", message: "Patient file was opened for \(currentPatient!.name).", preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
                alertController.addAction(ok)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else { //Patient was not found for the given name
                let alertController = UIAlertController(title: "Error!", message: "No patient was found for the given name. Please enter an existing patient's name.", preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
                alertController.addAction(ok)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        } else { //Nothing entered in MLTW
            print("Please enter a patient name.")
        }
        multiLineView.clear()
    }
    
    @IBAction func mapButtonClick(sender: AnyObject) {
        //Checks if the input value matches an EMR field before mapping to it & opening a scope:
        if mltwTextLabel.text?.characters.count > 0 {
            
            openScope = EMRField(inputWord: mltwTextLabel.text!, currentPatient: currentPatient!) //Open a new scope
            
            //For a given input, first we need to check if a patient file is currently open (whether 'currentPatient' exists. If not, we must next check if the user is inputting a MK for entry of a patient's name. If not, then the user must first input a patient name.
            //If currentPatient exists, then we need to check if the input word matches an EMR field name (this task is handled by the 'EMRFieldName' class).
            if (openScope!.matchFound()) {
                //Check if 'currentPatient' exists:
                if (currentPatient == nil) {//Does NOT exist
                    //If it doesn't exist, first check if the user is trying to enter a new patient:
                    if (openScope!.getFieldName() == "name") {
                        //Open scope for new patient name:
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.mltwTextLabel.text = "Scope opened for <\(self.openScope?.getFieldName())>" //NOT WORKING
                        })
                        mapButton.enabled = false
                        sendButton.enabled = true //Enables send button while scope is open
                        print("New Patient - Scope Opened")
                    } else {//'Current Patient' exists but no patient file is open
                        //Alert user that new patient must first be entered:
                        let alertController = UIAlertController(title: "No Files are Open!", message: "There are currently no patient files open. Please enter a patient name before proceeding.", preferredStyle: .Alert)
                        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
                        alertController.addAction(ok)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        //Configure view for patient name entry:
                    }
                } else {//'Current patient' exists & match is found for keyword
                    //Open scope for NON-NAME field:
                    if (openScope!.getFieldName() == "name") {
                        //Throw error message - user should not be entering a new name while a current patient exists (they must clear the old patient first).
                        let alertController = UIAlertController(title: "Error!", message: "A patient file is already open. Please close this file if you wish to add another patient.", preferredStyle: .Alert)
                        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
                        alertController.addAction(ok)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    } else {
                        //Open Scope:
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.mltwTextLabel.text = "Scope opened for <\(self.openScope?.getFieldName())>" //NOT WORKING
                        })
                        mapButton.enabled = false //Disables 'map' button after scope has been opened
                        sendButton.enabled = true //Enables 'send' button while scope is open
                        print("Match found for keyword. Enter value to be mapped.")
                    }
                }
            } else {//'matchFound' == nil
                let alertController = UIAlertController(title: "No match found!", message: "No field matching your input was found in the EMR. Please enter a valid field.", preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
                alertController.addAction(ok)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            multiLineView.clear()
        } else {//Nothing entered by user
            print("Please enter a value to be mapped.")
        }
    }
    
    @IBAction func sendButtonClick(sender: AnyObject) {
        if (openScope!.matchFound()) && ((mltwTextLabel.text?.characters.count)! > 0) {
            let emrFieldValue = mltwTextLabel.text!
            if (currentPatient == nil) {//No Patient File Open
                //If there is no file open, the input fieldValue must (theoretically) be a patient name (else 'send' wouldn't be enabled). Initialize the currentPatient w/ the input name:
                currentPatient = Patient(name: emrFieldValue, insertIntoManagedObjectContext: managedObjectContext)
                saveManagedObjectContext(managedObjectContext)
            } else {//Patient File Open
                //Add the input information to the 'currentPatient' & save it to the MOC. Each value that is sent to the EMR must be formatted correctly (dates must be formatted as dates, ints as ints, etc.) - 'setFieldValue()' handles formatting.
                openScope?.setFieldValueForCurrentPatient()
                saveManagedObjectContext(managedObjectContext)
            }
            print(currentPatient)
            multiLineView.clear()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mltwTextLabel.text = "<\(emrFieldValue)> was mapped to '\(self.openScope?.getFieldName())' for \(self.currentPatient?.name)" //NOT WORKING
            })
            openScope = nil //Clears the scope to prepare for the next map/send cycle
            sendButton.enabled = false //Disables 'send' after scope is closed
            mapButton.enabled = true //Enables 'map' after scope is closed
        } else {
            print("Please enter a value")
        }
    }
    
    @IBAction func closeFileButtonClick(sender: AnyObject) {
        //Close the existing patient file that is being worked on (& remove the current patient from the MOC) - first, we transfer the 'currentPatient' object -> a new object, which will be placed in the MOC, so that the info is not lost when the 'currentPatient' is removed from the MOC.
        openScope = nil //if there is a scope open, close it
        if (currentPatient != nil) {
            let patient : Patient = currentPatient! //Transfer data
            managedObjectContext.insertObject(patient) //Add new object to MOC
            managedObjectContext.deleteObject(currentPatient!) //Remove currentPatient from MOC
            saveManagedObjectContext(managedObjectContext) //saves MOC after changes have been made
        }
        
        mapButton.enabled = true //enable 'map' to start cycle anew
        sendButton.enabled = false //disable 'send' to prevent data -> a closed scope
        multiLineView.clear()
        currentPatient = nil //clear the currentPatient
    }
    
    @IBAction func fetchButtonClick(sender: AnyObject) {
        fetchAllPatients()
        keyboardCheckTextField.becomeFirstResponder()
        if (self.segueButtonHasBeenClicked == false) { //proceed only if button has not been clicked yet
            segueButtonHasBeenClicked = true
            activityIndicator.startAnimating()
            NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "delayedKeyboardCheck:", userInfo: nil, repeats: false) //delay keyboard check to give time for keyboard to pop up
        }
    }
    
    //MARK: - User Authentication & Patient Selection
    
    var loggedIn : Bool = true { //When we want login functionality, set it to FALSE!!!
        didSet {
            if loggedIn == true {
                //Configure view appropriately.
            } else {
                self.performSegueWithIdentifier("showLogin", sender: self)
            }
        }
    }
    
    @IBAction func logoutButtonClick(sender: AnyObject) {
        //Clear out existing user defaults:
        //        let appDomain = NSBundle.mainBundle().bundleIdentifier
        //        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        loggedIn = false
    }
    
    func didLoginSuccessfully() { //Delegate Method
        loggedIn = true
        dismissViewControllerAnimated(true, completion: nil) //returns to PCM VC
    }
    
    var currentPatient: Patient? { //Check for open patient file
        didSet {
            if (currentPatient != nil) { //Patient file is open. Let view render as defined elsewhere.
            } else { //No patient file is open. Segue to patientSelectionVC
                self.performSegueWithIdentifier("showPatientSelection", sender: self)
            }
        }
    }
    
    func patientFileHasBeenOpened() { //Patient Selection Delegate Method
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Keyboard Tracking
    
    func keyboardChangedFrame(notification: NSNotification) { //fires when keyboard changes
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardFrame: CGRect = (userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue)!
        let keyboard: CGRect = self.view.convertRect(keyboardFrame, fromView: self.view.window)
        keyboardSizeArray.append(keyboard.size.height)
    }
    
    func delayedKeyboardCheck(timer: NSTimer) {
        activityIndicator.stopAnimating()
        if (shouldPerformSegueWithIdentifier("showDEM", sender: self) == true) {
            performSegueWithIdentifier("showDEM", sender: self)
        }
        keyboardSizeArray = [] //clear for next sequence
        segueButtonHasBeenClicked = false //reset the checker to enable the button to be clicked again
    }
    
    //MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "showDEM") { //Check for keyboard before transitioning
            keyboardCheckTextField.resignFirstResponder() //banish keyboard if it is visible
            let lastKeyboardSize = keyboardSizeArray.last
            if (lastKeyboardSize == 0.0) { //keyboard size = 0.0 -> BT keyboard
                return true
            } else { //keyboard size > 0 -> no BT keyboard
                let alertController = UIAlertController(title: "Warning!", message: "Please attach a bluetooth keyboard to your device before transitioning into Data Entry Mode.", preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
                alertController.addAction(ok)
                self.presentViewController(alertController, animated: true, completion: nil)
                return false
            }
        } else { //should never be called
            return true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLogin" {
            let loginViewController = segue.destinationViewController as! LoginViewController
            loginViewController.delegate = self
        } else if segue.identifier == "showPatientSelection" {
            let patientSelectionViewController = segue.destinationViewController as! PatientSelectionViewController
            patientSelectionViewController.delegate = self
        } else if segue.identifier == "showDEM" { //pass currentPatient & user before segue & set 'openedPCM' to false
            let destinationVC = (segue.destinationViewController as! TabBarViewController)
            destinationVC.pcmIsOpen = false
            let dataEntryModeVC = (destinationVC.viewControllers![0] as! DataEntryModeViewController)
            dataEntryModeVC.currentPatient = self.currentPatient
        }
    }
    
}