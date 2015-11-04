//  FrontOfficeModeViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 11/2/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// This VC is only for use by members of the front office (as authenticated during login). They can use this VC for creation of new patients or update of existing patient information. Ask Vibha what front office people do - create new patients, handle billing, anything else? 

import UIKit

class FrontOfficeModeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var escapeButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var dataEntryImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var tableViewLabels: [String] = ["firstName", "lastName", "dob", "gender", "homePhone", "mobilePhone", "email", "address1", "address2", "city", "state", "zip"]
    var tableViewCellColors: [UIColor] = []
    var newWidth: CGFloat? //on rotation, the width of the incoming view
    var newHeight: CGFloat? //on rotation, the height of the incoming view
    var jsonDictToServer = Dictionary<String, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        renderDataEntryImageView(tableViewLabels.count)
        
//        for view in dataEntryImageView.subviews {
//            //tags 1-4 are required for creating new patient (rest are optional). Add in the tags that are required for Athena's API.
//            if (view.tag == 1 || view.tag == 2) { //first & last name NOT optional
//                //let lowercaseInput = inputWord.lowercaseString
//            } else if (view.tag == 3) { //dob
//                let dateFormat = "../../...." //modify to allow only #s
//                let matchPredicate = NSPredicate(format:"SELF MATCHES %@", dateFormat)
//                //                    if (matchPredicate.evaluateWithObject(lowercaseInput)) {
//                //                        self.match = true
//                //                    }
//            } else if (view.tag == 4) { //gender
//                let genderFormat: [String] = ["male", "female"]
//                let matchPredicate = NSPredicate(format:"SELF MATCHES %@", genderFormat)
//                //                    if (matchPredicate.evaluateWithObject(lowercaseInput)) {
//                //                        self.match = true
//                //                    }
//            } else if (view.tag == 5) {
//                //Optional but has specified format:
//                let emailFormat = ".*@.*.com" //modify properly
//                let matchPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
//                //                    if (matchPredicate.evaluateWithObject(lowercaseInput)) {
//                //                        self.match = true
//                //                    }
//            } else if (view.tag > 5 && view.tag < tableViewCellLabels!.count) { //optional
//                let key = tableViewCellLabels![counter]
//                let value = (view as? UITextField)?.text
//                if (value != nil) { //make sure cast from UIView -> TextField worked
//                    let trimmedValue = value!.stringByTrimmingCharactersInSet(whitespaceSet)
//                    if (trimmedValue == "") { //make sure no value is left empty
//                        error = true
//                        errorTagIndicator = view.tag
//                        notificationText = "Please enter a value for '\(key)'"
//                        break
//                    }
//                    openScope?.jsonDictToServer[fieldName]![key] = trimmedValue
//                    notificationText += key + ": " + trimmedValue + "\n"
//                } else { //shouldn't trigger unless a UIView added to dataEntryIV has a tag (error)
//                    notificationText = "Error occurred. UIView in DataEntryIV has a tag when it shouldn't."
//                    error = true
//                }
//                counter += 1
//            } else if (view.tag == 100) {//Grab last textField's or textView's input value
//                let key = (tableViewCellLabels!.last)!
//                if (lastFieldTrimmedText == "") { //check if any values were left empty
//                    error = true
//                    errorTagIndicator = view.tag
//                    notificationText = "Please enter a value for '\(key)'"
//                    break
//                } else { //no field is empty
//                    openScope?.jsonDictToServer[fieldName]![key] = lastFieldTrimmedText
//                    if (openScope?.getFieldName() == "historyOfPresentIllness") {
//                        notificationText += "History of present illness has been entered."
//                    } else { //all other fields
//                        notificationText += key + ": " + lastFieldTrimmedText
//                    }
//                }
//            }
//        }
//        
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) { //called when view rotates, yields NEW size
        if tableView.hidden == false {
            newWidth = size.width
            newHeight = size.height
            //redraw the TV
        }
    }
    
    //MARK: - TableView & DataEntryImageView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewLabels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = tableViewLabels[indexPath.row]
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.separatorInset = UIEdgeInsetsZero
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let numberOfLabels = CGFloat(tableViewLabels.count)
        var cellHeight = CGFloat()
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight) {
            cellHeight = 690/numberOfLabels //device in landscape
        } else if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft) {
            cellHeight = 690/numberOfLabels //device in landscape
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
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
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
        
        if (!rotationHasOccurred) { //No rotation, first time the view has been opened
            let height = dataEntryImageView.frame.height
            let width = dataEntryImageView.frame.width
            print(height, width)
            partitionImageViewForOrientation(numberOfLabels, viewWidth: 750, viewHeight: 690)
        } else { //Rotation has occurred while the TV & imageView are visible
            let imageViewWidth = newWidth! - 260
            let imageViewHeight = newHeight! - 100
            partitionImageViewForOrientation(numberOfLabels, viewWidth: imageViewWidth, viewHeight: imageViewHeight)
        }
    }
    
    func partitionImageViewForOrientation(numberOfLabels: Int, viewWidth: CGFloat, viewHeight: CGFloat) { //Handles partitioning based on width & height of the imageView
        //If current fieldName allows for multiple sub-scopes, reveal the label & plus button:
        let numberOfPartitions = CGFloat(numberOfLabels)
        let partitionSize = viewHeight/numberOfPartitions
        if numberOfLabels > 1 { //No partitioning for only 1 label
            for partition in 1...(numberOfLabels - 1) {
                // Coordinate system - top left corner of the dataEntryIV is point (0, 0).
                let partitionNumber = CGFloat(partition)
                
                //Match partition color w/ the label color!!! First add a separate UIView to each partition & then add a unique textLabel & background color to the view. The UIView sits in the top left corner & extends the entire length & width of partitioned area.
                let product = 2 * partitionSize * partitionNumber - partitionSize
                let partitionView = UIImageView(frame: CGRect(x: 0, y: ((product - partitionSize)/2), width: viewWidth, height: partitionSize))
                //partitionView.backgroundColor = tableViewCellColors![partition - 1]
                let textField = UITextField(frame: CGRect(x: ((viewWidth * 0.25)/2), y: ((product - 50)/2), width: (viewWidth * 0.75), height: 50))
                textField.tag = partition //tag each textField for later reference
                let placeholderText = tableViewLabels[partition - 1]
                let placeholder = "Enter a value for the \(placeholderText) & press 'Tab'"
                textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor.yellowColor()]) //change placeholder color
                textField.textColor = UIColor.whiteColor()
                textField.backgroundColor = UIColor.clearColor()
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
        //lastPartitionView.backgroundColor = tableViewCellColors![numberOfLabels - 1]
        dataEntryImageView.addSubview(lastPartitionView)
        dataEntryImageView.sendSubviewToBack(lastPartitionView)
        
        
        let lastTextFieldYPosition = (viewHeight + lastPartitionTopPoint - 50)/2
        let lastTextField = UITextField(frame: CGRect(x: (viewWidth * 0.125), y: lastTextFieldYPosition, width: (viewWidth * 0.75), height: 50))
        lastTextField.textColor = UIColor.whiteColor()
        lastTextField.backgroundColor = UIColor.clearColor()
        lastTextField.tag = 100 //allows us to reference lastTextField in 'TFshouldReturn' function
        let placeholderText = tableViewLabels[numberOfLabels - 1]
        let placeholder = "Enter a value for \(placeholderText) & press the 'Return' key."
        lastTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor.yellowColor()]) //set placeholder text color
        lastTextField.delegate = self
        dataEntryImageView.addSubview(lastTextField)
        dataEntryImageView.bringSubviewToFront(lastTextField)
        if (numberOfPartitions == 1) { //if there is only 1 label, the lastTF is also 1st responder
            lastTextField.becomeFirstResponder()
        }
        
        drawLine(lastPartitionView, fromPoint: [CGPoint(x: 0, y: 0)], toPoint: [CGPoint(x: 0, y: lastPartitionView.frame.size.height)]) //final vertical line
    }
    
    func drawLine(imageView: UIImageView, fromPoint: [CGPoint], toPoint: [CGPoint]) {
        UIGraphicsBeginImageContext(imageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        imageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        for i in 0...(fromPoint.count - 1) {
            CGContextMoveToPoint(context, fromPoint[i].x, fromPoint[i].y)
            CGContextAddLineToPoint(context, toPoint[i].x, toPoint[i].y)
        }
        
        CGContextSetLineCap(context, .Round)
        CGContextSetLineWidth(context, 1.25)
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0) //white color
        CGContextSetBlendMode(context, .Normal)
        
        CGContextStrokePath(context)
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        imageView.alpha = 1.0
        UIGraphicsEndImageContext()
    }
    
    //MARK: - Network Request
    
    func sendHTTPRequestToEMR() {
        let dataParser = EMRDataParser(patientDict: jsonDictToServer)
        dataParser.ParseJSON {
            (let returnedEMRData) in
            print("Patient ID: \(returnedEMRData?.patientID)")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let input = textField.text
        textField.resignFirstResponder()
        if (textField.tag == 100) { //Sender is lastTextField from dataEntryImageView
            var error: Bool = false
            var errorTagIndicator: Int = 0
            getInputValuesFromTextFields(input!, notificationString: { (let notification) in
                error = notification.0
                errorTagIndicator = notification.1 //gives tag of the view which is empty
            })
            if (error == true) { //block reconfiguration of the view if there was an error
                dataEntryImageView.viewWithTag(errorTagIndicator)?.becomeFirstResponder()
                return false //block transition
            }
            
            print("Sending dictionary to EMR...")
            sendHTTPRequestToEMR() //*testing, send data -> server when user presses enter
        }
        for view in dataEntryImageView.subviews {
            if let textField = (view as? UITextField) {
                textField.text = ""
            }
        }
        textField.text = "" //clear textField before proceeding
        return true
    }
    
    func getInputValuesFromTextFields(lastFieldText: String, notificationString: ((Bool, Int, String) -> Void)) { //Grab values entered in textFields for notificationsFeed & mapping dictionary
        var counter = 0
        let whitespaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet() //trim whiteSpace & \n
        let lastFieldTrimmedText = lastFieldText.stringByTrimmingCharactersInSet(whitespaceSet)
        var notificationText = "" //text sent -> notificationFeed
        var error: Bool = false //false = no error, true = error (empty field found)
        var errorTagIndicator: Int = 0 //tells system tag # of offending field
        
        for view in dataEntryImageView.subviews {
            if (view.tag > 0 && view.tag < tableViewLabels.count) {
                let key = tableViewLabels[counter]
                print(key)
                let value = (view as? UITextField)?.text
                if (value != nil) { //make sure cast from UIView -> TextField worked
                    let trimmedValue = value!.stringByTrimmingCharactersInSet(whitespaceSet)
                    print(trimmedValue)
                    if (trimmedValue == "") { //make sure no value is left empty
                        print("error, counter: \(counter)")
                        error = true
                        errorTagIndicator = view.tag
                        notificationText = "Please enter a value for '\(key)'"
                        break
                    }
                    jsonDictToServer[key] = trimmedValue
                    notificationText += key + ": " + trimmedValue + "\n"
                } else { //shouldn't trigger unless a UIView added to dataEntryIV has a tag (error)
                    notificationText = "Error occurred. UIView in DataEntryIV has a tag when it shouldn't."
                    error = true
                }
                counter += 1
            } else if (view.tag == 100) {//Grab last textField's input value
                let key = (tableViewLabels.last)!
                if (lastFieldTrimmedText == "") { //check if any values were left empty
                    error = true
                    errorTagIndicator = view.tag
                    notificationText = "Please enter a value for '\(key)'"
                    break
                } else { //no field is empty
                    jsonDictToServer[key] = lastFieldTrimmedText
                    notificationText += key + ": " + lastFieldTrimmedText
                }
            }
        }
        notificationString(error, errorTagIndicator, notificationText) //Send back the closure
    }
    
    //MARK: - Button Actions
    
    @IBAction func escapeButtonClick(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func nextButtonClick(sender: AnyObject) {
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

}
