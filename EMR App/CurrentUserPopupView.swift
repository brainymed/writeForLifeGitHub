//  CurrentUserPopupView.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/26/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Configure this class visually using IB & hidden buttons/views!

import UIKit

class CurrentUserPopupView: UIView {
    
    var currentUser : String
    var currentUserLabel = UILabel()
    var logoutButton = UIButton()
    var changeEMRButton = UIButton() //offers user the ability to switch EMRs if they use multiple ones
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addCustomView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCustomView() { //Open popover showing who the current user is & offering option to logout or change EMR.
        //Show the 'current user' label:
        currentUserLabel.frame = CGRectMake(150, 300, 350, 50)
        currentUserLabel.backgroundColor = UIColor.lightGrayColor()
        currentUserLabel.textAlignment = NSTextAlignment.Center
        currentUserLabel.minimumScaleFactor = 1.0
        currentUserLabel.text = "Current User: \(currentUser)"
        self.addSubview(currentUserLabel)
        
        //Show the 'logout' button:
        logoutButton.frame = CGRectMake(150, 400, 150, 50)
        logoutButton.backgroundColor = UIColor.grayColor()
        logoutButton.setTitle("Logout", forState: UIControlState.Normal)
        logoutButton.addTarget(self, action: "logoutButtonClick", forControlEvents: UIControlEvents.TouchUpInside) //Sets the button action click -> 'logoutButtonClick' function
        self.addSubview(logoutButton)
        
        //Show the 'change EMR' button:
        changeEMRButton.frame = CGRectMake(150, 400, 150, 50)
        changeEMRButton.backgroundColor = UIColor.grayColor()
        changeEMRButton.setTitle("Close File", forState: UIControlState.Normal)
        changeEMRButton.addTarget(self, action: "closePatientFileButtonClick", forControlEvents: UIControlEvents.TouchUpInside) //Sets the button action click -> 'closePatientFileButtonClick' function
        self.addSubview(logoutButton)
    }
    
    @IBAction func logoutButtonClick() {
        
    }

}
