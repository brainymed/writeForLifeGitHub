//  DataEntryModeViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/21/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Controls the Data Entry portion of the app for information input -> EMR.

import UIKit
import CoreData

class DataEntryModeViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, PhysicalAndROSDelegate {
    
    let preferences: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var openScope: EMRField? //handles MK identification & data mapping -> EMR
    var patientFileWasJustOpened: Bool = false //checks if patient file was just opened (for notification)
    var fileWasOpenedOrCreated: String = "" //checks if file was opened or created
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var transitionedToDifferentView: Bool = false //false = currently in DEM, true = segued away
    
    @IBOutlet weak var fieldNameTextField: UITextField!
    @IBOutlet weak var fieldNameEntryLabel: UILabel!
    @IBOutlet weak var currentPatientButton: UIButton!
    @IBOutlet weak var currentUserButton: UIButton!
    @IBOutlet weak var notificationsFeed: UILabel! //Convert notification feed -> scrolling set of TV cells instead of a label?
    @IBOutlet weak var escapeButton: UIButton! //escape from fieldEntry view
    
    //CurrentUser & CurrentPatient Views (this can be achieved more cleanly using a popover segue):
    @IBOutlet weak var patientInfoView: UIView!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var currentPatientLabel: UILabel!
    @IBOutlet weak var currentUserLabel: UILabel!
    
    //Table View & Data Entry ImageView:
    @IBOutlet weak var labelsTableView: UITableView!
    @IBOutlet weak var dataEntryImageView: UIImageView!
    var tableViewCellLabels: [String]? //labels in TV cells based on entered MK
    var tableViewCellColors: [UIColor]? //color code the labels & partitions
    var newWidth: CGFloat? //on rotation, the width of the incoming view
    var newHeight: CGFloat? //on rotation, the height of the incoming view
    var physicalExamView: PhysicalAndROSView? //renders Px view (singleton)
    var reviewOfSystemsView: PhysicalAndROSView? //renders ROS view (singleton)
    
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
        self.definesPresentationContext = true //needed for BT keyboard check/key commands to work in Px/ROS views
        
        //Sets the DEMVC as delegate & datasource for TV:
        labelsTableView.delegate = self
        labelsTableView.dataSource = self
        labelsTableView.hidden = true
        dataEntryImageView.hidden = true
        
