//  PhysicalAndROSView.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/14/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Use the same view for Physical & ROS - when we segue into this view, we will send over whether the query was for 'Physical' or 'ROS' & then configure the view's actions accordingly.

import UIKit

class PhysicalAndROSView: UIView {

    var query : String
    
    //This initializer is not building when I add the 2nd parameter for the 'query'
    override init(frame: CGRect, query: String) {
        super.init(frame: frame)
        self.query = query
        if self.query == "physicalExam" {
            self.addViewForPhysical()
        } else if self.query == "ROS" {
            self.addViewForROS()
        } else {
            print("Error, condition should never be called from Physical&ROSView")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViewForPhysical() { //Add custom view for physical exam
    
    }
    
    func addViewForROS() { //Add custom view for ROS
        
    }
}
