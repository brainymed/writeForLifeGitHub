//  PatientCareModeViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/21/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Controls the Patient Care Mode of the app (for handwritten information input & information extraction).
// Use COLLECTION VIEW (lookup) potentially for handling widgets!!!

import UIKit
import CoreGraphics
import CoreData

class PatientCareModeViewController: UIViewController, MLTWMultiLineViewDelegate, LoginViewControllerDelegate, PatientSelectionViewControllerDelegate {
    
    @IBOutlet weak var multiLineView: CustomMLTWView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var mltwTextLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var openButton: UIButton!
    
    @IBOutlet weak var leftMarginView: UIView!
    @IBOutlet weak var rightMarginView: UIView!
    
    var currentUser: String?
    var patientFileWasJustOpened: Bool = false //checks if patient file was just opened (for notification)
    var openScope: EMRField? //the currently open scope @ any given point in time; there can only be 1!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var newWidth: CGFloat?
    var newHeight: CGFloat?
    
    //MARK: - Default View Configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMLTW()
        configureStylus()
    }
    
    override func viewDidAppear(animated: Bool) {
        print("Current User (PCMVC): \(currentUser)")
        print("Current Patient (PCMVC): \(currentPatient?.name)")
        if (currentPatient == nil) {
            //If there is no patient file open, force the user to open one (e.g. by selecting from list of the day's patients):
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) { //Handle view rotation
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        multiLineView.guidelinesColor = UIColor.blueColor() //sets color of guidelines
        
        //Configure Interface:
        multiLineView.inputViewBackgroundColor = UIColor(red: 0.45, green: 0.0, blue: 0.0, alpha: 0.2) //Customize background for MLTW View to make it look like a cream-colored notebook
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
                closeButton.enabled = true //If file is open, user should have option to close it
                openButton.enabled = false //Disable 'open' button until file is closed
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
                        openButton.enabled = false //Disables 'open' button while patient file is open
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
                saveManagedObjectContext()
                closeButton.enabled = true //We enable the 'close' option when a patient file is open.
            } else {//Patient File Open
                //Add the input information to the 'currentPatient' & save it to the MOC. Each value that is sent to the EMR must be formatted correctly (dates must be formatted as dates, ints as ints, etc.) - 'setFieldValue()' handles formatting.
                openScope?.setFieldValueForPatient(emrFieldValue, forPatient: currentPatient!)
                saveManagedObjectContext()
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
            saveManagedObjectContext() //saves MOC after changes have been made
            currentPatient = nil //clear the currentPatient
        }
        
        closeButton.enabled = false //disable 'close' button when the file is closed
        mapButton.enabled = true //enable 'map' to start cycle anew
        sendButton.enabled = false //disable 'send' to prevent data -> a closed scope
        openButton.enabled = true //Re-enables 'open' button after current patient file is closed
        multiLineView.clear()
    }
    
    @IBAction func fetchButtonClick(sender: AnyObject) {
        fetchAllPatients()
    }
    
    //MARK: - User Authentication
    
    var loggedIn : Bool = true { //When we want login functionality, set it to FALSE!!!
        didSet {
            if loggedIn == true {
                //Configure view appropriately:
            } else {
                self.performSegueWithIdentifier("showLogin", sender: self)
            }
        }
    }
    
    @IBAction func logoutButtonClick(sender: AnyObject) {
        closeFileButtonClick(sender) //Closes open patient file & resets buttons before logging out
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
                self.performSegueWithIdentifier("showPatientSelection", sender: nil)
            }
        }
    }
    
    func patientFileHasBeenOpened() { //Patient Selection Delegate Method
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLogin" {
            let loginViewController = segue.destinationViewController as! LoginViewController
            loginViewController.delegate = self
        } else if segue.identifier == "showPatientSelection" {
            let patientSelectionViewController = segue.destinationViewController as! PatientSelectionViewController
            patientSelectionViewController.delegate = self
        }
    }
    
}