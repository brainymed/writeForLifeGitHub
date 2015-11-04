//  PhysicalAndROSDataEntryView.swift
//  EMR App
//  Created by Arnav Pondicherry  on 11/2/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// This class encapsulates all functionality for the dataEntryView in the Physical&ROSView.

import UIKit

protocol PhysicalAndROSDelegate {
    //This delegate acts as follows: when the user hits the 'Close View' button, it calls a function in the delegate (DEM & PCMVC) that renders the view appropriately!
    func physicalOrROSViewWasClosed()
}

class PhysicalAndROSDataEntryView: UIView {
    
    var delegate: PhysicalAndROSDelegate? //Delegate Stored Property
    
    let applicationMode: String
    let viewChoice: String
    var currentVisibleSection: Int //used to keep track of which sub-section of the view is open
    var openOrganSystemButton: PhysicalAndROSOrganSystemButton? //whichever button was selected
    var physicalAndROSView: PhysicalAndROSView? //reference to superview
    
    //Default Views:
    var organSystemSelectionTextField = UITextField()
    var dataEntryInstructionsLabel = UILabel()
    var titleLabel = UILabel()
    var closeViewButton = UIButton()
    
    //Custom Views:
    var organSystemTitleLabel = UILabel()
    var sectionTitleLabel = UILabel ()
    var escapeButton = UIButton()
    var nextSectionButton = UIButton()
    var lastSectionButton = UIButton()
    var buttonCollectionView = UIView() //view that holds selected 'findingButton's
    
    //MARK: - Initializers
    
    init(applicationMode: String, viewChoice: String) {
        self.applicationMode = applicationMode
        self.viewChoice = viewChoice
        self.currentVisibleSection = 0
        
        super.init(frame: CGRect(x: 200, y: 0, width: 764, height: 619)) //only call super.init AFTER initializing instance variables
        
        renderDefaultDataEntryView() //true == first time view is being rendered
    }
    
