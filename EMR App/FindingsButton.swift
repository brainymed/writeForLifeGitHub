//  FindingsButton.swift
//  EMR App
//  Created by Arnav Pondicherry  on 11/3/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Custom button for Physical&ROSDataEntryView which keeps track of position of the button (in the buttonCollectionView or in the regular view.

import UIKit

class FindingsButton: UIButton {

    var inCollectionView: Bool = false //set to true when button moves -> collectionView
    var originalFrame: CGRect //reference to original position in dataEntryView
    
    override init(frame: CGRect) {
        self.originalFrame = frame
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AdditionalFindingsButton: FindingsButton {
    var additionalFindings: String = "" //capture the custom text entered for the button
    var visualState: Bool = false //false = default visuals, true = highlighted
}
