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
    func patientFileHasBeenOpened()
}

class PatientSelectionViewController: UIViewController, UITextFieldDelegate, EAAccessoryDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var delegate: PatientSelectionViewControllerDelegate? //Delegate Stored Property
    var currentPatient: Patient?
    var properNameFormat: Bool = false
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var bluetoothCentralManager = CBCentralManager()
    var keyboardSizeArray: [CGFloat] = []
    var keyboardAppearedHasFired: Bool?
    var bluetoothKeyboardAttached: Bool = false //true = BT keyboard, false = no BT keyboard
    
    @IBOutlet weak var patientNameTextField: UITextField!
    
    override var keyCommands: [UIKeyCommand]? {
        let controlKey = UIKeyModifierFlags.Control
        let shiftKey = UIKeyModifierFlags.Shift
        let commandA = UIKeyCommand(input: "a", modifierFlags: [controlKey, shiftKey], action: "controlAKeyPressed:") //detects keyboard commands
        let upArrow = UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: "upArrowKeyPressed:") //the modifierFlags array can contain 0 modifier flags or more than 1 (e.g. when creating a cmd + shift + "" shortcut
        return [commandA, upArrow]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        patientNameTextField.becomeFirstResponder()
        
        //Add notifications the first time this view loads:
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChangedFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardAppeared:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) { //function is called AFTER the keyboard appears!
        //Check if this picks up anything for Abhi's BT keyboard:
        //        let manager = EAAccessoryManager.sharedAccessoryManager()
        //        manager.registerForLocalNotifications()
        //        print("Connected Accessories: \(manager.connectedAccessories)")
        //        for accessory in manager.connectedAccessories {
        //            print("Name: \(accessory)")
        //        }
        //
        //        bluetoothCentralManager = CBCentralManager(delegate: self, queue: nil)
        //        bluetoothCentralManager.scanForPeripheralsWithServices(nil, options: nil)
        //        let peripheralArray = bluetoothCentralManager.retrieveConnectedPeripheralsWithServices([])
        //        let otherArray = bluetoothCentralManager.retrievePeripheralsWithIdentifiers([])
        //        print(peripheralArray)
        //        print(otherArray)
        
        //Check if starting keyboard is BT or normal (if the variable exists/has been set, then the keyboardAppeared action has fired & we know the initial keyboard is NOT BT.
        if (keyboardAppearedHasFired == nil) { //BT keyboard
            bluetoothKeyboardAttached = true
            print("BT Keyboard Attached? \(bluetoothKeyboardAttached)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            print("BT powered on")
        case CBCentralManagerState.PoweredOff:
            print("BT powered off")
        default:
            print("Default BT switch")
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
        keyboardAppearedHasFired = true //check for 1st time view appears
        let lastKeyboardSize = keyboardSizeArray.last
        let height: CGFloat = self.view.frame.size.height
        if (lastKeyboardSize > height) {
            bluetoothKeyboardAttached = true
        } else {
            bluetoothKeyboardAttached = false
        }
        keyboardSizeArray = [] //clear for next sequence
    }
    
    //MARK: - Custom Keyboard Shortcuts
    
    func controlAKeyPressed(command: UIKeyCommand) {
        print("User entered control + A")
    }
    
    func upArrowKeyPressed(command: UIKeyCommand) {
        print("User hit up arrow key")
    }
    
    //MARK: - Button Actions
    
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
            currentPatient = Patient(name: patientNameTextField.text!, insertIntoManagedObjectContext: managedObjectContext)
            if (bluetoothKeyboardAttached == true) { //BT keyboard attached, segue -> DEM
                self.delegate?.currentPatient = currentPatient
                self.delegate?.patientFileWasJustOpened = true
                self.delegate?.patientFileHasBeenOpened()
            } else { //No BT keyboard, segue -> PCM
                performSegueWithIdentifier("showPCM", sender: self)
            }
        } else {
            print("Enter patient name")
        }
    }
    
    @IBAction func createPatientFileButtonClick(sender: AnyObject) {
        if properNameFormat == true {
            patientNameTextField.resignFirstResponder()
            currentPatient = Patient(name: patientNameTextField.text!, insertIntoManagedObjectContext: managedObjectContext)
            if (bluetoothKeyboardAttached == true) { //BT keyboard attached, segue -> DEM
                self.delegate?.currentPatient = currentPatient
                self.delegate?.patientFileWasJustOpened = true
                self.delegate?.patientFileHasBeenOpened()
            } else { //No BT keyboard, segue -> PCM
                performSegueWithIdentifier("showPCM", sender: self)
            }
        } else {
            print("Enter patient name")
        }
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPCM") { //Pass current patient
            let patientCareModeViewController = (segue.destinationViewController as! PatientCareModeViewController)
            patientCareModeViewController.currentPatient = self.currentPatient
        }
    }
    
}
