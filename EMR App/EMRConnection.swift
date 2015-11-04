//  EMRConnection.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/29/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Create a network connection to the centralized web server.

import Foundation

class EMRConnection {
    let openScope: EMRField?
    let baseURL: NSURL
    let queryURL: NSURL
    lazy var config: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var session: NSURLSession = NSURLSession(configuration: self.config)
    var jsonDict: Dictionary<String, AnyObject>?
    
    init (openScope: EMRField) { //compute URL server to send information to based on fieldName
        //This will only work for single dictionary transfers (i.e. the user is online and entering patient data. If we are pulling from the persistent store to sync, there will be no (reliable) currentPatient, so we will have to do something else.
        self.jsonDict = nil
        self.openScope = openScope
        self.baseURL = NSURL(string: "http://www.brainymed.com/brainymed/api/")!
        
        var queryString: String = "" //string to be appended
        switch (openScope.getFieldName())! {
        case "medications":
            queryString = "id/"
            self.queryURL = NSURL(string: queryString, relativeToURL: baseURL)!
            print("URL: http://www.brainymed.com/brainymed/api/\(queryString)")
        case "vitals":
            queryString = "id/"
            self.queryURL = NSURL(string: queryString, relativeToURL: baseURL)!
            print("URL: http://www.brainymed.com/brainymed/api/\(queryString)")
        case "physicalExam":
            queryString = "id/"
            self.queryURL = NSURL(string: queryString, relativeToURL: baseURL)!
            print("URL: http://www.brainymed.com/brainymed/api/\(queryString)")
        case "reviewOfSystems":
            queryString = "id/"
            self.queryURL = NSURL(string: queryString, relativeToURL: baseURL)!
            print("URL: http://www.brainymed.com/brainymed/api/\(queryString)")
        case "allergies":
            queryString = "id/"
            self.queryURL = NSURL(string: queryString, relativeToURL: baseURL)!
            print("URL: http://www.brainymed.com/brainymed/api/\(queryString)")
        case "historyOfPresentIllness":
            queryString = "id/"
            self.queryURL = NSURL(string: queryString, relativeToURL: baseURL)!
            print("URL: http://www.brainymed.com/brainymed/api/\(queryString)")
        default: //should never be called
            self.queryURL = NSURL(string: "", relativeToURL: baseURL)!
        }
    }
    
    init(patientDict: Dictionary<String, AnyObject>) {
        self.baseURL = NSURL(string: "http://www.brainymed.com/brainymed/api/")!
        self.queryURL = NSURL(string: "patients", relativeToURL: baseURL)!
        self.openScope = nil
        self.jsonDict = patientDict
    }
    
    typealias JSONDictionaryCompletion = ([String : AnyObject]?) -> Void
    
    func downloadJSONFromURL(completion : JSONDictionaryCompletion) {
        print("Downloading JSON...")
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: self.queryURL)
        request.setValue("application/JSON", forHTTPHeaderField: "Content-Type") //must be set
        
        //HTTP GET Request & Headers:
//        request.HTTPMethod = "GET"
//        let accessToken = "6kjk4t9xazjczaqv364cvt7b"
//        request.setValue("application/JSON", forHTTPHeaderField: "Accept") //Generates 406 response code
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        request.setValue("70.105.169.126", forHTTPHeaderField: "X-Originating-IP")
//        request.HTTPBody = data //Needed? Usually appending data to URL.
        
        //HTTP POST request - for data entry, pass in the fieldName being mapped to & the data being sent. For data extraction, pass in the (processed?) query name.
        request.HTTPMethod = "POST"
        if (jsonDict == nil) {
            jsonDict = self.openScope!.jsonDictToServer
        } else { //patient creation, dict has already been created
        }
        let body: NSDictionary = NSDictionary(dictionary: jsonDict!)
        do {
            let dictionaryAsJSON: NSData = try (NSJSONSerialization.dataWithJSONObject(body, options: []))
            request.HTTPBody = dictionaryAsJSON
        } catch {
            print("Error in creating object")
        }
//        let postData = NSData(base64EncodedString: <#T##String#>, options: <#T##NSDataBase64DecodingOptions#>)
//        request.HTTPBody = postData
//        request.setValuer(postLength as String, forHTTPHeaderField: "Content-Length")
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/JSON", forHTTPHeaderField: "Accept")
        
        print("Creating data task...")
        let dataTask = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            if let httpResponse = response as? NSHTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    print("Response Headers: \(httpResponse.allHeaderFields)")
                    do {
                        let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String : AnyObject]
                        completion(jsonDictionary)
                    } catch (let errors as NSError) {
                        print(errors)
                    }
                case 404:
                    print("Page not found. HTTP status code: \(httpResponse.statusCode)")
                default:
                    print("HTTP request unsuccessful. Status Code: \(httpResponse.statusCode)")
                }
            } else {
                print("Error: not a valid HTTP response. Please check your network connection.")
            }
        }
        dataTask.resume()
    }
}