//  PhysicalAndROSView.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/14/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Upon rotation, we want to - swap the image, hide certain buttons & reveal others, & reposition the rotation button from one side to the other. We will layer all of the buttons on the view & selectively hide them.
//Create Auto-Layout constraints programmatically!!!

import UIKit

class PhysicalAndROSView: UIView { //Create custom L side view containing the appropriate image & its buttons. Handle orientation appropriately.
    let index: Int //assign unique index to each image (used for rotating images)
    let viewChoice: String //check if the input query is for physical or ROS
    let gender: Int //check if the currentPatient is male or female (0 = male & 1 = female)
    let childOrAdult: Int //check if patient is child or adult (0 = adult & 1 = child)
    var imageName: String
    var rotation: Bool //checks if rotation has occurred
    let orientation: Int = 0 //landscape = 0 (default), portrait = 1
    
    let rotationButton = UIButton()
    let generalAppearanceButton = UIButton()
    let neurologicalSystemButton = UIButton()
    let headAndNeckButton = UIButton()
    let cardiovascularSystemButton = UIButton()
    let respiratorySystemButton = UIButton()
    let gastrointestinalSystemButton = UIButton()
    let genitourinarySystemButton = UIButton()
    let peripheralVascularSystemButton = UIButton()
    let breastButton = UIButton()
    let spineAndBackButton = UIButton()
    let renalSystemButton = UIButton()
    
    let bodyImageView = UIImageView()
    
    init(viewChoice: String, gender: Int, childOrAdult: Int) {
        self.viewChoice = viewChoice
        self.gender = gender
        self.childOrAdult = childOrAdult
        self.rotation = false
        
        //Pick starting image for the view:
        if self.childOrAdult == 0 { //Patient is an adult
            if self.gender == 0 { //Male adult {1}
                self.index = 1
                self.imageName = "adult_male_outline_front.png"
            } else { //Female adult {2}
                self.index = 2
                self.imageName = "adult_female_outline_front.png"
            }
        } else { //Patient is a child
            if self.gender == 0 { //Male child {3}
                self.index = 3
                self.imageName = "child_male_outline_front.png"
            } else { //Female child {4}
                self.index = 4
                self.imageName = "child_female_outline_front.png"
            }
        }
        
        super.init(frame: CGRect(x: 60, y: 100, width: 200, height: 619)) //only called super.init AFTER initializing instance variables
        self.backgroundColor = UIColor.lightGrayColor()
        self.addSubview(bodyImageView)
        self.bodyImageView.frame = self.bounds
        self.bodyImageView.image = UIImage(named: self.imageName)!
        
        //Rotation button view & action:
        rotationButton.frame = CGRectMake(10, 10, 35, 35)
        rotationButton.setImage(UIImage(named: "rotate.png"), forState: UIControlState.Normal)
        rotationButton.addTarget(self, action: "rotateButtonClick:", forControlEvents: UIControlEvents.TouchUpInside) //Sets the button action click -> 'rotateButtonClick' function
        self.insertSubview(rotationButton, aboveSubview: bodyImageView)
        
        //generalAppearance button view & action:
        generalAppearanceButton.frame = CGRectMake(60, 60, 55, 35)
        generalAppearanceButton.setTitle("General", forState: UIControlState.Normal)
        generalAppearanceButton.backgroundColor = UIColor.redColor()
        generalAppearanceButton.alpha = 0.45
        generalAppearanceButton.addTarget(self, action: "generalAppearanceButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        self.insertSubview(generalAppearanceButton, aboveSubview: bodyImageView)
        
        //neuroSystem button view & action:
        neurologicalSystemButton.frame = CGRectMake(100, 100, 55, 35)
        neurologicalSystemButton.setTitle("Neuro", forState: UIControlState.Normal)
        neurologicalSystemButton.backgroundColor = UIColor.redColor()
        neurologicalSystemButton.alpha = 0.45
        neurologicalSystemButton.addTarget(self, action: "neurologicalSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        self.insertSubview(neurologicalSystemButton, aboveSubview: bodyImageView)
        
        //CV system button view & action:
        cardiovascularSystemButton.frame = CGRectMake(100, 200, 55, 35)
        cardiovascularSystemButton.setTitle("CV", forState: UIControlState.Normal)
        cardiovascularSystemButton.backgroundColor = UIColor.redColor()
        cardiovascularSystemButton.alpha = 0.45
        cardiovascularSystemButton.addTarget(self, action: "cardiovascularSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        self.insertSubview(cardiovascularSystemButton, aboveSubview: bodyImageView)
        
        //respiratorySystem button view & action:
        respiratorySystemButton.frame = CGRectMake(100, 300, 55, 35)
        respiratorySystemButton.setTitle("Lungs", forState: UIControlState.Normal)
        respiratorySystemButton.backgroundColor = UIColor.redColor()
        respiratorySystemButton.alpha = 0.45
        respiratorySystemButton.addTarget(self, action: "respiratorySystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        self.insertSubview(respiratorySystemButton, aboveSubview: bodyImageView)
    }
    
    required init?(coder aDecoder: NSCoder) { //called when view is reconstituted from nib???
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Handle Image Rotation
    
    func rotateButtonClick(sender: UIButton) { //Renders rotated image
        bodyImageView.image = getRotatedImageFile()
    }
    
    func getRotatedImageFile() -> UIImage { //Checks current rotation status & returns the opposite image for the set
        var newImageName = String()
        if self.rotation == false { //Rotation from front -> back
            self.rotation = true
            switch self.index {
            case 1:
                newImageName = "adult_male_outline_back.png"
            case 2:
                newImageName = "adult_female_outline_back.png"
            case 3:
                newImageName = "child_male_outline_back.png"
            case 4:
                newImageName = "child_female_outline_back.png"
            default: //This case should never be triggered!
                newImageName = ""
            }
        } else { //Rotation from back -> front
            self.rotation = false
            switch self.index {
            case 1:
                newImageName = "adult_male_outline_front.png"
            case 2:
                newImageName = "adult_female_outline_front.png"
            case 3:
                newImageName = "child_male_outline_front.png"
            case 4:
                newImageName = "child_female_outline_front.png"
            default: //This case should never be triggered!
                newImageName = ""
            }
        }
        return UIImage(named: newImageName)!
    }
    
    //MARK: - Button Actions
    
    func generalAppearanceButtonClick(sender: UIButton) {
    }
    
    func headAndNeckButtonClick(sender: UIButton) {
    }
    
    func neurologicalSystemButtonClick(sender: UIButton) {
    }
    
    func cardiovascularSystemButtonClick(sender: UIButton) {
    }
    
    func respiratorySystemButtonClick(sender: UIButton) {
    }
    
    func gastrointestinalSystemButtonClick(sender: UIButton) {
    }
    
    func genitourinarySystemButtonClick(sender: UIButton) {
    }
    
    func renalSystemButtonClick(sender: UIButton) {
    }
    
    func breastButtonClick(sender: UIButton) {
    }
    
    func spineAndBackButtonClick(sender: UIButton) {
    }
    
    func peripheralVascularSystemButtonClick(sender: UIButton) {
    }

}