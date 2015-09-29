//  CurrentPatientPopupView.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/26/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Configure this class visually using IB!

import UIKit

class CurrentPatientPopupView: UIView {
    
    let currentPatient : Patient?
    var currentPatientLabel = UILabel()
    var closePatientFileButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addCustomView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCustomView() {
        //Show the current patient & offer the user the ability to close the patient file.
        currentPatientLabel.frame = CGRectMake(150, 300, 350, 50)
        currentPatientLabel.backgroundColor = UIColor.lightGrayColor()
        currentPatientLabel.textAlignment = NSTextAlignment.Center
        currentPatientLabel.minimumScaleFactor = 1.0
        currentPatientLabel.text = "Current Patient: \(currentPatient?.name)"
        self.addSubview(currentPatientLabel)
        
        closePatientFileButton.frame = CGRectMake(150, 400, 150, 50)
        closePatientFileButton.backgroundColor = UIColor.grayColor()
        closePatientFileButton.setTitle("Close File", forState: UIControlState.Normal)
        closePatientFileButton.addTarget(self, action: "closePatientFileButtonClick", forControlEvents: UIControlEvents.TouchUpInside) //Sets the button action click -> 'closePatientFileButtonClick' function
        self.addSubview(closePatientFileButton)
    }

    @IBAction func closePatientFileButtonClick() {
        
    }

}
