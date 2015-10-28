//  HelperFunctions.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/15/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Various Helper Functions:

import Foundation
import CoreData

func saveManagedObjectContext(context: NSManagedObjectContext) { //Saves the MOC
    do {
        try context.save()
        print("MOC Save Successful.")
    } catch {
        print("Error occurred in saving MOC.")
    }
}

func clearPatientFromDataStore(patient: Patient) { //Removes the patient from the MOC after data has been sent to the EMR
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    context.deleteObject(patient)
}

func clearAllPatientsFromDataStore() {
    print("Clearing Patients...")
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let entityDescription = NSEntityDescription.entityForName("Patient", inManagedObjectContext: context)
    let request = NSFetchRequest()
    request.entity = entityDescription
    do {
        let objects = try context.executeFetchRequest(request)
        for object in objects {
            context.deleteObject(object as! NSManagedObject)
            print("object deleted")
        }
        saveManagedObjectContext(context)
    } catch {
        NSLog("Error. Execute fetch failed")
    }
}

func fetchAllPatients() { //Returns all patients in Core Data store
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let entityDescription = NSEntityDescription.entityForName("Patient", inManagedObjectContext: context)
    let request = NSFetchRequest()
    request.entity = entityDescription
    do {
        let objects = try context.executeFetchRequest(request)
        if objects.count > 0 {
            print("Number of objects fetched: \(objects.count)")
            for result in objects {
                let patient = result as! Patient
                print("Name: \(patient.name). Test Val: \(patient.testValue). Vitals: \(patient.vitals). Medications: \(patient.medications). Allergies: \(patient.allergies).") //Will return optional
            }
        } else {
            print("No results found in the Core Data Store.")
        }
    } catch {
        NSLog("Error! 'Execute Fetch Request' Failed.")
    }
}

func openPatientFile(patientName: String) -> Patient? { //Opens the file for the searched patient (@ first, it fetches the patient from the core data store & makes them the current patient | later on, it will open the file directly in the EMR).
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let entityDescription = NSEntityDescription.entityForName("Patient", inManagedObjectContext: context)
    let request = NSFetchRequest()
    request.entity = entityDescription
    
    //Predicate: used to map info for specific patients to the EMR. Currently we are using a predicate that searches by name (only works if the name is unique). In reality, multiple patients could have the same name, so we should search by a unique patient ID #.
    let pred = NSPredicate(format: "(name = %@)", patientName) //Filters results - matches a value in the obtained results to the string.
    request.predicate = pred
    
    do {
        let patients = try context.executeFetchRequest(request)
        if patients.count > 0 {
            print("Number of objects fetched for the entered name: \(patients.count)")
            return (patients[0] as! Patient)
        } else {
            print("No results found for given name.")
        }
    } catch {
        NSLog("Error! 'Execute Fetch Request' Failed.")
    }
    return nil
}
