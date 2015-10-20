//  DataEntryModeViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/21/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Controls the Data Entry portion of the app for information input -> EMR.

import UIKit
import CoreData

class DataEntryModeViewController: UIViewController, LoginViewControllerDelegate, PatientSelectionViewControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var currentUser: String? //current user (HCP) who is logged in
    var openScope: EMRField? //handles MK identification & data mapping -> EMR
    var patientFileWasJustOpened: Bool = false //checks if patient file was just opened (for notification)
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var fieldNameTextField: UITextField!
    @IBOutlet weak var fieldNameEntryLabel: UILabel!
    @IBOutlet weak var currentPatientButton: UIButton!
    @IBOutlet weak var currentUserButton: UIButton!
    @IBOutlet weak var notificationsFeed: UILabel! //Convert notification feed -> scrolling set of TV cells instead of a text view
    
    //CurrentUser & CurrentPatient Views (this can be achieved more cleanly using a popover segue):
    @IBOutlet weak var patientInfoView: UIView!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var currentPatientLabel: UILabel!
    @IBOutlet weak var currentUserLabel: UILabel!
    
    //Table View & Associated Side View:
    @IBOutlet weak var labelsTableView: UITableView!
    @IBOutlet weak var dataEntryImageView: UIImageView!
    var tableViewCellLabels: [String]? //labels in TV cells based on entered MK
    let tableViewCellColors: [UIColor] = [UIColor.lightGrayColor(), UIColor.darkGrayColor(), UIColor.whiteColor(), UIColor.yellowColor()] //We will color code the labels to the partitions
    var newWidth: CGFloat? //on rotation, the width of the incoming view
    var newHeight: CGFloat? //on rotation, the height of the incoming view
    var physicalOrROSView: PhysicalAndROSView? //renders Px or ROS view
    
    //Template Buttons:
    @IBOutlet weak var vitalsButton: UIButton!
    @IBOutlet weak var hpiButton: UIButton!
    @IBOutlet weak var medicationsButton: UIButton!
    @IBOutlet weak var allergiesButton: UIButton!
    @IBOutlet weak var physicalButton: UIButton!
    @IBOutlet weak var rosButton: UIButton!
    
    //DataEntryIV - Additional Item Rendering:
    @IBOutlet weak var plusButton: UIButton! //button for adding additional items in appropriate views
    @IBOutlet weak var currentItemNumberLabel: UILabel! //label indicating current item # for view
    
    //MARK: - Standard View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sets the DEMVC as delegate & datasource for TV:
        labelsTableView.delegate = self
        labelsTableView.dataSource = self
        labelsTableView.hidden = true
        dataEntryImageView.hidden = true
        
        //Configure fieldName entry view to start:
        configureViewForEntry("fieldName")
        
        //Difficulty tracking the keyboard's status in this view. For some reason, the functions on this view are called in the patientSelection & Login views (probably b/c we segue modally), so there is interference. We might have to redefine. 
    }
    
    override func viewDidAppear(animated: Bool) {
        if loggedIn == false {//If user isn't logged in, modally segue -> login screen. Need this line b/c 'didSet' function is NOT called when we initially set value of 'loggedIn'.
            performSegueWithIdentifier("showLogin", sender: nil)
        }
        
        if currentPatient == nil { //user must select patient to proceed
            performSegueWithIdentifier("showPatientSelection", sender: nil)
        }
        
        if (patientFileWasJustOpened == true) {
            notificationsFeed.text = "Patient file has been opened for \((currentPatient?.name)!.uppercaseString)"
            fadeIn()
            fadeOut()
            patientFileWasJustOpened = false
        }
        
        print("Current User (DEMVC): \(currentUser)")
        print("Current Patient (DEMVC): \(currentPatient?.name)")
        
        //Alternative way to authenticate using user defaults:
        //        let preferences : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        //        let loggedInCheck : Int = preferences.integerForKey("ISLOGGEDIN") as Int
        //        if (loggedInCheck != 1) {
        //            self.performSegueWithIdentifier("showLogin", sender: self)
        //        } else {
        //            self.loginStatusLabel.text = preferences.valueForKey("USERNAME") as? String
        //        }
        
        //Call the correct first responder depending on view status:
        setFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - View Rotation
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait) {
            print("Device is now in Portrait. Width = \(size.width). Height = \(size.height)")
        } else {
            print("Device is now in Landscape. Width = \(size.width). Height = \(size.height)")
        }
        
        //Redraw the TV & dataEntryImageView on rotation when the table view is active. Set newWidth & newHeight to indicate rotation has occurred while the TV & imageView were open
        if labelsTableView.hidden == false {
            newWidth = size.width
            newHeight = size.height
            configureViewForEntry("fieldValue")
        }
    }
    
    //MARK: - Default View Configuration
    
    func configureViewForEntry(desiredView: String) { //Configures view
        switch desiredView {
        case "fieldName": //Configure view for field name entry
            //Hide fieldValue entry views:
            labelsTableView.hidden = true
            dataEntryImageView.hidden = true
            plusButton.hidden = true
            currentItemNumberLabel.hidden = true
            
            //Bring up 'Field Name' Entry Views, set delegate & 1st responder:
            fieldNameEntryLabel.hidden = false
            fieldNameTextField.hidden = false
            fieldNameTextField.delegate = self
            fieldNameTextField.becomeFirstResponder()
        case "fieldValue":
            //Hide the fieldName entry views & pull up the formatted TV & imageView:
            fieldNameEntryLabel.hidden = true
            fieldNameTextField.hidden = true
            fieldNameTextField.resignFirstResponder()
            renderDataEntryImageView(tableViewCellLabels!.count)
            labelsTableView.reloadData() //refreshes visible TV cells w/ existing data
            labelsTableView.hidden = false
            dataEntryImageView.hidden = false
        default:
            print("Error. Switch case triggered unknown statement")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool { //Configure behavior for 'RETURN' button
        plusButton.hidden = true //re-hide plus button & itemLabel (in case they were opened)
        currentItemNumberLabel.hidden = true
        let input = textField.text
        textField.text = ""
        textField.resignFirstResponder()
        
        if textField.tag == 1 { // sender is fieldName text field
            openScope = EMRField(inputWord: input!, currentPatient: currentPatient!)
            if (openScope!.matchFound()) { //Open Scope & render view according to fieldName
                print("Match found")
                notificationsFeed.text = "Scope has been opened for '\(openScope!.getFieldName()!)' field"
                fadeIn()
                fadeOut()
                        
                //Check if the user requested a physical or ROS view:
                if (openScope?.getFieldName() == "physicalExam" || openScope?.getFieldName() == "reviewOfSystems") { //Render Px or ROS View
                    configurePhysicalOrROSView((openScope?.getFieldName())!)
                } else { //NOT a Px or ROS view
                    tableViewCellLabels = openScope?.getLabelsForMK() //set the # of tableView cells according to the MK
                    configureViewForEntry("fieldValue")
                }
            } else {//'matchFound' == nil
                openScope = nil
                print("No match found!")
                //Keep the first responder here & accept a new field name entry:
                configureViewForEntry("fieldName")
            }
        } else if textField.tag == 100 { //Sender is lastTextField from dataEntryImageView sending FVs
            //Obtain dictionary & notificationText containing input values; send dictionary -> central web server/persistent store & show notification, then configure the 'fieldName' view:
            getInputValuesFromTextFields(input!, notificationString: { (let notification) in
                self.notificationsFeed.text = notification //display all mapped values in feed
                })
            for (item, value) in (openScope?.jsonDictToServer)! { //output dictionary contents
                print("Dict: \(item): \(value)")
            }
            fadeIn()
            fadeOut()
            dataEntryImageView.viewWithTag(1)?.resignFirstResponder() //resign 1st responder
            tableViewCellLabels = nil //clear array w/ labels
            configureViewForEntry("fieldName")
            openScope = nil //close the existing scope
        } else if textField.tag == 200 { //sender is Px & ROS dataEntryView textField
            switch input!.lowercaseString { //configure view based on input
            case "g":
                physicalOrROSView?.generalAppearanceButtonClick((physicalOrROSView?.generalAppearanceButton)!)
            case "hn":
                physicalOrROSView?.headAndNeckButtonClick((physicalOrROSView?.headAndNeckButton)!)
            case "n":
                physicalOrROSView?.neurologicalSystemButtonClick((physicalOrROSView?.neurologicalSystemButton)!)
            case "p":
                physicalOrROSView?.psychiatricButtonClick((physicalOrROSView?.psychiatricButton)!)
            case "h":
                physicalOrROSView?.cardiovascularSystemButtonClick((physicalOrROSView?.cardiovascularSystemButton)!)
            case "l":
                physicalOrROSView?.respiratorySystemButtonClick((physicalOrROSView?.respiratorySystemButton)!)
            case "gi":
                physicalOrROSView?.gastrointestinalSystemButtonClick((physicalOrROSView?.gastrointestinalSystemButton)!)
            case "gu":
                physicalOrROSView?.genitourinarySystemButtonClick((physicalOrROSView?.genitourinarySystemButton)!)
            case "pe":
                physicalOrROSView?.peripheralVascularSystemButtonClick((physicalOrROSView?.peripheralVascularSystemButton)!)
            case "s":
                physicalOrROSView?.spineAndBackButtonClick((physicalOrROSView?.spineAndBackButton)!)
            case "m":
                physicalOrROSView?.musculoskeletalSystemButtonClick((physicalOrROSView?.musculoskeletalSystemButton)!)
            case "b":
                physicalOrROSView?.breastButtonClick((physicalOrROSView?.breastButton)!)
            default:
                notificationsFeed.text = "No results found for entry. Please enter a valid abbreviation"
                fadeIn()
                fadeOut()
            }
        }
        return true
    }
    
    func setFirstResponder() { //called any time DEM appears on screen, sets 1st responder
        //When user returns to this screen, we want to bring up the previous 1st responder again:
        if (fieldNameTextField.hidden == false) {
            fieldNameTextField.becomeFirstResponder()
        } else if (dataEntryImageView.hidden == false) { //reset 1st responder -> status @ switch
            //Find every empty textField present in the view (i.e. any field w/o text in it) & set 1st responder to the empty field w/ the LOWEST tag #.
            var emptySubviewTagArray: [Int] = []
            var smallestTag: Int = 101 //starting value must be > than the largest possible tag (100)
            for subview in dataEntryImageView.subviews {
                if (subview as! UITextField).text == "" {
                    emptySubviewTagArray.append(subview.tag)
                }
            }
            for tagValue in emptySubviewTagArray {
                if (tagValue < smallestTag) {
                    smallestTag = tagValue
                }
            }
            if (smallestTag != 101) {
                dataEntryImageView.viewWithTag(smallestTag)?.becomeFirstResponder()
            } else {
                dataEntryImageView.viewWithTag(100)?.becomeFirstResponder()
            }
        }
    }
    
    //MARK: - Notification Feed Animations
    
    func fadeIn() { //Fades in the twitter feed instantly
        self.view.bringSubviewToFront(notificationsFeed)
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.notificationsFeed.alpha = 1.0
            }, completion: nil)
    }
    
    func fadeOut() { //Gradually fades out the twitter feed
        UIView.animateWithDuration(1.0, delay: 3.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.notificationsFeed.alpha = 0.0
            }, completion: nil)
    }
    
    //MARK: - Dynamic View Configuration (TV & ImageView)
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numberOfCells = tableViewCellLabels?.count {
            return numberOfCells
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //When we draw cells, put a background color for each cell that matches the color of the side view (create an array of colors & iterate through it as each cell is drawn, selecting a color from the array each time)! Can help user w/ visual cues.
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        if let labelArray = tableViewCellLabels { //Partition TV based on # of cells
            cell.textLabel?.text = labelArray[indexPath.row]
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            cell.textLabel?.textColor = UIColor.blueColor()
            cell.backgroundColor = tableViewCellColors[indexPath.row] //picks color from array, matched to color in partition
            tableView.separatorColor = UIColor.whiteColor()
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            cell.separatorInset = UIEdgeInsetsZero
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None //When user taps on cell, it does not change in appearance
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let labelArray = tableViewCellLabels {
            let numberOfLabels = CGFloat(labelArray.count)
            var cellHeight = CGFloat()
            if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight) {
                cellHeight = 619/numberOfLabels //device in landscape
            } else if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft) {
                cellHeight = 619/numberOfLabels //device in landscape
            } else if (UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait) {
                cellHeight = 875/numberOfLabels //device in portrait
            } else {//Check NF width to determine orientation. Update code to work on all iPads!!!
                if (view.frame.width < 800) {//Portrait - width = 768
                    cellHeight = 875/numberOfLabels
                } else { //Landscape - NF width = 1024
                    cellHeight = 619/numberOfLabels
                }
            }
            return cellHeight
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        //Disable selection of TV cells & prevent swiping functionality. User interaction is disabled from Interface Builder.
        return nil
    }
    
    func renderDataEntryImageView(numberOfLabels: Int) {
        for view in dataEntryImageView.subviews { //Before rendering, wipe out any old textLabels!
            view.removeFromSuperview()
        }
        dataEntryImageView.image = nil //Clears any existing lines drawn in the view
        
        //Compute the width & height of dataEntryImageView if rotation is occurring. If the values of newWidth/newHeight are nil, no rotation has happened yet! The initial view can be drawn with standard methods. The rotated view must take into account the new orientation.
        var rotationHasOccurred : Bool = false
        if (newWidth != nil) {
            rotationHasOccurred = true
        }
        
        print("Image View - Height: \(dataEntryImageView.frame.height). Width: \(dataEntryImageView.frame.width)")
        print("MinX: \(dataEntryImageView.frame.minX). MaxX: \(dataEntryImageView.frame.maxX)")
        print("MinY: \(dataEntryImageView.frame.minY). MaxY: \(dataEntryImageView.frame.maxY)")
        print("Table View - Height: \(labelsTableView.frame.height). Width: \(labelsTableView.frame.width)")
        
        if (!rotationHasOccurred) { //No rotation, first time the view has been opened
            let height = dataEntryImageView.frame.height
            let width = dataEntryImageView.frame.width
            partitionImageViewForOrientation(numberOfLabels, viewWidth: width, viewHeight: height)
        } else { //Rotation has occurred while the TV & imageView are visible
            let imageViewWidth = newWidth! - 260
            let imageViewHeight = newHeight! - 100
            partitionImageViewForOrientation(numberOfLabels, viewWidth: imageViewWidth, viewHeight: imageViewHeight)
        }
    }
    
    func partitionImageViewForOrientation(numberOfLabels: Int, viewWidth: CGFloat, viewHeight: CGFloat) { //Handles partitioning based on width & height of the imageView
        //If current fieldName allows for multiple sub-scopes, reveal the label & plus button:
        if (openScope?.getCurrentItem() != nil) {
            plusButton.hidden = false
            currentItemNumberLabel.hidden = false
            let label = (openScope?.getCurrentItem()!.0)!
            let count = (openScope?.getCurrentItem()!.1)!
            currentItemNumberLabel.text = "\(label) \(count)"
        }
        
        let numberOfPartitions = CGFloat(numberOfLabels)
        let partitionSize = viewHeight/numberOfPartitions
        if numberOfLabels > 1 { //No partitioning for only 1 label
            for partition in 1...(numberOfLabels - 1) {
                // Coordinate system - top left corner of the image view is point (0, 0).
                let partitionNumber = CGFloat(partition)
                drawLineFrom(CGPoint(x: 0, y: (partitionSize*partitionNumber)), toPoint: CGPoint(x: viewWidth, y: (partitionSize*partitionNumber)))
                print("From Point: (0, \(partitionSize*partitionNumber)). To Point: (\(dataEntryImageView.frame.width), \(partitionSize*partitionNumber))")
                
                //Match partition color w/ the label color!!! We need to add a separate UIView to each partition, and then add a unique textLabel & background color to that view. Add a UIView to cover each partition, then a centered textLabel inside the view. View should be in the top left corner & extend entire length & width of partitioned area.
//                let partitionView = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
//                partitionView.backgroundColor = tableViewCellColors[partition - 1]
                let product = 2 * partitionSize * partitionNumber - partitionSize
                let textField = UITextField(frame: CGRect(x: ((viewWidth * 0.25)/2), y: ((product - 50)/2), width: (viewWidth * 0.75), height: 50))
                textField.tag = partition //tag each textField for later reference
                textField.placeholder = "Please enter a value for the \(openScope!.getLabelsForMK()![partition - 1])"
                textField.textColor = UIColor.blackColor()
                textField.backgroundColor = UIColor.clearColor()
                textField.userInteractionEnabled = true //In IB, set user interaction = enabled for parent imageView as well or textField will not respond to touch!
                dataEntryImageView.addSubview(textField)
                dataEntryImageView.bringSubviewToFront(textField)
                if partition == 1 { //The top-most label is the 1st responder
                    textField.becomeFirstResponder()
                }
            }
        }
        //Generate the last textField - split the final partition in half (or the entire frame if there is only 1 label). Make the delegate = the VC.
        let lastPartitionTopPoint = viewHeight - partitionSize
        let lastTextFieldYPosition = (viewHeight + lastPartitionTopPoint - 50)/2
        let lastTextField = UITextField(frame: CGRect(x: ((viewWidth * 0.25)/2), y: lastTextFieldYPosition, width: (viewWidth * 0.75), height: 50))
        lastTextField.textColor = UIColor.blackColor()
        lastTextField.backgroundColor = UIColor.clearColor()
        lastTextField.tag = 100 //allows us to reference textField in 'TFshouldReturn' function
        lastTextField.placeholder = "Enter a value for \(openScope!.getLabelsForMK()![numberOfLabels - 1]) & press the 'Return' key."
        lastTextField.delegate = self
        if (numberOfPartitions == 1) { //If there is only 1 label, the last label is also 1st responder
            lastTextField.becomeFirstResponder()
        }
        dataEntryImageView.addSubview(lastTextField)
        dataEntryImageView.bringSubviewToFront(lastTextField)
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        //First, set up a context holding the image currently in the mainImageView.
        UIGraphicsBeginImageContext(view.frame.size) //'View' specifies root view in the view hierarchy
        let context = UIGraphicsGetCurrentContext()
        dataEntryImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        //Get the current touch point & then draw a line from the last point to the current point:
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        //Set the drawing parameters for line size & color:
        CGContextSetLineCap(context, .Round)
        CGContextSetLineWidth(context, 0.5)
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0)
        CGContextSetBlendMode(context, .Normal)
        
        //Draw the path:
        CGContextStrokePath(context)
        
        //Wrap up the drawing context to render the new line:
        dataEntryImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        dataEntryImageView.alpha = 1.0
        UIGraphicsEndImageContext()
    }
    
    @IBAction func plusButtonClick(sender: AnyObject) {
        //Grab the info currently in the view & then render the view for addition of a new object of the same type (e.g. for medications, diagnoses, allergies, etc.). The dictionary receiving this information should be partitioned into sub-parts (e.g. "med1", "med2", etc. & then the information should be mapped to corresponding sub-scopes).
        if (openScope?.getCurrentItem() != nil) { //Checks if fieldName has sub-scope
            //Construct the dictionary:
            let lastFieldText = (dataEntryImageView.viewWithTag(100) as? UITextField)?.text //Grab last textField's input value
            getInputValuesFromTextFields(lastFieldText!, notificationString: { (let notification) -> Void in
                self.notificationsFeed.text = notification
                })
            fadeIn()
            fadeOut()
            dataEntryImageView.viewWithTag(1)?.becomeFirstResponder() //Set 1st txtField as 1st responder
            
            //Render the next item's label:
            openScope?.incrementCurrentItemNumber() //increment counter for next item's label
            let label = (openScope?.getCurrentItem()!.0)!
            let count = (openScope?.getCurrentItem()!.1)!
            currentItemNumberLabel.text = "\(label) \(count)"
        }
    }
    
    func configurePhysicalOrROSView(requestedView: String) {
        //Hide open views
        fieldNameEntryLabel.hidden = true
        fieldNameTextField.hidden = true
        
        //Render the custom view. Make sure to put in an adjustable frame (not static, but based on view dimensions)!
        let physicalOrROSDataEntryView = PhysicalAndROSDataEntryView(frame: CGRect(x: 260, y: 100, width: 764, height: 619)) //allows 'Return' behavior to be configured
        self.view.addSubview(physicalOrROSDataEntryView)
        physicalOrROSDataEntryView.renderDefaultDataEntryView()
        physicalOrROSDataEntryView.organSystemSelectionTextField.delegate = self
        physicalOrROSView = PhysicalAndROSView(dataEntryView: physicalOrROSDataEntryView, viewChoice: requestedView, gender: 0, childOrAdult: 0) //capture patient gender & age programmatically (for now assign defaults). Don't forget to set the variable to nil after view is closed.
        self.view.addSubview(physicalOrROSView!)
        
        
        //Bring back fieldName view after Px or ROS is closed
    }
    
    //MARK: - Capture User Inputs
    
    func getInputValuesFromTextFields(lastFieldText: String, notificationString: (String -> Void)) {
        //Grab the values entered in text fields for the notificationsFeed & mapping dictionary:
        var counter = 0
        var notificationText = ""
        let fieldName = (openScope?.getFieldName())!
        
        if (openScope?.getCurrentItem() != nil) { //fieldName has sub-scope (called by '+BtnClick')
            //Construct the dictionary's custom key:
            let label = (openScope?.getCurrentItem()!.0)!.lowercaseString
            let currentItemCount = (openScope?.getCurrentItem()!.1)!
            let currentItemKey = label + String(currentItemCount)
            //Add the key into the jsonDict:
            openScope?.jsonDictToServer[fieldName]![currentItemKey] = Dictionary<String, AnyObject>()
            var tempDict : [String : AnyObject] = (openScope?.jsonDictToServer[fieldName]![currentItemKey])! as! [String : AnyObject] //create temporary dict to assign value
            for view in dataEntryImageView.subviews {
                if (view.tag > 0 && view.tag < tableViewCellLabels!.count) {
                    let key = tableViewCellLabels![counter]
                    let value = ((view as? UITextField)?.text)!
                    tempDict[key] = value
                    notificationText += key + ": " + value + "\n"
                    counter += 1
                    (view as? UITextField)?.text = "" //clears the view's text
                } else if (view.tag == 100) {//Grab last textField's input value
                    let key = (tableViewCellLabels?.last)!
                    tempDict[key] = lastFieldText
                    notificationText += key + ": " + lastFieldText
                    (view as? UITextField)?.text = "" //clears the view's text
                }
                openScope?.jsonDictToServer[fieldName]![currentItemKey] = tempDict //Assign the temporary value in the temp dict -> jsonDictToServer @ end of each iteration
            }
        } else { //fieldName does NOT have sub-scopes (only called by 'textFieldShouldReturn')
            for view in dataEntryImageView.subviews {
                if (view.tag > 0 && view.tag < tableViewCellLabels!.count) {
                    let key = tableViewCellLabels![counter]
                    let value = ((view as? UITextField)?.text)!
                    openScope?.jsonDictToServer[fieldName]![key] = value
                    notificationText += key + ": " + value + "\n"
                    counter += 1
                } else if (view.tag == 100) {//Grab last textField's input value
                    let key = (tableViewCellLabels!.last)!
                    openScope?.jsonDictToServer[fieldName]![key] = lastFieldText
                    notificationText += key + ": " + lastFieldText
                }
            }
        }
        notificationString(notificationText) //Send back the closure containing the notification text
    }
    
    //MARK: - Template-Selection View Configuration
    
    @IBAction func vitalsButtonClick(sender: AnyObject) {
        if (currentPatient != nil) {
            openScope = EMRField(inputWord: "vitals", currentPatient: currentPatient!)
            tableViewCellLabels = openScope?.getLabelsForMK()
            configureViewForEntry("fieldValue")
        } else { //In future, the template buttons should be disabled while no patient is entered.
            print("Enter a patient first.")
        }
    }
    
    @IBAction func hpiButtonClick(sender: AnyObject) {
        if (currentPatient != nil) {
            //render appropriate view
        } else { //In future, the template buttons should be disabled while no patient is entered.
            print("Enter a patient first.")
        }
    }
    
    @IBAction func medicationsButtonClick(sender: AnyObject) {
        if (currentPatient != nil) {
            openScope = EMRField(inputWord: "medications", currentPatient: currentPatient!)
            tableViewCellLabels = openScope?.getLabelsForMK()
            configureViewForEntry("fieldValue")
        } else { //In future, the template buttons should be disabled while no patient is entered.
            print("Enter a patient first.")
        }
    }
    
    @IBAction func allergiesButtonClick(sender: AnyObject) {
        if (currentPatient != nil) {
            openScope = EMRField(inputWord: "allergies", currentPatient: currentPatient!)
            tableViewCellLabels = openScope?.getLabelsForMK()
            configureViewForEntry("fieldValue")
        } else { //In future, the template buttons should be disabled while no patient is entered.
            print("Enter a patient first.")
        }
    }
    
    @IBAction func physicalButtonClick(sender: AnyObject) {
        if (currentPatient != nil) {
            openScope = EMRField(inputWord: "physical", currentPatient: currentPatient!)
            configurePhysicalOrROSView((openScope?.getFieldName())!)
        } else { //In future, the template buttons should be disabled while no patient is entered.
            print("Enter a patient first.")
        }
    }
    
    @IBAction func rosButtonClick(sender: AnyObject) {
        sendHTTPRequestToEMR()
        if (currentPatient != nil) {
            openScope = EMRField(inputWord: "ros", currentPatient: currentPatient!)
            configurePhysicalOrROSView((openScope?.getFieldName())!)
        } else { //In future, the template buttons should be disabled while no patient is entered.
            print("Enter a patient first.")
        }
    }
    
    //MARK: - Network Request
    
    func sendHTTPRequestToEMR() {
        let url = NSURL(string: "https://api.athenahealth.com/preview1/1/practiceinfo")
        let dataParser = EMRDataParser(url: url!)
        dataParser.ParseJSON {
            (let returnedEMRData) in
            if let data = returnedEMRData {
                print("Total Count: \(data.totalCount)")
                print("Practice Info: \(data.practiceInfo)")
                if let practiceInfo = data.practiceInfo {
                    let value = practiceInfo[0]
                    let id = value["practiceid"]
                    print("Practice ID: \(id)\n")
                }
            }
        }
        
        let url2 = NSURL(string: "https://api.athenahealth.com/preview1/195900/departments?limit=10&offset=1&providerlist=false&showalldepartments=false")
        let dataParser2 = EMRDataParser(url: url2!)
        dataParser2.ParseJSON {
            (let returnedEMRData) in
            if let data = returnedEMRData {
                print("\nTotal Count: \(data.totalCount)")
                if let depts = data.departments {
                    var departmentIDs : [AnyObject] = []
                    for department in depts {
                        let departmentID = department["departmentid"]
                        departmentIDs.append(departmentID!)
                    }
                    print("\nDepartment ID #s: \(departmentIDs)")
                }
            }
        }
    }
    
    //MARK: - Current Patient & User Views
    
    @IBAction func currentPatientButtonClick(sender: AnyObject) {
        userInfoView.hidden = true
        //Clicking this button configures the popup if it is hidden & closes the popup if it is visible:
        if patientInfoView.hidden == true { //Reveal the view
            patientInfoView.hidden = false //Note: revealing view reveals all subviews too
            if currentPatient != nil {
                currentPatientLabel.text = "Current Patient: \(currentPatient!.name)"
            } else {
                currentPatientLabel.text = "No Patient File Open"
            }
        } else { //Hide the view
            patientInfoView.hidden = true
        }
    }
    
    @IBAction func currentUserButtonClick(sender: AnyObject) {
        patientInfoView.hidden = true
        //Clicking this button configures the popup if it is hidden & closes the popup if it is visible:
        if userInfoView.hidden == true { //Reveal the view
            userInfoView.hidden = false //revealing view reveals all subviews too
            currentUserLabel.text = "Current User: \(currentUser!)"
        } else { //Hide the view
            userInfoView.hidden = true
        }
    }
    
    @IBAction func logoutButtonClick(sender: AnyObject) {
        //Clear out existing user defaults:
        //        let appDomain = NSBundle.mainBundle().bundleIdentifier
        //        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        print("Logging Out")
        loggedIn = false //changes loggedIn value to trigger delegate methods
        userInfoView.hidden = true
    }
    
    @IBAction func closePatientFileButtonClick(sender: AnyObject) {
        //Close the patient file by setting 'currentPatient' = nil:
        currentPatient = nil
        patientInfoView.hidden = true
    }
    
    @IBAction func changeEMRButtonClick(sender: AnyObject) {
        // Later on, give user the option to log in to a different EMR (for users w/ multiple EMRs)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //In response to a touch, checks where  touch occurred. If either the patientInfoView or userInfoView is open & the touch is outside the open view, it hides the view.
        let touch = touches.first
        let touchLocation = touch!.locationInView(view)
        let userInfoViewFrame = CGRect(x: 60, y: 221, width: 180, height: 80)
        let patientInfoViewFrame = CGRect(x: 60, y: 139, width: 180, height: 80)
        if (userInfoView.hidden == false) && (!CGRectContainsPoint(userInfoViewFrame, touchLocation)) {
            userInfoView.hidden = true
        } else if (patientInfoView.hidden == false) && (!CGRectContainsPoint(patientInfoViewFrame, touchLocation)) {
            patientInfoView.hidden = true
        }
    }
    
    //MARK: - User Authentication & Patient Selection
    
    var loggedIn : Bool = true { //When we want login functionality, set it to FALSE!!!
        didSet {
            if loggedIn == true { //Do nothing, go to DEM view.
            } else { //go to login screen
                self.performSegueWithIdentifier("showLogin", sender: self)
            }
        }
    }
    
    func didLoginSuccessfully() { //Login Delegate Method
        loggedIn = true //Sets loginValue to true, which configures the default view
        dismissViewControllerAnimated(true, completion: nil) //When we first load the VC, the VC performs a segue & modally shows the login screen; when we call 'dismissVC' (after authentication is complete), it dismisses the modally presented screen.
    }
    
    var currentPatient: Patient? { //Check for open patient file
        didSet {
            if (currentPatient != nil) { //Patient file is open. Let view render as defined elsewhere.
            } else { //No patient file is open. Segue to patientSelectionVC
                self.performSegueWithIdentifier("showPatientSelection", sender: self)
            }
        }
    }
    
    func patientFileHasBeenOpened() { //Patient Selection Delegate Method
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Custom Keyboard Shortcuts
    
    override var keyCommands: [UIKeyCommand]? { //special Apple API for defining keyboard shortcuts
        let controlKey = UIKeyModifierFlags.Control
        let shiftKey = UIKeyModifierFlags.Shift
        let commandA = UIKeyCommand(input: "a", modifierFlags: [controlKey, shiftKey], action: "controlAKeyPressed:") //UIKeyCommand detects specified keyboard commands
        let upArrow = UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: "upArrowKeyPressed:") //the modifierFlags array can contain 0 modifier flags or more than 1 (e.g. when creating a cmd + shift + "" shortcut
        return [commandA, upArrow]
    }
    
    func controlAKeyPressed(command: UIKeyCommand) {
        print("User entered control + A")
    }
    
    func upArrowKeyPressed(command: UIKeyCommand) {
        print("User hit up arrow key")
    }
    
    //MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Before we segue, set the delegate property depending on the destination VC:
        if segue.identifier == "showLogin" {
            let loginViewController = segue.destinationViewController as! LoginViewController
            loginViewController.delegate = self //set the DEM VC as delegate of the LoginVC
        } else if segue.identifier == "showPatientSelection" {
            let patientSelectionViewController = segue.destinationViewController as! PatientSelectionViewController
            patientSelectionViewController.delegate = self
        }
    }
    
}