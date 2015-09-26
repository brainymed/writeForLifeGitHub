//  DataEntryModeViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/21/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Controls the Data Entry portion of the app for information input into the EMR. Make sure to add LOGOUT button for both views so that others can utilize the app @ any point! 

// Stagger the horizontal centering of the views by 60 pts so they are centered in the clear area!

import UIKit

class DataEntryModeViewController: UIViewController, LoginViewControllerDelegate, UITextFieldDelegate {
    
    var currentPatient: Patient?
    var openScope: EMRField?
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var patientNameTextField: UITextField!
    @IBOutlet weak var patientNameEntryLabel: UILabel!
    @IBOutlet weak var fieldNameTextField: UITextField!
    @IBOutlet weak var fieldNameEntryLabel: UILabel!
    @IBOutlet weak var fieldValueEntryLabel: UILabel!
    @IBOutlet weak var fieldValueAnalog: UITextField!
    @IBOutlet weak var openExistingFileButton: UIButton!
    @IBOutlet weak var createNewFileButton: UIButton!
    @IBOutlet weak var notificationsFeed: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        patientNameTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        if loggedIn == false {//If user is not logged in, we modally segue to the login screen. We need this line of code b/c the 'didSet' function is NOT called when we initially set the value of 'loggedIn'.
            performSegueWithIdentifier("showLogin", sender: nil)
        }
        
        //Alternative way using user defaults:
        //        let preferences : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        //        let loggedInCheck : Int = preferences.integerForKey("ISLOGGEDIN") as Int
        //        if (loggedInCheck != 1) {
        //            self.performSegueWithIdentifier("showLogin", sender: self)
        //        } else {
        //            self.loginStatusLabel.text = preferences.valueForKey("USERNAME") as? String
        //        }
        print("Current Patient (DEMVC): \(currentPatient?.name)")
        
//        if currentPatient == nil { //If there is no current patient, configure view for name entry:
//            //The length of this view should be configured so it does NOT interfere w/ the navigation items in the top, left & right margins!!! Currently, it fills the whole screen & (even though we cannot see it), is preventing user actions from reaching the buttons on the top margin.
//            let customView = PatientNameEntryView(frame: CGRect(x: 60, y: 100, width: 400, height: 400))
//            customView.tag = 1000
//            self.view.addSubview(customView)
//        } else {
//            //Configure view differently. Allow the user to hit the 'ENTER' button & submit information for other, non-name views!
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Handling Rotation of View
    override func viewWillLayoutSubviews() {
        for subview in view.subviews {
            if subview.tag == 1000 {
                subview.removeFromSuperview()
            }
        }
//        let customView = PatientNameEntryView(frame: CGRect(x: 60, y: 100, width: view.frame.width - 60, height: view.frame.height - 150))
//        customView.backgroundColor = UIColor.blueColor()
//        customView.tag = 1000
//        self.view.addSubview(customView)
    }
    
    //MARK: - Standard View Configuration
    
    @IBAction func createNewFileButtonClick(sender: AnyObject) {
        //Create a new patient file:
        currentPatient?.name = patientNameTextField.text!
        configureViewForFieldNameEntry()
        
        notificationsFeed.text = "New File Created for {}"
        fadeIn()
        fadeOut()
    }
    
    @IBAction func openExistingFileButtonClick(sender: AnyObject) {
        //Open an existing patient file for the given name (check for patient):
        currentPatient?.name = patientNameTextField.text!
        configureViewForFieldNameEntry()
        
        notificationsFeed.text = "Patient File Opened for {}"
        fadeIn()
        fadeOut()
    }
    
    func configureViewForFieldNameEntry() { //Configures view AFTER patient file has been opened
        //Hide patient name entry views:
        patientNameTextField.hidden = true
        patientNameEntryLabel.hidden = true
        openExistingFileButton.hidden = true
        createNewFileButton.hidden = true
        
        //Bring up 'Field Name' Entry Views:
        fieldNameEntryLabel.hidden = false
        fieldNameTextField.hidden = false
        
        //Set delegate for fieldNameTextField & make it the 1st responder.
        fieldNameTextField.delegate = self
        fieldNameTextField.becomeFirstResponder()
    }
    
    //Configure behavior when 'RETURN' button is hit:
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.text = ""
        textField.resignFirstResponder()
        
