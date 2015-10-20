//  TabBarViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/15/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Handles passing of information from VC -> VC.

import UIKit
import CoreBluetooth

class TabBarViewController: UITabBarController, UITabBarControllerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager = CBCentralManager()
    
    override func viewDidLoad() {
        //Set the delegate of the TabBarController to itself:
        self.delegate = self
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    //MARK: - Bluetooth Functionality
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case CBCentralManagerState.PoweredOff:
            print("")
        case CBCentralManagerState.PoweredOn:
            print("")
        default:
            break
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        centralManager.connectPeripheral(peripheral, options: nil)
        print("Peripheral Discovered: \(RSSI)")
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Device connected to peripheral: \(peripheral.name)")
        peripheral.delegate = self
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Connection to peripheral failed")
    }
    
    // MARK: - Navigation

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {//Function called BEFORE the transition takes place
        // The Tab Bar controller does NOT segue between its tabs, so you must use this & the next delegate protocols to handle passing data between your VCs in the controller.
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        // When the user selects a button to move between views, we will pass the currentPatient from the previous VC to the current VC. We don't need to check since currentPatient is optional in both cases, so it will simply pass 'nil' if no file is opened.
        let dataEntryModeViewController = tabBarController.viewControllers![0] as! DataEntryModeViewController
        let dataExtractionModeViewController = tabBarController.viewControllers![1] as! DataExtractionModeViewController
        
        if (viewController == dataEntryModeViewController) { //Transition: Data Extraction -> Data Entry
            print("Sender: Data Extraction Mode VC")
            (viewController as! DataEntryModeViewController).currentPatient = dataExtractionModeViewController.currentPatient
        }
        
        if (viewController == dataExtractionModeViewController) { //Transition: Data Entry -> Extraction
            print("Sender: Data Entry Mode VC")
            (viewController as! DataExtractionModeViewController).currentPatient = dataEntryModeViewController.currentPatient
        }
    }
    
}

extension UITabBarController {
    //Tells the TabBarController to respond to the supportedInterfaceOrientations & shouldAutorotate functions from the children VCs. 
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
