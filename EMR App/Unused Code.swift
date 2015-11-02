//Garbage Code that might come in handy later:

//Setting Layers: 
textField.layer.zPosition = 1

//Setting textField border
textField.layer.borderWidth = 1.0 
textField.layer.borderColor = UIColor.blackColor().CGColor

//Grabbing input values for notification feed & dictionary:
//            var jsonDictToServer = Dictionary<String, [String : AnyObject]>()
//            jsonDictToServer[(openScope?.getFieldName())!] = Dictionary<String, AnyObject>()
//            var inputValuesForFieldName = jsonDictToServer[(openScope?.getFieldName())!]! //set the overall key to the current fieldName. The values will depend on the field name.
//
//            var counter = 1
//            var notificationText = ""
//            for view in dataEntryImageView.subviews {
//                //Grab the values entered in text fields for the notificationsFeed & mapping dictionary:
//                if (view.tag > 0 && view.tag < tableViewCellLabels!.count) {
//                    inputValuesForFieldName[tableViewCellLabels![counter - 1]] = ((view as? UITextField)?.text)!
//                    notificationText += tableViewCellLabels![counter - 1] + ": " + ((view as? UITextField)?.text)! + "\n"
//                }
//                counter += 1
//            }
//            //Grab the last text field's input value for feed & mapping dictionary:
//            notificationText += (tableViewCellLabels?.last!)! + ": " + input!
//            inputValuesForFieldName[(tableViewCellLabels?.last!)!] = input!
//            print(inputValuesForFieldName)

//            notificationsFeed.text = notificationText //display all mapped values to user
//            fadeIn()
//            fadeOut()
//            dataEntryImageView.canResignFirstResponder() //resign 1st responder?
//            tableViewCellLabels = nil //clear array w/ labels
//            configureViewForEntry("fieldName")
//            openScope = nil //Last, close the scope


//Drawing & Removing Custom Views in VC:
let customView = PatientNameEntryView(frame: CGRect(x: 60, y: 100, width: view.frame.width - 60, height: view.frame.height - 150))
customView.tag = 1000
self.view.addSubview(customView)
for subview in view.subviews {
    if subview.tag == 1000 {
        subview.removeFromSuperview()
    }
}

//Drawing Margins:
//    func configureMargins() {
//        mainImageView.image = nil //clear existing lines
//        if (newWidth != nil) { //Rotation has occurred
//            drawLineFrom(CGPoint(x: 0, y: 0), toPoint: CGPoint(x: newWidth!, y: 0)) //Top Layout Margin (separates from status bar)
//            drawLineFrom(CGPoint(x: 0, y: 80), toPoint: CGPoint(x: newWidth!, y: 80)) //Top Horizontal Margin
//            drawLineFrom(CGPoint(x: 80, y: 0), toPoint: CGPoint(x: 80, y: newHeight!)) //Left Vertical Margin
//            drawLineFrom(CGPoint(x: (newWidth! - 65), y: 0), toPoint: CGPoint(x: (newWidth! - 65), y: newHeight!)) //Right Vertical Margin
//        } else { //No rotation has occurred
//            print("Standard Config")
//            drawLineFrom(CGPoint(x: view.frame.minX, y: view.frame.minY), toPoint: CGPoint(x: view.frame.maxX, y: view.frame.minY)) //Top Layout Margin
//            drawLineFrom(CGPoint(x: view.frame.minX, y: (view.frame.minY + 80)), toPoint: CGPoint(x: view.frame.width, y: (view.frame.minY + 80))) //Top Horizontal Margin
//            drawLineFrom(CGPoint(x: (view.frame.minX + 80), y: view.frame.minY), toPoint: CGPoint(x: (view.frame.minX + 80), y: view.frame.height)) //Left Vertical Margin
//            drawLineFrom(CGPoint(x: (view.frame.width - 85), y: view.frame.minY), toPoint: CGPoint(x: (view.frame.width - 85), y: view.frame.height)) //Right Vertical Margin
//        }
//    }

//    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
//        //This method draws the margins in our view:
//        //First, set up a context holding the image currently in the mainImageView.
//        UIGraphicsBeginImageContext(view.frame.size) //'View' specifies the root view in the view hierarchy
//        let context = UIGraphicsGetCurrentContext()
//        mainImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
//
//        //Get the current touch point & then draw a line from the last point to the current point. The touch events trigger so quickly that the result is a smooth curve:
//        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
//        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
//
//        //Set the drawing parameters for line size & color:
//        CGContextSetLineCap(context, .Round)
//        CGContextSetLineWidth(context, 2.0)
//        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0)
//        CGContextSetBlendMode(context, .Normal)
//
//        //Draw the path:
//        CGContextStrokePath(context)
//
//        //Wrap up the drawing context to render the new line:
//        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
//        mainImageView.alpha = 1.0
//        UIGraphicsEndImageContext()
//    }

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

