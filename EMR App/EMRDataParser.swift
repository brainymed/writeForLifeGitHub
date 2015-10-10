//  EMRDataParser.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/30/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Handle the response/data returned by the EMR (through the web server) in response to the HTTP request.

import Foundation

struct EMRDataParser {
    let url : NSURL
    
    init(url : NSURL) {//initialize struct by inputting the URL for our web server - we simply pass the long-form version of the field name entered & the data entered into each field as a JSON object.
        self.url = url
    }
    
    func ParseJSON(completion : (EMRReturnedDataObject? -> Void)) {
        let emrConnection = EMRConnection(queryURL: url)
        emrConnection.downloadJSONFromURL {
            (let JSONDictionary) in
            print("JSONDictionary contents: \(JSONDictionary)")
            let returnedData = self.returnedDataFromJSON(JSONDictionary) //retrieve the parsed dict
            completion(returnedData) //present this dict to the user as a completion
        }
    }
    
    func returnedDataFromJSON(jsonDictionary : [String : AnyObject]?) -> EMRReturnedDataObject? {
        //This function takes a JSONDict as an input [w/ String Key : AnyObject Value] & returns a dictionary object. The initializer of the 'ReturnedDataObject' will break apart the dictionary and assign each value for a key to a variable in the app.
        if let returnedEMRData = jsonDictionary {
            return EMRReturnedDataObject(emrDataDictionary: returnedEMRData)
        } else {
            print("JSON dictionary returned nil.")
            return nil
        }
    }
    
}