//  HumanBodyImageView.swift
//  EMR App
//  Created by Arnav Pondicherry  on 11/2/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

import UIKit

class HumanBodyImageView: UIImageView {

    let viewChoice: String
    let index: Int //assign unique index to each image (used for rotating images)
    let gender: Int //0 = male, 1 = female
    let childOrAdult: Int
    var rotated: Bool //checks if rotation has occurred; false = FRONT view, true = BACK view
    var imageName: String
    var physicalAndROSView: PhysicalAndROSView? //reference to superview
    
    //Organ System Buttons:
    let rosButtonsArray: [PhysicalAndROSOrganSystemButton]
    let rosButtonLabelsArray: [String]
    let rosButtonsForBackArray: [PhysicalAndROSOrganSystemButton] //buttons shown on back of the body
    let physicalButtonsArray: [PhysicalAndROSOrganSystemButton]
    let physicalButtonLabelsArray: [String]
    let physicalButtonsForBackArray: [PhysicalAndROSOrganSystemButton] //buttons shown on back of the body
    
    let rotationButton: UIButton = UIButton()
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
    
    //MARK: - Initializers
    
    init(viewChoice: String, gender: Int, childOrAdult: Int) {
        self.viewChoice = viewChoice
        self.gender = gender
        self.childOrAdult = childOrAdult
        self.rotated = false
        
        //Pick starting image for the view:
        if (self.childOrAdult == 0) { //Patient is an adult
            if (self.gender == 0) { //Male adult {1}
                self.index = 1
                self.imageName = "adult_male_outline_front.png"
            } else { //Female adult {2}
                self.index = 2
                self.imageName = "adult_female_outline_front.png"
            }
        } else { //Patient is a child
            if (self.gender == 0) { //Male child {3}
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
        rosButtonLabelsArray = ["Endocrine", "Hematologic/Lymphatic", "Allergic/Immunologic", "Constitutional", "Neurologic", "Cardiovascular", "Respiratory", "GI", "GU", "Integumentary", "Musculoskeletal", "Psychiatric", "Eyes", "ENMT"]
        rosButtonsForBackArray = []
        
        physicalButtonsArray = [chaperoneButton, rectalSystemButton, breastButton, backButton, headAndNeckButton, constitutionalButton, neurologicalSystemButton, cardiovascularSystemButton, respiratorySystemButton, gastrointestinalSystemButton, genitourinarySystemButton, integumentarySystemButton, musculoskeletalSystemButton, psychiatricButton, eyesButton, enmtButton]
        physicalButtonLabelsArray = ["Chaperone", "Rectal", "Breast", "Back", "H&N", "Constitutional", "Neurologic", "Heart", "Lungs", "Abdomen", "GU", "Skin", "Musculoskeletal", "Psychiatric", "Eyes", "ENMT"]
        physicalButtonsForBackArray = [backButton, rectalSystemButton]
        
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 619)) //only call super.init AFTER initializing instance variables, set frame to length of screen (minus the margins) dynamically
        
        self.backgroundColor = UIColor.lightGrayColor()
        self.userInteractionEnabled = true
        self.image = UIImage(named: self.imageName)!
        
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
        
        generalButtonConfiguration() //configure the organSystem buttons
    }
    
