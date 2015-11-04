//  PatientSelectionViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 10/16/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

import UIKit

class PatientSelectionViewController: UIViewController, UITextFieldDelegate {
    
    var currentPatient: Patient? = nil
    var currentUser: String?
    let preferences: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var fileWasOpenedOrCreated: String = "" //checks if new or existing patient file was opened
    var properNameFormat: Bool = false
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var openPatientFileButton: UIButton!
    @IBOutlet weak var createPatientFileButton: UIButton!
    @IBOutlet weak var patientNameTextField: UITextField!
    @IBOutlet weak var orLabel: UILabel!
    
    //Keyboard Detection:
    var keyboardSizeArray: [CGFloat] = []
    var keyboardAppearedHasFired: Bool?
    var bluetoothKeyboardAttached: Bool = false //true = BT keyboard, false = no BT keyboard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openPatientFileButton.layer.cornerRadius = 10.0 //round button edges
        createPatientFileButton.layer.cornerRadius = 10.0 //round button edges
        patientNameTextField.delegate = self
        
        //Add notifications the first time this view loads:
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChangedFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardAppeared:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        defaultViewConfiguration(preferences.objectForKey("PROVIDER_TYPE") as! String)
    }
    
    override func viewDidAppear(animated: Bool) { //function is called AFTER the keyboard appears!
    }
    
    //MARK: - View Configuration
    
    func defaultViewConfiguration(provider: String) {
        //Check what "PROVIDER_TYPE" of the user is: "Front Office", "Nurse", or "Physician"
        //let viewsDictionary = ["openButton": openPatientFileButton, "createButton": createPatientFileButton, "orLabel": orLabel, "textField": patientNameTextField]
        switch provider {
        case "Front Office": //show both buttons in Storyboard-defined layout
            //Programmatically add constraints to buttons (height & width of all objects is already set):
            print("")
        case "Nurse":
            createPatientFileButton.hidden = true
            orLabel.hidden = true
//            let openButton_constraint_vertical = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[openButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
//            let openButton_constraint_hCenter = NSLayoutConstraint(item: openPatientFileButton, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
//            view.addConstraints(openButton_constraint_vertical)
//            view.addConstraint(openButton_constraint_hCenter)
            //How do we reset the view after the user closes a file?
        case "Physician":
            createPatientFileButton.hidden = true
            orLabel.hidden = true
        default:
            print("Error - defaultViewConfig default switch statement")
        }
    }
    
    //MARK: - Patient File Button Actions
    
    func restoreDefaultView() {
        openPatientFileButton.highlighted = false
        createPatientFileButton.highlighted = false
        openPatientFileButton.alpha = 1.0
        openPatientFileButton.enabled = true
        createPatientFileButton.alpha = 1.0
        createPatientFileButton.enabled = true
        patientNameTextField.hidden = true
        patientNameTextField.resignFirstResponder()
    }
    
    @IBAction func openPatientFileButtonClick(sender: AnyObject) { //reveal the text field.
        openPatientFileButton.highlighted = true
        createPatientFileButton.alpha = 0.3
        createPatientFileButton.enabled = false
        patientNameTextField.hidden = false
        patientNameTextField.becomeFirstResponder()
    }
    
    @IBAction func createPatientFileButtonClick(sender: AnyObject) {
        //On button click, configures view for entry of a new patient. Present the required information in the first screen & optional information in the second screen, allow movement between screens using the arrow keys. Check if there is a keyboard attached, & if not, ask user to attach one.
        createPatientFileButton.highlighted = true
        openPatientFileButton.alpha = 0.3
        openPatientFileButton.enabled = false
        patientNameTextField.becomeFirstResponder()
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "delayedKeyboardCheck:", userInfo: nil, repeats: false) //check before transition if user has BT keyboard, first twice for some reason
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Clear button behaviors when touch occurs not on button:
        if !(openPatientFileButton.touchInside) || !(createPatientFileButton.touchInside) {
            restoreDefaultView()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        restoreDefaultView()
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
        let trimmedName = patientNameTextField.text?.stringByTrimmingCharactersInSet(whitespaceSet)
        if (trimmedName != "") {
            properNameFormat = true
        } else {
            properNameFormat = false
        }
        if properNameFormat == true {
            patientNameTextField.resignFirstResponder()
            if (bluetoothKeyboardAttached == true) { //BT keyboard attached, segue -> FOM or DEM
                if (preferences.objectForKey("PROVIDER_TYPE") as! String == "Front Office") {
                    //Configure FOM for modifying patient's documents:
                    performSegueWithIdentifier("showFOM", sender: self)
                    return true
                } else {
                    currentPatient = Patient(firstName: "a", lastName: "p", gender: Gender.Male, dob: NSDate(dateString: "11/23/1992"), insertIntoManagedObjectContext: managedObjectContext)
                    performSegueWithIdentifier("showDEM", sender: self)
                    return true
                }
                
                //                if let existingPatient = openPatientFile(trimmedName!) {
                //                    currentPatient = existingPatient
                //                    fileWasOpenedOrCreated = "opened"
                //                    performSegueWithIdentifier("showDEM", sender: self)
                //                    return true
                //                } else { //no patient found for given name
                //                    patientNameTextField.becomeFirstResponder()
                //                    let alertController = UIAlertController(title: "Oops!", message: "No patient was found for the given name.", preferredStyle: .Alert)
                //                    let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
                //                    alertController.addAction(ok)
                //                    presentViewController(alertController, animated: true, completion: nil)
                //                    return false
                //                }
            } else { //No BT keyboard, segue -> PCM
                if let existingPatient = openPatientFile(trimmedName!) {
                    currentPatient = existingPatient
                    fileWasOpenedOrCreated = "opened"
                    performSegueWithIdentifier("showPCM", sender: self)
                    return true
                } else { //no patient found for given name
                    patientNameTextField.becomeFirstResponder()
                    let alertController = UIAlertController(title: "Oops.", message: "No patient was found for the given name.", preferredStyle: .Alert)
                    let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
                    alertController.addAction(ok)
                    presentViewController(alertController, animated: true, completion: nil)
                    return false
                }
            }
        } else {
            patientNameTextField.becomeFirstResponder()
            print("Please enter a patient name.")
            return false
        }
    }
    
    //MARK: - Keyboard Tracking
    
    func keyboardChangedFrame(notification: NSNotification) { //fires when keyboard changes
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardFrame: CGRect = (userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue)!
        let keyboard: CGRect = self.view.convertRect(keyboardFrame, fromView: self.view.window)
        let sum = keyboard.origin.y + keyboard.size.height
        keyboardSizeArray.append(sum)
    }
    
    func keyboardAppeared(notification: NSNotification) {
        keyboardAppearedHasFired = true //check variable for 1st time view appears
        let lastKeyboardSize = keyboardSizeArray.last
        let height: CGFloat = self.view.frame.size.height
        if (lastKeyboardSize > height) {
            bluetoothKeyboardAttached = true
        } else {
            bluetoothKeyboardAttached = false
        }
        keyboardSizeArray = [] //clear for next sequence
    }
    
    func delayedKeyboardCheck(timer: NSTimer) { //fires after delay
        if (shouldPerformSegueWithIdentifier("showFOM", sender: self)) {
            performSegueWithIdentifier("showFOM", sender: self)
        } else {
            patientNameTextField.resignFirstResponder()
            let alertController = UIAlertController(title: "Warning", message: "Please enter a bluetooth keyboard before proceeding.", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
            alertController.addAction(ok)
            presentViewController(alertController, animated: true, completion: nil)
        }
        restoreDefaultView()
    }
    
    //MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "showFOM") {
            if (bluetoothKeyboardAttached == true) {
                return true
            } else {
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPCM") { //Pass current patient
            let patientCareModeViewController = (segue.destinationViewController as! PatientCareModeViewController)
            patientCareModeViewController.currentUser = self.currentUser
            patientCareModeViewController.currentPatient = self.currentPatient
            patientCareModeViewController.patientFileWasJustOpened = true
            patientCareModeViewController.fileWasOpenedOrCreated = self.fileWasOpenedOrCreated
        } else if (segue.identifier == "showDEM") { //-> data entry mode
            let tabBarViewController = (segue.destinationViewController as! TabBarViewController)
            let dataEntryModeViewController = (tabBarViewController.viewControllers![0]) as! DataEntryModeViewController
            dataEntryModeViewController.currentUser = self.currentUser
            dataEntryModeViewController.currentPatient = self.currentPatient
            dataEntryModeViewController.patientFileWasJustOpened = true //marker for notification display
            dataEntryModeViewController.fileWasOpenedOrCreated = self.fileWasOpenedOrCreated
            dataEntryModeViewController.transitionedToDifferentView = false
        }
    }
    
}
