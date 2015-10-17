//  PhysicalAndROSOrganSystemButton.swift
//  EMR App
//  Created by Arnav Pondicherry  on 10/14/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Custom button class for Px & ROS views to check if information has been entered for an organ system

import UIKit

class PhysicalAndROSOrganSystemButton: UIButton {
    var informationHasBeenEnteredForOrganSystem: Bool
    
    override init(frame: CGRect) {
        self.informationHasBeenEnteredForOrganSystem = false
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) { //called when view is reconstituted from nib???
        fatalError("init(coder:) has not been implemented")
    }
}
