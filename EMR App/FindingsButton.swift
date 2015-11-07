//  FindingsButton.swift
//  EMR App
//  Created by Arnav Pondicherry  on 11/3/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Custom button for Physical&ROSDataEntryView which keeps track of position of the button (in the buttonCollectionView or in the regular view.

import UIKit

class FindingsButton: UIButton {

    var inCollectionView: Bool = false { //set to true when button moves -> collectionView
        didSet {
            if (inCollectionView == false) { //if button is not in collectionView, it has no position
                positionInCollectionView = nil
            }
        }
    }
    
    var positionInCollectionView: (Int, Int)? { //(column #, row #) in collectionView
        didSet {
            if (positionInCollectionView != nil) {
                let columnNumber = positionInCollectionView!.0
                let rowNumber = positionInCollectionView!.1
                if (columnNumber == 0) { //first column
                    appropriateFrameInCollectionView = CGRect(x: 10, y: (45 + rowNumber*50), width: 120, height: 40)
                } else if (columnNumber == 1) { //second column
                    appropriateFrameInCollectionView = CGRect(x: 150, y: (45 + rowNumber*50), width: 120, height: 40)
                }
            }
        }
    }
    
    var originalFrame: CGRect //reference to original position in dataEntryView
    var appropriateFrameInCollectionView: CGRect? //the correct position for the button based on row/col

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
