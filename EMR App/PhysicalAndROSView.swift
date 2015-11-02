//  PhysicalAndROSView.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/14/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Upon rotation, we want to - swap the image, hide certain buttons & reveal others, & reposition the rotation button from one side to the other. We will layer all of the buttons on the view & selectively hide them.
//Create Auto-Layout constraints programmatically!!!
//Should we set the view to nil after it is closed out? What if user wants to enter some info, leave & then come back. All saved information will be erased. At what point do we set the object to nil???
//We will generate one large view to cover the entire screen. On this large view, in default we will have the body image view & the default rendering of the dataEntryView. When a button is tapped, we will then remove the bodyImageView & render the dataEntryView in full.

import UIKit

protocol PhysicalAndROSDelegate {
    //This delegate acts as follows: when the user hits the 'Close View' button, it calls a function in the delegate (DEM & PCMVC) that renders the view appropriately!
    func physicalOrROSViewWasClosed()
}

class PhysicalAndROSView: UIView { //Handle orientation appropriately.
    var delegate: PhysicalAndROSDelegate? //Delegate Stored Property

    let applicationMode: String //check if class object was created by DEM or PCM, render view accordingly
    let index: Int //assign unique index to each image (used for rotating images)
    let viewChoice: String //check if the input query is for physical or ROS
    let gender: Int //check if the currentPatient is male or female (0 = male & 1 = female)
    let childOrAdult: Int //check if patient is child or adult (0 = adult & 1 = child)
    var imageName: String
    var rotated: Bool //checks if rotation has occurred
    let rotationButton = UIButton()
    
    //Organ System Buttons:
    let rosButtonsArray: [UIButton]
    let rosButtonLabelsArray: [String]
    let physicalButtonsArray: [UIButton]
    let physicalButtonLabelsArray: [String]
    
    let neurologicalSystemButton: PhysicalAndROSOrganSystemButton //
    let cardiovascularSystemButton: PhysicalAndROSOrganSystemButton //
    let respiratorySystemButton: PhysicalAndROSOrganSystemButton //Px -> 'lungs'
    let gastrointestinalSystemButton: PhysicalAndROSOrganSystemButton //Px -> 'abdomen'
    let genitourinarySystemButton: PhysicalAndROSOrganSystemButton //Px -> split into male & female
    let musculoskeletalSystemButton: PhysicalAndROSOrganSystemButton //
    let psychiatricButton: PhysicalAndROSOrganSystemButton //
    let integumentarySystemButton: PhysicalAndROSOrganSystemButton //Px -> 'skin'
    let constitutionalButton: PhysicalAndROSOrganSystemButton //
    let eyesButton: PhysicalAndROSOrganSystemButton //
    let enmtButton: PhysicalAndROSOrganSystemButton //
    
    let endocrineSystemButton: PhysicalAndROSOrganSystemButton //ROS only
    let hematologicLymphaticSystemButton: PhysicalAndROSOrganSystemButton //ROS only
    let allergicImmunologicSystemButton: PhysicalAndROSOrganSystemButton //ROS only
    
    let headAndNeckButton: PhysicalAndROSOrganSystemButton //Px only -> split into 'head' & 'neck'
    let breastButton: PhysicalAndROSOrganSystemButton //Px only
    let backButton: PhysicalAndROSOrganSystemButton //Px only
    let chaperoneButton: PhysicalAndROSOrganSystemButton //Px only
    let rectalSystemButton: PhysicalAndROSOrganSystemButton //Px only
    
    var dataEntryLabelArray: [String: AnyObject]? //array of labels used to populate the R side view for data entry
    var dataEntrySectionArray: [String]? //array of sections to break down physical/ROS. Should be made nil after completing data entry for a given section!!!
    let bodyImageView = UIImageView()
    var dataEntryView = UIView() //handles all data entry
    var organSystemSelectionTextField = UITextField() //textField in default dataEntryView
    
