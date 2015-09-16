//  ReadOnlyViewController.swift
//  Created by Arnav Pondicherry  on 9/5/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Controls the Read-Only portion of the app for information extraction from EMR.

import UIKit

class ReadOnlyViewController: UIViewController, MLTWMultiLineViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var multiLineView: MLTWMultiLineView!
    
    var currentPatient: Patient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeMLTW()
        
        let customView = PatientNameEntryView(frame: CGRect(x: 0, y: 0, width: 50, height: 100))
        self.view.addSubview(customView)
        
        print("Current Patient (ROVC): \(currentPatient)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeMLTW() {
        multiLineView.delegate = self
        multiLineView.guidelineFirstPosition = 100.0 //changes position of the lines drawn on the view
        multiLineView.autoScrollDisabled = true
        
        self.configureRecognitionForLocale()
    }
    
    func configureRecognitionForLocale() {
        let cursiveResource : NSString = NSBundle.mainBundle().pathForResource("en_US-ak-cur.lite", ofType: "res")!
        let textResource : NSString = NSBundle.mainBundle().pathForResource("en_US-lk-text.lite", ofType: "res")!
        let resourceArray : [NSString] = [cursiveResource, textResource]
        let certificate = NSData(bytes: myCertificate, length: myCertificate.count)
        multiLineView.configureWithLocale("en_US", resources: resourceArray, lexicon: nil, certificate: certificate, density: 132 * 2)
    }
    
    func multiLineViewDidBeginConfiguration(view: MLTWMultiLineView!) {
        //
    }
    
    func multiLineViewDidEndConfiguration(view: MLTWMultiLineView!) {
        //
    }
    
    func multiLineView(view: MLTWMultiLineView!, didFailConfigurationWithError error: NSError!) {
        NSLog("Failed configuration: %@", error.localizedDescription)
    }
    
    func multiLineViewDidStartRecognition(view: MLTWMultiLineView!) {
        //Called when program starts recognizing handwriting & converting -> text:
    }
    
    func multiLineViewDidEndRecognition(view: MLTWMultiLineView!) {
        //
    }
    
    func multiLineView(view: MLTWMultiLineView!, didChangeText text: String!) {
        textView.text = text
    }
    
    //MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Do something:
    }
}
