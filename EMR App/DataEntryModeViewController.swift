//  DataEntryModeViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/21/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Controls the Data Entry portion of the app for information input into the EMR.

import UIKit

class DataEntryModeViewController: UIViewController, LoginViewControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var currentPatient: Patient? { //Open patient file
        didSet {
            if (currentPatient != nil) { //Patient file is open. Handle accordingly.
                
            } else { //No patient file is open. Configure view for opening a patient file.
                configureViewForEntry("patientName")
            }
        }
    }
    
    var currentUser: String? //current user (HCP) who is logged in
    var openScope: EMRField? //handles MK identification & data mapping -> EMR
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var patientNameTextField: UITextField!
    @IBOutlet weak var patientNameEntryLabel: UILabel!
    @IBOutlet weak var fieldNameTextField: UITextField!
    @IBOutlet weak var fieldNameEntryLabel: UILabel!
    @IBOutlet weak var openExistingFileButton: UIButton!
    @IBOutlet weak var createNewFileButton: UIButton!
    @IBOutlet weak var currentPatientButton: UIButton!
    @IBOutlet weak var currentUserButton: UIButton!
    @IBOutlet weak var notificationsFeed: UILabel! //Convert notification feed -> scrolling set of TV cells instead of a text view
    
    // CurrentUser & CurrentPatient Views:
    @IBOutlet weak var patientInfoView: UIView!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var currentPatientLabel: UILabel!
    @IBOutlet weak var currentUserLabel: UILabel!
    
    // Table View & Associated Side View:
    @IBOutlet weak var labelsTableView: UITableView!
    @IBOutlet weak var dataEntryImageView: UIImageView!
    var tableViewCellLabels: [String]? //labels in TV cells based on entered MK
    var newWidth: CGFloat? //on rotation, the width of the incoming view
    var newHeight: CGFloat? //on rotation, the height of the incoming view
    
    // Template Buttons:
    @IBOutlet weak var vitalsButton: UIButton!
    @IBOutlet weak var hpiButton: UIButton!
    @IBOutlet weak var medicationsButton: UIButton!
    @IBOutlet weak var allergiesButton: UIButton!
    @IBOutlet weak var physicalButton: UIButton!
    @IBOutlet weak var rosButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        patientNameTextField.becomeFirstResponder()
        
        //Sets the VC as delegate & datasource for TV:
        labelsTableView.delegate = self
        labelsTableView.dataSource = self
        labelsTableView.hidden = true
        dataEntryImageView.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        if loggedIn == false {//If user is not logged in, modally segue -> login screen. Need this line b/c 'didSet' function is NOT called when we initially set value of 'loggedIn'.
            performSegueWithIdentifier("showLogin", sender: nil)
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
        
        if currentPatient == nil { //If there is no current patient, configure view for name entry
            configureViewForEntry("patientName")
        } else {
            //Let app go to whichever screen it was previously on.
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func createNewFileButtonClick(sender: AnyObject) {
        //Create a new patient file:
        let inputName = patientNameTextField.text!
        //Perform predicate matching for new patient entry (not necessary when opening existing patient file b/c that data will come from EMR):
        let fullNameFormat = ".* .*" //add optional portion for middle name
        let matchPredicate = NSPredicate(format:"SELF MATCHES %@", fullNameFormat)
        if (matchPredicate.evaluateWithObject(inputName)) {
            currentPatient = Patient(name: inputName, insertIntoManagedObjectContext: managedObjectContext)
            patientNameTextField.text = ""
            configureViewForEntry("fieldName")
            notificationsFeed.text = "New patient file created for \(inputName.uppercaseString)"
            fadeIn()
            fadeOut()
        } else {
            print("Please enter a full name")
        }
    }
    
    @IBAction func openExistingFileButtonClick(sender: AnyObject) {
        //Open an existing patient file for the given name (check for patient) using the EMR patient name retrieval API or the persistent store:
        let inputName = patientNameTextField.text!
        currentPatient = Patient(name: inputName, insertIntoManagedObjectContext: managedObjectContext)
        patientNameTextField.text = ""
        configureViewForEntry("fieldName")
        notificationsFeed.text = "Patient file opened for \(inputName.uppercaseString)"
        fadeIn()
        fadeOut()
    }
    
    func configureViewForEntry(desiredView: String) { //Configures view
        switch desiredView {
        case "patientName": //Configure view to open a patient file
            //Hide field name & field value entry views:
            fieldNameTextField.hidden = true
            fieldNameEntryLabel.hidden = true
            labelsTableView.hidden = true
            dataEntryImageView.hidden = true
            
            //Bring up patient name entry views:
            patientNameTextField.hidden = false
            patientNameEntryLabel.hidden = false
            openExistingFileButton.hidden = false
            createNewFileButton.hidden = false
            patientNameTextField.becomeFirstResponder() //Set textField -> 1st responder
        case "fieldName": //Configure view for field name entry
            //If open, hide patient name entry views, field value entry views, & resign 1st responder:
            if patientNameTextField.hidden == false {
                patientNameTextField.resignFirstResponder()
                patientNameTextField.hidden = true
                patientNameEntryLabel.hidden = true
                openExistingFileButton.hidden = true
                createNewFileButton.hidden = true
            } else if labelsTableView.hidden == false { //Hide TV & ImageView
                labelsTableView.hidden = true
                dataEntryImageView.hidden = true
            }
            
            //Bring up 'Field Name' Entry Views, set delegate & 1st responder:
            fieldNameEntryLabel.hidden = false
            fieldNameTextField.hidden = false
            fieldNameTextField.delegate = self
            fieldNameTextField.becomeFirstResponder()
        case "fieldValue":
            //Hide the open views & pull up the formatted TV & imageView:
            fieldNameEntryLabel.hidden = true
            fieldNameTextField.hidden = true
            renderDataEntryImageView(tableViewCellLabels!.count)
            labelsTableView.reloadData() //refreshes visible TV cells w/ existing data
            labelsTableView.hidden = false
            dataEntryImageView.hidden = false
        default:
            print("Error. Switch case triggered unknown statement")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool { //Configure behavior when 'RETURN' button is hit
        let input = textField.text
        textField.text = ""
        textField.resignFirstResponder()
        
        if textField.tag == 1 { // sender is Field Name TF
            //Configure behavior based on the value that was entered:
            openScope = EMRField(inputWord: input!)
            if (openScope!.matchFound()) {
                //Check if 'currentPatient' exists:
                if (currentPatient == nil) {//File is NOT open
                    //This should never trigger b/c a patient file must be open before any behaviors can take place!
                    openScope = nil
                    print("No patient file open")
                } else {//'Current patient' exists & match is found for keyword
                    //Open scope for NON-NAME field:
                    if (openScope!.getFieldName() == "name") {
                        //Should never be called - user doesn't enter patient name this way.
                        openScope = nil
                        print("'Name' entered as field name")
                        configureViewForEntry("fieldName")
                    } else {
                        //Open Scope (render the view according to the fieldName that was entered):
                        print("Match found")
                        notificationsFeed.text = "Scope has been opened for '\(openScope!.getFieldName()!)' field"
                        fadeIn()
                        fadeOut()
                        tableViewCellLabels = openScope?.getLabelsForMK() //set the # of tableView cells according to the MK
                        configureViewForEntry("fieldValue")
                    }
                }
            } else {//'matchFound' == nil
                openScope = nil
                print("No match found!")
                //Keep the first responder here & accept a new field name entry:
                configureViewForEntry("fieldName")
            }
        } else if textField.tag == 2 { // Sender is textField from dataEntryImageView sending FV
            //Send the input values to the EMR or persistent data store, post "{} has been mapped to {}" in the twitter feed, & return the fieldName view:
            notificationsFeed.text = "'\(input!)' has been sent to '\(openScope!.getFieldName()!)'"
            fadeIn()
            fadeOut()
            dataEntryImageView.canResignFirstResponder() //resign 1st responder?
            tableViewCellLabels = nil
            configureViewForEntry("fieldName")
            openScope = nil //Last, close the scope
        }
        return true
    }
    
    func fadeIn() { //Fades in the twitter feed instantly
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.notificationsFeed.alpha = 1.0
            }, completion: nil)
    }
    
    func fadeOut() { //Gradually fades out the twitter feed
        UIView.animateWithDuration(1.0, delay: 4.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.notificationsFeed.alpha = 0.0
            }, completion: nil)
    }
    
    //MARK: - Template-Selection View Configuration
    
    @IBAction func vitalsButtonClick(sender: AnyObject) {
        if (currentPatient != nil) {
            openScope = EMRField(inputWord: "vitals")
            tableViewCellLabels = openScope?.getLabelsForMK()
            configureViewForEntry("fieldValue")
        } else { //In future, the template buttons should be disabled while no patient is entered.
            print("Enter a patient first.")
        }
    }
    
    @IBAction func hpiButtonClick(sender: AnyObject) {
        
    }
    
    @IBAction func medicationsButtonClick(sender: AnyObject) {
        
    }
    
    @IBAction func allergiesButtonClick(sender: AnyObject) {
        
    }
    
    @IBAction func physicalButtonClick(sender: AnyObject) {
        
    }
    
    @IBAction func rosButtonClick(sender: AnyObject) {
        
    }
    
    //MARK: - Dynamic View Configuration (TV & ImageView)
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Number of cells we show is based on the # of labels needed:
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
            cell.backgroundColor = UIColor.lightGrayColor()
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
            if UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait {
                cellHeight = 875/numberOfLabels //device in portrait
            } else {
                cellHeight = 619/numberOfLabels //device in landscape
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
    
    func renderDataEntryImageView(numberOfLabels: Int) {//Partitions imageView 
        //Match partition color w/ the label color.
        for view in dataEntryImageView.subviews { //Before rendering, wipe out any old textLabels!
            view.removeFromSuperview()
        }
        dataEntryImageView.image = nil //Clears any existing lines
        
        //Compute the width & height of the dataEntryImageView if rotation is occurring. If the values of newWidth & newHeight are nil, we know that we are on the initial view! The initial view can be drawn with standard methods. 
        //What happens if the user rotates before opening up the table/imageView? -The TV does not get rendered properly in portrait. Even if the device begins the interaction in portrait mode, the tableView is not rendered properly, ONLY on rotation is this fixed. Landscape works correctly in all cases (starting in landscape, rotating in landscape, rotating while outside the view into landscape). 'reloadData' is called only when the tableView is visible? Reload the data just before rendering. The imageView is rendered correctly.
        var rotationHasOccurred : Bool = false
        if (newWidth != nil) {
            rotationHasOccurred = true
        }
        
        print("Image View - Height: \(dataEntryImageView.frame.height). Width: \(dataEntryImageView.frame.width)")
        print("MinX: \(dataEntryImageView.frame.minX). MaxX: \(dataEntryImageView.frame.maxX)")
        print("MinY: \(dataEntryImageView.frame.minY). MaxY: \(dataEntryImageView.frame.maxY)")
        print("Table View - Height: \(labelsTableView.frame.height). Width: \(labelsTableView.frame.width)")
        
        let numberOfPartitions = CGFloat(numberOfLabels)
        if (!rotationHasOccurred) { //No rotation, first time the view has been opened
            let partitionSize = (dataEntryImageView.frame.height)/numberOfPartitions
            if numberOfLabels > 1 { //No partitioning for only 1 label
                for partition in 1...(numberOfLabels - 1) {
                    // Coordinate system - top left corner of the image view is point (0, 0), width = 764, height = 619 points (in portrait orientation).
                    let partitionNumber = CGFloat(partition)
                    drawLineFrom(CGPoint(x: 0, y: (partitionSize*partitionNumber)), toPoint: CGPoint(x: dataEntryImageView.frame.width, y: (partitionSize*partitionNumber)))
                    //print("From Point: (0, \(partitionSize*partitionNumber)). To Point: (\(dataEntryImageView.frame.width), \(partitionSize*partitionNumber))")
                    
                    //Add a centered textLabel into each partition:
                    let product = 2 * partitionSize * partitionNumber - partitionSize
                    let textField = UITextField(frame: CGRect(x: ((dataEntryImageView.frame.width * 0.25)/2), y: ((product - 50)/2), width: (dataEntryImageView.frame.width * 0.75), height: 50))
                    textField.placeholder = "Please enter a value for the \(openScope!.getLabelsForMK()![partition - 1])"
                    textField.textColor = UIColor.blackColor()
                    textField.backgroundColor = UIColor.clearColor()
                    textField.userInteractionEnabled = true //In IB, set user interaction = enabled for imageView as well or textField will not respond to touch!
                    dataEntryImageView.addSubview(textField)
                    dataEntryImageView.bringSubviewToFront(textField)
                    if partition == 1 { //The top-most label is the 1st responder
                        textField.becomeFirstResponder()
                    }
                }
            }
            //Generate the last textField - split the final partition in half (or the entire frame if there is only 1 label). Make the delegate = the VC.
            let lastPartitionTopPoint = dataEntryImageView.frame.height - partitionSize
            let lastTextFieldYPosition = (dataEntryImageView.frame.height + lastPartitionTopPoint - 50)/2
            let lastTextField = UITextField(frame: CGRect(x: ((dataEntryImageView.frame.width * 0.25)/2), y: lastTextFieldYPosition, width: dataEntryImageView.frame.width * 0.75, height: 50))
            lastTextField.textColor = UIColor.blackColor()
            lastTextField.backgroundColor = UIColor.clearColor()
            lastTextField.tag = 2
            lastTextField.placeholder = "Enter a value for \(openScope!.getLabelsForMK()![numberOfLabels - 1]) & press the 'Return' key."
            lastTextField.delegate = self
            if (numberOfPartitions == 1) { //If there is only 1 label, the last label is also 1st responder
                lastTextField.becomeFirstResponder()
            }
            dataEntryImageView.addSubview(lastTextField)
            dataEntryImageView.bringSubviewToFront(lastTextField)
        } else { //Rotation has occurred while the TV & imageView are visible
            let imageViewWidth = newWidth! - 260
            let imageViewHeight = newHeight! - 100
            let partitionSize = (imageViewHeight)/numberOfPartitions
            if numberOfLabels > 1 {
                for partition in 1...(numberOfLabels - 1) {
                    let partitionNumber = CGFloat(partition)
                    drawLineFrom(CGPoint(x: 0, y: (partitionSize*partitionNumber)), toPoint: CGPoint(x: imageViewWidth, y: (partitionSize*partitionNumber)))
                    print("From Point: (0, \(partitionSize*partitionNumber)). To Point: (\(imageViewWidth), \(partitionSize*partitionNumber))")
                    
                    let product = 2 * partitionSize * partitionNumber - partitionSize
                    let textField = UITextField(frame: CGRect(x: ((imageViewWidth * 0.25)/2), y: ((product - 50)/2), width: (imageViewWidth * 0.75), height: 50))
                    textField.placeholder = "Please enter a value for the \(openScope!.getLabelsForMK()![partition - 1])"
                    textField.textColor = UIColor.blackColor()
                    textField.backgroundColor = UIColor.clearColor()
                    textField.userInteractionEnabled = true
                    dataEntryImageView.addSubview(textField)
                    dataEntryImageView.bringSubviewToFront(textField)
                    if partition == 1 {
                        textField.becomeFirstResponder()
                    }
                }
            }
            let lastPartitionTopPoint = imageViewHeight - partitionSize
            let lastTextFieldYPosition = (imageViewHeight + lastPartitionTopPoint - 50)/2
            let lastTextField = UITextField(frame: CGRect(x: ((imageViewWidth * 0.25)/2), y: lastTextFieldYPosition, width: (imageViewWidth * 0.75), height: 50))
            lastTextField.textColor = UIColor.blackColor()
            lastTextField.backgroundColor = UIColor.clearColor()
            lastTextField.tag = 2
            if newWidth! < 1024 {
                lastTextField.placeholder = "Enter a value for \(openScope!.getLabelsForMK()![numberOfLabels - 1]) & press 'Return'."
            } else {
                lastTextField.placeholder = "Enter a value for \(openScope!.getLabelsForMK()![numberOfLabels - 1]) & press the 'Return' key."
            }
            lastTextField.delegate = self
            if (numberOfPartitions == 1) {
                lastTextField.becomeFirstResponder()
            }
            dataEntryImageView.addSubview(lastTextField)
            dataEntryImageView.bringSubviewToFront(lastTextField)
            newWidth = nil //Clear the rotation indicators so they will be refreshed
            newHeight = nil
        }
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
        if currentPatient != nil {
            currentPatient = nil
            let alertController = UIAlertController(title: "Success!", message: "Patient file was closed. Please open a new file before continuing.", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
            alertController.addAction(ok)
            self.presentViewController(alertController, animated: true, completion: nil)
            configureViewForEntry("patientName")
        } else {
            let alertController = UIAlertController(title: "Error!", message: "No patient file is open.", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
            alertController.addAction(ok)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
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
    
    //MARK: - User Authentication
    
    var loggedIn : Bool = true { //When we want login functionality, set it to FALSE!!!
        didSet {
            if loggedIn == true { //Do nothing, go to DEM view.
            } else {
                self.performSegueWithIdentifier("showLogin", sender: self) //go to login screen
            }
        }
    }
    
    func didLoginSuccessfully() { //Delegate Method
        loggedIn = true //Sets loginValue to true, which configures the default view
        dismissViewControllerAnimated(true, completion: nil) //When we first load the VC, the VC performs a segue & modally shows the login screen; when we call 'dismissVC' (after authentication is complete), it dismisses the modally presented screen.
    }
    
    //MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Before we segue, set the delegate property only if the login VC is about to be shown:
        if segue.identifier == "showLogin" {
            let loginViewController = segue.destinationViewController as! LoginViewController
            loginViewController.delegate = self //set the DEM VC as delegate of the LoginVC
        }
    }
    
}