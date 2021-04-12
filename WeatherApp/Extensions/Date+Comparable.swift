//
//  Date+Comparable.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 01.01.2021.
//

import Foundation

// Extending Date class to be able to divide and get TimeInterval result
extension Date {
    /// Allows us to get TimeInterval between two dates
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return abs(lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate)
    }
}
