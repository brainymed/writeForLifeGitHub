//  LoginViewController.swift
//  Created by Arnav Pondicherry  on 8/23/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let preferences: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var providerTypeLabels: [String] = ["Front Office", "Nurse", "Physician"]
    @IBOutlet weak var providerTypeTableView: UITableView!
    
    //Keyboard Detection:
    var keyboardSizeArray: [CGFloat] = []
    var keyboardAppearedHasFired: Bool?
    var bluetoothKeyboardAttached: Bool = false //true = BT keyboard, false = no BT keyboard
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        providerTypeTableView.delegate = self
        providerTypeTableView.dataSource = self
        providerTypeTableView.layer.borderColor = UIColor.whiteColor().CGColor
        providerTypeTableView.layer.borderWidth = 2.0
        providerTypeTableView.layer.cornerRadius = 8
        
        //Add notifications the first time this view loads:
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChangedFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardAppeared:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        providerTypeTableView.hidden = true //default is hidden TV
        usernameField.becomeFirstResponder()
        if (keyboardAppearedHasFired == nil) { //BT keyboard attached
            bluetoothKeyboardAttached = true
        }
        print("Username from preferences: \(preferences.objectForKey("USERNAME"))")
    }
    
    //MARK: - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerTypeLabels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = providerTypeLabels[indexPath.row]
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.blueColor()
        cell.separatorInset = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Check username & password against provider type & authenticate:
        var loggedIn: Bool = false
        if (indexPath.row == 0) { //user is in front office
            if (usernameField.text == "a" && passwordField.text == "a") {
                loggedIn = true
            }
        } else if (indexPath.row == 1) { //user is nurse
            if (usernameField.text == "b" && passwordField.text == "b") {
                loggedIn = true
            }
        } else if (indexPath.row == 2) { //user is physician
            if (usernameField.text == "c" && passwordField.text == "c") {
                loggedIn = true
            }
        }
        
        if (loggedIn == true) { //check if authentication was successful & set user defaults/segue
            preferences.setValue(usernameField.text, forKey: "USERNAME")
            preferences.setValue(providerTypeLabels[indexPath.row], forKey: "PROVIDER_TYPE")
            if (bluetoothKeyboardAttached == true) { //segue -> DEM
                performSegueWithIdentifier("showDEM", sender: self)
            } else { //segue -> PCM
                performSegueWithIdentifier("showPCM", sender: self)
            }
        } else { //unsuccessful login, display error
            let alertController = UIAlertController(title: "Error!", message: "Incorrect username or password.", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                self.resetInterface()
            })
            alertController.addAction(ok)
            presentViewController(alertController, animated: true, completion: nil)
            tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        }
    }
    
    func resetInterface() {
        passwordField.text = ""
        providerTypeTableView.hidden = true
        passwordField.becomeFirstResponder()
    }
    
    //MARK: - Keyboard Tracking
    
    func keyboardChangedFrame(notification: NSNotification) { //fires when keyboard changes
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardFrame: CGRect = (userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue)!
        let keyboard: CGRect = self.view.convertRect(keyboardFrame, fromView: self.view.window)
        let sum = keyboard.origin.y + keyboard.size.height
        keyboardSizeArray.append(sum)
    }
    
    func keyboardAppeared(notification: NSNotification) {
        keyboardAppearedHasFired = true //check variable for 1st time view appears
        let lastKeyboardSize = keyboardSizeArray.last
        let height: CGFloat = self.view.frame.size.height
        if (lastKeyboardSize > height) {
            bluetoothKeyboardAttached = true
        } else {
            bluetoothKeyboardAttached = false
        }
        keyboardSizeArray = [] //clear for next sequence
    }
    
    //MARK: Login Actions
    
    @IBAction func loginButtonClick(sender: AnyObject) {
        //When the button is tapped, reveal the table view containing the provider types:
        providerTypeTableView.hidden = false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //Disable the 'login' button when nothing is present in the text field. This is set up so that as long as the PWD field is empty, the submit button is disabled. We set this up by linking the passwordTextField delegate to the LoginVC (right click & drag from the 'delegate' to the VC button in the top left).
        //Go to the storyboard, click on the button, & on the Attributes page set the 'State Config' to DISABLED; then scroll down to the 'Control' section & uncheck the box saying ENABLED!
        let length = (textField.text?.characters.count)! - range.length + string.characters.count
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
        if ((length > 0) && (textField.text?.stringByTrimmingCharactersInSet(whitespaceSet) != "")) {
            loginButton.enabled = true
        } else {
            loginButton.enabled = false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        loginButtonClick(textField)
        return true
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let preferences: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if (segue.identifier == "showPCM") {
            let patientCareModeViewController = (segue.destinationViewController as! PatientCareModeViewController)
            patientCareModeViewController.currentUser = preferences.objectForKey("USERNAME") as? String
        } else if (segue.identifier == "showDEM") {
            let tabBarViewController = (segue.destinationViewController as! TabBarViewController)
            let dataEntryModeViewController = (tabBarViewController.viewControllers![0]) as! DataEntryModeViewController
            dataEntryModeViewController.currentUser = preferences.objectForKey("USERNAME") as? String
            dataEntryModeViewController.transitionedToDifferentView = false
        }
    }

}