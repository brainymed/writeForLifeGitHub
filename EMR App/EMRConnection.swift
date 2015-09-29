//  EMRConnection.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/29/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// Create a network connection w/ the EMR & pass over data.

import Foundation

class EMRConnection {
    let queryURL : NSURL
    lazy var config : NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var session : NSURLSession = NSURLSession(configuration: self.config)
    
    init (queryURL : NSURL) {
        self.queryURL = queryURL
    }
    
    typealias JSONDictionaryCompletion = ([String : AnyObject]?) -> Void
    
    func downloadJSONFromURL(completion : JSONDictionaryCompletion) {
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: self.queryURL)
        
        //HTTP GET Request:
        request.HTTPMethod = "GET"
        request.setValue("application/JSON", forHTTPHeaderField: "Accept")
        request.setValue("utf-8", forHTTPHeaderField: "Accept-Encoding")
        
        //Create your HTTP POST request:
//        let request = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = "POST"
//        request.HTTPBody = postData
//        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/JSON", forHTTPHeaderField: "Accept")
        
        let dataTask = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            if let httpResponse = response as? NSHTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String : AnyObject]
                        completion(jsonDictionary)
                    } catch {
                        
                    }
                case 404:
                    print("Page not found. HTTP status code: \(httpResponse.statusCode)")
                default:
                    print("Get request not successful. HTTP status code: \(httpResponse.statusCode)")
                }
            } else {
                print("Error: not a valid HTTP response. Please check your network connection.")
            }
        }
        dataTask.resume()
    }
}