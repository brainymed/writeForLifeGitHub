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

    // The Tab Bar controller does not segue between its tabs, so you must use these 2 delegate protocols to handle passing data between your VCs in the controller. 
    // We will NOT prevent the user from switching between tabs if a patient file is not opened. However, we will make sure the first interaction the user has with each separate interface (after logging in) is to open an existing patient file or create a new one.
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {//Function called BEFORE the transition takes place
        return true
    }
    
    // When the user selects a button to move between views, we will pass the currentPatient from the previous VC to the current VC. We don't need to check since currentPatient is optional in both cases, so it will simply pass 'nil' if no file is opened.
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let dataEntryModeViewController = tabBarController.viewControllers![0] as! DataEntryModeViewController
        let patientCareModeViewController = tabBarController.viewControllers![1] as! PatientCareModeViewController
        
        if (viewController == dataEntryModeViewController) { //Transition: Patient Care -> Data Entry Mode
            print("Sender: Patient Care Mode VC")
            (viewController as! DataEntryModeViewController).currentPatient = patientCareModeViewController.currentPatient
        }
        
        if (viewController == patientCareModeViewController) { //Transition: Data Entry -> Patient Care Mode
            print("Sender: Data Entry Mode VC")
            (viewController as! PatientCareModeViewController).currentPatient = dataEntryModeViewController.currentPatient
        }
    }
}

//Tells the TabBarController to respond to the supportedInterfaceOrientations & shouldAutorotate functions from the children VCs. 
extension UITabBarController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if let selected = selectedViewController {
            return selected.supportedInterfaceOrientations()
        }
        return super.supportedInterfaceOrientations()
    }
    public override func shouldAutorotate() -> Bool {
        if let selected = selectedViewController {
            return selected.shouldAutorotate()
        }
        return super.shouldAutorotate()
    }
}
