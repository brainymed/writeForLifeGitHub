//  PatientNameEntryView.swift
//  EMR App
//
//  Created by Arnav Pondicherry  on 9/14/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Call this class when the patient clicks on the 'enter name' template button. In order for this view to be rendered, it must be called (in the VC) as a sub-view of the master view!
// See the ReadOnlyVC for example of implementation

import UIKit

class PatientNameEntryView: UIView {
    
    var label : UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addCustomView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCustomView() {
        label.frame = CGRectMake(50, 10, 200, 100)
        label.backgroundColor=UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        label.text = "test label"
        label.hidden=true
        self.addSubview(label)
        
        let btn: UIButton = UIButton()
        btn.frame = CGRectMake(50, 120, 200, 100)
        btn.backgroundColor=UIColor.redColor()
        btn.setTitle("button", forState: UIControlState.Normal)
        btn.addTarget(self, action: "changeLabel", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(btn)
        
        let txtField : UITextField = UITextField()
        txtField.frame = CGRectMake(50, 250, 100,50)
        txtField.backgroundColor = UIColor.grayColor()
        self.addSubview(txtField)
    }
}
