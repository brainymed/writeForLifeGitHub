//  PhysicalAndROSView.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/14/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Upon rotation, we want to - swap the image, hide certain buttons & reveal others, & reposition the rotation button from one side to the other. We will layer all of the buttons on the view & selectively hide them.
//Create Auto-Layout constraints programmatically!!!
//Should we set the view to nil after it is closed out? What if user wants to enter some info, leave & then come back. All saved information will be erased. At what point do we set the object to nil???

import UIKit

class PhysicalAndROSView: UIView { //Handle orientation appropriately.
    let index: Int //assign unique index to each image (used for rotating images)
    let viewChoice: String //check if the input query is for physical or ROS
    let gender: Int //check if the currentPatient is male or female (0 = male & 1 = female)
    let childOrAdult: Int //check if patient is child or adult (0 = adult & 1 = child)
    var imageName: String
    var rotated: Bool //checks if rotation has occurred
    let rotationButton = UIButton()
    let dataEntryView: PhysicalAndROSDataEntryView //the R side of the view
    
    //Organ System Buttons:
    let buttonsArray: [UIButton]
    let buttonLabelsArray: [String]
    let generalAppearanceButton: PhysicalAndROSOrganSystemButton
    let neurologicalSystemButton: PhysicalAndROSOrganSystemButton
    let headAndNeckButton: PhysicalAndROSOrganSystemButton
    let cardiovascularSystemButton: PhysicalAndROSOrganSystemButton
    let respiratorySystemButton: PhysicalAndROSOrganSystemButton
    let gastrointestinalSystemButton: PhysicalAndROSOrganSystemButton
    let genitourinarySystemButton: PhysicalAndROSOrganSystemButton
    let peripheralVascularSystemButton: PhysicalAndROSOrganSystemButton
    let breastButton: PhysicalAndROSOrganSystemButton
    let spineAndBackButton: PhysicalAndROSOrganSystemButton
    let musculoskeletalSystemButton: PhysicalAndROSOrganSystemButton
    let psychiatricButton: PhysicalAndROSOrganSystemButton
//    let endocrineSystemButton: PhysicalAndROSOrganSystemButton
//    let hematopoieticSystemButton: PhysicalAndROSOrganSystemButton
    
    var dataEntryLabelArray: [String]? //array of labels used to populate the R side view for data entry
    var dataEntrySectionArray: [String]? //array of sections to break down physical/ROS. Should be made nil after completing data entry for a given section!!!
    let bodyImageView = UIImageView()
    
