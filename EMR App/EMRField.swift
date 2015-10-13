//  EMRField.swift
//  EMR App
//
//  Created by Arnav Pondicherry  on 9/15/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

import Foundation

//This class takes in a user input & uses it to generate an EMR-compatible 'field name'.
// Process: user inputs word -> checks if input matches an existing fieldName -> if it matches, the class generates a fieldName -> user inputs field value -> converts field value to correct data type ->
class EMRField {
    private var match : Bool = false
    private var fieldName : String? //'fieldName' should always = nil when 'match' == FALSE
    private var fieldValue : AnyObject?
    private var tableViewLabels : [String]?
    private var currentItemCounter : Int? //for specific views (e.g. medications, diagnoses, allergies), counts the # of the item currently open.
    private var currentItemLabel : String? //for specific views, generates a (singular) label to indicate what item is currently open (e.g. "medication", "diagnosis", "allergy"). The label & counter should only exist simultaneously!
    var jsonDictToServer = Dictionary<String, [String : AnyObject]>() //dictionary containing user inputs being mapped -> server
    //var inputValuesForFieldName = Dictionary<String, AnyObject>() //dictionary entry for the current field name
    
    init(inputWord: String) {
        //Initializer matches the input word to a keyword format & returns a boolean value & an EMR field name, which can be obtained from separate getter functions.
        let lowercaseInput = inputWord.lowercaseString
        let formatArray : [String] = ["^.*name$", "^dob$", "^date of birth$", "^test$", "^med.*$", "^blood pressure$", "^bp$", "^heart rate$", "^hr$", "^resp.*$", "^rr$", "^temp.*$", "^vitals$", "^physical$", "^r.*o.*s.*$", "allergies"]
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
            self.fieldName = "name"
        case 1, 2:
            print("Please enter the date in MM/DD/YYYY format.")
            self.fieldName = "dateOfBirth"
        case 3:
            self.fieldName = "testValue"
        case 4:
            self.fieldName = "medications"
            self.currentItemCounter = 1
            self.currentItemLabel = "Medication"
        case 5, 6:
            self.fieldName = "bloodPressure"
        case 7, 8:
            self.fieldName = "heartRate"
        case 9, 10:
            self.fieldName = "respirations"
        case 11:
            self.fieldName = "temperature"
        case 12:
            self.fieldName = "vitals"
        case 13:
            self.fieldName = "physicalExam"
        case 14:
            self.fieldName = "reviewOfSystems"
        case 15:
            self.fieldName = "allergies"
        default:
            //If the counter's value is 1 greater than the length(formatArray), NO match was found.
            self.fieldName = nil
        }
        
        if let currentField = self.fieldName { //Create an entry in the mapping dict for the fieldName
            self.jsonDictToServer[currentField] = Dictionary<String, AnyObject>()
            //self.inputValuesForFieldName = (self.jsonDictToServer[currentField])!
        }
    }
    
    //MARK: - Match Checking
    
    internal func matchFound() -> Bool {
        return self.match
    }
    
    //MARK: - Setting Field Name
    internal func getFieldName() -> String? {
        return self.fieldName
    }
    
    internal func setFieldValueForPatient(inputValue: String, forPatient patient: Patient) {
        //Takes in a field value + patient & sets that FV for the appropriate field name in the persistent data store:
        if let field = self.fieldName {
            switch field {
            case "dateOfBirth":
                //Causing problems when I try to print the DOB:
                self.fieldValue = NSDate(dateString: inputValue)
            case "testValue":
                patient.setValue(inputValue, forKey: field)
            case "medications":
                //Add values to the existing medication & initialize a new medication object. We need to provide an easy & intuitive interface option for entry of data for EMR fields w/ multiple sub-parts.
                patient.medications["medication1"]!["name"] = inputValue
                patient.medications["medication1"]!["dose"] = inputValue
                patient.medications["medication1"]!["frequency"] = inputValue
            case "bloodPressure":
                //Format this based on how it is formatted in the EMR - for now, we will leave it as a string.
                patient.vitals["bloodPressure"] = inputValue
            case "heartRate":
                patient.vitals["heartRate"] = Int(inputValue)
            case "respirations":
                patient.vitals["respirations"] = Int(inputValue)
            case "temperature":
                patient.vitals["temperature"] = Int(inputValue)
            case "vitals":
                print("Vitals entered")
            case "physicalExam":
                print("PX")
            case "reviewOfSystems":
                print("ROS")
            case "allergies":
                print("allergies")
            default:
                NSLog("Error ('setFieldValue()')! This case shouldn't be triggered unless a case for 'fieldName' was missed")
            }
        }
    }
    
    internal func getLabelsForMK() -> [String]? { //Sets the TV labels based on the MK
        if let field = self.fieldName {
            switch field {
            case "dateOfBirth":
                //Causing problems when I try to print the DOB:
                tableViewLabels = ["Date Of Birth"]
            case "testValue":
                tableViewLabels = ["Test Value"]
            case "medications":
                tableViewLabels = ["Medication Name", "Route", "Dosage", "Frequency"]
            case "vitals":
                tableViewLabels = ["Blood Pressure", "Heart Rate", "Respiratory Rate", "Temperature"]
            case "physicalExam":
                tableViewLabels = ["Anterior View", "Posterior View"]
            case "reviewOfSystems":
                tableViewLabels = ["Anterior View", "Posterior View"]
            case "allergies":
                tableViewLabels = ["Allergen"]
            default:
                tableViewLabels = ["Default Switch (Error)"]
            }
        }
        return tableViewLabels
    }
    
    //MARK: - Current Item Number
    internal func getCurrentItem() -> (String, Int)? { //returns current item for specific fieldNames
        if let counter = currentItemCounter {
            return (self.currentItemLabel!, counter)
        } else {
            return nil
        }
    }
    
    internal func incrementCurrentItemNumber() {
        if (currentItemCounter != nil) {
            self.currentItemCounter! += 1
        }
    }
}