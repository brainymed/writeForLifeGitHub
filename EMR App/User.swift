//  User.swift
//  EMR App
//  Created by Arnav Pondicherry  on 11/1/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

//Class type of the current user, containing the user's name, password(?), linked medical records, etc. This information can be loaded into the user defaults when the user signs in.

import Foundation

class User {
    
    private let firstName: String
    private let lastName: String
    private var fullName: String { //full name (computed property, read only)
        get {
            return ("\(firstName) \(lastName)")
        }
    }
    private var username: String? //username for accessing app
    private var password: String?
    private var linkedMedicalRecordSystems: [String] = ["Athena"] //default EMR
    private var practiceName: String?
    private var practiceAddress: String?
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    func getUsername() -> String {
        if (self.username != nil) {
            return (self.username!)
        } else {
            return ""
        }
    }
}
