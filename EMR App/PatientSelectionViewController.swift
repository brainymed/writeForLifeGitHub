//  PatientSelectionViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 10/16/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

import UIKit

class PatientSelectionViewController: UIViewController {
    
    var currentPatient: Patient? = nil
    var currentUser: String?
    var fileWasOpenedOrCreated: String = "" //checks if new or existing patient file was opened
    var properNameFormat: Bool = false
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    //Keyboard Detection:
    var keyboardSizeArray: [CGFloat] = []
    var keyboardAppearedHasFired: Bool?
    var bluetoothKeyboardAttached: Bool = false //true = BT keyboard, false = no BT keyboard
    
    @IBOutlet weak var patientNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        patientNameTextField.becomeFirstResponder()
        
        //Add notifications the first time this view loads:
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChangedFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardAppeared:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) { //function is called AFTER the keyboard appears!
        //Check if starting keyboard is BT or normal (if the variable exists/has been set, then the keyboardAppeared action has fired & we know the initial keyboard is NOT BT.
        if (keyboardAppearedHasFired == nil) { //BT keyboard
            bluetoothKeyboardAttached = true
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
    
    //MARK: - Patient File Button Actions
    
    @IBAction func openPatientFileButtonClick(sender: AnyObject) {
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
        let trimmedName = patientNameTextField.text?.stringByTrimmingCharactersInSet(whitespaceSet)
        if (trimmedName != "") {
            properNameFormat = true
        } else {
            properNameFormat = false
        }
        if properNameFormat == true {
            patientNameTextField.resignFirstResponder()
            if (bluetoothKeyboardAttached == true) { //BT keyboard attached, segue -> DEM
                if let existingPatient = openPatientFile(trimmedName!) {
                    currentPatient = existingPatient
                    fileWasOpenedOrCreated = "opened"
                    performSegueWithIdentifier("showDEM", sender: self)
                } else { //no patient found for given name
                    patientNameTextField.becomeFirstResponder()
                    let alertController = UIAlertController(title: "Oops!", message: "No patient was found for the given name.", preferredStyle: .Alert)
                    let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
                    alertController.addAction(ok)
                    presentViewController(alertController, animated: true, completion: nil)
                }
            } else { //No BT keyboard, segue -> PCM
                if let existingPatient = openPatientFile(trimmedName!) {
                    currentPatient = existingPatient
                    fileWasOpenedOrCreated = "opened"
                    performSegueWithIdentifier("showPCM", sender: self)
                } else { //no patient found for given name
                    patientNameTextField.becomeFirstResponder()
                    let alertController = UIAlertController(title: "Oops.", message: "No patient was found for the given name.", preferredStyle: .Alert)
                    let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
                    alertController.addAction(ok)
                    presentViewController(alertController, animated: true, completion: nil)
                }
            }
        } else {
            patientNameTextField.becomeFirstResponder()
            print("Please enter a patient name.")
        }
    }
    
    @IBAction func createPatientFileButtonClick(sender: AnyObject) {
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
        let trimmedName = patientNameTextField.text?.stringByTrimmingCharactersInSet(whitespaceSet)
        if (trimmedName != "") {
            properNameFormat = true
        } else {
            properNameFormat = false
        }
        if properNameFormat == true {
            patientNameTextField.resignFirstResponder()
            if (bluetoothKeyboardAttached == true) { //BT keyboard attached, segue -> DEM
                if (openPatientFile(trimmedName!) != nil) { //patient already exists
                    patientNameTextField.becomeFirstResponder()
                    let alertController = UIAlertController(title: "Warning", message: "File already exists for this patient. Please open it.", preferredStyle: .Alert)
                    let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
                    alertController.addAction(ok)
                    presentViewController(alertController, animated: true, completion: nil)
                } else { //no patient found for given name
                    currentPatient = Patient(name: trimmedName!, insertIntoManagedObjectContext: managedObjectContext)
                    fileWasOpenedOrCreated = "created"
                    performSegueWithIdentifier("showDEM", sender: self)
                }
            } else { //No BT keyboard, segue -> PCM
                if (openPatientFile(trimmedName!) != nil) { //patient already exists
                    patientNameTextField.becomeFirstResponder()
                    let alertController = UIAlertController(title: "Warning", message: "File already exists for this patient. Please open it.", preferredStyle: .Alert)
                    let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
                    alertController.addAction(ok)
                    presentViewController(alertController, animated: true, completion: nil)
                } else { //no patient found for given name
                    currentPatient = Patient(name: trimmedName!, insertIntoManagedObjectContext: managedObjectContext)
                    fileWasOpenedOrCreated = "created"
                    performSegueWithIdentifier("showPCM", sender: self)
                }
            }
        } else {
            patientNameTextField.becomeFirstResponder()
            print("Please enter a patient name.")
        }
    }
    
    //MARK: - Keyboard Shortcuts
    
    override var keyCommands: [UIKeyCommand]? { //special Apple API for defining keyboard shortcuts
        let controlKey = UIKeyModifierFlags.Control
        let controlO = UIKeyCommand(input: "o", modifierFlags: [controlKey], action: "controlOKeyPressed:")
        let controlC = UIKeyCommand(input: "c", modifierFlags: [controlKey], action: "controlCKeyPressed:")
        return [controlO, controlC]
    }
    
    func controlOKeyPressed(command: UIKeyCommand) {
        openPatientFileButtonClick(self)
    }
    
    func controlCKeyPressed(command: UIKeyCommand) {
        createPatientFileButtonClick(self)
    }
    
    //MARK: - Navigation
    
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
