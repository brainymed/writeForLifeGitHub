//  EMRReturnedDataObject.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/30/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

//This data object will be populated AFTER the app sends request -> EMR & obtains JSON data as a response. Once we receive JSON, we will break it down into a custom dictionary object - we know what parameters could possibly be returned & create a dictionary entry for each potential parameter.

import Foundation

struct EMRReturnedDataObject {
    let totalCount : Int?
    let practiceInfo : [[String : String]]?
    let departments : [[String : AnyObject]]?
    
    init(emrDataDictionary : [String: AnyObject]) { //Make sure to use conditional chaining b/c we don't know what pieces of info will be returned when
        self.totalCount = emrDataDictionary["totalcount"] as? Int
        self.practiceInfo = emrDataDictionary["practiceinfo"] as? [[String : String]]
        self.departments = emrDataDictionary["departments"] as? [[String : AnyObject]]
    }
}