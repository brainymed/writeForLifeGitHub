//  EMRField.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/15/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

//This class takes in a user input & uses it to generate an EMR-compatible 'field name'.
//Process: user inputs word -> checks if input matches an existing fieldName -> if it matches, the class generates a fieldName -> user inputs field value -> converts field value to correct data type ->

import Foundation

class EMRField {
    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext //MOC for insertion of persistent data objects
    private var match : Bool = false
    private var currentPatient: Patient //assign open scope -> the current patient
    private var fieldName : String? //'fieldName' should always = nil when 'match' == FALSE
    private var tableViewLabels : [String]?
    private var tableViewCellColors : [UIColor]?
    private var currentItemCounter : Int? //for specific views (e.g. medications, diagnoses, allergies), counts the # of the item currently open.
    private var currentItemLabel : String? //for specific views, generates a (singular) label to indicate what item is currently open (e.g. "medication", "diagnosis", "allergy"). The label & counter should only exist simultaneously!
    var jsonDictToServer = Dictionary<String, [String : AnyObject]>() //dictionary containing user inputs being mapped -> server; related to the Patient class (dict keys -> Patient properties)
    
    init(inputWord: String, patient: Patient) {
        self.currentPatient = patient
        
        //Initializer matches the input word to a keyword format & returns a boolean value & an EMR field name, which can be obtained from separate getter functions.
        let lowercaseInput = inputWord.lowercaseString
        let formatArray : [String] = ["^med.*$", "^vitals$", "^physical$", "^r.*o.*s.*$", "allergies", "hpi"]
        var stopCounter = -1
        for format in formatArray {
            stopCounter += 1
            let matchPredicate = NSPredicate(format:"SELF MATCHES %@", format)
            if (matchPredicate.evaluateWithObject(lowercaseInput)) {
                self.match = true
                break
            }
        }
        
        //If the loop completes w/o finding a match ('match' == FALSE), we need to increment the stopCounter by 1 to indicate that its value is > length(formatArray).
        if !(self.match) {
            stopCounter += 1
        }
        
        //Use the value of the counter to determine when the loop stopped. Based on that value (which indicates the value in the 'formatArray' that matched the input, we assign a 'fieldName'.
        switch stopCounter {
        case 0:
            self.fieldName = "medications"
            self.currentItemCounter = 1
            self.currentItemLabel = "Medication"
        case 1:
            self.fieldName = "vitals"
        case 2:
            self.fieldName = "physicalExam"
        case 3:
            self.fieldName = "reviewOfSystems"
        case 4:
            self.fieldName = "allergies"
            self.currentItemCounter = 1
            self.currentItemLabel = "Allergy"
        case 5:
            self.fieldName = "historyOfPresentIllness"
        default:
            //If the counter's value is 1 greater than the length(formatArray), NO match was found.
            self.fieldName = nil
        }
        
        if let currentField = self.fieldName {
            //Create an entry in the mapping dict for the fieldName:
            self.jsonDictToServer[currentField] = Dictionary<String, AnyObject>()
            
            //Set the tableViewLabels array for the fieldName. We will need 2 arrays, one for display to the user (neatly formatted) & one matching the format specified by the server:
            switch currentField { //max # of labels that can fit in the view is 12 (from the looks of it)
            case "medications":
                tableViewLabels = ["Medication Name", "Route", "Dosage", "Frequency"]
            case "vitals":
                tableViewLabels = ["Height", "Weight", "Blood Pressure", "Heart Rate", "Respiratory Rate", "Temperature"]
            case "physicalExam":
                tableViewLabels = [] //no labels - TV is not called
            case "reviewOfSystems":
                tableViewLabels = [] //no labels - TV is not called
            case "allergies":
                tableViewLabels = ["Allergen", "Reaction", "Severity"]
            case "historyOfPresentIllness":
                tableViewLabels = ["History of Present Illness"]
            default:
                tableViewLabels = ["[getLabelsForMK - Default Switch (Error)"]
            }
            
            //Generate the tableViewCellColors array as a gradient from light -> dark blue, w/ the # of divisions depending on the # of labels. If there is only 1 label, use the default.
            let defaultColor = UIColor(red: 44/255, green: 137/255, blue: 210/255, alpha: 1)
            let boundColor = UIColor(red: 23/255, green: 75/255, blue: 125/255, alpha: 1)
            let numberOfLabels = (tableViewLabels?.count)!
            if (numberOfLabels == 0) { //no labels -> no color array
                tableViewCellColors = []
            } else if (numberOfLabels == 1) { //if there is 1 label, set the background -> default
                tableViewCellColors = [defaultColor]
            } else { //all other arrays should have a gradient
                tableViewCellColors = [boundColor] //top-most item is darkest color
                let redGradient: Double = (49 - 23)
                let greenGradient: Double = (159 - 75)
                let blueGradient: Double = (210 - 125)
                for i in 1...(numberOfLabels - 1) {
                    let counter = Double(i)
                    let total = Double(numberOfLabels - 1)
                    let partitionLength: Double = counter/total
                    let red = CGFloat((23 + redGradient * partitionLength))
                    let green = CGFloat((75 + greenGradient * partitionLength))
                    let blue = CGFloat((125 + blueGradient * partitionLength))
                    let intermediateColor = UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
                    tableViewCellColors?.append(intermediateColor)
                }
            }
        }
        
    }
    
