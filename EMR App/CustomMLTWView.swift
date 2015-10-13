//  CustomMLTWView.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/14/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

import Foundation
import CoreGraphics

//Integrate w/ JotTouch Stylus & Enable Palm Rejection

class CustomMLTWView : MLTWMultiLineView, JotPalmRejectionDelegate {
    //Use to render custom drawing options such as gesture recognition. 
    func jotStylusTouchBegan(touches: Set<NSObject>!) {
        print("Touches Began")
    }
    
    func jotStylusTouchEnded(touches: Set<NSObject>!) {
        print("Touches Ended")
    }
    
    func jotStylusTouchCancelled(touches: Set<NSObject>!) {
        print("Touches Cancelled")
    }
    
    func jotStylusTouchMoved(touches: Set<NSObject>!) {
        print("Touches Moved")
    }
    
    func jotSuggestsToDisableGestures() {
        print("Gestures Disabled?")
    }
    
    func jotSuggestsToEnableGestures() {
        print("Gestures Enabled")
    }
}