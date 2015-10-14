//Garbage Code that might come in handy later:

//Setting Layers: 
textField.layer.zPosition = 1

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