        //Configure fieldName entry view to start:
        configureViewForEntry("fieldName")
    }
    
    override func viewDidAppear(animated: Bool) {
        //The ENTIRE viewDidAppear function is run when the view appears (i.e. it does not stop running after segueing to a different view. It runs through the end first. We need to put in checks to account for this (when checking for currentPatient, make sure currentUser is set first).
        //Rethink the current routing - a FO user will never need to be redirected to DEM, so we need a different starting point (loginVC).
        if (currentUser == nil) { //if user isn't logged in, modally segue -> login screen.
            performSegueWithIdentifier("showLogin", sender: nil)
        }
        
        currentPatient = openPatientFile("arnav") //disable when doing live testing
        
        if ((currentUser != nil) && (currentPatient == nil)) { //if user isn't logged in, modally segue -> login screen.
            performSegueWithIdentifier("showPatientSelection", sender: nil)
        }
        
        if (patientFileWasJustOpened == true) {
            if (fileWasOpenedOrCreated == "opened") {
                notificationsFeed.text = "Patient file has been opened for \((currentPatient?.fullName)!.uppercaseString)"
            } else if (fileWasOpenedOrCreated == "created") {
                notificationsFeed.text = "Patient file has been created for \((currentPatient?.fullName)!.uppercaseString)"
            }
            fadeIn()
            fadeOut()
            patientFileWasJustOpened = false
        }
        
        print("Current User (DEnMVC): \(currentUser)")
        print("Current Patient (DEnMVC): \(currentPatient?.fullName)")
        
        setFirstResponder() //call the correct first responder depending on view status
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - View Rotation
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) { //called when view rotates, yields NEW size
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
    
    func setFirstResponder() { //called any time DEM appears or view is rendered, sets 1st responder
        //When user returns to this screen, bring up the previous 1st responder again:
        if (fieldNameTextField.hidden == false) {
            fieldNameTextField.becomeFirstResponder()
        } else if (dataEntryImageView.hidden == false) { //reset 1st responder -> status @ switch
            //Find every empty textField present in dataEntryIV (i.e. any field w/o text in it) & set 1st responder to the empty field w/ the LOWEST tag #.
            var emptySubviewTagArray: [Int] = []
            var smallestTag: Int = 101 //starting value must be > than the largest possible tag (100)
            for view in dataEntryImageView.subviews {
                if let textField = (view as? UITextField) { //optional cast b/c some views in the dataEntryIV are of type UIView or UITextView
                    let whitespaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
                    let trimmedText = textField.text!.stringByTrimmingCharactersInSet(whitespaceSet)
                    if (trimmedText == "") {
                        emptySubviewTagArray.append(view.tag)
                    }
                }
            }
            for tagValue in emptySubviewTagArray {
                if (tagValue < smallestTag) {
                    smallestTag = tagValue
                }
            }
            if (smallestTag != 101) { //emptySubviewArray contains views (not empty)
                dataEntryImageView.viewWithTag(smallestTag)?.becomeFirstResponder()
            } else { //the emptySubviewArray = []
                dataEntryImageView.viewWithTag(100)?.becomeFirstResponder() //called for HPI view b/c the optional cast would do nothing
            }
        }
    }
    
    func configureViewForEntry(desiredView: String) { //Configures view
        userInfoView.hidden = true //hide info labels on left during transition
        patientInfoView.hidden = true
        closePhysicalAndROSViews()
        
        switch desiredView {
        case "fieldName": //Configure view for field name entry
            //Hide fieldValue entry views:
            labelsTableView.hidden = true
            dataEntryImageView.hidden = true
            plusButton.hidden = true
            currentItemNumberLabel.hidden = true
            escapeButton.hidden = true
            
            //Bring up 'Field Name' Entry Views, set delegate:
            fieldNameEntryLabel.hidden = false
            fieldNameTextField.hidden = false
            fieldNameTextField.delegate = self
        case "fieldValue":
            //Hide the fieldName entry views:
            fieldNameEntryLabel.hidden = true
            fieldNameTextField.hidden = true
            fieldNameTextField.resignFirstResponder()
            plusButton.hidden = true
            currentItemNumberLabel.hidden = true
            
            //Pull up the formatted TV & imageView + escape button:
            renderDataEntryImageView(tableViewCellLabels!.count)
            labelsTableView.reloadData() //refreshes visible TV cells w/ existing data
            labelsTableView.hidden = false
            dataEntryImageView.hidden = false
            escapeButton.hidden = false
            self.view.bringSubviewToFront(escapeButton)
        default:
            print("Error. Switch case triggered unknown statement")
        }
        setFirstResponder()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool { //hide the user & patientInfo views when user types
        //For some reason, typing in the fieldName TF increases memory consumption!
        if (userInfoView.hidden == false) {
            userInfoView.hidden = true
        }
        if (patientInfoView.hidden == false) {
            patientInfoView.hidden = true
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool { //Configure behavior for 'RETURN' button
        let input = textField.text
        textField.resignFirstResponder()
        if (textField.tag == 1) { //sender is fieldName text field
            openScope = EMRField(inputWord: input!, patient: currentPatient!)
            if (openScope!.matchFound()) { //Open Scope & render view according to fieldName
                print("Match found")
                notificationsFeed.text = "Scope has been opened for '\(openScope!.getFieldName()!)' field"
                fadeIn()
                fadeOut()
                        
                //Check if the user requested a physical or ROS view:
                if (openScope?.getFieldName() == "physicalExam" || openScope?.getFieldName() == "reviewOfSystems") { //Render Px or ROS View
                    configurePhysicalOrROSView((openScope?.getFieldName())!)
                } else { //NOT a Px or ROS view
                    (tableViewCellLabels, tableViewCellColors) = (openScope?.getLabelsForMK())! //set the # of tableView cells according to the MK
                    configureViewForEntry("fieldValue")
                }
            } else {//'matchFound' == nil
                openScope = nil
                print("No match found!")
                configureViewForEntry("fieldName") //re-render fieldName entry view
            }
        } else if (textField.tag == 100) { //Sender is lastTextField from dataEntryImageView sending FVs
            //Obtain dictionary & notificationText containing input values; send dictionary -> central web server/persistent store & show notification, then configure the 'fieldName' view:
            var error: Bool = false
            var errorTagIndicator: Int = 0
            getInputValuesFromTextFields(input!, notificationString: { (let notification) in
                self.notificationsFeed.text = notification.2 //display all mapped values in feed
                error = notification.0
                errorTagIndicator = notification.1 //gives tag of the view which is empty
            })
            for (item, value) in (openScope?.jsonDictToServer)! { //output dictionary contents
                print("Dict: \(item): \(value)")
            }
            fadeIn()
            fadeOut()
            if (error == true) { //block reconfiguration of the view if there was an error
                dataEntryImageView.viewWithTag(errorTagIndicator)?.becomeFirstResponder()
                return false //block transition
            }
            
            print("Sending dictionary to EMR...")
            sendHTTPRequestToEMR() //*testing, send data -> server when user presses enter
            tableViewCellLabels = nil //clear array w/ labels
            plusButton.hidden = true //re-hide plusButton & itemLabel (in case they were opened)
            currentItemNumberLabel.hidden = true
            configureViewForEntry("fieldName")
            openScope = nil //close the existing scope
            print("Current Patient: \(currentPatient?.fullName)")
        } else if (textField.tag == 200) { //sender is Px & ROS dataEntryView organSystemTextField
            let viewChoice = openScope?.getFieldName()
            switchOrganSystemButtons(viewChoice!, input: input!)
        }
        textField.text = "" //clear textField before proceeding
        return true
    }
    
    func textViewShouldReturn(textView: UITextView) -> Bool { //get info from a textView (e.g. HPI)
        var error: Bool = false
        var errorTagIndicator: Int = 0
        getInputValuesFromTextFields(textView.text, notificationString: { (let notification) in
            self.notificationsFeed.text = notification.2 //display all mapped values in feed
            error = notification.0
            errorTagIndicator = notification.1 //gives tag of the view which is empty
        })
        for (item, value) in (openScope?.jsonDictToServer)! { //output dictionary contents
            print("Dict: \(item): \(value)")
        }
        fadeIn()
        fadeOut()
        if (error == true) { //block reconfiguration of the view if there was an error
            dataEntryImageView.viewWithTag(errorTagIndicator)?.becomeFirstResponder()
            return false //block transition
        }
        tableViewCellLabels = nil //clear array w/ labels
        plusButton.hidden = true //re-hide plusButton & itemLabel (in case they were opened)
        currentItemNumberLabel.hidden = true
        configureViewForEntry("fieldName")
        openScope = nil //close the existing scope
        textView.text = "" //clear view before proceeding
        return true
    }
    
    func switchOrganSystemButtons(viewChoice: String, input: String) {
        if (viewChoice == "physicalExam") { //switch Px buttons only
            let bodyImageView = physicalExamView!.bodyImageView
            switch input.lowercaseString { //configure view based on input
            case "c":
                bodyImageView.constitutionalButtonClick((bodyImageView.constitutionalButton))
            case "hn":
                bodyImageView.headAndNeckButtonClick((bodyImageView.headAndNeckButton))
            case "n":
                bodyImageView.neurologicalSystemButtonClick((bodyImageView.neurologicalSystemButton))
            case "p":
                bodyImageView.psychiatricButtonClick((bodyImageView.psychiatricButton))
            case "h":
                bodyImageView.cardiovascularSystemButtonClick((bodyImageView.cardiovascularSystemButton))
            case "l":
                bodyImageView.respiratorySystemButtonClick((bodyImageView.respiratorySystemButton))
            case "gi":
                bodyImageView.gastrointestinalSystemButtonClick((bodyImageView.gastrointestinalSystemButton))
            case "gu":
                bodyImageView.genitourinarySystemButtonClick((bodyImageView.genitourinarySystemButton))
            case "sk":
                bodyImageView.integumentarySystemButtonClick((bodyImageView.integumentarySystemButton))
            case "b":
                bodyImageView.backButtonClick((bodyImageView.backButton))
            case "ms":
                bodyImageView.musculoskeletalSystemButtonClick((bodyImageView.musculoskeletalSystemButton))
            case "re":
                bodyImageView.rectalSystemButtonClick((bodyImageView.rectalSystemButton))
            case "ch":
                bodyImageView.chaperoneButtonClick((bodyImageView.chaperoneButton))
            case "enmt":
                bodyImageView.enmtButtonClick((bodyImageView.enmtButton))
            case "ey":
                bodyImageView.eyesButtonClick((bodyImageView.eyesButton))
            case "br":
                bodyImageView.breastButtonClick((bodyImageView.breastButton))
            default:
                physicalExamView?.dataEntryView.organSystemSelectionTextField.becomeFirstResponder()
                notificationsFeed.text = "No results found for entry. Please enter a valid abbreviation"
                fadeIn()
                fadeOut()
            }
        } else if (viewChoice == "reviewOfSystems") { //switch ROS buttons only
            let bodyImageView = reviewOfSystemsView!.bodyImageView
            switch input.lowercaseString { //configure view based on input
            case "c":
                bodyImageView.constitutionalButtonClick((bodyImageView.constitutionalButton))
            case "n":
                bodyImageView.neurologicalSystemButtonClick((bodyImageView.neurologicalSystemButton))
            case "p":
                bodyImageView.psychiatricButtonClick((bodyImageView.psychiatricButton))
            case "cv":
                bodyImageView.cardiovascularSystemButtonClick((bodyImageView.cardiovascularSystemButton))
            case "r":
                bodyImageView.respiratorySystemButtonClick((bodyImageView.respiratorySystemButton))
            case "gi":
                bodyImageView.gastrointestinalSystemButtonClick((bodyImageView.gastrointestinalSystemButton))
            case "gu":
                bodyImageView.genitourinarySystemButtonClick((bodyImageView.genitourinarySystemButton))
            case "in":
                bodyImageView.integumentarySystemButtonClick((bodyImageView.integumentarySystemButton))
            case "ms":
                bodyImageView.musculoskeletalSystemButtonClick((bodyImageView.musculoskeletalSystemButton))
            case "en":
                bodyImageView.endocrineSystemButtonClick((bodyImageView.endocrineSystemButton))
            case "hl":
                bodyImageView.hematologicLymphaticSystemButtonClick((bodyImageView.hematologicLymphaticSystemButton))
            case "ai":
                bodyImageView.allergicImmunologicSystemButtonClick((bodyImageView.allergicImmunologicSystemButton))
            case "enmt":
                bodyImageView.enmtButtonClick((bodyImageView.enmtButton))
            case "ey":
                bodyImageView.eyesButtonClick((bodyImageView.eyesButton))
            default:
                reviewOfSystemsView?.dataEntryView.organSystemSelectionTextField.becomeFirstResponder()
                notificationsFeed.text = "No results found for entry. Please enter a valid abbreviation"
                fadeIn()
                fadeOut()
            }
        }
    }
    
    @IBAction func escapeButtonClick(sender: AnyObject) { //return to fieldName view
        configureViewForEntry("fieldName")
        openScope = nil //close the existing scope
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
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        if let labelArray = tableViewCellLabels { //Partition TV based on # of cells
            cell.textLabel?.text = labelArray[indexPath.row]
            cell.textLabel?.numberOfLines = 2
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.backgroundColor = tableViewCellColors![indexPath.row] //picks color from array (matched to color in partition)
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
        //Disable selection of TV cells/prevent swiping. User interaction is disabled from IB.
        return nil
    }
    
    func renderDataEntryImageView(numberOfLabels: Int) {
        for view in dataEntryImageView.subviews { //Before rendering, wipe out all old textLabels/views
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
            openScope?.setLastItemEntered() //handles setting of the lastItemEntered if necessary
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
                // Coordinate system - top left corner of the dataEntryIV is point (0, 0).
                let partitionNumber = CGFloat(partition)
                
                //Match partition color w/ the label color!!! First add a separate UIView to each partition & then add a unique textLabel & background color to the view. The UIView sits in the top left corner & extends the entire length & width of partitioned area.
                let product = 2 * partitionSize * partitionNumber - partitionSize
                let partitionView = UIImageView(frame: CGRect(x: 0, y: ((product - partitionSize)/2), width: viewWidth, height: partitionSize))
                partitionView.backgroundColor = tableViewCellColors![partition - 1]
                let textField = UITextField(frame: CGRect(x: ((viewWidth * 0.25)/2), y: ((product - 50)/2), width: (viewWidth * 0.75), height: 50))
                textField.tag = partition //tag each textField for later reference
                let placeholderText = openScope?.getLabelsForMK().0![partition - 1]
                let placeholder = "Enter a value for the \(placeholderText!) & press 'Tab'"
                textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()]) //change placeholder color
                textField.textColor = UIColor.whiteColor()
                textField.backgroundColor = UIColor.clearColor()
                textField.tintColor = UIColor.blackColor() //cursor color
                textField.userInteractionEnabled = true //In IB, set user interaction = enabled for parent imageView as well or textField will not respond to touch!
                
                dataEntryImageView.addSubview(partitionView)
                dataEntryImageView.addSubview(textField)
                dataEntryImageView.sendSubviewToBack(partitionView)
                dataEntryImageView.bringSubviewToFront(textField)
                if (partition == 1) { //The top-most label is the 1st responder
                    textField.becomeFirstResponder()
                }
                let fromPoints = [CGPoint(x: 0, y: partitionView.frame.size.height), CGPoint(x: 0, y: 0)]
                let toPoints = [CGPoint(x: partitionView.frame.size.width, y: partitionView.frame.size.height), CGPoint(x: 0, y: partitionView.frame.size.height)]
                drawLine(partitionView, fromPoint: fromPoints, toPoint: toPoints) //2 lines
            }
        }
        
        //Generate the lastTextField & its background view. Set the lastTF's delegate -> VC.
        let lastPartitionTopPoint = viewHeight - partitionSize
        let lastPartitionYPosition = (viewHeight + lastPartitionTopPoint - partitionSize)/2
        let lastPartitionView = UIImageView(frame: CGRect(x: 0, y: lastPartitionYPosition, width: viewWidth, height: partitionSize))
        lastPartitionView.backgroundColor = tableViewCellColors![numberOfLabels - 1]
        dataEntryImageView.addSubview(lastPartitionView)
        dataEntryImageView.sendSubviewToBack(lastPartitionView)
        
        if (openScope?.getFieldName() == "historyOfPresentIllness") { //for HPI, render textView
            //Frame - split the remainder of total area; textView width is 80% of the total width, so there is 20% remaining, the x start point should be 10% of the total. Same for y.
            let textView = UITextView(frame: CGRect(x: (viewWidth * 0.10), y: (viewHeight * 0.10), width: (viewWidth * 0.80), height: (viewHeight * 0.80)))
            textView.textColor = UIColor.whiteColor()
            textView.font = UIFont(name: "HelveticaNeue", size: 16) //change font size
            textView.backgroundColor = UIColor.clearColor()
            textView.tintColor = UIColor.blackColor()
            textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            textView.layer.borderWidth = 1.0 //set border
            textView.layer.borderColor = UIColor.blackColor().CGColor //modify border color
            textView.tag = 100 //use same tag # to allow code reusability
            textView.becomeFirstResponder()
            dataEntryImageView.addSubview(textView)
            dataEntryImageView.bringSubviewToFront(textView)
        } else { //normal view rendering
            let lastTextFieldYPosition = (viewHeight + lastPartitionTopPoint - 50)/2
            let lastTextField = UITextField(frame: CGRect(x: (viewWidth * 0.125), y: lastTextFieldYPosition, width: (viewWidth * 0.75), height: 50))
            lastTextField.textColor = UIColor.whiteColor()
            lastTextField.backgroundColor = UIColor.clearColor()
            lastTextField.tintColor = UIColor.blackColor() //cursor color
            lastTextField.tag = 100 //allows us to reference lastTextField in 'TFshouldReturn' function
            let placeholderText = openScope?.getLabelsForMK().0![numberOfLabels - 1]
            let placeholder = "Enter a value for \(placeholderText!) & press the 'Return' key."
            lastTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()]) //set placeholder text color
            lastTextField.delegate = self
            dataEntryImageView.addSubview(lastTextField)
            dataEntryImageView.bringSubviewToFront(lastTextField)
            if (numberOfPartitions == 1) { //if there is only 1 label, the lastTF is also 1st responder
                lastTextField.becomeFirstResponder()
            }
        }
        
        drawLine(lastPartitionView, fromPoint: [CGPoint(x: 0, y: 0)], toPoint: [CGPoint(x: 0, y: lastPartitionView.frame.size.height)]) //final vertical line
    }
    
    func drawLine(imageView: UIImageView, fromPoint: [CGPoint], toPoint: [CGPoint]) { //accept an array of points so that multiple lines can be drawn. Make sure # fromPoints = # toPoints!
        //First, set up a context holding the image currently in the mainImageView.
        UIGraphicsBeginImageContext(imageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        imageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        //For each item in the array, get the current touch point & draw a line between points:
        for i in 0...(fromPoint.count - 1) {
            CGContextMoveToPoint(context, fromPoint[i].x, fromPoint[i].y)
            CGContextAddLineToPoint(context, toPoint[i].x, toPoint[i].y)
        }
        
        //Set the drawing parameters for line size & color:
        CGContextSetLineCap(context, .Round)
        CGContextSetLineWidth(context, 1.25)
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0) //white color
        CGContextSetBlendMode(context, .Normal)
        
        //Draw the path:
        CGContextStrokePath(context)
        
        //Wrap up the drawing context to render the new line:
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        imageView.alpha = 1.0
        UIGraphicsEndImageContext()
    }
    
    @IBAction func plusButtonClick(sender: AnyObject) {
        //Grab the info currently in the view & then render the view for addition of a new object of the same type (e.g. for medications, diagnoses, allergies, etc.). The dictionary receiving this information should be partitioned into sub-parts (e.g. "med1", "med2", etc. & then the information should be mapped to corresponding sub-scopes).
        if (openScope?.getCurrentItem() != nil) { //Checks if fieldName has sub-scope
            //Construct the dictionary:
            let lastFieldText = (dataEntryImageView.viewWithTag(100) as? UITextField)?.text //Grab last textField's input value
            var error: Bool = false
            var errorTagIndicator: Int = 0
            getInputValuesFromTextFields(lastFieldText!, notificationString: { (let notification) -> Void in
                error = notification.0
                errorTagIndicator = notification.1
                self.notificationsFeed.text = notification.2
            })
            fadeIn()
            fadeOut()
            
            if (error == false) {
                dataEntryImageView.viewWithTag(1)?.becomeFirstResponder() //Set 1st txtField as 1st responder
                //Render the next item's label:
                openScope?.incrementCurrentItemNumber() //increment counter for next item's label
                let label = (openScope?.getCurrentItem()!.0)!
                let count = (openScope?.getCurrentItem()!.1)!
                currentItemNumberLabel.text = "\(label) \(count)"
            } else { //error occurred, don't switch views
                dataEntryImageView.viewWithTag(errorTagIndicator)?.becomeFirstResponder()
            }
        }
    }
    
    //MARK: - Physical & ROS View Configuration
    
    func configurePhysicalOrROSView(requestedView: String) {
        //Hide fieldName & fieldValue entry views:
        fieldNameEntryLabel.hidden = true
        fieldNameTextField.hidden = true
        labelsTableView.hidden = true
        dataEntryImageView.hidden = true
        plusButton.hidden = true
        currentItemNumberLabel.hidden = true
        closePhysicalAndROSViews()
        
        if (requestedView == "physicalExam") {
            if (physicalExamView == nil) { //create the Px object
                physicalExamView = PhysicalAndROSView(applicationMode: "DEM", viewChoice: requestedView, gender: 0, childOrAdult: 0) //capture patient gender & age programmatically (for now assign defaults).
            }
            physicalExamView?.hidden = false //reveal Px view
            physicalExamView?.dataEntryView.delegate = self
            self.view.addSubview(physicalExamView!)
            physicalExamView?.dataEntryView.organSystemSelectionTextField.becomeFirstResponder()
            physicalExamView?.dataEntryView.organSystemSelectionTextField.delegate = self
        } else if (requestedView == "reviewOfSystems") {
            if (reviewOfSystemsView == nil) { //create the ROS object
                reviewOfSystemsView = PhysicalAndROSView(applicationMode: "DEM", viewChoice: requestedView, gender: 0, childOrAdult: 0)
            }
            reviewOfSystemsView?.hidden = false //reveal ROS view
            reviewOfSystemsView?.dataEntryView.delegate = self
            self.view.addSubview(reviewOfSystemsView!)
            reviewOfSystemsView?.dataEntryView.organSystemSelectionTextField.becomeFirstResponder()
            reviewOfSystemsView?.dataEntryView.organSystemSelectionTextField.delegate = self
        }
    }
    
    func callNotificationsFeedFromPhysicalAndROSView(notificationText: String) {
        notificationsFeed.text = notificationText
        fadeIn()
        fadeOut()
    }
    
    func closePhysicalAndROSViews() {
        //Called whenever another view is rendered:
        reviewOfSystemsView?.hidden = true
        reviewOfSystemsView?.renderDefaultView()
        physicalExamView?.hidden = true
        physicalExamView?.renderDefaultView()
    }
    
    func physicalOrROSViewWasClosed() { //delegate method - renders view for fieldName entry
        //Reset the Physical or ROS View for next time the user opens it:
        configureViewForEntry("fieldName")
    }
    
    //MARK: - Capture User Inputs
    
    func getInputValuesFromTextFields(lastFieldText: String, notificationString: ((Bool, Int, String) -> Void)) { //Grab values entered in textFields/textView for notificationsFeed & mapping dictionary
        var counter = 0
        let whitespaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet() //trim whiteSpace & \n
        let lastFieldTrimmedText = lastFieldText.stringByTrimmingCharactersInSet(whitespaceSet)
        var notificationText = "" //text sent -> notificationFeed
        let fieldName = (openScope?.getFieldName())!
        var error: Bool = false //false = no error, true = error (empty field found)
        var errorTagIndicator: Int = 0 //tells system tag # of offending field
        
        if (openScope?.generateCustomDictionaryKey() != nil) { //indicates that fieldName has sub-scopes (called by '+BtnClick')
            let currentItemKey = (openScope?.generateCustomDictionaryKey())! //obtain custom key
            //Add the key into the jsonDict:
            openScope?.jsonDictToServer[fieldName]![currentItemKey] = Dictionary<String, AnyObject>()
            var tempDict: [String: AnyObject] = (openScope?.jsonDictToServer[fieldName]![currentItemKey])! as! [String: AnyObject] //create temporary dict to assign value
            let dictionaryItemKeys: [String] = (openScope?.getDictionaryKeysForMK())! //keys match -> API
            for view in dataEntryImageView.subviews { //iterate through the views & capture values
                if (view.tag > 0 && view.tag < tableViewCellLabels!.count) {
                    let label = tableViewCellLabels![counter] //for user to see
                    let key = dictionaryItemKeys[counter]
                    let value = (view as? UITextField)?.text
                    if (value != nil) { //make sure cast from UIView -> TextField worked
                        let trimmedValue = value!.stringByTrimmingCharactersInSet(whitespaceSet)
                        if (trimmedValue == "") { //make sure no value is left empty
                            error = true
                            errorTagIndicator = view.tag
                            notificationText = "Please enter a value for '\(label)'"
                            break
                        } else {
                            tempDict[key] = trimmedValue //'key' from dictItemsArray, 'value' = txt input
                            notificationText += label + ": " + trimmedValue + "\n"
                        }
                    } else { //shouldn't trigger unless a UIView added to dataEntryIV has a tag (error)
                        notificationText = "Error occurred. UIView in DataEntryIV has a tag when it shouldn't."
                        error = true
                    }
                    counter += 1
                } else if (view.tag == 100) { //grab lastTextField's input value
                    let label = (tableViewCellLabels?.last)! //for user to see
                    let key: String = dictionaryItemKeys.last!
                    if (lastFieldTrimmedText == "") { //check if any value is empty
                        error = true
                        errorTagIndicator = view.tag
                        notificationText = "Please enter a value for '\(label)'"
                        break
                    } else { //no value is empty
                        tempDict[key] = lastFieldTrimmedText
                        notificationText += label + ": " + lastFieldTrimmedText
                    }
                }
                openScope?.jsonDictToServer[fieldName]![currentItemKey] = tempDict //Assign the temporary value in the temp dict -> jsonDictToServer @ end of each iteration
            }
            
            if (error == false) {
                for view in dataEntryImageView.subviews { //Clear the text in the textFields:
                    (view as? UITextField)?.text = ""
                }
                
                //Capture the last entered item's counter #, so that we will not overwrite the persistent data object if the user tries to enter more items. 
                let countedField = (openScope?.getCurrentItem()!.0)!
                let lastCounterNumber = (openScope?.getCurrentItem()!.1)! //capture last item that was entered
                if (countedField == "Medication") {
                    currentPatient?.lastMedicationInserted = lastCounterNumber //save value in Patient obj
                } else if (countedField == "Allergy") {
                    currentPatient?.lastAllergyInserted = lastCounterNumber //save value in Patient obj
                }
            }
            
        } else { //fieldName does NOT have sub-scopes (only called by textField- or textViewShouldReturn)
            let dictionaryItemKeys: [String] = (openScope?.getDictionaryKeysForMK())!
            for view in dataEntryImageView.subviews {
                if (view.tag > 0 && view.tag < tableViewCellLabels!.count) {
                    let label = tableViewCellLabels![counter] //for user to see
                    let key = dictionaryItemKeys[counter]
                    let value = (view as? UITextField)?.text
                    if (value != nil) { //make sure cast from UIView -> TextField worked
                        let trimmedValue = value!.stringByTrimmingCharactersInSet(whitespaceSet)
                        if (trimmedValue == "") { //make sure no value is left empty
                            error = true
                            errorTagIndicator = view.tag
                            notificationText = "Please enter a value for '\(label)'"
                            break
                        } else {
                            openScope?.jsonDictToServer[fieldName]![key] = trimmedValue
                            notificationText += label + ": " + trimmedValue + "\n"
                        }
                    } else { //shouldn't trigger unless a UIView added to dataEntryIV has a tag (error)
                        notificationText = "Error occurred. UIView in DataEntryIV has a tag when it shouldn't."
                        error = true
                    }
                    counter += 1
                } else if (view.tag == 100) {//Grab last textField's or textView's input value
                    let label = (tableViewCellLabels!.last)! //for patient to see
                    let key: String = dictionaryItemKeys.last!
                    if (lastFieldTrimmedText == "") { //check if any values were left empty
                        error = true
                        errorTagIndicator = view.tag
                        notificationText = "Please enter a value for '\(label)'"
                        break
                    } else { //no field is empty
                        openScope?.jsonDictToServer[fieldName]![key] = lastFieldTrimmedText
                        if (openScope?.getFieldName() == "historyOfPresentIllness") {
                            notificationText += "History of present illness has been entered."
                        } else { //all other fields
                            notificationText += label + ": " + lastFieldTrimmedText
                        }
                    }
                }
            }
        }
        if (error == false) {
            openScope?.setFieldValueForCurrentPatient() //*
        }
        notificationString(error, errorTagIndicator, notificationText) //Send back the closure containing the notification text, error (bool), & error tagIndicator
    }
    
    //MARK: - Template-Selection View Configuration
    
    @IBAction func vitalsButtonClick(sender: AnyObject) {
        openScope = EMRField(inputWord: "vitals", patient: currentPatient!)
        (tableViewCellLabels, tableViewCellColors) = (openScope?.getLabelsForMK())!
        configureViewForEntry("fieldValue")
    }
    
    @IBAction func hpiButtonClick(sender: AnyObject) {
        openScope = EMRField(inputWord: "hpi", patient: currentPatient!)
        (tableViewCellLabels, tableViewCellColors) = (openScope?.getLabelsForMK())!
        configureViewForEntry("fieldValue")
    }
    
    @IBAction func medicationsButtonClick(sender: AnyObject) {
        openScope = EMRField(inputWord: "medications", patient: currentPatient!)
        (tableViewCellLabels, tableViewCellColors) = (openScope?.getLabelsForMK())!
        configureViewForEntry("fieldValue")
    }
    
    @IBAction func allergiesButtonClick(sender: AnyObject) {
        openScope = EMRField(inputWord: "allergies", patient: currentPatient!)
        (tableViewCellLabels, tableViewCellColors) = (openScope?.getLabelsForMK())!
        configureViewForEntry("fieldValue")
    }
    
    @IBAction func physicalButtonClick(sender: AnyObject) {
        openScope = EMRField(inputWord: "physical", patient: currentPatient!)
        configurePhysicalOrROSView((openScope?.getFieldName())!)
    }
    
    @IBAction func rosButtonClick(sender: AnyObject) {
        openScope = EMRField(inputWord: "ros", patient: currentPatient!)
        configurePhysicalOrROSView((openScope?.getFieldName())!)
    }
    
    //MARK: - Network Request
    
    func sendHTTPRequestToEMR() {
        let dataParser = EMRDataParser(openScope: openScope!)
        dataParser.ParseJSON {
            (let returnedEMRData) in
            print("Patient ID: \(returnedEMRData?.patientID)")
        }
    }
    
    //MARK: - Current Patient & User Views
    
    @IBAction func currentPatientButtonClick(sender: AnyObject) {
        userInfoView.hidden = true
        //Clicking this button configures the popup if it is hidden & closes the popup if it is visible:
        if patientInfoView.hidden == true { //reveal the view
            self.view.bringSubviewToFront(patientInfoView)
            patientInfoView.hidden = false //revealing the view reveals all subviews too
            if (currentPatient != nil) {
                currentPatientLabel.text = "Current Patient: \(currentPatient!.fullName)"
            } else {
                currentPatientLabel.text = "No Patient File Open"
            }
        } else { //hide the view
            patientInfoView.hidden = true
        }
    }
    
    @IBAction func currentUserButtonClick(sender: AnyObject) {
        patientInfoView.hidden = true
        //Clicking this button configures the popup if it is hidden & closes the popup if it is visible:
        if (userInfoView.hidden == true) { //reveal the view
            self.view.bringSubviewToFront(userInfoView)
            userInfoView.hidden = false //revealing view reveals all subviews too
            if (currentUser != nil) {
                currentUserLabel.text = "Current User: \(currentUser!)"
            } else {
                currentUserLabel.text = "No user logged in"
            }
        } else { //hide the view
            userInfoView.hidden = true
        }
    }
    
    @IBAction func logoutButtonClick(sender: AnyObject) { //for now, will also clear scope/current patient
        //Clear out existing user defaults:
        let preferences: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        preferences.removeObjectForKey("USERNAME")
        preferences.removeObjectForKey("PROVIDER_TYPE")
        
        openScope = nil
        physicalExamView = nil
        reviewOfSystemsView = nil
        currentUser = nil //clears currentUser to trigger segue
        currentPatient = nil //clears currentPatient
        configureViewForEntry("fieldName")
        userInfoView.hidden = true
        
        //For now we will have it clear the MOC as well:
        clearAllPatientsFromDataStore()
        fetchAllPatients()
    }
    
    @IBAction func closePatientFileButtonClick(sender: AnyObject) {
        //Close the patient file by setting 'currentPatient' = nil, setting any openScope & Px/ROS view to nil, and rendering the view for fieldName entry:
        physicalExamView = nil
        reviewOfSystemsView = nil
        openScope = nil
        currentPatient = nil
        configureViewForEntry("fieldName")
        patientInfoView.hidden = true
    }
    
    @IBAction func changeEMRButtonClick(sender: AnyObject) {
        // Later on, give user the option to log in to a different EMR (for users w/ multiple EMRs)
        
        //For now, fetch patients in data store for checking:
        fetchAllPatients()
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
    
    var currentUser: String? = "a" { //when we want login functionality, set this to nil!
        didSet {
            if (currentUser != nil) { //do nothing, go to DEM view.
            } else { //go to login screen
                performSegueWithIdentifier("showLogin", sender: self)
            }
        }
    }
    
    var currentPatient: Patient? { //check if patient file is open
        didSet {
            if (currentPatient != nil) { //Patient file is open. Let view render as defined elsewhere.
            } else { //No patient file is open, segue -> patientSelectionVC
                if (currentUser != nil) { //make sure that logout button wasn't clicked
                   performSegueWithIdentifier("showPatientSelection", sender: self)
                }
            }
        }
    }
    
    //MARK: - Custom Keyboard Shortcuts
    
    override var keyCommands: [UIKeyCommand]? { //special Apple API for defining keyboard shortcuts
        let controlKey = UIKeyModifierFlags.Control
        let commandKey = UIKeyModifierFlags.Command
        //let shiftKey = UIKeyModifierFlags.Shift
        let controlA = UIKeyCommand(input: "a", modifierFlags: [controlKey], action: "addItemKeyPressed:") //UIKeyCommand detects specified keyboard commands
        let controlQ = UIKeyCommand(input: "q", modifierFlags: [controlKey], action: "quitKeyPressed:")
        let controlRArrow = UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: controlKey, action: "controlRightArrowKeyPressed:") //for HPI data capture
        let commandRightArrow = UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: [commandKey], action: "nextKeyPressed:") //for HPI data capture
        let commandLeftArrow = UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: [commandKey], action: "lastKeyPressed:") //for HPI data capture
        return [controlA, controlQ, commandLeftArrow, commandRightArrow, controlRArrow]
    }
    
    func addItemKeyPressed(command: UIKeyCommand) { //adds items in meds, allergies, diagnosis views
        if (openScope?.getCurrentItem() != nil) { //Ctrl+A can be used to add additional item
            plusButtonClick(self)
        }
    }
    
    func quitKeyPressed(command: UIKeyCommand) { //acts as the escape button
        if (openScope?.getFieldName() == "physicalExam") {
            let dataEntryView = physicalExamView!.dataEntryView
            if (physicalExamView?.bodyImageView.hidden == true) { //dataEntryView is open
                dataEntryView.escapeButtonClick(dataEntryView.escapeButton)
            }
        } else if (openScope?.getFieldName() == "reviewOfSystems") {
            let dataEntryView = reviewOfSystemsView!.dataEntryView
            if (reviewOfSystemsView?.bodyImageView.hidden == true) { //dataEntryView is open
                dataEntryView.escapeButtonClick(dataEntryView.escapeButton)
            }
        } else if (openScope?.getFieldName() != nil) { //fieldEntry view is open
            escapeButtonClick(self)
        }
    }
    
    func controlRightArrowKeyPressed(command: UIKeyCommand) {
        if (openScope?.getFieldName() == "historyOfPresentIllness") { //Modify the actual key command later, but this is used to capture the info in the textView of the HPI
            let textView = dataEntryImageView.viewWithTag(100) as? UITextView
            if (textView != nil) { //make sure the textView casting worked
                textViewShouldReturn(textView!)
            }
        }
    }
    
    func nextKeyPressed(command: UIKeyCommand) { //matches -> (nextSection) in Px/ROS views
        if (openScope?.getFieldName() == "physicalExam") {
            let dataEntryView = physicalExamView!.dataEntryView
            if (physicalExamView?.bodyImageView.hidden == true) { //organSystemView is open
                dataEntryView.nextSectionButtonClick(dataEntryView.nextSectionButton)
            }
        } else if (openScope?.getFieldName() == "reviewOfSystems") {
            let dataEntryView = reviewOfSystemsView!.dataEntryView
            if (reviewOfSystemsView?.bodyImageView.hidden == true) { //organSystemView is open
                dataEntryView.nextSectionButtonClick(dataEntryView.nextSectionButton)
            }
        }
    }
    
    func lastKeyPressed(command: UIKeyCommand) { //matches <- (previousSection) in Px/ROS views
        if (openScope?.getFieldName() == "physicalExam") {
            let dataEntryView = physicalExamView!.dataEntryView
            if (physicalExamView?.bodyImageView.hidden == true) { //dataEntryView is open
                dataEntryView.lastSectionButtonClick(dataEntryView.lastSectionButton)
            }
        } else if (openScope?.getFieldName() == "reviewOfSystems") {
            let dataEntryView = reviewOfSystemsView!.dataEntryView
            if (reviewOfSystemsView?.bodyImageView.hidden == true) { //dataEntryView is open
                dataEntryView.lastSectionButtonClick(dataEntryView.lastSectionButton)
            }
        }
    }
    
    //MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPatientSelection") {
            let patientSelectionVC = (segue.destinationViewController as! PatientSelectionViewController)
            patientSelectionVC.currentUser = self.currentUser
            transitionedToDifferentView = true
        } else if (segue.identifier == "showLogin") {
            transitionedToDifferentView = true
        }
    }
    
}