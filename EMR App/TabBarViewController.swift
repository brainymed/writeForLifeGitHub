//  TabBarViewController.swift
//  EMR App
//
//  Created by Arnav Pondicherry  on 9/15/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        //Set the delegate of the TabBarController to itself:
        self.delegate = self
    }
    
    // MARK: - Navigation

    // The Tab Bar controller does not segue between its tabs, so you must use these 2 delegate protocols to handle passing data between your VCs in the controller. We only need to configure behavior for the transition from the Write -> Read Controller; when we transition, there must be a patient selected so that the Read Controller can extract info from the EMR for that patient. B/C the Read controller cannot close a patient file, we don't need to worry about checking to see if the 'currentPatient' exists - on transition, we simply pass over the 'currentPatient' object.
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        let readViewController = tabBarController.viewControllers![1] as! ReadOnlyViewController
        let writeViewController = tabBarController.viewControllers![0] as! WriteOnlyViewController
        
        if viewController == readViewController { //Transition: Write -> Read Mode
            //Check if currentPatient exists in the current VC:
            if (writeViewController.currentPatient != nil) { //Patient file is open
                //Perform segue if 'currentPatient' is set:
                return true
            }
            else { //No patient file is open
                //Cancel segue if 'currentPatient' is not set & send an alert:
                let alertController = UIAlertController(title: "Error!", message: "No patient file is currently open. Please enter a patient name before proceeding to the Read View.", preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })
                alertController.addAction(ok)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                //Render the view for patient name entry:
                
                return false
            }
        }
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let readViewController = tabBarController.viewControllers![1] as! ReadOnlyViewController
        let writeViewController = tabBarController.viewControllers![0] as! WriteOnlyViewController
        
        if viewController == readViewController { //Transition: Write -> Read Mode
            print("Sender: Write Only")
            print("Tab Bar Controller (Before): \(readViewController.currentPatient)")
            (viewController as! ReadOnlyViewController).currentPatient = writeViewController.currentPatient!
            print("Tab Bar Controller (After): \(readViewController.currentPatient)")
        } else { //Transition: Read -> Write Mode
            print("Sender: Read Only")
            writeViewController.currentPatient = readViewController.currentPatient
        }
    }
}