        if textField.tag == 1 { // sender is Field Name TF
            //Configure behavior based on the value that was entered:
            openScope = EMRField(inputWord: textField.text!)
//            if (openScope!.matchFound()) {
//                //Check if 'currentPatient' exists:
//                if (currentPatient == nil) {//Does NOT exist
//                    //If it doesn't exist, first check if the user is trying to enter a new patient:
//                    if (openScope!.getFieldName() == "name") {
//                        //Open scope for new patient name:
//                    } else {//'Current Patient' exists but no patient file is open
//                        //This should never trigger b/c a patient file must be open before any behaviors can take place
//                    }
//                } else {//'Current patient' exists & match is found for keyword
//                    //Open scope for NON-NAME field:
//                    if (openScope!.getFieldName() == "name") {
//                        //Throw error message - user should not be entering a new name while a current patient exists (they must clear the old patient first).
//                    } else {
//                        //Open Scope (render the view according to the fieldName that was entered):
//                        //Bring up the 'Field Value' Entry Views:
//                    }
//                }
//            } else {//'matchFound' == nil
//                print("No match found!")
//                //Keep the first responder here & accept a new field name entry.
//            }
            //Hide the open views & render the view based on the entered value (post "{} Field has been opened" in the twitter feed):
            fieldNameEntryLabel.hidden = true
            fieldNameTextField.hidden = true
            fieldValueEntryLabel.hidden = false
            fieldValueAnalog.hidden = false
            
            //Updates twitter feed asynchronously; eventually, we want this to be a scrollable view that the user can refer back to.
            notificationsFeed.text = "Scope has been opened for {} field"
            fadeIn()
            fadeOut()
            
            //Swap delegates:
            textField.delegate = nil
            fieldValueAnalog.delegate = self
            fieldValueAnalog.becomeFirstResponder()
        } else if textField.tag == 2 { // Sender is Field Value Analog (to be deleted when specific configurations are enabled)
            //Send the input values to the EMR or persistent data store, post "{} has been mapped to {}" in the twitter feed, & return the fieldName view:
            fieldValueEntryLabel.hidden = true
            fieldValueAnalog.hidden = true
            fieldNameEntryLabel.hidden = false
            fieldNameTextField.hidden = false
            
            notificationsFeed.text = "'{Value}' has been sent to '{Field}'"
            fadeIn()
            fadeOut()
            
            textField.delegate = nil
            fieldNameTextField.delegate = self
            fieldNameTextField.becomeFirstResponder()
        }
        return true
    }
    
    func fadeIn() { //Fades in the twitter feed instantly
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.notificationsFeed.alpha = 1.0
            }, completion: nil)
    }
    
    func fadeOut() { //Gradually fades out the twitter feed
        UIView.animateWithDuration(1.0, delay: 4.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.notificationsFeed.alpha = 0.0
            }, completion: nil)
    }
    
    //MARK: - Check Users
    
    @IBAction func patientIconButtonClick(sender: AnyObject) {
        //Clicking this button highlights the button & displays a view, allowing the user to see the current patient & close the patient file if needed.
    }
    
    @IBAction func doctorIconButtonClick(sender: AnyObject) {
        //Clicking this button highlights the button & displays a view, allowing the user to see who the current HCP logged in is & logout if needed.
    }
    
    @IBAction func logoutButtonClick(sender: AnyObject) {
        //Clear out existing user defaults:
        //        let appDomain = NSBundle.mainBundle().bundleIdentifier
        //        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        print("Logout")
        loggedIn = false
    }
    
    //MARK: - User Authentication
    
    //Since this is the initial VC, we will redirect -> login screen from here if no user is logged in:
    var loggedIn : Bool = true { //When we want login functionality, set it to FALSE!!!
        didSet {
            if loggedIn == true {
                //Do nothing, go to DEM VC.
            } else {
                self.performSegueWithIdentifier("showLogin", sender: self) //go to login screen
            }
        }
    }
    
    //Delegate Method:
    func didLoginSuccessfully() {
        loggedIn = true //Sets the loginValue to true, which will call the 'configureView' function!
        dismissViewControllerAnimated(true, completion: nil) //When we first load the VC, the VC performs a segue & modally shows the login screen (it 'owns' that screen); when we call 'dismissVC' it dismisses the modally presented screen after authentication is complete.
    }
    
    //MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Before we segue, we want to set the delegate property only if the login VC is about to be shown:
        if segue.identifier == "showLogin" {
            let loginViewController = segue.destinationViewController as! LoginViewController
            loginViewController.delegate = self //we set the homescreen VC as the delegate of the LoginVC!
        }
    }
    
}