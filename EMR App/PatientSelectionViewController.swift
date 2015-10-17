//  PatientSelectionViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 10/16/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

import UIKit

protocol PatientSelectionViewControllerDelegate {
    //This delegate acts as follows: when the user selects a patient, we dismiss the patient selection screen, return to the home screen, & set the currentPatient. This protocol has 1 required property (currentPatient) & 1 method which is called when we select a patient.
    var currentPatient: Patient? { get set }
    var patientFileWasJustOpened: Bool { get set } //marker for display of notification
    func patientFileHasBeenOpened()
}

class PatientSelectionViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: PatientSelectionViewControllerDelegate? //Delegate Stored Property
    var currentPatient: Patient?
    var properNameFormat: Bool = false
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var patientNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        patientNameTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
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
            self.delegate?.currentPatient = currentPatient
            self.delegate?.patientFileWasJustOpened = true
            self.delegate?.patientFileHasBeenOpened()
        } else {
            print("Enter patient name")
        }
    }
    
    @IBAction func createPatientFileButtonClick(sender: AnyObject) {
        if properNameFormat == true {
            patientNameTextField.resignFirstResponder()
            currentPatient = Patient(name: patientNameTextField.text!, insertIntoManagedObjectContext: managedObjectContext)
            self.delegate?.currentPatient = currentPatient
            self.delegate?.patientFileWasJustOpened = true
            self.delegate?.patientFileHasBeenOpened()
        } else {
            print("Enter patient name")
        }
    }
    
}
