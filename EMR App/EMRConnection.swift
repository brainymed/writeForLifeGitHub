//  EMRConnection.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/29/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Create a network connection to the centralized web server.

import Foundation

class EMRConnection {
    let queryURL : NSURL
    lazy var config : NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var session : NSURLSession = NSURLSession(configuration: self.config)
    
    init (queryURL : NSURL) {//URL is absolute URL of web server. We will POST all data to this URL.
        self.queryURL = queryURL
    }
    
    typealias JSONDictionaryCompletion = ([String : AnyObject]?) -> Void
    
    func downloadJSONFromURL(completion : JSONDictionaryCompletion) {
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: self.queryURL)
        
        //HTTP GET Request & Headers:
        request.HTTPMethod = "GET"
        let accessToken = "6kjk4t9xazjczaqv364cvt7b"
        //request.setValue("application/JSON", forHTTPHeaderField: "Accept") //Generates 406 response code
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("70.105.169.126", forHTTPHeaderField: "X-Originating-IP")
        //request.HTTPBody = NSData() //Needed? Usually appending data to URL. 
        
        //Create HTTP POST request - for data entry, pass in the fieldName being mapped to & the data being sent. For data extraction, pass in the (processed?) query name. 
//        let request = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = "POST"
//        let postData = NSData(base64EncodedString: <#T##String#>, options: <#T##NSDataBase64DecodingOptions#>)
//        request.HTTPBody = postData
//        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/JSON", forHTTPHeaderField: "Accept")
        
        let dataTask = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            if let httpResponse = response as? NSHTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    print("Response Headers: \(httpResponse.allHeaderFields)")
                    do {
                        let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String : AnyObject]
                        completion(jsonDictionary)
                    } catch {
                        
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