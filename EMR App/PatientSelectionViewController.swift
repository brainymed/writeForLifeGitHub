//  PatientSelectionViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 10/16/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

import UIKit
import ExternalAccessory
import CoreBluetooth

protocol PatientSelectionViewControllerDelegate {
    //This delegate acts as follows: when the user selects a patient, we dismiss the patient selection screen, return to the home screen, & set the currentPatient. This protocol has 1 required property (currentPatient) & 1 method which is called when we select a patient.
    var currentPatient: Patient? { get set }
    var patientFileWasJustOpened: Bool { get set } //marker for display of notification
    var fileWasOpenedOrCreated: String { get set } //checks if file was opened or created
    func patientFileHasBeenOpened()
}

class PatientSelectionViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: PatientSelectionViewControllerDelegate? //Delegate Stored Property
    var currentPatient: Patient?
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool { //Disable button press if the textField is empty
        let length = (textField.text?.characters.count)! - range.length + string.characters.count
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
        if ((length > 0) && (textField.text?.stringByTrimmingCharactersInSet(whitespaceSet) != "")) {
            properNameFormat = true
        } else {
            properNameFormat = false
        }
        return true
    }
    
    @IBAction func openPatientFileButtonClick(sender: AnyObject) {
        if properNameFormat == true {
            patientNameTextField.resignFirstResponder()
            if (bluetoothKeyboardAttached == true) { //BT keyboard attached, follow delegate -> DEM
                if let existingPatient = openPatientFile(patientNameTextField.text!) {
                    currentPatient = existingPatient
                    self.delegate?.currentPatient = currentPatient
                    self.delegate?.patientFileWasJustOpened = true
                    self.delegate?.fileWasOpenedOrCreated = "opened"
                    self.delegate?.patientFileHasBeenOpened()
                } else { //no patient found for given name
                    patientNameTextField.becomeFirstResponder()
                }
            } else { //No BT keyboard, segue -> PCM
                if let existingPatient = openPatientFile(patientNameTextField.text!) {
                    currentPatient = existingPatient
                    performSegueWithIdentifier("showPCM", sender: self)
                } else { //no patient found for given name
                    patientNameTextField.becomeFirstResponder()
                }
            }
        } else {
            print("Enter patient name")
            patientNameTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func createPatientFileButtonClick(sender: AnyObject) {
        if properNameFormat == true {
            patientNameTextField.resignFirstResponder()
            currentPatient = Patient(name: patientNameTextField.text!, insertIntoManagedObjectContext: managedObjectContext)
            if (bluetoothKeyboardAttached == true) { //BT keyboard attached, follow delegate -> whichever view was used to close the patient file
                self.delegate?.currentPatient = currentPatient
                self.delegate?.patientFileWasJustOpened = true
                self.delegate?.fileWasOpenedOrCreated = "created"
                self.delegate?.patientFileHasBeenOpened()
            } else { //No BT keyboard, segue -> PCM
                performSegueWithIdentifier("showPCM", sender: self)
            }
        } else {
            patientNameTextField.becomeFirstResponder()
            print("Enter patient name")
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
            patientCareModeViewController.currentPatient = self.currentPatient
        }
    }
    
}