    required init?(coder aDecoder: NSCoder) { //called when view is reconstituted from nib???
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Button Configuration
    
    private func generalButtonConfiguration() {
        var counter = 0
        if (self.viewChoice == "physicalExam") {
            for button in self.physicalButtonsArray { //draw all buttons for a given view
                button.setTitle(physicalButtonLabelsArray[counter], forState: UIControlState.Normal)
                button.titleLabel?.font = UIFont.boldSystemFontOfSize(15) //bold font
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                button.backgroundColor = UIColor.redColor()
                self.addSubview(button)
                button.alpha = 0.39
                counter += 1
            }
            for button in physicalButtonsForBackArray { //hide the buttons on the back of the IV
                button.hidden = true
            }
        } else if (self.viewChoice == "reviewOfSystems") {
            for button in self.rosButtonsArray { //draw all buttons for a given view
                button.setTitle(rosButtonLabelsArray[counter], forState: UIControlState.Normal)
                button.titleLabel?.font = UIFont.boldSystemFontOfSize(15) //bold font
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                button.backgroundColor = UIColor.redColor()
                self.addSubview(button)
                button.alpha = 0.39
                counter += 1
            }
            for button in rosButtonsForBackArray { //hide the buttons on the back of the IV
                button.hidden = true
            }
        }
        revealBreastButton()
        self.addSubview(addRotationButton()) //add configured rotation button
    }
    
    private func revealBreastButton() { //reveal breastButton for adult females in front Px view
        if (viewChoice == "physicalExam") && (rotated == false) {
            if (gender == 1 && childOrAdult == 0) {
                breastButton.hidden = false
            } else {
                breastButton.hidden = true
            }
        }
    }
    
    internal func configureButtonVisualsOnSelection(sender: PhysicalAndROSOrganSystemButton) {
        //Handle how buttons look after they have been selected - after the button has been selected & data has been entered, we should highlight it in green to let the user know it is done:
        if (sender.informationHasBeenEnteredForOrganSystem == true) { //set the selected button to green AFTER user is done entering info (call it after the escape button is pressed)
            sender.backgroundColor = UIColor.greenColor()
        }
    }
    
    //MARK: - Body Image Rotation
    
    func addRotationButton() -> UIButton {
        rotationButton.frame = CGRectMake(150, 560, 35, 35)
        rotationButton.setImage(UIImage(named: "rotate.png"), forState: UIControlState.Normal)
        rotationButton.addTarget(self, action: "rotationButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        return rotationButton
    }
    
    func rotationButtonClick(sender: UIButton) { //Renders rotated image w/ corresponding buttons
        if (self.viewChoice == "physicalExam") {
            if (self.rotated == false) { //rotation from front -> back (reveal back, hide front)
                for button in physicalButtonsArray { //hides ALL buttons
                    button.hidden = true
                }
                for button in physicalButtonsForBackArray { //reveals only the BACK buttons
                    button.hidden = false
                }
            } else { //rotation from back -> front (reveal front, hide back)
                for button in physicalButtonsArray { //reveals ALL buttons
                    button.hidden = false
                }
                for button in physicalButtonsForBackArray { //hides only the BACK buttons
                    button.hidden = true
                }
            }
        } else if (self.viewChoice == "reviewOfSystems") {
            if (self.rotated == false) { //rotation from front -> back (reveal back, hide front)
                for button in rosButtonsArray { //hide ALL
                    button.hidden = true
                }
                for button in rosButtonsForBackArray { //reveal BACK
                    button.hidden = false
                }
            } else { //rotation from back -> front (reveal front, hide back)
                for button in rosButtonsArray { //reveal ALL
                    button.hidden = false
                }
                for button in rosButtonsForBackArray { //hide BACK
                    button.hidden = true
                }
            }
        }
        self.image = getRotatedImageFile()
        revealBreastButton()
    }
    
    private func getRotatedImageFile() -> UIImage { //checks current rotation status & returns the opposite image for the set
        var newImageName = String()
        if (rotated == false) { //rotation from front -> back
            rotated = true
            switch self.index {
            case 1:
                newImageName = "adult_male_outline_back.png"
            case 2:
                newImageName = "adult_female_outline_back.png"
            case 3:
                newImageName = "child_male_outline_back.png"
            case 4:
                newImageName = "child_female_outline_back.png"
            default: //this case should never be triggered!
                newImageName = ""
            }
        } else { //rotation from back -> front
            rotated = false
            switch self.index {
            case 1:
                newImageName = "adult_male_outline_front.png"
            case 2:
                newImageName = "adult_female_outline_front.png"
            case 3:
                newImageName = "child_male_outline_front.png"
            case 4:
                newImageName = "child_female_outline_front.png"
            default: //this case should never be triggered!
                newImageName = ""
            }
        }
        return UIImage(named: newImageName)!
    }
    
    //MARK: - Organ System Button Actions
    
    func passButtonActionToSuperview(sender: PhysicalAndROSOrganSystemButton) {
        physicalAndROSView = (self.superview as? PhysicalAndROSView)
        physicalAndROSView?.passButtonActionToDataEntryView(sender)
    }
    
    func constitutionalButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        //***Important: these buttons are a great place for counters to check what items are clicked on & which ones are not (which will help us adjust the interface accordingly).
        if self.viewChoice == "physicalExam" {
            constitutionalButton.sectionsArray = ["General Appearance", "Level of Distress", "Ambulation"] //how to match labels -> sections? When 'Additional Notes' is tapped, open a text field for data entry.
            constitutionalButton.labelsArray = ["General Appearance": ["Cachectic", "Too Thin", "Overweight", "Obese", "Morbidly Obese", "Additional Notes"], "Level of Distress": ["Distress", "Acutely Ill", "Chronically Ill", "Additional Notes"], "Ambulation": ["Limited Ambulation", "Ambulation with Cane", "Ambulation with Walker", "In Wheelchair", "Additional Notes"]] //if 'distress' is selected, ask for how much distress (textField)
        } else if self.viewChoice == "reviewOfSystems" {
            constitutionalButton.sectionsArray = ["Constitution"]
            constitutionalButton.labelsArray = ["Constitution": ["Fever", "Night Sweats", "Weight gain", "Weight loss", "Exercise Intolerance", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func headAndNeckButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if self.viewChoice == "physicalExam" {
            headAndNeckButton.sectionsArray = ["Head", "Neck", "Lymph Nodes", "Thyroid"]
            headAndNeckButton.labelsArray = ["Head": ["Macrocephaly", "Microcephaly", "Evidence of Injury", "Additional Notes"], "Neck": ["Pain with Motion", "Tender", "Deviated Trachea", "Cervical Mass", "Crepitus", "Nuchal Rigidity", "Muscle Rigidity", "Additional Notes"], "Lymph Nodes": ["Cervical LAD", "Supraclavicular LAD", "Axillary LAD", "Inguinal LAD", "Additional Notes"], "Thyroid": ["Thyromegaly", "Tenderness", "Palpable Nodule", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func neurologicalSystemButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if self.viewChoice == "physicalExam" {
            neurologicalSystemButton.sectionsArray = ["Gait & Station", "Cranial Nerves", "Sensation", "Reflexes", "Coordination & Cerebellum"]
            neurologicalSystemButton.labelsArray = ["Gait & Station": ["Irregular Gait", "Wide-Based Gait", "Waddling", "Additional Notes"], "Cranial Nerves": ["Abnormal", "Additional Notes"], "Sensation": ["Abnormal", "Abnormal Monofilament Test", "Additional Notes"], "Reflexes": ["Abnormal DTRs", "Asymmetric", "Diminished", "Additional Notes"], "Coordination & Cerebellum": ["Finger-to-Nose Impaired", "Resting Tremor", "Intention Tremor", "Romberg Sign", "Additional Notes"]]
        } else if self.viewChoice == "reviewOfSystems" {
            neurologicalSystemButton.sectionsArray = ["Neuro"]
            neurologicalSystemButton.labelsArray = ["Neuro": ["Loss of Consciousness", "Weakness", "Numbness", "Seizures", "Dizziness", "Migraines", "Headaches", "Tremor", "Restless Legs", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func cardiovascularSystemButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if self.viewChoice == "physicalExam" {
            cardiovascularSystemButton.sectionsArray = ["Apical Impulse", "Heart Auscultation", "Neck Vessels", "Pulses Including Femoral/Pedal"]
            cardiovascularSystemButton.labelsArray = ["Apical Impulse": ["Displaced", "Accentuated", "Additional Notes"], "Heart Auscultation": ["Bradycardia", "Tachycardia", "Regularly Irregular Rhythm", "Irregularly Irregular Rhythm", "Murmur", "Rub", "Gallop", "Click", "SEM", "S2 with Physiologic Splitting", "Additional Notes"], "Neck Vessels": ["Carotid Bruit", "JVD", "Hepatojugular Reflex", "Additional Notes"], "Pulses Including Femoral/Pedal": ["Diminished", "Absent", "Additional Notes"]]
        } else if self.viewChoice == "reviewOfSystems" {
            cardiovascularSystemButton.sectionsArray = ["CV"]
            cardiovascularSystemButton.labelsArray = ["CV": ["Chest Pain", "Arm Pain on Exertion", "Shortness of Breath when Walking", "Shortness of Breath when Lying Down", "Palpitations", "Known Heart Murmur", "Light-headedness on Standing", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func respiratorySystemButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if self.viewChoice == "physicalExam" {
            respiratorySystemButton.sectionsArray = ["Respiratory Effort", "Percussion", "Auscultation"]
            respiratorySystemButton.labelsArray = ["Respiratory Effort": ["Dypneic", "Tachypneic", "Use of Accessory Muscles", "Intercostal Retractions", "Additional Notes"], "Percussion": ["Dullness or Flatness", "Hyperresonance", "Additional Notes"], "Auscultation": ["Decreased Breath Sounds", "Diminished Air Movement", "Inspiratory Wheezing", "Expiratory Wheezing", "Dry Rales/Crackles", "Wet Rales/Crackles", "Rhonchi", "Rales/Crackles on Left", "Rales/Crackles on Right", "Additional Notes"]]
        } else if self.viewChoice == "reviewOfSystems" {
            respiratorySystemButton.sectionsArray = ["Respiratory"]
            respiratorySystemButton.labelsArray = ["Respiratory": ["Cough", "Wheezing", "Shortness of Breath", "Coughing up Blood", "Sleep Apnea", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func gastrointestinalSystemButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if self.viewChoice == "physicalExam" {
            gastrointestinalSystemButton.sectionsArray = ["Bowel Sounds", "Inspection & Palpation", "Liver", "Spleen", "Hernia"]
            gastrointestinalSystemButton.labelsArray = ["Bowel Sounds": ["Increased", "Diminished", "Absent", "High Pitched", "Additional Notes"], "Inspection & Palpation": ["Distended", "Epigastric Tenderness", "LUQ Tenderness", "RUQ Tenderness", "LLQ Tenderness", "RLQ Tenderness", "Suprapubic Tenderness", "Guarding", "Rebound Tenderness", "Mass", "CVA Tenderness", "Additional Notes"], "Liver": ["Tenderness", "Hepatomegaly", "Additional Notes"], "Spleen": ["Tenderness", "Splenomegaly", "Additional Notes"], "Hernia": ["Inguinal", "Periumbilical", "Incisional", "Ventral", "Additional Notes"]] //don't like CVA tenderness here (should be in back)!
        } else if self.viewChoice == "reviewOfSystems" {
            gastrointestinalSystemButton.sectionsArray = ["GI"]
            gastrointestinalSystemButton.labelsArray = ["GI": ["Abdominal Pain", "Vomiting", "Change in Appetite", "Diarrhea", "Vomiting Blood", "Dyspepsia", "GERD", "Black or Tarry Stools", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func genitourinarySystemButtonClick(sender: PhysicalAndROSOrganSystemButton) { //Gender choice changes labels
        if self.viewChoice == "physicalExam" {
            if self.gender == 0 { //Male patient
                genitourinarySystemButton.sectionsArray = ["Male GU Exam", "Penis", "Scrotum", "Testes", "Prostate"]
                genitourinarySystemButton.labelsArray = ["Male GU Exam": ["Patient Does Not Know Exam", "Additional Notes"], "Penis": ["Lesion", "Discharge", "Abnormal Foreskin", "Circumcised", "Additional Notes"], "Scrotum": ["Swelling", "Tenderness", "Hydrocele", "Varicocele", "Additional Notes"], "Testes": ["Not Descended", "Enlarged", "Mass", "Tenderness", "Additional Notes"], "Prostate": ["Asymmetrical", "Enlarged", "Tender", "Nodule", "Hard/Indurated", "Boggy (Fluctuant)", "Prostate", "Additional Notes"]]
            } else { //Female patient
                genitourinarySystemButton.sectionsArray = ["Female GU Exam", "External Genitalia", "Vagina", "Cervix", "Uterus", "Adnexae", "Bladder & Urethra"]
                genitourinarySystemButton.labelsArray = ["Female GU Exam": ["Patient Does Not Know Exam", "Additional Notes"], "External Genitalia": ["Abnormal", "Lesion", "Rash", "Additional Notes"], "Vagina": ["Abnormal Discharge", "Purulent Discharge", "Dry Mucosa", "Mass", "Tenderness", "Atrophic Mucosa", "Additional Notes"], "Cervix": ["Discharge", "Purulent Discharge", "Cervical Motion Tenderness", "Sample Taken for Pap Smear", "Absent Cervix", "Additional Notes"], "Uterus": ["Anteverted", "Retroverted", "Irregular Contour", "Mass", "Enlarged", "Tender", "Uterine Prolapse", "Absent", "Additional Notes"], "Adnexae": ["Palpable Mass", "Tender", "Additional Notes"], "Bladder & Urethra": ["Urethral Discharge", "Distended Bladder", "Cystocele", "Additional Notes"]]
            }
        } else if self.viewChoice == "reviewOfSystems" {
            genitourinarySystemButton.sectionsArray = ["GU"]
            genitourinarySystemButton.labelsArray = ["GU": ["Incontinence", "Difficulty Urinating", "Hematuria", "Increased Frequency", "Incomplete Emptying", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func breastButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if self.viewChoice == "physicalExam" {
            breastButton.sectionsArray = ["Breast Exam", "Breast"]
            breastButton.labelsArray = ["Breast Exam": ["Patient Does Not Know Exam", "Additional Notes"], "Breast": ["Mass", "Abnormal Tenderness", "Abnormal Discharge", "Fibrocystic", "Asymmetry", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func backButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if self.viewChoice == "physicalExam" {
            backButton.sectionsArray = ["Back"]
            backButton.labelsArray = ["Back": ["Scoliosis", "Kyphosis", "Abnormal Lordosis", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func integumentarySystemButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if self.viewChoice == "physicalExam" {
            integumentarySystemButton.sectionsArray = ["Inspection & Palpation", "Nails"]
            integumentarySystemButton.labelsArray = ["Inspection & Palpation": ["Rash", "Lesion", "Ulcer", "Indurated", "Nodule", "Decreased Turgor", "Jaundice", "Tattos", "Additional Notes"], "Nails": ["Abnormal", "Additional Notes"]]
        } else if self.viewChoice == "reviewOfSystems" {
            integumentarySystemButton.sectionsArray = ["Skin"]
            integumentarySystemButton.labelsArray = ["Skin": ["Abnormal Mole", "Jaundice", "Rash", "Laceration", "Itching", "Dry Skin", "Growths/Lesions", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func musculoskeletalSystemButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if self.viewChoice == "physicalExam" {
            musculoskeletalSystemButton.sectionsArray = ["Motor Strength & Tone", "Joints, Bones, & Muscles", "Extremities"]
            musculoskeletalSystemButton.labelsArray = ["Motor Strength & Tone": ["Abnormal Motor Strength", "Hypertonicity", "Hypotonicity", "Additional Notes"], "Joints, Bones, & Muscles": ["Limited ROM", "Bony Deformity", "Contracture", "Malalignment", "Tenderness", "Additional Notes"], "Extremities": ["Cyanosis", "Edema", "Varicosities", "Palpable Cord", "Clubbing", "Homan's Sign"]]
        } else if self.viewChoice == "reviewOfSystems" {
            musculoskeletalSystemButton.sectionsArray = ["MS"]
            musculoskeletalSystemButton.labelsArray = ["MS": ["Muscle Aches", "Muscle Weakness", "Arthralgia/Joint Pain", "Back Pain", "Swelling in the Extremities", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func psychiatricButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if self.viewChoice == "physicalExam" {
            psychiatricButton.sectionsArray = ["Insight", "Mental Status", "Orientation", "Memory"]
            psychiatricButton.labelsArray = ["Insight": ["Poor Insight", "Additional Notes"], "Mental Status": ["Abnormal Affect", "Lethargic", "Confused", "Anxious", "Depressed", "Agitated", "Additional Notes"], "Orientation": ["Not Oriented to Time", "Not Oriented to Place", "Not Oriented to Person", "Additional Notes"], "Memory": ["Recent Memory Abnormal", "Remote Memory Abnormal", "Additional Notes"]]
        } else if self.viewChoice == "reviewOfSystems" {
            psychiatricButton.sectionsArray = ["Psych"]
            psychiatricButton.labelsArray = ["Psych": ["Depression", "Sleep Disturbances", "Feeling Unsafe in Relationship", "Alcohol Abuse", "Anxiety", "Hallucinations", "Suicidal Thoughts", "Restless Sleep", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func endocrineSystemButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if (self.viewChoice == "reviewOfSystems") {
            endocrineSystemButton.sectionsArray = ["Endocrine"]
            endocrineSystemButton.labelsArray = ["Endocrine": ["Fatigue", "Increased Thirst", "Hair Loss", "Increased Hair Growth", "Cold Intolerance", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func hematologicLymphaticSystemButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if (self.viewChoice == "reviewOfSystems") {
            hematologicLymphaticSystemButton.sectionsArray = ["Lymph"]
            hematologicLymphaticSystemButton.labelsArray = ["Lymph": ["Swollen Glands", "Easy Bruising", "Excessive Bleeding", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func eyesButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if self.viewChoice == "physicalExam" {
            eyesButton.sectionsArray = ["Lids & Conjunctivae", "Pupils", "Corneas", "Fundoscopic", "EOM", "Lens", "Sclerae"]
            eyesButton.labelsArray = ["Lids & Conjunctivae": ["Injected", "Discharge", "Pallor", "Xanthelasma", "Ptosis", "Exophthalmos", "Additional Notes"], "Pupils": ["Non-reactive to Light", "Anisocoria", "Additional Notes"], "Corneas": ["Arcus Senilis", "Abrasion", "Opacity", "Ulceration", "Additional Notes"], "Fundoscopic": ["Papilledema", "Increased Cupping", "Blurred Margins", "Narrowing of Arterioles", "A-V Nicking", "Exudate", "Soft Exudate", "Hard Exudate", "Hemorrhage", "Optic Disc Not Well Visualized", "Fundus Not Well Visualized", "Additional Notes"], "EOM": ["Dysconjugated", "Strabismus", "Nystagmus", "Additional Notes"], "Lens": ["Cataract", "Additional Notes"], "Sclerae": ["Injected", "Icteric", "Abrasion", "Additional Notes"]]
        } else if self.viewChoice == "reviewOfSystems" {
            eyesButton.sectionsArray = ["Eyes"] //empty
            eyesButton.labelsArray = ["Eyes": ["Dry Eyes", "Vision Change", "Irritation", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func enmtButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if self.viewChoice == "physicalExam" {
            enmtButton.sectionsArray = ["Ears", "Hearing", "Nose", "Lips, Teeth, & Gums", "Oropharynx"]
            enmtButton.labelsArray = ["Ears": ["External Ear Lesion", "EAC Ceruminous", "EAC Discharge", "TM Erythematous", "TM Bulging", "TM Perforated", "TM Opacified", "TM Immobile", "Middle Ear Fluid", "Additional Notes"], "Hearing": ["Hearing Decreased", "Weber's Sign", "Additional Notes"], "Nose": ["External Nose Lesion", "Nares Non-Patent", "Deviated Septum", "Nasal Obstruction", "Sinus Tenderness", "Nasal Discharge", "Nasal Discharge-Purulent", "Nasal Discharge-Rhinorrhea", "Post Nasal Drip", "Additional Notes"], "Lips, Teeth, & Gums": ["Mouth Ulcers", "Gingival Erythema", "Poor Dentition", "Edentulous", "Additional Notes"], "Oropharynx": ["Erythema", "Tonsils Enlarged", "Exudate", "Tonsils Absent", "Additional Notes"]]
        } else if self.viewChoice == "reviewOfSystems" {
            enmtButton.sectionsArray = ["Ears", "Nose", "Mouth/Throat"]
            enmtButton.labelsArray = ["Ears": ["Difficulty Hearing", "Ear Pain", "Additional Notes"], "Nose": ["Frequent Nosebleeds", "Nose Problems", "Sinus Problems", "Additional Notes"], "Mouth/Throat": ["Sore Throat", "Bleeding Gums", "Snoring", "Dry Mouth", "Mouth Ulcers", "Oral Abnormalities", "Teeth Problems", "Mouth Breathing", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func chaperoneButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if (self.viewChoice == "physicalExam") {
            chaperoneButton.sectionsArray = ["Chaperone"]
            chaperoneButton.labelsArray = ["Chaperone": ["Present", "Offered & Declined", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func rectalSystemButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if (self.viewChoice == "physicalExam") {
            rectalSystemButton.sectionsArray = ["Rectal"]
            rectalSystemButton.labelsArray = ["Rectal": ["Decreased Tone", "Hemorrhoids", "Fissure", "Mass", "Stool Heme Positive", "Rectocele", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }
    
    func allergicImmunologicSystemButtonClick(sender: PhysicalAndROSOrganSystemButton) {
        if (self.viewChoice == "reviewOfSystems") {
            allergicImmunologicSystemButton.sectionsArray = ["Immune"]
            allergicImmunologicSystemButton.labelsArray = ["Immune": ["Runny Nose", "Sinus Pressure", "Itching", "Hives", "Frequent Sneezing", "Additional Notes"]]
        }
        passButtonActionToSuperview(sender)
    }

}
