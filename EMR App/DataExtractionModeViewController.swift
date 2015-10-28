//  DataExtractionModeViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 10/14/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Takes in user extraction queries when a BT keyboard is detected. This is essentially the same view as DEM, with a standing tableView on the R margin that holds widgets. The textField & label in this center requesting extraction queries are ALWAYS present unless a widget is opened.
// Change the templates at the top to common EXTRACTION templates. Add these templates to PCM also.

import UIKit

class DataExtractionModeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, LoginViewControllerDelegate, PatientSelectionViewControllerDelegate {
    
    @IBOutlet weak var extractionQueryTextLabel: UILabel!
    @IBOutlet weak var extractionQueryTextField: UITextField!
    @IBOutlet weak var notificationsFeed: UILabel!
    
    var currentUser: String? //current user (HCP) who is logged in
    var openScope: EMRField? //handles MK identification & data mapping -> EMR
    var patientFileWasJustOpened: Bool = false //checks if patient file was just opened (for notification)
    var fileWasOpenedOrCreated: String = ""
    
    //MARK: - Standard View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extractionQueryTextField.becomeFirstResponder()
        extractionQueryTextField.delegate = self
        notificationsFeed.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        print("Current User (ExtractionMVC): \(currentUser)")
        print("Current Patient (ExtractionMVC): \(currentPatient?.name)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Widgets Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    //MARK: - Text Field Logic
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Send extraction query -> web server to obtain data
        return true
    }
    
    //MARK: - Notification Feed Animations
    
    func fadeIn() { //Fades in the twitter feed instantly
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.notificationsFeed.alpha = 1.0
            }, completion: nil)
    }
    
    func fadeOut() { //Gradually fades out the twitter feed
        UIView.animateWithDuration(1.0, delay: 3.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.notificationsFeed.alpha = 0.0
            }, completion: nil)
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
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLogin" {
            let loginViewController = segue.destinationViewController as! LoginViewController
            loginViewController.delegate = self
        } else if segue.identifier == "showPatientSelection" {
            let patientSelectionViewController = segue.destinationViewController as! PatientSelectionViewController
            patientSelectionViewController.delegate = self
        }
    }

}