//MARK: - Organ System Labels (from Schwartz text)
func constitutionalButtonClick(sender: UIButton) {
    if self.viewChoice == "physicalExam" {
        dataEntryLabelArray = ["General Appearance", "Alert?", "Awake?", "Oriented?", "Distress?", "Other"]
    } else if self.viewChoice == "reviewOfSystems" {
        dataEntryLabelArray = ["Fatigue", "Weight Loss", "Weight Gain", "Loss of Appetite", "Energy Level", "Fever", "Sweating", "Other"]
    }
}

func headAndNeckButtonClick(sender: UIButton) {
    self.dataEntrySectionArray = ["General", "Eyes", "Ears", "Nose", "Mouth"]
    if self.viewChoice == "physicalExam" {
        dataEntryLabelArray = ["Scalp", "Lymph Nodes", "Thyroid", "Carotids", "Trachea", "PERRLA", "EOMI", "Visual Fields", "Visual Acuity", "Ophthalmoscopic Exam", "Auditory Acuity", "Otoscopic Exam", "Nasal Septum", "Sense of Smell", "Sinus Pain", "Facial Sensation", "Lips", "Gums", "Teeth", "Palate Deviation", "Tongue Deviation", "Gag Reflex","Other"]
    } else if self.viewChoice == "reviewOfSystems" {
        dataEntryLabelArray = ["Headache", "Head Injury", "Facial Pain", "Sinus Infection", "!!!Visual Changes", "Corrective Lenses", "Diplopia", "Blurred Vision", "Halos?", "Tearing", "Inflammation", "Discharge", "Spots", "Photophobia", "Eye Pain", "Trauma", "Cataracts", "Glaucoma", "!!!Deafness", "Tinnitus", "Ear Pain", "Discharge", "Infections", "!!!Change in Smell", "Obstruction", "Discharge", "Post-nasal Drip", "Epistaxis", "Trauma", "Nose Pain", "!!!Soreness", "Bleeding", "Ulcers", "Dentition", "Dentures", "Hoarseness", "Sore Throat", "Dysphagia", "Odynophagia", "!!!Masses", "Swollen Glands", "Stiffness", "Goiter", "Tenderness", "Trauma", "Other"]
    }
}

func neurologicalSystemButtonClick(sender: UIButton) {
    self.dataEntrySectionArray = ["General Neuro", "Muscular", "Sensory", "Cerebellar/Vestibular"]
    if self.viewChoice == "physicalExam" {
        dataEntryLabelArray = ["Mental Status", "Cranial Nerve Exam", "Orientation to Person/Place/Time", "Memory", "Muscle Strength", "Muscle Tone", "Reflexes", "Joint Position Sense", "Touch Discrimination", "Vibration Sense", "Rapid Alternating Movements", "Gait", "Romberg Test", "Other"]
    } else if self.viewChoice == "reviewOfSystems" {
        dataEntryLabelArray = ["Personality Changes", "Loss of Consciousness", "Memory Changes", "Syncope", "Aphasia", "Dysarthria", "Seizures", "Dizziness/Lightheadedness", "!!!Weakness/Paralysis", "Tremors", "Involuntary Movements", "Poor Coordination", "!!!Anesthesia", "Paresthesia", "Hyperesthesia", "!!!Loss of Balance", "Ataxia", "Vertigo", "Nystagmus", "Other"]
    }
}

func cardiovascularSystemButtonClick(sender: UIButton) {
    if self.viewChoice == "physicalExam" {
        dataEntryLabelArray = ["Chest Appearance", "Heart Sounds", "Murmurs", "JVD", "PMI", "Ventricular Heave/Thrills", "Other"]
    } else if self.viewChoice == "reviewOfSystems" {
        dataEntryLabelArray = ["Chest Pain", "Dyspnea on Exertion", "Orthopnea", "Cough", "Palpitations", "Abnormal Rhythm", "Other"]
    }
}

func respiratorySystemButtonClick(sender: UIButton) {
    if self.viewChoice == "physicalExam" {
        dataEntryLabelArray = ["Tactile Fremitus", "Lung Sounds", "Wheezes?", "Rales?", "Ronchi?", "Percussion", "Other"]
    } else if self.viewChoice == "reviewOfSystems" {
        dataEntryLabelArray = ["Chest Pain", "Dyspnea", "Cough", "Sputum", "Wheezing", "Bronchitis", "Pneumonia", "Other"]
    }
}

