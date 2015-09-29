//  LoginViewController.swift
//  Created by Arnav Pondicherry  on 8/23/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

import UIKit

protocol LoginViewControllerDelegate {
    //This delegate acts as follows: when the user enters a username & pwd, if we successfully validate those credentials, we dismiss the login screen, return to the home screen, & change the text field. This protocol has 1 required variable (currentUser) & 1 method which is called when we login & want move away from the login VC. We also want some other object to act as a delegate to the login VC to dismiss it when it is done doing the login work, so we need a delegate STORED PROPERTY (in the VC code)!
    var currentUser: String? { get set }
    func didLoginSuccessfully()
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: LoginViewControllerDelegate? //Delegate Stored Property
    var currentUser: String?
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonClick(sender: AnyObject) {
        //When the button is tapped, authenticate the username & pwd against EMR:
        if usernameField.text?.lowercaseString == "a" && passwordField.text == "a" {
            //Pass the currently logged in user to the open VC:
            currentUser = usernameField.text
            delegate?.currentUser = currentUser //sets the current user for the delegate VC
            delegate?.didLoginSuccessfully() //If we can authenticate the username & pwd, we call the delegate method
        } else {//Use the alert controller to display a failure message.
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

}