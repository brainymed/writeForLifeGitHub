//  Patient+CoreDataProperties.swift
//  EMR App
//  Created by Arnav Pondicherry  on 10/26/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu to delete and recreate this implementation file for your updated model.

import Foundation
import CoreData

extension Patient {

    @NSManaged var dateOfBirth: NSDate
    @NSManaged var medications: [String : [String : AnyObject]]
    @NSManaged var allergies: [String : [String : AnyObject]]
    @NSManaged var name: String
    @NSManaged var testValue: String?
    @NSManaged var vitals: [String: AnyObject]
    
    convenience init(name: String, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        let entity = NSEntityDescription.entityForName("Patient", inManagedObjectContext: context!)
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.name = name
    }
    
}
