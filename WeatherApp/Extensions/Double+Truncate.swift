//
//  Double+Truncate.swift
//  WeatherApp
//
//  Created by Steve on 02/12/2020.
//

import Foundation

extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