    init(applicationMode: String, viewChoice: String, gender: Int, childOrAdult: Int) {
        self.applicationMode = applicationMode
        self.viewChoice = viewChoice
        self.gender = gender
        self.childOrAdult = childOrAdult
        self.rotated = false
        
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
        
        //Initialize all of the custom organ system buttons:
        constitutionalButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 10, y: 62, width: 55, height: 30))
        headAndNeckButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 79, y: 79.5, width: 40, height: 25))
        neurologicalSystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 73, y: 12, width: 50, height: 30))
        cardiovascularSystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 103, y: 137, width: 50, height: 30))
        respiratorySystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 45, y: 156, width: 50, height: 30))
        gastrointestinalSystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 81.5, y: 238, width: 35, height: 30))
        genitourinarySystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 81.5, y: 310, width: 35, height: 30))
        breastButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 103, y: 187, width: 50, height: 30))
        backButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 77, y: 180, width: 50, height: 30))
        musculoskeletalSystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 157, y: 226, width: 30, height: 30))
        psychiatricButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 132, y: 62, width: 50, height: 30))
        endocrineSystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 110, y: 300, width: 70, height: 30))
        integumentarySystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 57.5, y: 550, width: 65, height: 30))
        eyesButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 120, y: 0, width: 55, height: 30))
        enmtButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 120, y: 100, width: 55, height: 30))
        chaperoneButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 120, y: 150, width: 55, height: 30))
        rectalSystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 77, y: 300, width: 55, height: 30))
        allergicImmunologicSystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 90, y: 400, width: 100, height: 30))
        hematologicLymphaticSystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 90, y: 500, width: 80, height: 30))
        
        //Divide buttons according to their views:
        rosButtonsArray = [endocrineSystemButton, hematologicLymphaticSystemButton, allergicImmunologicSystemButton, constitutionalButton, neurologicalSystemButton, cardiovascularSystemButton, respiratorySystemButton, gastrointestinalSystemButton, genitourinarySystemButton, integumentarySystemButton, musculoskeletalSystemButton, psychiatricButton, eyesButton, enmtButton]
        rosButtonLabelsArray = ["Endocrine", "Hematologic/Lymphatic", "Allergic/Immune", "Constitutional", "Neuro", "CV", "Resp", "GI", "GU", "Integ", "MS", "Psych", "Eyes", "ENMT"]
        physicalButtonsArray = [chaperoneButton, rectalSystemButton, breastButton, backButton, headAndNeckButton, constitutionalButton, neurologicalSystemButton, cardiovascularSystemButton, respiratorySystemButton, gastrointestinalSystemButton, genitourinarySystemButton, integumentarySystemButton, musculoskeletalSystemButton, psychiatricButton, eyesButton, enmtButton]
        physicalButtonLabelsArray = ["Chaperone", "Rectal", "Breast", "Back", "H&N", "Constitutional", "Neuro", "Heart", "Lungs", "Abdomen", "GU", "Skin", "MS", "Psych", "Eyes", "ENMT"]
        
        super.init(frame: CGRect(x: 60, y: 100, width: 964, height: 619)) //only call super.init AFTER initializing instance variables, set frame to length of screen (minus the margins) dynamically
        
        //Add imageView & dataEntryView:
        bodyImageView.backgroundColor = UIColor.lightGrayColor()
        bodyImageView.userInteractionEnabled = true
        self.addSubview(bodyImageView)
        self.addSubview(dataEntryView)
        bodyImageView.frame = CGRect(x: 0, y: 0, width: 200, height: 619)
        bodyImageView.image = UIImage(named: self.imageName)!
        dataEntryView.frame = CGRect(x: 200, y: 0, width: 764, height: 619)
        
        //rotationButton view & action:
        rotationButton.frame = CGRectMake(150, 560, 35, 35)
        rotationButton.setImage(UIImage(named: "rotate.png"), forState: UIControlState.Normal)
        rotationButton.addTarget(self, action: "rotationButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        bodyImageView.addSubview(rotationButton)
        
        //Create button actions:
        constitutionalButton.addTarget(self, action: "constitutionalButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        headAndNeckButton.addTarget(self, action: "headAndNeckButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        neurologicalSystemButton.addTarget(self, action: "neurologicalSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        cardiovascularSystemButton.addTarget(self, action: "cardiovascularSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        respiratorySystemButton.addTarget(self, action: "respiratorySystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        breastButton.addTarget(self, action: "breastButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        gastrointestinalSystemButton.addTarget(self, action: "gastrointestinalSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        genitourinarySystemButton.addTarget(self, action: "genitourinarySystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.addTarget(self, action: "backButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        integumentarySystemButton.addTarget(self, action: "integumentarySystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        musculoskeletalSystemButton.addTarget(self, action: "musculoskeletalSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        psychiatricButton.addTarget(self, action: "psychiatricButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        endocrineSystemButton.addTarget(self, action: "endocrineSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        eyesButton.addTarget(self, action: "eyesButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        enmtButton.addTarget(self, action: "enmtButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        chaperoneButton.addTarget(self, action: "chaperoneButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        rectalSystemButton.addTarget(self, action: "rectalSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        allergicImmunologicSystemButton.addTarget(self, action: "allergicImmunologicSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        hematologicLymphaticSystemButton.addTarget(self, action: "hematologicLymphaticSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        generalButtonConfiguration() //set up the organSystem buttons
        renderDefaultDataEntryView() //set up the default dataEntryView
    }
    
    required init?(coder aDecoder: NSCoder) { //called when view is reconstituted from nib???
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Button Visuals
    
    private func generalButtonConfiguration() {
        var counter = 0
        if (self.viewChoice == "physicalExam") {
            for button in self.physicalButtonsArray { //draw all buttons for a given view
                button.setTitle(physicalButtonLabelsArray[counter], forState: UIControlState.Normal)
                button.titleLabel?.font = UIFont.boldSystemFontOfSize(15) //bold font
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                button.backgroundColor = UIColor.redColor()
                bodyImageView.addSubview(button)
                button.alpha = 0.39
                counter += 1
            }
        } else if (self.viewChoice == "reviewOfSystems") {
            for button in self.rosButtonsArray { //draw all buttons for a given view
                button.setTitle(rosButtonLabelsArray[counter], forState: UIControlState.Normal)
                button.titleLabel?.font = UIFont.boldSystemFontOfSize(15) //bold font
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                button.backgroundColor = UIColor.redColor()
                bodyImageView.addSubview(button)
                button.alpha = 0.39
                counter += 1
            }
        }
        
        if (gender == 1 && childOrAdult == 0) { //Reveal breastButton for adult females
            breastButton.hidden = false
        } else {
            breastButton.hidden = true
        }
        backButton.hidden = true
        rectalSystemButton.hidden = true
    }
    
    private func configureButtonVisualsOnSelection(sender: UIButton) {
        //Handle how other buttons look & respond while a button is currently selected. We may only need to highlight the button after something has been selected & data has been entered.
//        for button in buttonsArray {
//            if button == sender { //set the selected button to green AFTER user is done using it
//                button.backgroundColor = UIColor.greenColor()
//                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
//            } else { //grey out & disable(?) all other buttons
//                //button.enabled = false //remember to enable the buttons after the view is closed for the open button
//                button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
//                button.backgroundColor = UIColor.redColor() //in future, we will want to allow completed buttons to keep their changed color
//                rotationButton.enabled = false //Disable rotation button on selection to prevent rotation while info is being entered
//            }
//        }
    }
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) { //restore view to normal state if touch is not on button
//        //Might not need this code b/c we are rendering the view & eliminating the bodyImageView.
//        let touch = touches.first
//        let touchLocation = touch!.locationInView(self)
//        
//        let rotationButtonFrame = CGRectMake(150, 560, 35, 35)
//        let generalAppearanceButtonFrame = CGRectMake(10, 62, 55, 30)
//        let headAndNeckButtonFrame = CGRectMake(79, 79.5, 40, 25)
//        let neurologicalSystemButtonFrame = CGRectMake(73, 12, 50, 30)
//        let cardiovascularSystemButtonFrame = CGRectMake(103, 137, 50, 30)
//        let respiratorySystemButtonFrame = CGRectMake(45, 156, 50, 30)
//        let breastButtonFrame = CGRectMake(103, 187, 50, 30)
//        let gastrointestinalSystemButtonFrame = CGRectMake(81.5, 238, 35, 30)
//        let genitourinarySystemButtonFrame = CGRectMake(81.5, 310, 35, 30)
//        let spineAndBackButtonFrame = CGRectMake(77, 180, 50, 30)
//        let peripheralVascularSystemButtonFrame = CGRectMake(57.5, 550, 85, 30)
//        let musculoskeletalSystemButtonFrame = CGRectMake(157, 226, 30, 30)
//        let psychiatricButtonFrame = CGRectMake(132, 62, 50, 30)
//        let framesArray = [rotationButtonFrame, generalAppearanceButtonFrame, headAndNeckButtonFrame, neurologicalSystemButtonFrame, cardiovascularSystemButtonFrame, respiratorySystemButtonFrame, breastButtonFrame, gastrointestinalSystemButtonFrame, genitourinarySystemButtonFrame, spineAndBackButtonFrame, peripheralVascularSystemButtonFrame, musculoskeletalSystemButtonFrame, psychiatricButtonFrame]
//        
//        var touchOnButton = false
//        for frame in framesArray {
//            if (CGRectContainsPoint(frame, touchLocation)) {
//                touchOnButton = true
//                break
//            }
//        }
//        
//        if touchOnButton == false {
//            for button in buttonsArray {
//                button.backgroundColor = UIColor.redColor()
//                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
//            }
//            rotationButton.enabled = true
//        }
//    }
    
    //MARK: - Body Image Rotation
    
    func rotationButtonClick(sender: UIButton) { //Renders rotated image
        //Enable & Disable Corresponding Buttons:
        var frontViewButtonsArray: [UIButton] = []
        var backViewButtonsArray: [UIButton] = []
        if (self.viewChoice == "physicalExam") {
            backViewButtonsArray = [backButton, rectalSystemButton]
            frontViewButtonsArray = [chaperoneButton, breastButton, headAndNeckButton, constitutionalButton, neurologicalSystemButton, cardiovascularSystemButton, respiratorySystemButton, gastrointestinalSystemButton, genitourinarySystemButton, integumentarySystemButton, musculoskeletalSystemButton, psychiatricButton, eyesButton, enmtButton]
        } else if (self.viewChoice == "reviewOfSystems") {
            frontViewButtonsArray = rosButtonsArray
            backViewButtonsArray = []
        }
        if self.rotated == false { //rotation from front -> back
            for button in frontViewButtonsArray {
                button.hidden = true
            }
            for button in backViewButtonsArray {
                button.hidden = false
            }
        } else { //rotation from back -> front
            for button in frontViewButtonsArray {
                button.hidden = false
            }
            for button in backViewButtonsArray {
                button.hidden = true
            }
        }
        bodyImageView.image = getRotatedImageFile()
    }
    
    private func getRotatedImageFile() -> UIImage { //Checks current rotation status & returns the opposite image for the set
        var newImageName = String()
        if self.rotated == false { //Rotation from front -> back
            self.rotated = true
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
            self.rotated = false
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
    
    //MARK: - Organ System Button Actions
    
    func constitutionalButtonClick(sender: UIButton) {
        //***Important: these buttons are a great place for counters to check what items are clicked on & which ones are not & adjust the interface accordingly.
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntrySectionArray = ["General Appearance", "Level of Distress", "Ambulation"] //how to match labels -> sections? Keep an 'Additional Notes' option for every section (when it is tapped, open a text field).
            dataEntryLabelArray = ["General Appearance": ["Cachectic", "Too Thin", "Overweight", "Obese", "Morbidly Obese", "Additional Notes"], "Level of Distress": ["Distress", "Acutely Ill", "Chronically Ill", "Additional Notes"], "Ambulation": ["Limited Ambulation", "Ambulation with Cane", "Ambulation with Walker", "In Wheelchair", "Additional Notes"]] //if 'distress' is selected, ask for how much distress (textField)
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntrySectionArray = ["Constitution"]
            dataEntryLabelArray = ["Constitution": ["Fever", "Night Sweats", "Weight gain", "Weight loss", "Exercise Intolerance", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(constitutionalButton)
    }
    
    func headAndNeckButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntrySectionArray = ["Head", "Neck", "Lymph Nodes", "Thyroid"]
            dataEntryLabelArray = ["Head": ["Macrocephaly", "Microcephaly", "Evidence of Injury", "Additional Notes"], "Neck": ["Pain with Motion", "Tender", "Deviated Trachea", "Cervical Mass", "Crepitus", "Nuchal Rigidity", "Muscle Rigidity", "Additional Notes"], "Lymph Nodes": ["Cervical LAD", "Supraclavicular LAD", "Axillary LAD", "Inguinal LAD", "Additional Notes"], "Thyroid": ["Thyromegaly", "Tenderness", "Palpable Nodule", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(headAndNeckButton)
    }
    
    func neurologicalSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntrySectionArray = ["Gait & Station", "Cranial Nerves", "Sensation", "Reflexes", "Coordination & Cerebellum"]
            dataEntryLabelArray = ["Gait & Station": ["Irregular Gait", "Wide-Based Gait", "Waddling", "Additional Notes"], "Cranial Nerves": ["Abnormal", "Additional Notes"], "Sensation": ["Abnormal", "Abnormal Monofilament Test", "Additional Notes"], "Reflexes": ["Abnormal DTRs", "Asymmetric", "Diminished", "Additional Notes"], "Coordination & Cerebellum": ["Finger-to-Nose Impaired", "Resting Tremor", "Intention Tremor", "Romberg Sign", "Additional Notes"]]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntrySectionArray = ["Neuro"]
            dataEntryLabelArray = ["Neuro": ["Loss of Consciousness", "Weakness", "Numbness", "Seizures", "Dizziness", "Migraines", "Headaches", "Tremor", "Restless Legs", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(neurologicalSystemButton)
    }
    
    func cardiovascularSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntrySectionArray = ["Apical Impulse", "Heart Auscultation", "Neck Vessels", "Pulses Including Femoral/Pedal"]
            dataEntryLabelArray = ["Apical Impulse": ["Displaced", "Accentuated", "Additional Notes"], "Heart Auscultation": ["Bradycardia", "Tachycardia", "Regularly Irregular Rhythm", "Irregularly Irregular Rhythm", "Murmur", "Rub", "Gallop", "Click", "SEM", "S2 with Physiologic Splitting", "Additional Notes"], "Neck Vessels": ["Carotid Bruit", "JVD", "Hepatojugular Reflex", "Additional Notes"], "Pulses Including Femoral/Pedal": ["Diminished", "Absent", "Additional Notes"]]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntrySectionArray = ["CV"]
            dataEntryLabelArray = ["CV": ["Chest Pain", "Arm Pain on Exertion", "Shortness of Breath when Walking", "Shortness of Breath when Lying Down", "Palpitations", "Known Heart Murmur", "Light-headedness on Standing", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(cardiovascularSystemButton)
    }
    
    func respiratorySystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntrySectionArray = ["Respiratory Effort", "Percussion", "Auscultation"]
            dataEntryLabelArray = ["Respiratory Effort": ["Dypneic", "Tachypneic", "Use of Accessory Muscles", "Intercostal Retractions", "Additional Notes"], "Percussion": ["Dullness or Flatness", "Hyperresonance", "Additional Notes"], "Auscultation": ["Decreased Breath Sounds", "Diminished Air Movement", "Inspiratory Wheezing", "Expiratory Wheezing", "Dry Rales/Crackles", "Wet Rales/Crackles", "Rhonchi", "Rales/Crackles on Left", "Rales/Crackles on Right", "Additional Notes"]]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntrySectionArray = ["Respiratory"]
            dataEntryLabelArray = ["Respiratory": ["Cough", "Wheezing", "Shortness of Breath", "Coughing up Blood", "Sleep Apnea", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(respiratorySystemButton)
    }
    
    func gastrointestinalSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntrySectionArray = ["Bowel Sounds", "Inspection & Palpation", "Liver", "Spleen", "Hernia"]
            dataEntryLabelArray = ["Bowel Sounds": ["Increased", "Diminished", "Absent", "High Pitched", "Additional Notes"], "Inspection & Palpation": ["Distended", "Epigastric Tenderness", "LUQ Tenderness", "RUQ Tenderness", "LLQ Tenderness", "RLQ Tenderness", "Suprapubic Tenderness", "Guarding", "Rebound Tenderness", "Mass", "CVA Tenderness", "Additional Notes"], "Liver": ["Tenderness", "Hepatomegaly", "Additional Notes"], "Spleen": ["Tenderness", "Splenomegaly", "Additional Notes"], "Hernia": ["Inguinal", "Periumbilical", "Incisional", "Ventral", "Additional Notes"]] //don't like CVA tenderness here (should be in back)!
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntrySectionArray = ["GI"]
            dataEntryLabelArray = ["GI": ["Abdominal Pain", "Vomiting", "Change in Appetite", "Diarrhea", "Vomiting Blood", "Dyspepsia", "GERD", "Black or Tarry Stools", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(gastrointestinalSystemButton)
    }
    
    func genitourinarySystemButtonClick(sender: UIButton) { //Gender choice changes labels
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            if self.gender == 0 { //Male patient
                dataEntrySectionArray = ["Male GU Exam", "Penis", "Scrotum", "Testes", "Prostate"]
                dataEntryLabelArray = ["Male GU Exam": ["Patient Does Not Know Exam", "Additional Notes"], "Penis": ["Lesion", "Discharge", "Abnormal Foreskin", "Circumcised", "Additional Notes"], "Scrotum": ["Swelling", "Tenderness", "Hydrocele", "Varicocele", "Additional Notes"], "Testes": ["Not Descended", "Enlarged", "Mass", "Tenderness", "Additional Notes"], "Prostate": ["Asymmetrical", "Enlarged", "Tender", "Nodule", "Hard/Indurated", "Boggy (Fluctuant)", "Prostate", "Additional Notes"]]
            } else { //Female patient
                dataEntrySectionArray = ["Female GU Exam", "External Genitalia", "Vagina", "Cervix", "Uterus", "Adnexae", "Bladder & Urethra"]
                dataEntryLabelArray = ["Female GU Exam": ["Patient Does Not Know Exam", "Additional Notes"], "External Genitalia": ["Abnormal", "Lesion", "Rash", "Additional Notes"], "Vagina": ["Abnormal Discharge", "Purulent Discharge", "Dry Mucosa", "Mass", "Tenderness", "Atrophic Mucosa", "Additional Notes"], "Cervix": ["Discharge", "Purulent Discharge", "Cervical Motion Tenderness", "Sample Taken for Pap Smear", "Absent Cervix", "Additional Notes"], "Uterus": ["Anteverted", "Retroverted", "Irregular Contour", "Mass", "Enlarged", "Tender", "Uterine Prolapse", "Absent", "Additional Notes"], "Adnexae": ["Palpable Mass", "Tender", "Additional Notes"], "Bladder & Urethra": ["Urethral Discharge", "Distended Bladder", "Cystocele", "Additional Notes"]]
            }
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntrySectionArray = ["GU"]
            dataEntryLabelArray = ["GU": ["Incontinence", "Difficulty Urinating", "Hematuria", "Increased Frequency", "Incomplete Emptying", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(genitourinarySystemButton)
    }
    
    func breastButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntrySectionArray = ["Breast Exam", "Breast"]
            dataEntryLabelArray = ["Breast Exam": ["Patient Does Not Know Exam", "Additional Notes"], "Breast": ["Mass", "Abnormal Tenderness", "Abnormal Discharge", "Fibrocystic", "Asymmetry", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(breastButton)
    }
    
    func backButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntrySectionArray = ["Back"]
            dataEntryLabelArray = ["Back": ["Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(backButton)
    }
    
    func integumentarySystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntrySectionArray = ["Inspection & Palpation", "Nails"]
            dataEntryLabelArray = ["Inspection & Palpation": ["Rash", "Lesion", "Ulcer", "Indurated", "Nodule", "Decreased Turgor", "Jaundice", "Tattos", "Additional Notes"], "Nails": ["Abnormal", "Additional Notes"]]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntrySectionArray = ["Skin"]
            dataEntryLabelArray = ["Skin": ["Abnormal Mole", "Jaundice", "Rash", "Laceration", "Itching", "Dry Skin", "Growths/Lesions", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(integumentarySystemButton)
    }
    
    func musculoskeletalSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntrySectionArray = ["Motor Strength & Tone", "Joints, Bones, & Muscles", "Extremities"]
            dataEntryLabelArray = ["Motor Strength & Tone": ["Abnormal Motor Strength", "Hypertonicity", "Hypotonicity", "Additional Notes"], "Joints, Bones, & Muscles": ["Limited ROM", "Bony Deformity", "Contracture", "Malalignment", "Tenderness", "Additional Notes"], "Extremities": ["Cyanosis", "Edema", "Varicosities", "Palpable Cord", "Clubbing", "Homan's Sign"]]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntrySectionArray = ["MS"]
            dataEntryLabelArray = ["MS": ["Muscle Aches", "Muscle Weakness", "Arthralgia/Joint Pain", "Back Pain", "Swelling in the Extremities", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(musculoskeletalSystemButton)
    }
    
    func psychiatricButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntrySectionArray = ["Insight", "Mental Status", "Orientation", "Memory"]
            dataEntryLabelArray = ["Insight": ["Poor Insight", "Additional Notes"], "Mental Status": ["Abnormal Affect", "Lethargic", "Confused", "Anxious", "Depressed", "Agitated", "Additional Notes"], "Orientation": ["Not Oriented to Time", "Not Oriented to Place", "Not Oriented to Person", "Additional Notes"], "Memory": ["Recent Memory Abnormal", "Remote Memory Abnormal", "Additional Notes"]]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntrySectionArray = ["Psych"]
            dataEntryLabelArray = ["Psych": ["Depression", "Sleep Disturbances", "Feeling Unsafe in Relationship", "Alcohol Abuse", "Anxiety", "Hallucinations", "Suicidal Thoughts", "Restless Sleep", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(psychiatricButton)
    }
    
    func endocrineSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if (self.viewChoice == "reviewOfSystems") {
            dataEntrySectionArray = ["Endocrine"]
            dataEntryLabelArray = ["Endocrine": ["Fatigue", "Increased Thirst", "Hair Loss", "Increased Hair Growth", "Cold Intolerance", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(endocrineSystemButton)
    }
    
    func hematologicLymphaticSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if (self.viewChoice == "reviewOfSystems") {
            dataEntrySectionArray = ["Lymph"]
            dataEntryLabelArray = ["Lymph": ["Swollen Glands", "Easy Bruising", "Excessive Bleeding", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(hematologicLymphaticSystemButton)
    }
    
    func eyesButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntrySectionArray = ["Lids & Conjunctivae", "Pupils", "Corneas", "Fundoscopic", "EOM", "Lens", "Sclerae"]
            dataEntryLabelArray = ["Lids & Conjunctivae": ["Injected", "Discharge", "Pallor", "Xanthelasma", "Ptosis", "Exophthalmos", "Additional Notes"], "Pupils": ["Non-reactive to Light", "Anisocoria", "Additional Notes"], "Corneas": ["Arcus Senilis", "Abrasion", "Opacity", "Ulceration", "Additional Notes"], "Fundoscopic": ["Papilledema", "Increased Cupping", "Blurred Margins", "Narrowing of Arterioles", "A-V Nicking", "Exudate", "Soft Exudate", "Hard Exudate", "Hemorrhage", "Optic Disc Not Well Visualized", "Fundus Not Well Visualized", "Additional Notes"], "EOM": ["Dysconjugated", "Strabismus", "Nystagmus", "Additional Notes"], "Lens": ["Cataract", "Additional Notes"], "Sclerae": ["Injected", "Icteric", "Abrasion", "Additional Notes"]]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntrySectionArray = ["Eyes"] //empty
            dataEntryLabelArray = ["Eyes": ["Dry Eyes", "Vision Change", "Irritation", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(eyesButton)
    }
    
    func enmtButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntrySectionArray = ["Ears", "Hearing", "Nose", "Lips, Teeth, & Gums", "Oropharynx"]
            dataEntryLabelArray = ["Ears": ["External Ear Lesion", "EAC Ceruminous", "EAC Discharge", "TM Erythematous", "TM Bulging", "TM Perforated", "TM Opacified", "TM Immobile", "Middle Ear Fluid"], "Hearing": ["Hearing Decreased", "Weber's Sign", "Additional Notes"], "Nose": ["External Nose Lesion", "Nares Non-Patent", "Deviated Septum", "Nasal Obstruction", "Sinus Tenderness", "Nasal Discharge", "Nasal Discharge-Purulent", "Nasal Discharge-Rhinorrhea", "Post Nasal Drip", "Additional Notes"], "Lips, Teeth, & Gums": ["Mouth Ulcers", "Gingival Erythema", "Poor Dentition", "Edentulous", "Additional Notes"], "Oropharynx": ["Erythema", "Tonsils Enlarged", "Exudate", "Tonsils Absent", "Additional Notes"]]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntrySectionArray = ["Ears", "Nose", "Mouth/Throat"]
            dataEntryLabelArray = ["Ears": ["Difficulty Hearing", "Ear Pain", "Additional Notes"], "Nose": ["Frequent Nosebleeds", "Nose Problems", "Sinus Problems", "Additional Notes"], "Mouth/Throat": ["Sore Throat", "Bleeding Gums", "Snoring", "Dry Mouth", "Mouth Ulcers", "Oral Abnormalities", "Teeth Problems", "Mouth Breathing", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(enmtButton)
    }
    
    func chaperoneButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if (self.viewChoice == "physicalExam") {
            dataEntrySectionArray = ["Chaperone"]
            dataEntryLabelArray = ["Chaperone": ["Present", "Offered & Declined", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(chaperoneButton)
    }
    
    func rectalSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if (self.viewChoice == "physicalExam") {
            dataEntrySectionArray = ["Rectal"]
            dataEntryLabelArray = ["Rectal": ["Decreased Tone", "Hemorrhoids", "Fissure", "Mass", "Stool Heme Positive", "Rectocele", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(rectalSystemButton)
    }
    
    func allergicImmunologicSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if (self.viewChoice == "reviewOfSystems") {
            dataEntrySectionArray = ["Immune"]
            dataEntryLabelArray = ["Immune": ["Runny Nose", "Sinus Pressure", "Itching", "Hives", "Frequent Sneezing", "Additional Notes"]]
        }
        renderDataEntryViewForOrganSystemButton(allergicImmunologicSystemButton)
    }
    
    //MARK: - Default DataEntryView Rendering
        
    func renderDefaultDataEntryView() {//When we configure R side view, when no organ system is tapped, have label telling user what to do (w/ a list of keyboard shortcuts) & a text field to allow entry of shortcuts.
        
        //Configure view:
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor(red: 0, green: 0.25, blue: 0.40, alpha: 1.0)
            
        //Add label, textField & button:
        let dataEntryInstructionsLabel = UILabel(frame: CGRect(x: 150, y: 140, width: 500, height: 150))
        let closeViewButton = UIButton(frame: CGRect(x: 600, y: 50, width: 120, height: 30))
        organSystemSelectionTextField.frame = CGRect(x: 150, y: 300, width: 300, height: 50)
        dataEntryView.addSubview(dataEntryInstructionsLabel)
        dataEntryView.addSubview(closeViewButton)
        dataEntryView.addSubview(organSystemSelectionTextField)
            
        //Configure Instruction Label:
        dataEntryInstructionsLabel.numberOfLines = 5
        dataEntryInstructionsLabel.backgroundColor = UIColor.whiteColor()
        dataEntryInstructionsLabel.text = "Type in the abbreviation for an organ system or tap on the corresponding button. Abbreviations: General = G, Neuro = N, Psych = P, Heart = H, Lungs = L, GI = GI, GU = GU, Peripheral = Pe, MS = MS."
            
        //Configure TextField:
        organSystemSelectionTextField.userInteractionEnabled = true
        organSystemSelectionTextField.backgroundColor = UIColor.whiteColor()
        organSystemSelectionTextField.tag = 200 //assign unique tag for 'return' behavior config
        organSystemSelectionTextField.becomeFirstResponder()
        organSystemSelectionTextField.placeholder = "Enter an organ system and hit 'Return'"
        organSystemSelectionTextField.addTarget(self, action: "textFieldWasTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //Configure CloseView Button:
        closeViewButton.setTitle("Close View", forState: UIControlState.Normal)
        closeViewButton.addTarget(self, action: "closeViewButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
    }
        
    //MARK: - OrganSystem Button Rendering
        
    func renderDataEntryViewForOrganSystemButton(sender: PhysicalAndROSOrganSystemButton) {
        //Remove the human body from view & take the whole screen to render the interface:
        for subview in dataEntryView.subviews { //clears organSystemEntry view
            subview.removeFromSuperview()
        }
        
        for subview in bodyImageView.subviews {
            subview.removeFromSuperview()
        }
        
        bodyImageView.removeFromSuperview()
        dataEntryView.removeFromSuperview()
        
        //Redraw the dataEntryView to take up the entire screen, then add it back:
        dataEntryView.frame = CGRect(x: 0, y: 0, width: 964, height: 619)
        
        //Configure Escape Button (returns split view w/ humanBodyImage):
        let escapeButton = UIButton(frame: CGRect(x: 50, y: 50, width: 80, height: 30))
        escapeButton.setTitle("Escape", forState: UIControlState.Normal)
        escapeButton.addTarget(self, action: "escapeButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        self.dataEntryView.addSubview(escapeButton)
        self.addSubview(dataEntryView)
    }
        
    //MARK: - Close & Escape Button Actions
        
    func closeViewButtonClick(sender: UIButton) {
        //Remove views from main view & return the app to the default view (depends on application mode)
        if (self.applicationMode == "DEM") {
            self.removeFromSuperview()
            //Configure DEM view for fieldName entry using delegate method:
            self.delegate?.physicalOrROSViewWasClosed()
        } else if (self.applicationMode == "PCM") {
        
        }
    }
    
    func escapeButtonClick(sender: UIButton) { //called by hitting the escape (no escape on keyboards*) keyboard shortcut
        //Configuration depends on application mode:
        if (self.applicationMode == "DEM") { //Return to split view w/ bodyImageView on left & textField on right
            self.dataEntryView.removeFromSuperview()
            self.addSubview(bodyImageView)
            bodyImageView.addSubview(rotationButton)
            generalButtonConfiguration()
            dataEntryView.frame = CGRect(x: 200, y: 0, width: 764, height: 619)
            renderDefaultDataEntryView()
        } else if (self.applicationMode == "PCM") {
            
        }
    }
    
}