    init(dataEntryView: PhysicalAndROSDataEntryView, viewChoice: String, gender: Int, childOrAdult: Int) {
        self.viewChoice = viewChoice
        self.gender = gender
        self.childOrAdult = childOrAdult
        self.rotated = false
        self.dataEntryView = dataEntryView
        
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
        generalAppearanceButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 10, y: 62, width: 55, height: 30))
        headAndNeckButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 79, y: 79.5, width: 40, height: 25))
        neurologicalSystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 73, y: 12, width: 50, height: 30))
        cardiovascularSystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 103, y: 137, width: 50, height: 30))
        respiratorySystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 45, y: 156, width: 50, height: 30))
        gastrointestinalSystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 81.5, y: 238, width: 35, height: 30))
        genitourinarySystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 81.5, y: 310, width: 35, height: 30))
        breastButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 103, y: 187, width: 50, height: 30))
        spineAndBackButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 77, y: 180, width: 50, height: 30))
        peripheralVascularSystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 57.5, y: 550, width: 85, height: 30))
        musculoskeletalSystemButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 157, y: 226, width: 30, height: 30))
        psychiatricButton = PhysicalAndROSOrganSystemButton(frame: CGRect(x: 132, y: 62, width: 50, height: 30))
        
        self.buttonsArray = [generalAppearanceButton, headAndNeckButton, neurologicalSystemButton, cardiovascularSystemButton, respiratorySystemButton, gastrointestinalSystemButton, genitourinarySystemButton, breastButton, spineAndBackButton, peripheralVascularSystemButton, musculoskeletalSystemButton, psychiatricButton]
        self.buttonLabelsArray = ["General", "H&N", "Neuro", "Heart", "Lungs", "GI", "GU", "Breast", "Spine", "Peripheral", "MS", "Psych"]
        
        super.init(frame: CGRect(x: 60, y: 100, width: 200, height: 619)) //only call super.init AFTER initializing instance variables
        
        //Add imageView, dataEntryView, & background color:
        self.backgroundColor = UIColor.lightGrayColor()
        self.addSubview(bodyImageView)
        self.bodyImageView.frame = self.bounds
        self.bodyImageView.image = UIImage(named: self.imageName)!
        
        //rotationButton view & action:
        rotationButton.frame = CGRectMake(150, 560, 35, 35)
        rotationButton.setImage(UIImage(named: "rotate.png"), forState: UIControlState.Normal)
        rotationButton.addTarget(self, action: "rotationButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        self.insertSubview(rotationButton, aboveSubview: bodyImageView)
        
        //Create button actions:
        generalAppearanceButton.addTarget(self, action: "generalAppearanceButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        headAndNeckButton.addTarget(self, action: "headAndNeckButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        neurologicalSystemButton.addTarget(self, action: "neurologicalSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        cardiovascularSystemButton.addTarget(self, action: "cardiovascularSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        respiratorySystemButton.addTarget(self, action: "respiratorySystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        breastButton.addTarget(self, action: "breastButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        gastrointestinalSystemButton.addTarget(self, action: "gastrointestinalSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        genitourinarySystemButton.addTarget(self, action: "genitourinarySystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        spineAndBackButton.addTarget(self, action: "spineAndBackButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        peripheralVascularSystemButton.addTarget(self, action: "peripheralVascularSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        musculoskeletalSystemButton.addTarget(self, action: "musculoskeletalSystemButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        psychiatricButton.addTarget(self, action: "psychiatricButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        generalButtonConfiguration()
    }
    
    required init?(coder aDecoder: NSCoder) { //called when view is reconstituted from nib???
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Button Visuals
    
    private func generalButtonConfiguration() {
        var counter = 0
        for button in self.buttonsArray {
            button.setTitle(buttonLabelsArray[counter], forState: UIControlState.Normal)
            button.titleLabel?.font = UIFont.boldSystemFontOfSize(15) //bold font
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            button.backgroundColor = UIColor.redColor()
            self.insertSubview(button, aboveSubview: self.bodyImageView)
            button.alpha = 0.39
            counter += 1
        }
        
        if (gender == 1 && childOrAdult == 0) { //Reveal breastButton for adult females
            breastButton.hidden = false
        } else {
            breastButton.hidden = true
        }
        spineAndBackButton.hidden = true
    }
    
    private func configureButtonVisualsOnSelection(sender: UIButton) {
        //Handle how other buttons look & respond while a button is currently selected:
        for button in buttonsArray {
            if button == sender { //set the selected button to green AFTER user is done using it
                button.backgroundColor = UIColor.greenColor()
                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            } else { //grey out & disable(?) all other buttons
                //button.enabled = false //remember to enable the buttons after the view is closed for the open button
                button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
                button.backgroundColor = UIColor.redColor() //in future, we will want to allow completed buttons to keep their changed color
                rotationButton.enabled = false //Disable rotation button on selection to prevent rotation while info is being entered
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) { //restore view to normal state if touch is not on button
        let touch = touches.first
        let touchLocation = touch!.locationInView(self)
        
        let rotationButtonFrame = CGRectMake(150, 560, 35, 35)
        let generalAppearanceButtonFrame = CGRectMake(10, 62, 55, 30)
        let headAndNeckButtonFrame = CGRectMake(79, 79.5, 40, 25)
        let neurologicalSystemButtonFrame = CGRectMake(73, 12, 50, 30)
        let cardiovascularSystemButtonFrame = CGRectMake(103, 137, 50, 30)
        let respiratorySystemButtonFrame = CGRectMake(45, 156, 50, 30)
        let breastButtonFrame = CGRectMake(103, 187, 50, 30)
        let gastrointestinalSystemButtonFrame = CGRectMake(81.5, 238, 35, 30)
        let genitourinarySystemButtonFrame = CGRectMake(81.5, 310, 35, 30)
        let spineAndBackButtonFrame = CGRectMake(77, 180, 50, 30)
        let peripheralVascularSystemButtonFrame = CGRectMake(57.5, 550, 85, 30)
        let musculoskeletalSystemButtonFrame = CGRectMake(157, 226, 30, 30)
        let psychiatricButtonFrame = CGRectMake(132, 62, 50, 30)
        let framesArray = [rotationButtonFrame, generalAppearanceButtonFrame, headAndNeckButtonFrame, neurologicalSystemButtonFrame, cardiovascularSystemButtonFrame, respiratorySystemButtonFrame, breastButtonFrame, gastrointestinalSystemButtonFrame, genitourinarySystemButtonFrame, spineAndBackButtonFrame, peripheralVascularSystemButtonFrame, musculoskeletalSystemButtonFrame, psychiatricButtonFrame]
        
        var touchOnButton = false
        for frame in framesArray {
            if (CGRectContainsPoint(frame, touchLocation)) {
                touchOnButton = true
                break
            }
        }
        
        if touchOnButton == false {
            for button in buttonsArray {
                button.backgroundColor = UIColor.redColor()
                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
            rotationButton.enabled = true
        }
    }
    
    //MARK: - Body Image Rotation
    
    func rotationButtonClick(sender: UIButton) { //Renders rotated image
        //Enable & Disable Corresponding Buttons:
        let frontViewButtonsArray = [generalAppearanceButton, headAndNeckButton, neurologicalSystemButton, cardiovascularSystemButton, respiratorySystemButton, gastrointestinalSystemButton, genitourinarySystemButton, breastButton, peripheralVascularSystemButton, musculoskeletalSystemButton, psychiatricButton]
        let backViewButtonsArray = [spineAndBackButton]
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
    
    func generalAppearanceButtonClick(sender: UIButton) { //add data for the labels & sections array, allowing this information to be accessed in the 'partitionView' function in DEMVC. Labels depend on viewchoice.
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntryLabelArray = ["General Appearance", "Alert?", "Awake?", "Oriented?", "Distress?", "Other"]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntryLabelArray = ["Fatigue", "Weight Loss", "Weight Gain", "Loss of Appetite", "Energy Level", "Fever", "Sweating", "Other"]
        }
        self.dataEntryView.renderDataEntryViewForOrganSystemButton(generalAppearanceButton)
    }
    
    func headAndNeckButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        self.dataEntrySectionArray = ["General", "Eyes", "Ears", "Nose", "Mouth"] //how to match labels -> sections? Not everything will fit, so maybe use a R arrow key to scroll between sections? Keep an 'other' option for every section!
        if self.viewChoice == "physicalExam" {
            dataEntryLabelArray = ["Scalp", "Lymph Nodes", "Thyroid", "Carotids", "Trachea", "PERRLA", "EOMI", "Visual Fields", "Visual Acuity", "Ophthalmoscopic Exam", "Auditory Acuity", "Otoscopic Exam", "Nasal Septum", "Sense of Smell", "Sinus Pain", "Facial Sensation", "Lips", "Gums", "Teeth", "Palate Deviation", "Tongue Deviation", "Gag Reflex","Other"]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntryLabelArray = ["Headache", "Head Injury", "Facial Pain", "Sinus Infection", "!!!Visual Changes", "Corrective Lenses", "Diplopia", "Blurred Vision", "Halos?", "Tearing", "Inflammation", "Discharge", "Spots", "Photophobia", "Eye Pain", "Trauma", "Cataracts", "Glaucoma", "!!!Deafness", "Tinnitus", "Ear Pain", "Discharge", "Infections", "!!!Change in Smell", "Obstruction", "Discharge", "Post-nasal Drip", "Epistaxis", "Trauma", "Nose Pain", "!!!Soreness", "Bleeding", "Ulcers", "Dentition", "Dentures", "Hoarseness", "Sore Throat", "Dysphagia", "Odynophagia", "!!!Masses", "Swollen Glands", "Stiffness", "Goiter", "Tenderness", "Trauma", "Other"]
        }
        self.dataEntryView.renderDataEntryViewForOrganSystemButton(headAndNeckButton)
    }
    
    func neurologicalSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        self.dataEntrySectionArray = ["General Neuro", "Muscular", "Sensory", "Cerebellar/Vestibular"]
        if self.viewChoice == "physicalExam" {
            dataEntryLabelArray = ["Mental Status", "Cranial Nerve Exam", "Orientation to Person/Place/Time", "Memory", "Muscle Strength", "Muscle Tone", "Reflexes", "Joint Position Sense", "Touch Discrimination", "Vibration Sense", "Rapid Alternating Movements", "Gait", "Romberg Test", "Other"]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntryLabelArray = ["Personality Changes", "Loss of Consciousness", "Memory Changes", "Syncope", "Aphasia", "Dysarthria", "Seizures", "Dizziness/Lightheadedness", "!!!Weakness/Paralysis", "Tremors", "Involuntary Movements", "Poor Coordination", "!!!Anesthesia", "Paresthesia", "Hyperesthesia", "!!!Loss of Balance", "Ataxia", "Vertigo", "Nystagmus", "Other"]
        }
        self.dataEntryView.renderDataEntryViewForOrganSystemButton(neurologicalSystemButton)
    }
    
    func cardiovascularSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntryLabelArray = ["Chest Appearance", "Heart Sounds", "Murmurs", "JVD", "PMI", "Ventricular Heave/Thrills", "Other"]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntryLabelArray = ["Chest Pain", "Dyspnea on Exertion", "Orthopnea", "Cough", "Palpitations", "Abnormal Rhythm", "Other"]
        }
        self.dataEntryView.renderDataEntryViewForOrganSystemButton(cardiovascularSystemButton)
    }
    
    func respiratorySystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntryLabelArray = ["Tactile Fremitus", "Lung Sounds", "Wheezes?", "Rales?", "Ronchi?", "Percussion", "Other"]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntryLabelArray = ["Chest Pain", "Dyspnea", "Cough", "Sputum", "Wheezing", "Bronchitis", "Pneumonia", "Other"]
        }
        self.dataEntryView.renderDataEntryViewForOrganSystemButton(respiratorySystemButton)
    }
    
    func gastrointestinalSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntryLabelArray = ["Appearance", "Tenderness", "Distension", "Bowel Sounds", "Hepatomegaly", "Splenomegaly", "Ascites", "Aortic/Renal Bruit", "Hernias", "Hepatojugular Reflex", "Other"]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntryLabelArray = ["Heartburn", "Nausea", "Vomiting", "Abdominal Pain", "Distension", "Gas", "Bowel Habits", "Bowel Quality", "Jaundice", "Fatty Food Intolerane", "Other"]
        }
        self.dataEntryView.renderDataEntryViewForOrganSystemButton(gastrointestinalSystemButton)
    }
    
    func genitourinarySystemButtonClick(sender: UIButton) { //Gender choice changes labels
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            if self.gender == 0 { //Male patient
                dataEntryLabelArray = ["Appearance", "Perineum", "Other"]
            } else { //Female patient
                dataEntryLabelArray = ["Dysuria", "Urgency", "Frequency", "Polyuria", "Nocturia", "Difficulty Initiating Stream", "Decrease in Force", "Incontinence", "Flank Pain", "Suprapubic Pain", "Hematuria", "Kidney Stones", "Groin Swelling", "Trauma", "UTI", "!!!Lesions", "Itching", "Discharge", "Pain on Intercourse", "Other"]
            }
        } else if self.viewChoice == "reviewOfSystems" {
            if self.gender == 0 { //Male patient
                dataEntryLabelArray = ["Appearance", "Perineum", "Inguinal Nodes", "Scrotum", "Other"]
            } else { //Female patient
                dataEntryLabelArray = ["Dysuria", "Urgency", "Frequency", "Polyuria", "Nocturia", "Difficulty Initiating Stream", "Decrease in Force", "Incontinence", "Flank Pain", "Suprapubic Pain", "Hematuria", "Kidney Stones", "Groin Swelling", "Trauma", "!!!Lesions", "Discharge", "Impotence", "Penile Pain", "Scrotal Masses", "Testicular Masses", "Prostate Problems", "Other"]
            }
        }
        self.dataEntryView.renderDataEntryViewForOrganSystemButton(genitourinarySystemButton)
    }
    
    func breastButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntryLabelArray = ["Masses", "Other"]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntryLabelArray = ["Knows Self-Exam?", "Tenderness", "Asymmetry", "Mass", "Nipple Discharge", "Milky Discharge", "Change in Size", "Other"]
        }
        self.dataEntryView.renderDataEntryViewForOrganSystemButton(breastButton)
    }
    
    func spineAndBackButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntryLabelArray = ["Edema", "Sacroiliac Joint Tenderness", "Costovertebral Angle Tenderness", "Posture", "Spine Appearance"]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntryLabelArray = ["Other"]
        }
        self.dataEntryView.renderDataEntryViewForOrganSystemButton(spineAndBackButton)
    }
    
    func peripheralVascularSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntryLabelArray = ["Edema", "Carotid Bruit", "Femoral Bruit", "Radial Pulse", "Femoral Pulse", "Dorsalis Pedis Pulse", "Posterior Tibial Pulse", "Other"]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntryLabelArray = ["Cyanosis/Discoloration", "Ankle/Leg Swelling", "Leg Pain on Walking", "Varicose Veins", "Hair Loss in Extremities", "Other"]
        }
        self.dataEntryView.renderDataEntryViewForOrganSystemButton(peripheralVascularSystemButton)
    }
    
    func musculoskeletalSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        self.dataEntrySectionArray = ["Skin", "Muscles", "Joints"]
        if self.viewChoice == "physicalExam" {
            dataEntryLabelArray = ["Joint Swelling/Edema", "Joint Redness", "Range of Motion", "Other"]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntryLabelArray = ["Rash", "Itching", "Color Change", "Lesions/Ulcerations", "Changes in Moles/Spots", "Redness", "!!!Arthralgia", "Joint Inflammation", "Joint Stiffness", "Joint Pain", "Limiting of Motion", "!!!Back Pain", "Neck Pain", "Muscle Pain", "Muscle Weakness", "Atrophy", "!!!Bone Pain", "Fractures", "Other"]
        }
        self.dataEntryView.renderDataEntryViewForOrganSystemButton(musculoskeletalSystemButton)
    }
    
    func psychiatricButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntryLabelArray = ["Other"]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntryLabelArray = ["Suicidal Ideation", "Psychotic Symptoms", "Other"]
        }
        self.dataEntryView.renderDataEntryViewForOrganSystemButton(psychiatricButton)
    }
    
    func endocrineSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntryLabelArray = ["Other"]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntryLabelArray = ["Hyperglycemia", "Polydipsia", "Polyuria", "Heat/Cold Intolerance", "Excessive Sweating", "Loss of Hair/Increased Hair", "Skin Dryness", "Increased/Decreased Body Fat", "Menstrual Irregularity", "Other"]
        }
        //self.dataEntryView.renderDataEntryViewForOrganSystemButton(endocrineSystemButton)
    }
    
    func hematopoieticSystemButtonClick(sender: UIButton) {
        self.configureButtonVisualsOnSelection(sender)
        if self.viewChoice == "physicalExam" {
            dataEntryLabelArray = ["Other"]
        } else if self.viewChoice == "reviewOfSystems" {
            dataEntryLabelArray = ["Anemia", "Paleness", "Weakness", "Blood Loss", "Easy Bruising or Bleeding", "Other"]
        }
        //self.dataEntryView.renderDataEntryViewForOrganSystemButton(hematopoieticSystemButton)
    }
}