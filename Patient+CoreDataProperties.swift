//  Patient+CoreDataProperties.swift
//  EMR App
//  Created by Arnav Pondicherry  on 11/1/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.

import Foundation
import CoreData

extension Patient {

    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var sex: String
    @NSManaged var dateOfBirth: NSDate
    
    @NSManaged var medications: [String : [String : AnyObject]]
    @NSManaged var allergies: [String : [String : AnyObject]]
    @NSManaged var vitals: [String: AnyObject]
    @NSManaged var hpi: String?
    
    convenience init(firstName: String, lastName: String, gender: Gender, dob: NSDate, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        let entity = NSEntityDescription.entityForName("Patient", inManagedObjectContext: context!)
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dob
        
        if (gender == Gender.Male) {
            self.sex = "male"
        } else if (gender == Gender.Female) {
            self.sex = "female"
        }
    }

}
