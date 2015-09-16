//Garbage Code that might come in handy later:

//MARK: - ViewController Drawing Code

override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    //Called when user touches the screen. This is the start of the drawing event, so reset swiped to 'false' b/c touch hasn't moved yet. Save the last touch location in 'lastPoint' so when the user starts drawing, you can keep track of where they started.
    swiped = false
    if let touch = touches.first {
        lastPoint = touch.locationInView(self.view)
    }
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

