//
//  WeatherRecord.swift
//  WeatherApp
//
//  Created by Steve on 07/12/2020.
//

import Foundation
import CoreLocation

struct WeatherRecord {
    var temperature: Float
    var date: Date
    var coordinates: CLLocationCoordinate2D
    var distance: Float
    var flag: String
}

struct Coordinates {
    var lat: Float
    var long: Float
}

extension WeatherRecord: Equatable {
    static func == (lhs: WeatherRecord, rhs: WeatherRecord) -> Bool {
        return lhs.coordinates == rhs.coordinates
    }
}

