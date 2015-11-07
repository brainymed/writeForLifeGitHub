//  PhysicalAndROSDataEntryView.swift
//  EMR App
//  Created by Arnav Pondicherry  on 11/2/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// This class encapsulates all functionality for the dataEntryView in the Physical&ROSView.

import UIKit

protocol PhysicalAndROSDelegate {
    //This delegate acts as follows: when the user hits the 'Close View' button, it calls a function in the delegate (DEM & PCMVC) that renders the view appropriately!
    func physicalOrROSViewWasClosed()
    func callNotificationsFeedFromPhysicalAndROSView(notificationText: String)
}

// Problem - how do we control flow here? The user may not want to go through all the sections, so we should allow them to truncate the flow. Since we have next & last buttons, how can they navigate where they want to go more precisely rather than having to scroll through?

class PhysicalAndROSDataEntryView: UIView, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate, UITextFieldDelegate {
    
    var delegate: PhysicalAndROSDelegate? //Delegate Stored Property
    
    let applicationMode: String
    let viewChoice: String
    var currentVisibleSection: Int //used to keep track of which sub-section of the view is open
    var openOrganSystemButton: PhysicalAndROSOrganSystemButton? //whichever button was selected
    var physicalAndROSView: PhysicalAndROSView? //reference to superview
    
    //Default Views:
    var organSystemSelectionTextField = UITextField()
    var dataEntryInstructionsLabel = UILabel()
    var titleLabel = UILabel()
    var closeViewButton = UIButton()
    
    //Custom Views:
    var organSystemTitleLabel = UILabel()
    var sectionTitleLabel = UILabel()
    var escapeButton = UIButton()
    var nextSectionButton = UIButton()
    var lastSectionButton = UIButton()
    var doneButton = UIButton()
    var additionalFindingsTextField = UITextField()
    var additionalFindingsTextFieldShouldBeVisible: Bool = false //protection variable
    var buttonCollectionView = UIView() //view that holds selected 'findingButton's
    var buttonCollectionViewTitleLabel = UILabel() //title for collectionView
    var tagsForButtonsInCollectionView = Dictionary<String, [Int]>() //remembers what buttons are selected
    
    //TableView & Search Bar:
    var tableViewDataArray: [String] = [] //data displayed when user is not searching (should be empty)
    var filteredArray = [String]() //populated when user types in search bar
    var shouldShowSearchResults: Bool = false
    var findingsTableView: UITableView = UITableView(frame: CGRect(x: 220, y: 180, width: 360, height: 50), style: UITableViewStyle.Plain)
    var searchController = UISearchController(searchResultsController: nil) //does this need to be set to nil when the class is closed?
    
    //MARK: - Initializers
    
    init(applicationMode: String, viewChoice: String) {
        self.applicationMode = applicationMode
        self.viewChoice = viewChoice
        self.currentVisibleSection = 0
        
        super.init(frame: CGRect(x: 200, y: 0, width: 764, height: 619)) //only call super.init AFTER initializing instance variables
        
        //Set up TV & Search Controller/Search Bar:
        findingsTableView.delegate = self
        findingsTableView.dataSource = self
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        findingsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a finding and hit 'Return'"
        searchController.searchBar.barStyle = .Black
        searchController.searchBar.sizeToFit() //formats size properly WRT tableView
        findingsTableView.tableHeaderView = searchController.searchBar
        findingsTableView.hidden = true //TV is not visible
        
        renderDefaultDataEntryView()
    }
    
