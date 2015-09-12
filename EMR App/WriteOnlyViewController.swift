//  WriteOnlyViewController.swift
//  Created by Arnav Pondicherry  on 9/5/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Controls the Write-Only portion of the app (for information input)

import UIKit
import CoreGraphics

class WriteOnlyViewController: UIViewController {
    
    @IBOutlet weak var canvasImageView: UIImageView!
    
    var lastPoint = CGPoint.zero
    var red : CGFloat = 0.0
    var green : CGFloat = 0.0
    var blue : CGFloat = 0.0
    var lineWidth : CGFloat = 0.0 //how thick lines are
    var swiped = false //identifies if line is continuous
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Called when user touches the screen. This is the start of the drawing event, so reset swiped to 'false' b/c touch hasn't moved yet. Save the last touch location in 'lastPoint' so when the user starts drawing, you can keep track of where they started.
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.locationInView(self.view)
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        //This method draws a line between 2 points. Set up a context holding the image currently in the canvasImageView.
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        canvasImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        //Get the current touch point & then draw a line from the last point to the current point. The touch events trigger so quickly that the result is a smooth curve:
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        //Set the drawing parameters for line size & color:
        CGContextSetLineCap(context, .Round)
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextSetBlendMode(context, .Normal)
        
        //Draw the path:
        CGContextStrokePath(context)
        
        //Wrap up the drawing context to render the new line:
        canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        canvasImageView.alpha = 1.0
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Set 'swiped' to true so we can keep track of whether there is currently a touch in progress. If the touch moves, it calls the helper function to draw a line (drawLineFrom) & updates the 'lastPoint' so that it has the value of the point you just left off:
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.locationInView(view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //1st check if user is in middle of a swipe; if not, it means the user tapped the screen to draw a single point, so we just draw a single point. If the user was in the middle of a swipe, you don't need to do anything b/c the 'touchesMoved' function will have handled the drawing.
        if !swiped {
            //Draw a single point:
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
    }
    
}