func gastrointestinalSystemButtonClick(sender: UIButton) {
    if self.viewChoice == "physicalExam" {
        dataEntryLabelArray = ["Appearance", "Tenderness", "Distension", "Bowel Sounds", "Hepatomegaly", "Splenomegaly", "Ascites", "Aortic/Renal Bruit", "Hernias", "Hepatojugular Reflex", "Other"]
    } else if self.viewChoice == "reviewOfSystems" {
        dataEntryLabelArray = ["Heartburn", "Nausea", "Vomiting", "Abdominal Pain", "Distension", "Gas", "Bowel Habits", "Bowel Quality", "Jaundice", "Fatty Food Intolerane", "Other"]
    }
}

func genitourinarySystemButtonClick(sender: UIButton) { //Gender choice changes labels
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
}

func breastButtonClick(sender: UIButton) {
    if self.viewChoice == "physicalExam" {
        dataEntryLabelArray = ["Masses", "Other"]
    } else if self.viewChoice == "reviewOfSystems" {
        dataEntryLabelArray = ["Knows Self-Exam?", "Tenderness", "Asymmetry", "Mass", "Nipple Discharge", "Milky Discharge", "Change in Size", "Other"]
    }
}

func backButtonClick(sender: UIButton) {
    if self.viewChoice == "physicalExam" {
        dataEntryLabelArray = ["Edema", "Sacroiliac Joint Tenderness", "Costovertebral Angle Tenderness", "Posture", "Spine Appearance"]
}

func peripheralVascularSystemButtonClick(sender: UIButton) {
    if self.viewChoice == "physicalExam" {
        dataEntryLabelArray = ["Edema", "Carotid Bruit", "Femoral Bruit", "Radial Pulse", "Femoral Pulse", "Dorsalis Pedis Pulse", "Posterior Tibial Pulse", "Other"]
    } else if self.viewChoice == "reviewOfSystems" {
        dataEntryLabelArray = ["Cyanosis/Discoloration", "Ankle/Leg Swelling", "Leg Pain on Walking", "Varicose Veins", "Hair Loss in Extremities", "Other"]
    }
}

func musculoskeletalSystemButtonClick(sender: UIButton) {
    self.dataEntrySectionArray = ["Skin", "Muscles", "Joints"]
    if self.viewChoice == "physicalExam" {
        dataEntryLabelArray = ["Joint Swelling/Edema", "Joint Redness", "Range of Motion", "Other"]
    } else if self.viewChoice == "reviewOfSystems" {
        dataEntryLabelArray = ["Rash", "Itching", "Color Change", "Lesions/Ulcerations", "Changes in Moles/Spots", "Redness", "!!!Arthralgia", "Joint Inflammation", "Joint Stiffness", "Joint Pain", "Limiting of Motion", "!!!Back Pain", "Neck Pain", "Muscle Pain", "Muscle Weakness", "Atrophy", "!!!Bone Pain", "Fractures", "Other"]
}

func psychiatricButtonClick(sender: UIButton) {
    dataEntryLabelArray = ["Suicidal Ideation", "Psychotic Symptoms", "Other"]
}

func endocrineSystemButtonClick(sender: UIButton) {
    dataEntryLabelArray = ["Hyperglycemia", "Polydipsia", "Polyuria", "Heat/Cold Intolerance", "Excessive Sweating", "Loss of Hair/Increased Hair", "Skin Dryness", "Increased/Decreased Body Fat", "Menstrual Irregularity", "Other"]
}

func hematologicLymphaticSystemButtonClick(sender: UIButton) {
    dataEntryLabelArray = ["Anemia", "Paleness", "Weakness", "Blood Loss", "Easy Bruising or Bleeding", "Other"]
}

//Networking code -> Athena API
//        let url = NSURL(string: "https://api.athenahealth.com/preview1/1/practiceinfo")
//        let dataParser = EMRDataParser(url: url!)
//        dataParser.ParseJSON {
//            (let returnedEMRData) in
//            if let data = returnedEMRData {
//                print("Total Count: \(data.totalCount)")
//                print("Practice Info: \(data.practiceInfo)")
//                if let practiceInfo = data.practiceInfo {
//                    let value = practiceInfo[0]
//                    let id = value["practiceid"]
//                    print("Practice ID: \(id)\n")
//                }
//            }
//        }

//        let url2 = NSURL(string: "https://api.athenahealth.com/preview1/195900/departments?limit=10&offset=1&providerlist=false&showalldepartments=false")
//        let dataParser2 = EMRDataParser(url: url2!)
//        dataParser2.ParseJSON {
//            (let returnedEMRData) in
//            if let data = returnedEMRData {
//                print("\nTotal Count: \(data.totalCount)")
//                if let depts = data.departments {
//                    var departmentIDs : [AnyObject] = []
//                    for department in depts {
//                        let departmentID = department["departmentid"]
//                        departmentIDs.append(departmentID!)
//                    }
//                    print("\nDepartment ID #s: \(departmentIDs)")
//                }
//            }
//        }