    required init?(coder aDecoder: NSCoder) { //called when view is reconstituted from nib???
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Default View Rendering
    
    func renderDefaultDataEntryView() {
        //Configure view:
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor(red: 0, green: 0.25, blue: 0.40, alpha: 1.0)
        
        self.addSubview(configureViewTitleLabel())
        self.addSubview(configureDataEntryInstructionsLabel())
        self.addSubview(configureCloseViewButton())
        self.addSubview(configureOrganSystemSelectionTextField())
    }
    
    func configureViewTitleLabel() -> UILabel {
        titleLabel.frame = CGRect(x: 280, y: 10, width: 230, height: 40)
        titleLabel.font = UIFont.boldSystemFontOfSize(18)
        if (self.viewChoice == "physicalExam") {
            titleLabel.text = "Physical Exam View"
        } else {
            titleLabel.text = "Review of Systems View"
        }
        titleLabel.textColor = UIColor.whiteColor()
        //        let title_constraint_hCenter = NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        //        self.addConstraint(title_constraint_hCenter)
        return titleLabel
    }
    
    func configureDataEntryInstructionsLabel() -> UILabel {
        dataEntryInstructionsLabel.frame = CGRect(x: 150, y: 140, width: 500, height: 200)
        dataEntryInstructionsLabel.textAlignment = NSTextAlignment.Center
        dataEntryInstructionsLabel.numberOfLines = 7
        dataEntryInstructionsLabel.backgroundColor = UIColor.whiteColor()
        
        if (viewChoice == "physicalExam") { //PX label & abbreviations
            dataEntryInstructionsLabel.text = "Type in the abbreviation for an organ system or tap on the corresponding button to the left.\n Abbreviations: Constitutional = C, Neuro = N, Psych = P, Head & Neck = HN, Eyes = EY, Ears/Nose/Mouth/Throat = ENMT, Heart = H, Lungs = L, GI = GI, GU = GU, Musculoskeletal = MS, Breast = BR, Chaperone = CH, Rectal = RE, Back = B, Skin = SK."
        } else { //ROS label & abbreviations
            dataEntryInstructionsLabel.text = "Type in the abbreviation for an organ system or tap on the corresponding button to the left.\n Abbreviations: Constitutional = C, Neuro = N, Psych = P, Eyes = EY, Ears/Nose/Mouth/Throat = ENMT, Cardiovascular = CV, Respiratory = R, GI = GI, GU = GU, Musculoskeletal = MS, Integumentary = IN, Hematologic/Lymphatic = HL, Allergic/Immunologic = AI, Endocrine = EN."
        }
        return dataEntryInstructionsLabel
    }
    
    func configureOrganSystemSelectionTextField() -> UITextField {
        //How to create some spacing away from the wall?
        organSystemSelectionTextField.frame = CGRect(x: 150, y: 350, width: 500, height: 50)
        organSystemSelectionTextField.userInteractionEnabled = true
        organSystemSelectionTextField.backgroundColor = UIColor.whiteColor()
        organSystemSelectionTextField.tag = 200 //assign unique tag for 'return' behavior config
        organSystemSelectionTextField.becomeFirstResponder()
        organSystemSelectionTextField.placeholder = "Enter an organ system abbreviation and hit 'Return'"
        organSystemSelectionTextField.addTarget(self, action: "textFieldWasTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        return organSystemSelectionTextField
    }
    
    func configureCloseViewButton() -> UIButton { //button for escaping Px or ROS view
        closeViewButton.frame = CGRect(x: 600, y: 50, width: 120, height: 30)
        closeViewButton.setTitle("Close View", forState: UIControlState.Normal)
        closeViewButton.addTarget(self, action: "closeViewButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        closeViewButton.backgroundColor = UIColor.blackColor()
        return closeViewButton
    }
    
    //MARK: - Default Button Actions
    
    func closeViewButtonClick(sender: UIButton) {
        //Remove views from main view & return the app to the default view (depends on application mode)
        if (self.applicationMode == "DEM") {
            obtainReferenceToSuperview()
            self.superview?.removeFromSuperview() //removes the Px & ROS View (remove or delete?)
            self.delegate?.physicalOrROSViewWasClosed() //configure DEM for fieldName w/ delegate method
        } else if (self.applicationMode == "PCM") {
            //
        }
    }
    
    //MARK: - Custom View Rendering
    
    func renderDataEntryViewForOrganSystemButton(sender: PhysicalAndROSOrganSystemButton) {
        openOrganSystemButton = sender //set the openButton indicator
        
        //Remove the human body from view & take the whole screen to render the interface:
        obtainReferenceToSuperview()
        physicalAndROSView?.clearPhysicalAndROSView() //hides bodyIV & removes subviews from dataEntryV
        
        //Redraw the dataEntryView to take up the entire screen:
        self.frame = CGRect(x: 0, y: 0, width: 964, height: 619)
        self.backgroundColor = UIColor(red: 50/255, green: 163/255, blue: 216/255, alpha: 1)
        
        //Add subviews:
        self.addSubview(findingsTableView)
        searchController.searchBar.hidden = false
        searchController.searchBar.becomeFirstResponder()
        self.addSubview(configureEscapeButton())
        self.addSubview(configureViewTitleLabel())
        self.addSubview(configureDoneButton())
        self.addSubview(configureOrganSystemTitleLabel((sender.titleLabel?.text)!))
        if let sectionTitle = configureSectionTitleLabel() { //optional section label
            self.addSubview(sectionTitle)
        }
        self.addSubview(configureAdditionalFindingsTextField())
        self.addSubview(configureButtonCollectionView())
        
        let sectionsArray = openOrganSystemButton!.sectionsArray!
        if (sectionsArray.count != 1) {
            self.addSubview(configureNextSectionButton())
            self.addSubview(configureLastSectionButton())
        }
        
        //Create buttons for each label, matched to the sections, present 1 section @ a time:
        generateArrayOfButtonTitles()
        generateTableViewDataArray() //create table view's cells
        findingsTableView.reloadData()
    }
    
    func configureOrganSystemTitleLabel(system: String) -> UILabel {
        organSystemTitleLabel.frame = CGRect(x: 300, y: 70, width: 250, height: 40)
        organSystemTitleLabel.text = "Section: " + system
        organSystemTitleLabel.textColor = UIColor.whiteColor()
        return organSystemTitleLabel
    }
    
    func configureSectionTitleLabel() -> UILabel? { //section = sub-part of an organ system
        sectionTitleLabel.frame = CGRect(x: 300, y: 120, width: 250, height: 40)
        let sectionsArray = openOrganSystemButton!.sectionsArray!
        if (sectionsArray.count > 1) { //only render the label if there is more than 1 section
            sectionTitleLabel.text = "Sub-section: " + sectionsArray[currentVisibleSection] //grab items from open button's section array
            sectionTitleLabel.adjustsFontSizeToFitWidth = true
        } else { //empty section title (or just remove the label altogether?)
            return nil
        }
        sectionTitleLabel.textColor = UIColor.whiteColor()
        return sectionTitleLabel
    }
    
    func configureEscapeButton() -> UIButton {
        escapeButton.frame = CGRect(x: 50, y: 50, width: 80, height: 30)
        escapeButton.setTitle("Escape", forState: UIControlState.Normal)
        escapeButton.addTarget(self, action: "escapeButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        escapeButton.backgroundColor = UIColor.blackColor()
        return escapeButton
    }
    
    func configureDoneButton() -> UIButton { //available in all sections, so users can stop when they want
        doneButton.frame = CGRect(x: 750, y: 50, width: 80, height: 30)
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.addTarget(self, action: "doneButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.backgroundColor = UIColor.blackColor()
        return doneButton
    }
    
    func configureNextSectionButton() -> UIButton {
        nextSectionButton.frame = CGRect(x: 750, y: 570, width: 150, height: 30)
        nextSectionButton.enabled = true //default is enabled
        nextSectionButton.alpha = 1.0
        nextSectionButton.setTitle("Next Section", forState: UIControlState.Normal) //Can we orient the title differently (on top of the image, say?)
        nextSectionButton.setImage(UIImage(named: "right_arrow"), forState: UIControlState.Normal)
        nextSectionButton.addTarget(self, action: "nextSectionButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        nextSectionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        return nextSectionButton
    }
    
    func configureLastSectionButton() -> UIButton {
        lastSectionButton.frame = CGRect(x: 50, y: 570, width: 150, height: 30)
        lastSectionButton.enabled = false //default is not enabled b/c we start on the first section
        lastSectionButton.alpha = 0.5
        lastSectionButton.setTitle("Previous Section", forState: UIControlState.Normal) //Can we orient the title differently (on top of the image, say?)
        lastSectionButton.setImage(UIImage(named: "left_arrow"), forState: UIControlState.Normal)
        lastSectionButton.addTarget(self, action: "lastSectionButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        lastSectionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        return lastSectionButton
    }
    
    func configureAdditionalFindingsTextField() -> UITextField {
        let placeholder = "Enter Any Additional Findings & Press 'Return'"
        additionalFindingsTextField.frame = CGRect(x: 220, y: 180, width: 360, height: 40)
        additionalFindingsTextField.backgroundColor = UIColor.blackColor()
        additionalFindingsTextField.tintColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1)
        additionalFindingsTextField.textColor = UIColor.whiteColor()
        additionalFindingsTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        additionalFindingsTextField.hidden = true //default is hidden
        additionalFindingsTextField.delegate = self
        return additionalFindingsTextField
    }
    
    func configureButtonCollectionView() -> UIView {
        buttonCollectionView.frame = CGRect(x: 635, y: 100, width: 300, height: 350)
        buttonCollectionView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        
        //Configure Title:
        buttonCollectionView.addSubview(buttonCollectionViewTitleLabel)
        let titleWidth = buttonCollectionView.frame.width
        buttonCollectionViewTitleLabel.frame = CGRect(x: 0, y: 0, width: titleWidth, height: 35)
        buttonCollectionViewTitleLabel.text = "Selected Findings"
        buttonCollectionViewTitleLabel.textAlignment = .Center
        buttonCollectionViewTitleLabel.textColor = UIColor(red: 50/255, green: 163/255, blue: 216/255, alpha: 1)
        buttonCollectionViewTitleLabel.backgroundColor = UIColor.blackColor()
        buttonCollectionViewTitleLabel.font = UIFont.boldSystemFontOfSize(15)
        
        return buttonCollectionView
    }
    
    func generateArrayOfButtonTitles() { //create buttons on bottom of view for each section
        let labelsDict = openOrganSystemButton!.labelsArray!
        let sectionsArray = openOrganSystemButton!.sectionsArray!
        var labelsArray: [[String]] = [] //array containing an array of each section's labels
        for section in sectionsArray {
            let array = labelsDict[section] as! [String]
            labelsArray.append(array)
        }
        generateButtonsWithFindings(labelsArray)
    }
    
    private func generateButtonsWithFindings(buttonTitlesArray: [[String]]) {
        let currentSectionTitles = buttonTitlesArray[currentVisibleSection]
        let lastSectionTitleNumber = currentSectionTitles.count
        var tagIncrementer = 0
        var counter = 0
        var horizontalSpacer = 0 //horizontal spacing
        var verticalSpacer = 0 //vertical spacing
        for title in currentSectionTitles {
            if (counter%5 == 0) && (counter != 0) { //5 buttons per row
                //Every 5th button, add 1 to the value of row (which will create a new row):
                verticalSpacer += 1
                horizontalSpacer = 0 //reset when a new row is created (to start from left again)
                //Eventually we want to stagger the buttons so incomplete rows are centered
            }
            
            if (counter != (lastSectionTitleNumber - 1)) { //NOT the last item
                let button = FindingsButton(frame: CGRect(x: (100 + horizontalSpacer*150), y: (480 + verticalSpacer*50), width: 120, height: 40)) //custom button class
                button.tag = 20 + tagIncrementer //button tags are between 20 - 40
                button.setTitle(title, forState: UIControlState.Normal)
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                button.addTarget(self, action: "findingButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
                button.backgroundColor = UIColor.blackColor()
                button.layer.borderColor = UIColor.whiteColor().CGColor
                button.layer.borderWidth = 1.0
                button.layoutMargins = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5) //*
                self.addSubview(button)
            } else { //last item in the array ('Additional Findings' button) has special class
                let button = AdditionalFindingsButton(frame: CGRect(x: (100 + horizontalSpacer*150), y: (480 + verticalSpacer*50), width: 120, height: 40))
                button.tag = 20 + tagIncrementer
                button.setTitle(title, forState: UIControlState.Normal)
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                button.addTarget(self, action: "additionalFindingsButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
                button.backgroundColor = UIColor.blackColor()
                button.layer.borderColor = UIColor.whiteColor().CGColor
                button.layoutMargins = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5) //*
                button.layer.borderWidth = 1.0
                self.addSubview(button)
            }
            
            counter += 1
            horizontalSpacer += 1
            tagIncrementer += 1
        }
    }
    
    //MARK: - Table View Configuration
    
    func generateTableViewDataArray() { //constructs array based on which buttons are in the DEV
        var labelsForButtonsInView: [String] = []
        for view in self.subviews {
            if (view.tag >= 20) && (view.tag <= 40) {
                if let button = (view as? FindingsButton) {
                    labelsForButtonsInView.append((button.titleLabel?.text)!)
                } else if let lastButton = (view as? AdditionalFindingsButton) {
                    labelsForButtonsInView.append((lastButton.titleLabel?.text)!)
                }
            }
        }
        tableViewDataArray = labelsForButtonsInView
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if (shouldShowSearchResults) {
//            return filteredArray.count
//        } else {
//            return tableViewDataArray.count
//        }
        return 0 //don't display the TV itself (use the button highlighting as user's visual cue)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        if (shouldShowSearchResults) { //use filteredArray to populate dataArray
            cell.textLabel?.text = filteredArray[indexPath.row]
        } else { //use full list to populate dataArray
            cell.textLabel?.text = tableViewDataArray[indexPath.row]
        }
//        cell.textLabel?.numberOfLines = 2
//        cell.textLabel?.textAlignment = NSTextAlignment.Center
//        cell.backgroundColor = UIColor.blackColor()
//        cell.textLabel?.textColor = UIColor.whiteColor()
//        cell.separatorInset = UIEdgeInsetsZero
        cell.userInteractionEnabled = false
        return cell
    }
    
    //MARK: - Search Controller & Search Bar
    
    func renderDefaultFindingsButtonVisuals() { //resets visuals for buttons in dataEntryView
        for view in self.subviews {
            if (view.tag >= 20) && (view.tag <= 40) {
                if let button = (view as? FindingsButton) {
                    button.alpha = 1.0
                    button.userInteractionEnabled = true
                }
            }
        }
    }
    
    func didPresentSearchController(searchController: UISearchController) { //called when view 1st appears
        searchController.searchBar.showsCancelButton = false //gets rid of 'Cancel' button
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) { //called after tapping out of searchBar
        if (searchBar.hidden == false) && !(searchBar.isFirstResponder()) { //set it as 1st responder
            searchBar.becomeFirstResponder()
        } else if (searchBar.hidden == true) && (additionalFindingsTextFieldShouldBeVisible) {
            additionalFindingsTextField.becomeFirstResponder() //do not delete, only thing that works!
        }
        if (shouldShowSearchResults) { //reset TV data & button visuals
            shouldShowSearchResults = false
            findingsTableView.reloadData()
            renderDefaultFindingsButtonVisuals()
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") { //called when the field is cleared
            if (shouldShowSearchResults) { //set data from filtered -> complete array
                shouldShowSearchResults = false
                findingsTableView.reloadData()
                renderDefaultFindingsButtonVisuals()
            }
        } else { //called when text is entered; set data from filtered -> complete array
            shouldShowSearchResults = true
            findingsTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) { //called when 'Enter' is pressed
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet() //trim whiteSpace
        let searchBarTrimmedText = searchBar.text!.stringByTrimmingCharactersInSet(whitespaceSet)
        if (searchBarTrimmedText != "") && (filteredArray.count == 1) { //last item in filteredArray
            for view in self.subviews { //easier way to do this w/ tag?
                if let button = (view as? AdditionalFindingsButton) {
                    if (filteredArray.contains((button.titleLabel?.text)!)) {
                        additionalFindingsButtonClick(button)
                    }
                } else if let button = (view as? FindingsButton) {
                    if (filteredArray.contains((button.titleLabel?.text)!)) {
                        findingButtonClick(button)
                    }
                }
            }
            searchBar.text = ""
        } else if (searchBarTrimmedText != "") && (filteredArray.count > 1) {
            //If there is an exact match, select that button:
            if (filteredArray.contains(searchBarTrimmedText.capitalizedString)) { //check for EXACT match
                for view in self.subviews {
                    if let button = (view as? FindingsButton) { //if button label matches, 'click' it
                        if (button.titleLabel?.text == searchBarTrimmedText.capitalizedString) {
                            findingButtonClick(button)
                        }
                    }
                }
                searchBar.text = ""
            } else if (searchBarTrimmedText != "") && (filteredArray.count > 1) {
                //Provide notification telling user to narrow down to 1 option:
                delegate?.callNotificationsFeedFromPhysicalAndROSView("Please narrow your search down to 1 button before pressing 'Return'")
            }
        }
        shouldShowSearchResults = false //set data from filtered -> complete array
        findingsTableView.reloadData()
        renderDefaultFindingsButtonVisuals() //reset buttons
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet() //trim whiteSpace
        let searchString = searchController.searchBar.text?.stringByTrimmingCharactersInSet(whitespaceSet)
        if (searchString != "") {
            filteredArray = tableViewDataArray.filter({ (button) -> Bool in
                let buttonTitle: NSString = button
                //Rework this - we want to search from front -> back, not accepting any set of the string at any position in the word.
                let result = (buttonTitle.rangeOfString(searchString!, options: NSStringCompareOptions.CaseInsensitiveSearch)).location != NSNotFound
                return (result) //filters the data according to what we ask from it in the closure body, and stores the matching elements to the filteredArray. Each string in the source array is represented by the 'button' parameter value of the closure. This string is converted to a NSString object so we can use rangeOfString(…). The method checks if the searched term (searchString) exists in the current 'button', and if so it returns its range (NSRange) in the button string. If the string we’re searching for doesn’t exist in the current button value, then it returns 'NSNotFound'. As the closure expects a Bool value to be returned, return the comparison result between the rangeOfString return value & the NSNotFound value.
            })
            findingsTableView.reloadData()
            
            for view in self.subviews { //gray out & disable each button that doesn't match search results
                if let button = (view as? FindingsButton) { //cast works for additionalFindingsButton!
                    if !(filteredArray.contains((button.titleLabel?.text)!)) {
                        button.alpha = 0.5
                        button.userInteractionEnabled = false
                    } else { //button is contained -> normal visual
                        button.alpha = 1.0
                        button.userInteractionEnabled = true
                    }
                }
            }
        }
    }
    
    //MARK: - Custom Button Actions
    
    func escapeButtonClick(sender: UIButton) { //called by hitting escape (no escape on keyboards*) keyboard shortcut. We need to get the button is currently opened
        currentVisibleSection = 0 //reset for next run, or should we leave it as is so user can return to last point?
        tagsForButtonsInCollectionView = Dictionary<String, [Int]>() //reset or not?
        
        if (self.applicationMode == "DEM") { //return to default view
            returnToDefaultDataEntryView()
        } else if (self.applicationMode == "PCM") {
            
        }
    }
    
    func doneButtonClick(sender: UIButton) { //captures & stores information, then returns -> defaultView
        print("Done! Saving information...")
        //Capturing info: create a dictionary for each section containing the buttons that were selected + any additional findings. Based on this dictionary, we know what is normal (everything else). We need to check API to understand what to do but create the dictionary & save it to the persistent store (make 1 dict each for Px & ROS). 
        
        currentVisibleSection = 0 //reset for next run
        tagsForButtonsInCollectionView = Dictionary<String, [Int]>() //reset
        openOrganSystemButton?.informationHasBeenEnteredForOrganSystem = true //completion indicator, does this actually pass the reference to the actual button itself? Need to redraw button for it to show. 
        obtainReferenceToSuperview()
        physicalAndROSView?.passButtonVisualConfigurationToBodyImageView(openOrganSystemButton!)
        returnToDefaultDataEntryView()
    }
    
    //MARK: - Findings Buttons Logic
    
    func nextSectionButtonClick(sender: UIButton) { //moves view to next section (sync w/ R arrow?)
        let sectionsArray = openOrganSystemButton!.sectionsArray!
        let currentSection = sectionsArray[currentVisibleSection]
        
        if (sectionsArray.count > 1) {
            lastSectionButton.enabled = true //activate lastButton
            lastSectionButton.alpha = 1
            
            if (currentVisibleSection < sectionsArray.count - 1) {
                currentVisibleSection += 1 //don't forget to reset this variable whenever the escape button is pressed. This won't get reset if someone clicks on another template or gets out by some other method, how to account for this?
                let upcomingSection = sectionsArray[currentVisibleSection] //section being transitioned ->
                storeButtonsCurrentlyInCollectionView(currentSection)
                configureSectionTitleLabel()
                generateArrayOfButtonTitles() //draw new buttons FIRST
                assignButtonsToCollectionView(upcomingSection) //then re-allocate buttons
                generateTableViewDataArray() //create table view's data
                findingsTableView.reloadData()
            }
            
            if (currentVisibleSection == (sectionsArray.count - 1)) { //disable & gray out nextButton if (after pressing next), current visible section is the last one.
                nextSectionButton.alpha = 0.5
                nextSectionButton.enabled = false
            }
        }
        searchController.searchBar.becomeFirstResponder()
    }
    
    func lastSectionButtonClick(sender: UIButton) { //moves view to previous section (sync w/ L arrow?)
        nextSectionButton.enabled = true //reset nextSection button
        nextSectionButton.alpha = 1
        let sectionsArray = openOrganSystemButton!.sectionsArray!
        let currentSection = sectionsArray[currentVisibleSection]
        
        if (currentVisibleSection != 0) {
            currentVisibleSection -= 1 //reset this variable whenever the escape button is pressed
            let upcomingSection = sectionsArray[currentVisibleSection] //section we are moving to
            storeButtonsCurrentlyInCollectionView(currentSection)
            configureSectionTitleLabel() //generate new title
            generateArrayOfButtonTitles() //draw new buttons FIRST
            assignButtonsToCollectionView(upcomingSection) //then re-allocate buttons
            generateTableViewDataArray() //create table view's data
            findingsTableView.reloadData()
        }
            
        if (currentVisibleSection == 0) { //disable 'lastButton' in first section
            lastSectionButton.alpha = 0.5
            lastSectionButton.enabled = false
        }
        searchController.searchBar.becomeFirstResponder()
    }
    
    func storeButtonsCurrentlyInCollectionView(currentSection: String) {
        tagsForButtonsInCollectionView[currentSection] = [] //initialize dict
        for button in buttonCollectionView.subviews {
            if (button is FindingsButton) || (button is AdditionalFindingsButton) {
                tagsForButtonsInCollectionView[currentSection]!.append(button.tag)
                button.removeFromSuperview() //remember which buttons were removed by tag #! Set a tag number for the 'additional findings' button (it is always the last item in the array) that opens up a textField for custom entry, then change the button color to reflect special information (make it green). Press enter to accept info from the text field (use existing textField in the search bar!).
            }
        }
        for subview in self.subviews { //remove other existing buttons for current section
            if (subview.tag >= 20) && (subview.tag <= 40) { //buttons have tags from 20-40
                subview.removeFromSuperview()
            }
        }
    }
    
    func assignButtonsToCollectionView(upcomingSection: String) { //reassign buttons to collection view
        let buttonsInCollection: [Int]? = tagsForButtonsInCollectionView[upcomingSection]
        if let tagArray = buttonsInCollection {
            for tag in tagArray {
                let button = self.viewWithTag(tag) as? FindingsButton
                if (button != nil) {
                    findingButtonClick(button!)
                } else {
                    print("Physical&ROSDataEntryView -> lastSectionButtonClick (error!)")
                }
            }
        }
    }
    
    func findingButtonClick(sender: FindingsButton) { //all findingsButtons except 'Additional Findings'
        if (sender.inCollectionView == false) { //not in collectionView, move -> collectionView
            //Not rendering properly b/c - if you have 2 buttons in the view & click on the top-most one to remove it, there is still 1 button left. The next time you add a button, it counts & notices there is 1 button, so it adds the new button 1 slot down (where the other button is currently sitting). To adjust best practice is to slide up the other buttons.
            sender.inCollectionView = true
            sender.removeFromSuperview()
            let count = buttonCollectionView.subviews.count - 1 //check # of buttons already in the view (1 minus total b/c of the titleLabel)
            let buttonsInRow = count%6 //# of buttons in the right-most row
            buttonCollectionView.addSubview(sender)
            if (count >= 6) { //start a new row
                sender.frame = CGRect(x: 150, y: (45 + buttonsInRow*50), width: 120, height: 40)
                sender.positionInCollectionView = (1, buttonsInRow)
            } else {
                sender.frame = CGRect(x: 10, y: (45 + buttonsInRow*50), width: 120, height: 40)
                sender.positionInCollectionView = (0, buttonsInRow)
            }
        } else { //in collectionView, move -> dataEntryView
            let removedButtonColumn = sender.positionInCollectionView!.0
            let removedButtonRow = sender.positionInCollectionView!.1
            let removedButtonOverallPosition = 6 * removedButtonColumn + (removedButtonRow + 1)
            sender.inCollectionView = false //sets positionInView -> nil*
            sender.removeFromSuperview()
            self.addSubview(sender)
            sender.frame = sender.originalFrame //return to its original spot
            for view in buttonCollectionView.subviews { //set button's new position & change frame
                if let button = view as? FindingsButton { //generic cast, works for all buttons
                    let columnNumber = button.positionInCollectionView!.0
                    let rowNumber = button.positionInCollectionView!.1
                    let overallPosition = 6 * columnNumber + (rowNumber + 1)
                    if (overallPosition > removedButtonOverallPosition) { //only need to modify for buttons after the removed button
                        if (columnNumber == 1) && (rowNumber == 0) { //position -> last button in row 1
                            button.positionInCollectionView = (0, 5)
                        } else { //slide other buttons up 1 row
                            button.positionInCollectionView = (columnNumber, rowNumber - 1)
                        }
                        button.frame = button.appropriateFrameInCollectionView!
                    }
                }
            }
        }
        generateTableViewDataArray() //change the tableView data according to what items are in view
        findingsTableView.reloadData()
        renderDefaultFindingsButtonVisuals()
        searchController.searchBar.becomeFirstResponder()
        searchController.searchBar.text = ""
    }
    
    func additionalFindingsButtonClick(sender: AdditionalFindingsButton) {//'Additional Findings' button
        if (sender.inCollectionView == false) { //not in collectionView, move -> collectionView
            if (sender.additionalFindings == "") { //no additional findings added yet, highlight button
                switchAdditionalFindingsButtonVisualState(sender)
                renderAdditionalFindingsTextField() //display TF for entry
            } else { //additional finding has been entered, move -> collection view
                switchAdditionalFindingsButtonVisualState(sender)
                sender.inCollectionView = true
                sender.removeFromSuperview()
                let count = buttonCollectionView.subviews.count - 1
                let buttonsInRow = count%6 //# of buttons are in the right-most row
                buttonCollectionView.addSubview(sender)
                if (count >= 6) {
                    sender.frame = CGRect(x: 150, y: (45 + buttonsInRow*50), width: 120, height: 40)
                    sender.positionInCollectionView = (1, buttonsInRow)
                } else {
                    sender.frame = CGRect(x: 10, y: (45 + buttonsInRow*50), width: 120, height: 40)
                    sender.positionInCollectionView = (0, buttonsInRow)
                }
                generateTableViewDataArray() //change tableView data according to what items are in view
                findingsTableView.reloadData()
                renderDefaultFindingsButtonVisuals()
                renderAdditionalFindingsTextField() //hide TF
            }
        } else { //in collectionView, move -> dataEntryView
            let removedButtonColumn = sender.positionInCollectionView!.0
            let removedButtonRow = sender.positionInCollectionView!.1
            let removedButtonOverallPosition = 6 * removedButtonColumn + (removedButtonRow + 1)
            sender.inCollectionView = false
            sender.additionalFindings = "" //clear the findings
            sender.removeFromSuperview()
            self.addSubview(sender)
            sender.frame = sender.originalFrame //return to its original spot
            for view in buttonCollectionView.subviews { //set new position & change frame
                if let button = view as? FindingsButton {
                    let columnNumber = button.positionInCollectionView!.0
                    let rowNumber = button.positionInCollectionView!.1
                    let overallPosition = 6 * columnNumber + (rowNumber + 1)
                    if (overallPosition > removedButtonOverallPosition) {
                        if (columnNumber == 1) && (rowNumber == 0) { //position -> last button in row 1
                            button.positionInCollectionView = (0, 5)
                        } else { //slide other buttons up 1 row
                            button.positionInCollectionView = (columnNumber, rowNumber - 1)
                        }
                        button.frame = button.appropriateFrameInCollectionView!
                    }
                }
            }
            generateTableViewDataArray() //change the tableView data according to what items are in view
            findingsTableView.reloadData()
            renderDefaultFindingsButtonVisuals()
            searchController.searchBar.becomeFirstResponder()
        }
        searchController.searchBar.text = ""
    }
    
    func renderAdditionalFindingsTextField() { //handles display of TF vs. TV
        additionalFindingsTextField.text = "" //clear text for new cycle
        if (additionalFindingsTextField.hidden == true) { //reveal TF, hide TV
            additionalFindingsTextFieldShouldBeVisible = true
            additionalFindingsTextField.hidden = false
            searchController.active = false
            searchController.searchBar.hidden = true
            searchController.searchBar.resignFirstResponder()
            additionalFindingsTextField.becomeFirstResponder() //flashes for a second before disappearing! Something is taking FR afterwards maybe? After button press - ended called 2x (maybe once is when the view is invisible)
        } else { //reveal TV, hide TF
            additionalFindingsTextFieldShouldBeVisible = false
            additionalFindingsTextField.hidden = true
            searchController.searchBar.hidden = false
            additionalFindingsTextField.resignFirstResponder() //do not delete!
            searchController.searchBar.becomeFirstResponder() //do not delete (necessary)!
        }
    }
    
    func switchAdditionalFindingsButtonVisualState(button: AdditionalFindingsButton) {
        if (button.visualState == false) { //highlight button
            button.visualState = true
            button.backgroundColor = UIColor.greenColor()
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        } else { //restore to default
            button.visualState = false
            button.backgroundColor = UIColor.blackColor()
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool { //for additionalFindingsTF
        print("Return was hit, saving entered input...")
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet() //trim whiteSpace
        let textFieldTrimmedText = textField.text!.stringByTrimmingCharactersInSet(whitespaceSet)
        let labelsDict = openOrganSystemButton!.labelsArray!
        let sectionsArray = openOrganSystemButton!.sectionsArray!
        let section = sectionsArray[currentVisibleSection]
        let numberOfLabelsForCurrentSection = labelsDict[section]!.count
        let lastButtonTag = 19 + numberOfLabelsForCurrentSection
        let additionalFindingsButton = self.viewWithTag(lastButtonTag) as! AdditionalFindingsButton
        if (textFieldTrimmedText != "") { //values were entered, save -> AF button
            //Get reference to the additionalFindings button:
            additionalFindingsButton.additionalFindings = textField.text! //set button's custom info
            additionalFindingsButtonClick(additionalFindingsButton) //send -> collectionView
        } else { //empty, de-highlight the button & leave it in the view
            switchAdditionalFindingsButtonVisualState(additionalFindingsButton)
            renderAdditionalFindingsTextField()
        }
        textField.text = ""
        return true
    }
    
    //MARK: - Helper Functions
    
    func obtainReferenceToSuperview() {
        physicalAndROSView = (self.superview as? PhysicalAndROSView)
    }
    
    func clearDataEntryView() {
        obtainReferenceToSuperview()
        searchController.searchBar.hidden = true
        searchController.searchBar.resignFirstResponder()
        for button in buttonCollectionView.subviews { //clear collection view
            button.removeFromSuperview()
        }
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func returnToDefaultDataEntryView() {
        openOrganSystemButton = nil //clear openSystemButton
        clearDataEntryView() //remove all sub-views
        obtainReferenceToSuperview()
        physicalAndROSView?.bodyImageView.hidden = false //reveal bodyIV
        
        //Configure default dataEntryView:
        self.frame = CGRect(x: 200, y: 0, width: 764, height: 619)
        renderDefaultDataEntryView()
    }

}