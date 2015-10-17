//  PhysicalAndROSDataEntryView.swift
//  EMR App
//  Created by Arnav Pondicherry  on 10/14/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// R side view for data entry
//When we configure R side view, when no organ system is tapped, have label telling user what to do (w/ a list of keyboard shortcuts) & a text field to allow entry of shortcuts.
//We need to make this view a subView of the overall view, not of the physical&ROSView.
import UIKit

class PhysicalAndROSDataEntryView: UIView {
    
    var organSystemSelectionTextField = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) { //called when view is reconstituted from nib???
        fatalError("init(coder:) has not been implemented")
    }
   
    //MARK: - Default View Rendering
    
    func renderDefaultDataEntryView() {
        //Configure view:
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor(red: 0, green: 0.25, blue: 0.40, alpha: 1.0)
        
        //Add label, textField & button:
        let dataEntryInstructionsLabel = UILabel(frame: CGRect(x: 150, y: 140, width: 500, height: 150))
        let closeViewButton = UIButton(frame: CGRect(x: 600, y: 50, width: 80, height: 30))
        self.organSystemSelectionTextField.frame = CGRect(x: 150, y: 300, width: 300, height: 50)
        self.addSubview(dataEntryInstructionsLabel)
        self.addSubview(closeViewButton)
        self.addSubview(organSystemSelectionTextField)
        
        //Configure Instruction Label:
        dataEntryInstructionsLabel.numberOfLines = 5
        dataEntryInstructionsLabel.backgroundColor = UIColor.whiteColor()
        dataEntryInstructionsLabel.text = "Type in the abbreviation for an organ system or tap on the corresponding button. General = G, Neuro = N, Psych = P, Heart = H, Lungs = L, GI = GI, GU = GU, Peripheral = Pe, MS = M."
        
        //Configure TextField:
        organSystemSelectionTextField.userInteractionEnabled = true
        organSystemSelectionTextField.backgroundColor = UIColor.whiteColor()
        organSystemSelectionTextField.tag = 200 //assign unique tag for 'return' behavior config
        organSystemSelectionTextField.becomeFirstResponder()
        organSystemSelectionTextField.placeholder = "Enter an organ system and hit 'Return'"
        organSystemSelectionTextField.addTarget(self, action: "textFieldWasTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //Configure closeView Button:
        closeViewButton.setTitle("Close View", forState: UIControlState.Normal)
        closeViewButton.addTarget(self, action: "closeViewButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
//    func textFieldWasTapped(sender: AnyObject) {
//        organSystemSelectionTextField.becomeFirstResponder()
//    }
    
    //MARK: - Organ System Button Rendering
    
    func renderDataEntryViewForOrganSystemButton(sender: PhysicalAndROSOrganSystemButton) {
        
    }
    
    //MARK: - Close Open View
    
    func closeViewButtonClick(sender: UIButton) {
        //Remove views from main view & returns the app to the 'fieldName' view
        print("Button tapped")
    }
    
}