    //MARK: - Match Checking
    
    internal func matchFound() -> Bool {
        return self.match
    }
    
    //MARK: - Mapping FVs -> Field Name
    
    internal func getFieldName() -> String? {
        return self.fieldName
    }
    
    internal func getLabelsForMK() -> ([String]?, [UIColor]?) { //obtains TV labels & their colors
        return (tableViewLabels, tableViewCellColors)
    }
    
    internal func setFieldValueForCurrentPatient() {
        //Sets the FV for the appropriate field name in the persistent data store for the object's current patient using the 'jsonDictToServer':
        //Link up behavior w/ open & create file - when open is selected, pick the patient from the MOC! App crashes if inputs are empty, make sure they are not!
        if let field = self.fieldName {
            if let labelsArray = tableViewLabels {
                var inputValuesArray: [String] = []
                var counter = 0 //counter to access labels in the array
                if labelsArray.count == 0 { //Px & ROS views, custom behavior
                    switch field {
                    case "physicalExam":
                        print("PX")
                    case "reviewOfSystems":
                        print("ROS")
                    default: //should never be called (indicates array.count = 0 & view is not PX or ROS
                        print("Error in setFieldValueForCurrentPatient(), array count = 0")
                    }
                } else if (fieldName == "medications") || (fieldName == "allergies") { //for fields w/ subscopes
                    let customKey = self.generateCustomDictionaryKey()! //get current item label
                    for label in labelsArray { //generate array containing the input values
                        let inputValue = jsonDictToServer[field]![customKey]![label] as! String
                        inputValuesArray.append(inputValue)
                    }
                    switch field {
                    case "medications":
                        if (currentPatient.lastMedicationInserted != nil) { //checks to see if any meds were previously inserted
                            self.currentItemCounter = currentPatient.lastMedicationInserted
                        }
                        currentPatient.medications[customKey] = Dictionary<String, AnyObject>()
                        for input in inputValuesArray {
                            let label = labelsArray[counter]
                            currentPatient.medications[customKey]![label] = input
                            counter += 1
                        }
                    case "allergies":
                        if (currentPatient.lastAllergyInserted != nil) { //checks if any allergies were previously inserted
                            self.currentItemCounter = currentPatient.lastAllergyInserted
                        }
                        currentPatient.allergies[customKey] = Dictionary<String, AnyObject>()
                        for input in inputValuesArray {
                            let label = labelsArray[counter]
                            currentPatient.allergies[customKey]![label] = input
                            counter += 1
                        }
                    default:
                        NSLog("Error in setFieldValue() - 'elseif' default statement")
                    }
                } else { //fields w/o subscopes
                    for label in labelsArray { //generate array containing the input values
                        let inputValue = jsonDictToServer[field]![label] as! String
                        inputValuesArray.append(inputValue)
                    }
                    switch field {
                    case "vitals":
                        for input in inputValuesArray {
                            let label = labelsArray[counter]
                            if ((label == "Blood Pressure") || (label == "Height")) { //store value as string instead of int
                                currentPatient.vitals[label] = input
                            } else { //all other values are stored as Int
                                currentPatient.vitals[label] = Int(input)
                            }
                            counter += 1
                        }
                    case "historyOfPresentIllness":
                        currentPatient.hpi = inputValuesArray[0]
                    default:
                        NSLog("Error in setFieldValue() - 'else' default statement")
                    }
                }
            }
            saveManagedObjectContext(managedObjectContext) //save the updated Patient object
        }
    }
    
    //MARK: - Current Item Number
    
    internal func getCurrentItem() -> (String, Int)? { //returns the current item # as a tuple (e.g. ('Medication', 1)) for specific fieldNames
        if let counter = currentItemCounter {
            return (self.currentItemLabel!, counter)
        } else {
            return nil
        }
    }
    
    internal func generateCustomDictionaryKey() -> String? { //returns key for the jsonDictToServer
        if (currentItemCounter != nil) {
            let label = getCurrentItem()!.0.lowercaseString
            let count = getCurrentItem()!.1
            return (label + String(count))
        } else {
            return nil
        }
    }
    
    internal func incrementCurrentItemNumber() { //called when + button is clicked, increments the current item # by 1
        if (currentItemCounter != nil) {
            self.currentItemCounter! += 1
        }
    }
    
    internal func setLastItemEntered() { //checks if items were previously entered & sets the value
        //When the user opens scope for meds/allergies/incremented fields, the system checks if the currentPatient has values for any of the last__Inserted items. If so, & if that is the field currently being dealt with, it sets the counter to that value.
        if (currentItemCounter != nil) {
            if fieldName == "medications" {
                if (currentPatient.lastMedicationInserted != nil) {
                    currentItemCounter = (currentPatient.lastMedicationInserted)! + 1
                }
            } else if (fieldName == "allergies") {
                if (currentPatient.lastAllergyInserted != nil) {
                    currentItemCounter = (currentPatient.lastAllergyInserted)! + 1
                }
            } else if (fieldName == "diagnoses") {
                //do same for all incremented fields
            }
        }
    }
}