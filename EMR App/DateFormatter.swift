//  DateFormatter.swift
//  EMR App
//
//  Created by Arnav Pondicherry  on 9/15/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

import Foundation

extension NSDate {
    convenience init (dateString: String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "MM/dd/yyyy"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let fullDate = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval: 0, sinceDate: fullDate)
    }
}