    required init?(coder aDecoder: NSCoder) { //called when view is reconstituted from nib???
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Default View Rendering
    
    func renderDefaultDataEntryView() {
        //Configure view:
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor(red: 0, green: 0.25, blue: 0.40, alpha: 1.0)
        
        self.addSubview(configureViewTitleLabel())
        self.addSubview(configureDataEntryInstructionsLabel())
        self.addSubview(configureCloseViewButton())
        self.addSubview(configureOrganSystemSelectionTextField())
    }
    
    func configureViewTitleLabel() -> UILabel {
        titleLabel.frame = CGRect(x: 280, y: 10, width: 230, height: 40)
        titleLabel.font = UIFont.boldSystemFontOfSize(18)
        if (self.viewChoice == "physicalExam") {
            titleLabel.text = "Physical Exam View"
        } else {
            titleLabel.text = "Review of Systems View"
        }
        titleLabel.textColor = UIColor.whiteColor()
        //        let title_constraint_hCenter = NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        //        self.addConstraint(title_constraint_hCenter)
        return titleLabel
    }
    
    func configureDataEntryInstructionsLabel() -> UILabel {
        dataEntryInstructionsLabel.frame = CGRect(x: 150, y: 140, width: 500, height: 200)
        dataEntryInstructionsLabel.textAlignment = NSTextAlignment.Center
        dataEntryInstructionsLabel.numberOfLines = 7
        dataEntryInstructionsLabel.backgroundColor = UIColor.whiteColor()
        
        if (viewChoice == "physicalExam") { //PX label & abbreviations
            dataEntryInstructionsLabel.text = "Type in the abbreviation for an organ system or tap on the corresponding button to the left.\n Abbreviations: Constitutional = C, Neuro = N, Psych = P, Head & Neck = HN, Eyes = EY, Ears/Nose/Mouth/Throat = ENMT, Heart = H, Lungs = L, GI = GI, GU = GU, Musculoskeletal = MS, Breast = BR, Chaperone = CH, Rectal = RE, Back = B, Skin = SK."
        } else { //ROS label & abbreviations
            dataEntryInstructionsLabel.text = "Type in the abbreviation for an organ system or tap on the corresponding button to the left.\n Abbreviations: Constitutional = C, Neuro = N, Psych = P, Eyes = EY, Ears/Nose/Mouth/Throat = ENMT, Cardiovascular = CV, Respiratory = R, GI = GI, GU = GU, Musculoskeletal = MS, Integumentary = IN, Hematologic/Lymphatic = HL, Allergic/Immunologic = AI, Endocrine = EN."
        }
        return dataEntryInstructionsLabel
    }
    
    func configureOrganSystemSelectionTextField() -> UITextField {
        organSystemSelectionTextField.frame = CGRect(x: 150, y: 350, width: 500, height: 50)
        organSystemSelectionTextField.userInteractionEnabled = true
        organSystemSelectionTextField.backgroundColor = UIColor.whiteColor()
        organSystemSelectionTextField.tag = 200 //assign unique tag for 'return' behavior config
        organSystemSelectionTextField.becomeFirstResponder()
        organSystemSelectionTextField.placeholder = "Enter an organ system abbreviation and hit 'Return'"
        organSystemSelectionTextField.addTarget(self, action: "textFieldWasTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        return organSystemSelectionTextField
    }
    
    func configureCloseViewButton() -> UIButton { //button for escaping Px or ROS view
        closeViewButton.frame = CGRect(x: 600, y: 50, width: 120, height: 30)
        closeViewButton.setTitle("Close View", forState: UIControlState.Normal)
        closeViewButton.addTarget(self, action: "closeViewButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        closeViewButton.backgroundColor = UIColor.blackColor()
        return closeViewButton
    }
    
    //MARK: - Default Button Actions
    
    func closeViewButtonClick(sender: UIButton) {
        //Remove views from main view & return the app to the default view (depends on application mode)
        if (self.applicationMode == "DEM") {
            obtainReferenceToSuperview()
            self.superview?.removeFromSuperview() //removes the Px & ROS View (remove or delete?)
            self.delegate?.physicalOrROSViewWasClosed() //configure DEM for fieldName w/ delegate method
        } else if (self.applicationMode == "PCM") {
            //
        }
    }
    
    //MARK: - Custom View Rendering
    
    func renderDataEntryViewForOrganSystemButton(sender: PhysicalAndROSOrganSystemButton) {
        openOrganSystemButton = sender //set the openButton indicator
        
        //Remove the human body from view & take the whole screen to render the interface:
        obtainReferenceToSuperview()
        physicalAndROSView?.clearPhysicalAndROSView() //hides bodyIV & removes subviews from dataEntryV
        
        //Redraw the dataEntryView to take up the entire screen:
        self.frame = CGRect(x: 0, y: 0, width: 964, height: 619)
        
        //Add subviews:
        self.addSubview(configureEscapeButton())
        self.addSubview(configureViewTitleLabel())
        self.addSubview(configureOrganSystemTitleLabel((sender.titleLabel?.text)!))
        if let sectionTitle = configureSectionTitleLabel() { //optional section label
            self.addSubview(sectionTitle)
        }
        self.addSubview(configureButtonCollectionView())
        
        let sectionsArray = openOrganSystemButton!.sectionsArray!
        if (sectionsArray.count != 1) {
            self.addSubview(configureNextSectionButton())
            self.addSubview(configureLastSectionButton())
        }
        
        //Create buttons for each label, matched to the sections, present 1 section @ a time:
        generateArrayOfButtonTitles()
    }
    
    func configureOrganSystemTitleLabel(system: String) -> UILabel {
        organSystemTitleLabel.frame = CGRect(x: 350, y: 70, width: 200, height: 40)
        organSystemTitleLabel.text = system
        organSystemTitleLabel.textColor = UIColor.whiteColor()
        return organSystemTitleLabel
    }
    
    func configureSectionTitleLabel() -> UILabel? { //section = sub-part of an organ system
        sectionTitleLabel.frame = CGRect(x: 350, y: 120, width: 220, height: 40)
        let sectionsArray = openOrganSystemButton!.sectionsArray!
        if (sectionsArray.count > 1) { //only render the label if there is more than 1 section
            sectionTitleLabel.text = sectionsArray[currentVisibleSection] //grab items from open button's section array
            sectionTitleLabel.adjustsFontSizeToFitWidth = true
        } else { //empty section title (or just remove the label altogether?)
            return nil
        }
        sectionTitleLabel.textColor = UIColor.whiteColor()
        return sectionTitleLabel
    }
    
    func configureEscapeButton() -> UIButton {
        escapeButton.frame = CGRect(x: 50, y: 50, width: 80, height: 30)
        escapeButton.setTitle("Escape", forState: UIControlState.Normal)
        escapeButton.addTarget(self, action: "escapeButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        escapeButton.backgroundColor = UIColor.blackColor()
        return escapeButton
    }
    
    func configureNextSectionButton() -> UIButton {
        nextSectionButton.frame = CGRect(x: 750, y: 50, width: 120, height: 30)
        nextSectionButton.setTitle("Next Section", forState: UIControlState.Normal)
        nextSectionButton.addTarget(self, action: "nextSectionButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        nextSectionButton.backgroundColor = UIColor.blackColor()
        return nextSectionButton
    }
    
    func configureLastSectionButton() -> UIButton {
        lastSectionButton.frame = CGRect(x: 150, y: 50, width: 120, height: 30)
        lastSectionButton.enabled = false //default is not enabled b/c we start on the first section
        lastSectionButton.alpha = 0.5
        lastSectionButton.setTitle("Previous Section", forState: UIControlState.Normal)
        lastSectionButton.addTarget(self, action: "lastSectionButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        lastSectionButton.backgroundColor = UIColor.blackColor()
        lastSectionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        return lastSectionButton
    }
    
    func configureButtonCollectionView() -> UIView {
        buttonCollectionView.frame = CGRect(x: 610, y: 160, width: 300, height: 350)
        buttonCollectionView.backgroundColor = UIColor.lightGrayColor()
        return buttonCollectionView
    }
    
    func generateArrayOfButtonTitles() { //create buttons on bottom of view for each section
        let labelsDict = openOrganSystemButton!.labelsArray!
        let sectionsArray = openOrganSystemButton!.sectionsArray!
        var labelsArray: [[String]] = [] //array containing an array of each section's labels
        for section in sectionsArray {
            let array = labelsDict[section] as! [String]
            labelsArray.append(array)
        }
        generateButtonsWithFindings(labelsArray)
    }
    
    private func generateButtonsWithFindings(buttonTitlesArray: [[String]]) {
        let currentSectionTitles = buttonTitlesArray[currentVisibleSection]
        var tagIncrementer = 0
        var counter = 0 //horizontal spacing
        var row = 0 //vertical spacing
        for title in currentSectionTitles {
            if (counter%5 == 0) && (counter != 0) { //5 buttons per row
                //Every 5th button, add 1 to the value of row (which will create a new row)
                row += 1
                counter = 0 //reset counter when a new row is created (to start from left again)
            }
            let button = UIButton(frame: CGRect(x: (100 + counter*150), y: 400 + row*50, width: 120, height: 40))
            button.tag = 20 + tagIncrementer //button tags are between 20 - 40
            button.setTitle(title, forState: UIControlState.Normal)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.addTarget(self, action: "findingButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
            button.backgroundColor = UIColor.blackColor()
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.layer.borderWidth = 1.0
            self.addSubview(button)
            
            counter += 1
            tagIncrementer += 1
        }
    }
    
    //MARK: - Custom Button Actions
    
    func nextSectionButtonClick(sender: UIButton) { //moves view to next section (sync w/ R arrow?)
        let sectionsArray = openOrganSystemButton!.sectionsArray!
        if (sectionsArray.count > 1) {
            lastSectionButton.enabled = true //activate lastButton
            lastSectionButton.alpha = 1
            
            if (currentVisibleSection < sectionsArray.count - 1) {
                currentVisibleSection += 1 //don't forget to reset this variable whenever the escape button is prssed. This won't get reset if someone clicks on another template or gets out by some other method, how to account for this?
                configureSectionTitleLabel()
                for subview in self.subviews { //remove existing buttons for current section
                    if (subview.tag == 20) {
                        subview.removeFromSuperview()
                    }
                }
                generateArrayOfButtonTitles() //draw new buttons
            }
            
            if (currentVisibleSection == (sectionsArray.count - 1)) { //disable & gray out if (after pressing next), current visible section is the last one.
                nextSectionButton.alpha = 0.5
                nextSectionButton.enabled = false
            }
        }
        
        //When next section button is pressed, it should clear the buttonCollectionView but remember which buttons were present in the view so that if we return to the previous view, it will regenerate its existing status!
        for button in buttonCollectionView.subviews {
            button.removeFromSuperview() //remember which buttons were removed by tag #! Set a tag number for the 'additional findings' button (it is always the last item in the array) that opens up a textField for custom entry, then changes the button color to reflect special information (make it green). Press enter to accept info from the text field (use existing textField in the search bar!).
        }
    }
    
    func lastSectionButtonClick(sender: UIButton) { //moves view to previous section (sync w/ L arrow?)
        nextSectionButton.enabled = true //reset nextSection button
        nextSectionButton.alpha = 1
        if (currentVisibleSection != 0) {
            currentVisibleSection -= 1 //reset this button whenever the escape button is prssed
            configureSectionTitleLabel()
                
            for subview in self.subviews { //remove existing buttons for current section
                if (subview.tag == 20) {
                    subview.removeFromSuperview()
                }
            }
            generateArrayOfButtonTitles() //draw new buttons
        }
            
        if (currentVisibleSection == 0) {
            lastSectionButton.alpha = 0.5
            lastSectionButton.enabled = false
        }
        
        //When lastSection button is pressed, it should return the previous view to its previous status (indicating which buttons were added to the collection view)!
    }
    
    func escapeButtonClick(sender: UIButton) { //called by hitting escape (no escape on keyboards*) keyboard shortcut. We need to get the button is currently opened
        currentVisibleSection = 0 //reset for next run
        
        if (self.applicationMode == "DEM") { //return to default view
            clearDataEntryView() //remove all sub-views
            obtainReferenceToSuperview()
            physicalAndROSView?.bodyImageView.hidden = false //reveal bodyIV
            
            //Configure default dataEntryView:
            self.frame = CGRect(x: 200, y: 0, width: 764, height: 619)
            renderDefaultDataEntryView()
            
        } else if (self.applicationMode == "PCM") {
            
        }
    }
    
    func findingButtonClick(sender: UIButton) {
        //If button is selected, animate its motion into the collection view on the right:
        sender.removeFromSuperview()
        let count = buttonCollectionView.subviews.count //check # of buttons already in the view
        buttonCollectionView.addSubview(sender)
        if (count > 8) { //start a new row
            sender.frame = CGRect(x: 140, y: (10 + count*50), width: 120, height: 40)
        } else {
            sender.frame = CGRect(x: 10, y: (10 + count*50), width: 120, height: 40)
        }
    }
    
    //MARK: - Helper Functions
    
    func obtainReferenceToSuperview() {
        physicalAndROSView = (self.superview as? PhysicalAndROSView)
    }
    
    func clearDataEntryView() {
        obtainReferenceToSuperview()
        for subview in self.subviews {
            subview.removeFromSuperview() //remove or delete the subviews?
        }
    }

}
