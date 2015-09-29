//Garbage Code that might come in handy later:

//MARK: - ViewController Drawing Code

override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    //Called when user touches the screen. This is the start of the drawing event, so reset swiped to 'false' b/c touch hasn't moved yet. Save the last touch location in 'lastPoint' so when the user starts drawing, you can keep track of where they started.
    swiped = false
    if let touch = touches.first {
        lastPoint = touch.locationInView(self.view)
    }
}

override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    //Set 'swiped' to true so we can keep track of whether there is currently a touch in progress. If the touch moves, it calls the helper function to draw a line (drawLineFrom) & updates the 'lastPoint' so that it has the value of the point you just left off:
    swiped = true
    if let touch = touches.first {
        let currentPoint = touch.locationInView(view)
        drawLineFrom(lastPoint, toPoint: currentPoint)
        lastPoint = currentPoint
    }
}

override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    //1st check if user is in middle of a swipe; if not, it means the user tapped the screen to draw a single point, so we just draw a single point. If the user was in the middle of a swipe, you don't need to do anything b/c the 'touchesMoved' function will have handled the drawing.
    if !swiped {
        //Draw a single point:
        drawLineFrom(lastPoint, toPoint: lastPoint)
    }
}

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