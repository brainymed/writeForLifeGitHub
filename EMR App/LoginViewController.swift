//  LoginViewController.swift
//  Created by Arnav Pondicherry  on 8/23/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var currentUser: String?
    
    //Keyboard Detection:
    var keyboardSizeArray: [CGFloat] = []
    var keyboardAppearedHasFired: Bool?
    var bluetoothKeyboardAttached: Bool = false //true = BT keyboard, false = no BT keyboard
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add notifications the first time this view loads:
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChangedFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardAppeared:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        usernameField.becomeFirstResponder()
        if (keyboardAppearedHasFired == nil) { //BT keyboard attached
            bluetoothKeyboardAttached = true
        }
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
        //When the button is tapped, authenticate the username & pwd against EMR:
        if usernameField.text?.lowercaseString == "a" && passwordField.text == "a" {
            currentUser = usernameField.text //set the currentUser
            if (bluetoothKeyboardAttached == true) { //segue -> DEM
               performSegueWithIdentifier("showDEM", sender: self)
            } else { //segue -> PCM
                performSegueWithIdentifier("showPCM", sender: self)
            }
        } else { //use the alert controller to display a failure message.
            let alertController = UIAlertController(title: "Error!", message: "Incorrect username or password.", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                self.passwordField.text = ""
            })
            alertController.addAction(ok)
            presentViewController(alertController, animated: true, completion: nil)
        }
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
        if (segue.identifier == "showPCM") {
            let patientCareModeViewController = (segue.destinationViewController as! PatientCareModeViewController)
            patientCareModeViewController.currentUser = self.currentUser
        } else if (segue.identifier == "showDEM") {
            let tabBarViewController = (segue.destinationViewController as! TabBarViewController)
            let dataEntryModeViewController = (tabBarViewController.viewControllers![0]) as! DataEntryModeViewController
            dataEntryModeViewController.currentUser = self.currentUser
            dataEntryModeViewController.transitionedToDifferentView = false
        }
    }

}