//  DataExtractionModeViewController.swift
//  EMR App
//  Created by Arnav Pondicherry  on 10/14/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Takes in user extraction queries when a BT keyboard is detected. This is essentially the same view as DEM, with a standing tableView on the R margin that holds widgets. The textField & label in this center requesting extraction queries are ALWAYS present unless a widget is opened.
// Change the templates at the top to common EXTRACTION templates. Add these templates to PCM also.

import UIKit

class DataExtractionModeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var extractionQueryTextLabel: UILabel!
    @IBOutlet weak var extractionQueryTextField: UITextField!
    @IBOutlet weak var notificationsFeed: UILabel!
    
    var currentPatient: Patient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extractionQueryTextField.becomeFirstResponder()
        extractionQueryTextField.delegate = self
        notificationsFeed.alpha = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Widgets Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    //MARK: - Text Field Logic
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Send extraction query -> web server to obtain data
        return true
    }
    
    //MARK: - Notification Feed Animations
    
    func fadeIn() { //Fades in the twitter feed instantly
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.notificationsFeed.alpha = 1.0
            }, completion: nil)
    }
    
    func fadeOut() { //Gradually fades out the twitter feed
        UIView.animateWithDuration(1.0, delay: 3.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.notificationsFeed.alpha = 0.0
            }, completion: nil)
    }
}
