//  PhysicalAndROSView.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/14/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

//Create Auto-Layout constraints programmatically!!!
//Should we set the view to nil after it is closed out? What if user wants to enter some info, leave & then come back. All saved information will be erased. At what point do we set the object to nil???

//This class should handle all communication between its sub-views (bodyIV & dataEntryView).

import UIKit

class PhysicalAndROSView: UIView { //Handle orientation & rotation appropriately.
    
    let applicationMode: String //check if class object was created by DEM or PCM, render view accordingly
    let viewChoice: String //check if the input query is for physical or ROS
    let gender: Int //check if the currentPatient is male or female (0 = male & 1 = female)
    let childOrAdult: Int //check if patient is child or adult (0 = adult & 1 = child)
    
    let bodyImageView: HumanBodyImageView
    var dataEntryView: PhysicalAndROSDataEntryView
    
    init(applicationMode: String, viewChoice: String, gender: Int, childOrAdult: Int) {
        self.applicationMode = applicationMode
        self.viewChoice = viewChoice
        self.gender = gender
        self.childOrAdult = childOrAdult
        
        bodyImageView = HumanBodyImageView(viewChoice: self.viewChoice, gender: self.gender, childOrAdult: self.childOrAdult)
        dataEntryView = PhysicalAndROSDataEntryView(applicationMode: self.applicationMode, viewChoice: self.viewChoice)

        super.init(frame: CGRect(x: 60, y: 100, width: 964, height: 619)) //only call super.init AFTER initializing instance variables, set frame to length of screen (minus the margins) dynamically
        
        //Add imageView & dataEntryView:
        self.addSubview(bodyImageView)
        self.addSubview(dataEntryView)
    }
    
    required init?(coder aDecoder: NSCoder) { //called when view is reconstituted from nib???
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper Functions
    
    internal func clearPhysicalAndROSView() {
        for subview in dataEntryView.subviews { //clears dataEntryView subviews
            subview.removeFromSuperview() //remove or delete?
        }
        bodyImageView.hidden = true
    }
    
    internal func renderDefaultView() { //resets the Px/ROS view to default
        dataEntryView.returnToDefaultDataEntryView()
    }
    
    //MARK: - Communication Functions
    
    internal func passButtonActionToDataEntryView(sender: PhysicalAndROSOrganSystemButton) {
        //Passes button tap from bodyIV -> dataEntryView:
        dataEntryView.renderDataEntryViewForOrganSystemButton(sender)
    }
    
    internal func passButtonVisualConfigurationToBodyImageView(sender: PhysicalAndROSOrganSystemButton) {
        //Sends message to bodyIV -> highlight the indicate button green b/c info has been entered:
        bodyImageView.configureButtonVisualsOnSelection(sender)
    }

}