//  Patient.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/13/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

import Foundation
import CoreData

class Patient: NSManagedObject {
    
    var fullName: String { //full name (computed property, read only)
        get {
            return ("\(self.firstName) \(self.lastName)")
        }
    }
    
    //Check if any medication, allergy or diagnosis was previously inserted so we don't overwrite them. Note that if the patient file is closed (& currentPatient is set -> nil), this information is cleared out & we start at X1 again when that file is re-opened.
    var lastMedicationInserted: Int?
    var lastAllergyInserted: Int?
    var lastDiagnosisInserted: Int?
}

enum Gender: String { 
    case Male
    case Female
}
