//  PatientNameEntryView.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/14/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Whenever a view is loaded, after the program checks if the user is logged in, it will check if a patient file is opened. If no 'currentPatient' is found, this view will pop over the open view and force the user to either enter an existing patient's name & open the file or create a new file. In order for this view to be rendered, it must be called (in the VC) as a sub-view of the master view!
// See the DataEntryModeVC for example of implementation

import UIKit

class PatientNameEntryView: UIView {
    
    var textField : UITextField = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addCustomView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCustomView() {
        //Label asking user to input patient name:
//        let label = UILabel()
//        label.frame = CGRectMake(150, 300, 350, 50)
//        label.backgroundColor = UIColor.lightGrayColor()
//        label.textAlignment = NSTextAlignment.Center
//        label.minimumScaleFactor = 1.0
//        label.text = "Open an Existing File or Create a New File"
//        self.addSubview(label)
//        
//        //Text Field where user can enter patient name:
//        textField.frame = CGRectMake(525, 300, 300, 50)
//        textField.backgroundColor = UIColor.lightGrayColor()
//        textField.textColor = UIColor.blueColor()
//        self.addSubview(textField)
//        textField.becomeFirstResponder() //Automatically places cursor inside text box
//        
//        //2 Buttons, 1 for opening an existing file, 1 for creating a new one:
//        let createNewButton = UIButton()
//        let openExistingButton = UIButton()
//        createNewButton.frame = CGRectMake(150, 400, 150, 50)
//        openExistingButton.frame = CGRectMake(525, 400, 150, 50)
//        createNewButton.backgroundColor = UIColor.grayColor()
//        openExistingButton.backgroundColor = UIColor.grayColor()
//        createNewButton.setTitle("Create New File", forState: UIControlState.Normal)
//        createNewButton.addTarget(self, action: "createNewPatientFile", forControlEvents: UIControlEvents.TouchUpInside) //Sets the button action click -> 'createNewPatientFile' function
//        openExistingButton.setTitle("Open Patient File", forState: .Normal)
//        openExistingButton.addTarget(self, action: "openExistingPatientFile", forControlEvents: .TouchUpInside)
//        self.addSubview(createNewButton)
//        self.addSubview(openExistingButton)
    }
    
    //MARK: - Button Actions
    
    @IBAction func createNewPatientFile() {
        //Set current patient (in the super view) for the name entered, then dismiss the 'PatientNameEntry' View & bring up the normal data entry view:
        let patientName = textField.text
        print("Created New Patient File for \(patientName)")
    }
    
    @IBAction func openExistingPatientFile() {
        //Check if the patient name that was entered matches an existing patient. If so, set 'currentPatient' (in the super view) for the name entered, then dismiss the 'PatientNameEntry' View & bring up the normal data entry view:
        let patientName = textField.text
        if (false) { //If entered name matches existing patient
            print("Opened Patient File for \(patientName)")
        } else { // If entered name does not match existing patient, clear view & ask them to re-enter
            //Generate an alert for the user: []
            textField.text = ""
        }
    }
}
