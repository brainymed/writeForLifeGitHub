//  DataEntryModeViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/21/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Controls the Data Entry portion of the app for information input into the EMR. Make sure to add LOGOUT button for both views so that others can utilize the app @ any point! 

// Stagger the horizontal centering of the views by 60 pts so they are centered in the clear area!

import UIKit

class DataEntryModeViewController: UIViewController, LoginViewControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var currentPatient: Patient? {
        didSet {
            if (currentPatient != nil) { //Patient file is open. Handle accordingly.
                
            } else { //No patient file is open. Configure view for opening a patient file.
                configureViewForEntry("patientName")
            }
        }
    }
    
    var currentUser: String? //current user who is logged in
    var openScope: EMRField?
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var patientNameTextField: UITextField!
    @IBOutlet weak var patientNameEntryLabel: UILabel!
    @IBOutlet weak var fieldNameTextField: UITextField!
    @IBOutlet weak var fieldNameEntryLabel: UILabel!
    @IBOutlet weak var openExistingFileButton: UIButton!
    @IBOutlet weak var createNewFileButton: UIButton!
    @IBOutlet weak var currentPatientButton: UIButton!
    @IBOutlet weak var currentUserButton: UIButton!
    @IBOutlet weak var notificationsFeed: UILabel! //Convert our twitter feed -> a scrolling set of table view cells instead of a text view
    
    // Current user & patient views:
    @IBOutlet weak var patientInfoView: UIView!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var currentPatientLabel: UILabel!
    @IBOutlet weak var currentUserLabel: UILabel!
    
    // Table View & Associated Side View:
    @IBOutlet weak var labelsTableView: UITableView!
    @IBOutlet weak var dataEntryImageView: UIImageView!
    //var dataEntryView: UIView?
    var tableViewCellLabels: [String]? //labels in TV cells based on entered MK
    
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
        if loggedIn == false {//If user is not logged in, modally segue -> login screen. Need this line of code b/c 'didSet' function is NOT called when we initially set value of 'loggedIn'.
            performSegueWithIdentifier("showLogin", sender: nil)
        }
        
        print("Current User (DEMVC): \(currentUser)")
        print("Current Patient (DEMVC): \(currentPatient?.name)")
        
        //Alternative way using user defaults:
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
            //Configure view differently. Allow the user to hit the 'ENTER' button & submit information for other, non-name views!
            configureViewForEntry("fieldName")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Handling Rotation of View
    
    override func viewWillLayoutSubviews() { //Called when view rotates
//        for subview in view.subviews {
//            if subview.tag == 1000 {
//                subview.removeFromSuperview()
//            }
//        }
        
        //Redraw the lines WRT the table view on rotation if the table view is active:
        if labelsTableView.hidden == false {
            
        }
        
//        let customView = PatientNameEntryView(frame: CGRect(x: 60, y: 100, width: view.frame.width - 60, height: view.frame.height - 150))
//        customView.backgroundColor = UIColor.blueColor()
//        customView.tag = 1000
//        self.view.addSubview(customView)
    }
    
    //MARK: - Standard View Configuration
    
    @IBAction func createNewFileButtonClick(sender: AnyObject) {
        //Create a new patient file:
        let inputName = patientNameTextField.text!
        currentPatient = Patient(name: inputName, insertIntoManagedObjectContext: managedObjectContext)
        patientNameTextField.text = ""
        configureViewForEntry("fieldName")
        notificationsFeed.text = "New File Created for \(inputName)"
        fadeIn()
        fadeOut()
    }
    
    @IBAction func openExistingFileButtonClick(sender: AnyObject) {
        //Open an existing patient file for the given name (check for patient) using the EMR patient name retrieval API or the persistent store:
        let inputName = patientNameTextField.text!
        currentPatient = Patient(name: inputName, insertIntoManagedObjectContext: managedObjectContext)
        patientNameTextField.text = ""
        configureViewForEntry("fieldName")
        notificationsFeed.text = "Patient File Opened for \(inputName)"
        fadeIn()
        fadeOut()
    }
    
    func configureViewForEntry(desiredView: String) { //Configures view
        switch desiredView {
        case "patientName": //Configure view to open a patient file
            //Hide field name entry views:
            fieldNameTextField.hidden = true
            fieldNameEntryLabel.hidden = true
            
            //Bring up patient name entry views:
            patientNameTextField.hidden = false
            patientNameEntryLabel.hidden = false
            openExistingFileButton.hidden = false
            createNewFileButton.hidden = false
            
            //Make the 'patientNameTextField' the 1st responder:
            patientNameTextField.becomeFirstResponder()
        case "fieldName": //Configure view for field name entry
            //Hide patient name entry views & resign 1st responder:
            patientNameTextField.resignFirstResponder()
            patientNameTextField.hidden = true
            patientNameEntryLabel.hidden = true
            openExistingFileButton.hidden = true
            createNewFileButton.hidden = true
            
            //Bring up 'Field Name' Entry Views:
            fieldNameEntryLabel.hidden = false
            fieldNameTextField.hidden = false
            
            //Set delegate for fieldNameTextField & make it the 1st responder.
            fieldNameTextField.delegate = self
            fieldNameTextField.becomeFirstResponder()
        case "fieldValue":
            //Hide the open views & pull up the formatted TV, post "{} Field has been opened" in the twitter feed:
            fieldNameEntryLabel.hidden = true
            fieldNameTextField.hidden = true
            labelsTableView.reloadData()
            print(tableViewCellLabels)
            renderDataEntryImageView(tableViewCellLabels!.count)
            labelsTableView.hidden = false
            dataEntryImageView.hidden = false
        default:
            print("Error. Switch case triggered unknown statement")
        }
    }
    
    //Configure behavior when 'RETURN' button is hit:
    func textFieldShouldReturn(textField: UITextField) -> Bool {
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
        } else if textField.tag == 2 { // Sender is Field Value Analog (to be deleted when specific configurations are enabled)
            //Send the input values to the EMR or persistent data store, post "{} has been mapped to {}" in the twitter feed, & return the fieldName view:
            notificationsFeed.text = "'\(input!)' has been sent to '\(openScope!.getFieldName()!)'"
            fadeIn()
            fadeOut()
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
    
    //MARK: - Template Selection Rendering
    
    
    
    //MARK: - TableView & ImageView Rendering
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Number of cells we show is based on the # of labels needed:
        if let numberOfCells = tableViewCellLabels?.count {
            return numberOfCells
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //When we draw cells, put a background color for each cell that matches the color of the side view! Can help user w/ visual cues.
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        if let labelArray = tableViewCellLabels { //Partition TV based on # of cells
            cell.textLabel?.text = labelArray[indexPath.row]
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            cell.textLabel?.textColor = UIColor.blueColor()
            cell.backgroundColor = UIColor.lightGrayColor()
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None //When user taps on cell, it does not change in appearance
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let labelArray = tableViewCellLabels {
            let numberOfLabels = CGFloat(labelArray.count)
            let cellHeightPortrait = 619/numberOfLabels //device in portrait
            let cellHeightLandscape = 875/numberOfLabels //device in landscape
            return cellHeightPortrait
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        //Disable selection of TV cells & prevent the swiping functionality. User interaction is also disabled from Interface Builder.
        return nil
    }
    
    func renderDataEntryImageView(numberOfLabels: Int) {
        //Depending on the # of labels, we draw in a # of lines for the image view, then partition it into a # of views = # of labels. In each view, we will color code it to the label and then draw in a text view/label for data entry.
        let numberOfPartitions = CGFloat(numberOfLabels)
        let partitionSize = (dataEntryImageView.frame.height)/numberOfPartitions
        print("Image View - Height: \(dataEntryImageView.frame.height). Width: \(dataEntryImageView.frame.width)")
        print("MinX: \(dataEntryImageView.frame.minX). MaxX: \(dataEntryImageView.frame.maxX)")
        print("MinY: \(dataEntryImageView.frame.minY). MaxY: \(dataEntryImageView.frame.maxY)")
        print("Table View - Height: \(labelsTableView.frame.height). Width: \(labelsTableView.frame.width)")
        if numberOfLabels > 1 { //No partitioning for only 1 label
            for partition in 1...(numberOfLabels - 1) {
                let partitionNumber = CGFloat(partition)
                drawLineFrom(CGPoint(x: 0, y: (partitionSize*partitionNumber)), toPoint: CGPoint(x: dataEntryImageView.frame.width, y: (partitionSize*partitionNumber)))
                print("From Point: (0, \(partitionSize*partitionNumber)). To Point: (\(dataEntryImageView.frame.width), \(partitionSize*partitionNumber))")
            }
        }
//        drawLineFrom(CGPoint(x: 0, y: 206.33), toPoint: CGPoint(x: 764, y: 206.33))
//        drawLineFrom(CGPoint(x: 0, y: 412.66), toPoint: CGPoint(x: 764, y: 412.6))
//        drawLineFrom(CGPoint(x: 0, y: 619), toPoint: CGPoint(x: 764, y: 619))
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
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0)
        CGContextSetBlendMode(context, .Normal)
        
        //Draw the path:
        CGContextStrokePath(context)
        
        //Wrap up the drawing context to render the new line:
        dataEntryImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        dataEntryImageView.alpha = 1.0
        UIGraphicsEndImageContext()
    }
    
    //MARK: - Check Users
    
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
        //In response to a touch, checks where the touch occurred. If either the patientInfoView or userInfoView is open & the touch is outside, it hides the view. 
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
    
    //Since this is the initial VC, we will redirect -> login screen from here if no user is logged in:
    var loggedIn : Bool = true { //When we want login functionality, set it to FALSE!!!
        didSet {
            if loggedIn == true {
                //Do nothing, go to DEM view.
            } else {
                self.performSegueWithIdentifier("showLogin", sender: self) //go to login screen
            }
        }
    }
    
    //Delegate Method:
    func didLoginSuccessfully() {
        loggedIn = true //Sets the loginValue to true, which will call the 'configureView' function!
        dismissViewControllerAnimated(true, completion: nil) //When we first load the VC, the VC performs a segue & modally shows the login screen (it 'owns' that screen); when we call 'dismissVC' it dismisses the modally presented screen after authentication is complete.
    }
    
    //MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Before we segue, we want to set the delegate property only if the login VC is about to be shown:
        if segue.identifier == "showLogin" {
            let loginViewController = segue.destinationViewController as! LoginViewController
            loginViewController.delegate = self //we set the homescreen VC as the delegate of the LoginVC!
        }
    }
    
}