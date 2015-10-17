//  Patient+CoreDataProperties.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/15/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu to delete and recreate this implementation file for your updated model.

import Foundation
import CoreData

extension Patient {

    @NSManaged var dateOfBirth: NSDate
    @NSManaged var medications: [String : [String : AnyObject]]
    @NSManaged var name: String
    @NSManaged var testValue: String?
    @NSManaged var vitals: [String : AnyObject]

    convenience init(name: String, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        let entity = NSEntityDescription.entityForName("Patient", inManagedObjectContext: context!)
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.name = name
        
        //Initialize the values in the 'Vitals' dictionary:
        self.vitals["bloodPressure"] = nil
        self.vitals["heartRate"] = nil
        self.vitals["respirations"] = nil
        self.vitals["temperature"] = nil
        
        //Initialize the values in the 'Medications' dictionary (add 1 item, each time a new item is added we should expand the size of the dictionary):
        self.medications["medication1"] = Dictionary()
        self.medications["medication1"]!["name"] = nil
        self.medications["medication1"]!["dose"] = nil
        self.medications["medication1"]!["frequency"] = nil
    }
    
    func addVitals(vitalName: String, value: AnyObject) { //
        
    }
    
    func addMedications() {
        
    }
    
    func addPhysicalExamResults() {
        
    }
    
    func addReviewOfSystems() {
        
    }
}
