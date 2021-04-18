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

    init(data: WeatherDataAPIEntity) {
        self.temperature = Float(data.main!.temp)
        self.date = Date()
        self.coordinates = CLLocationCoordinate2D(latitude: data.coord!.lat, longitude: data.coord!.lon)
        self.distance = 0.0
        self.flag = data.sys!.country
    }
    
    init(data: WeatherDataDBEntity) {
        self.temperature = Float(data.temp)
        self.date = data.date
        self.coordinates = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
        self.distance = 0.0
        self.flag = data.flag ?? String()
    }

    init(temperature: Float, date: Date, coordinates: CLLocationCoordinate2D, distance: Float, flag: String) {
        self.temperature = temperature
        self.date = date
        self.coordinates = coordinates
        self.distance = distance
        self.flag = flag
    }
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

extension WeatherRecord {
    var rounded: WeatherRecord {
        let roundedCoords = CLLocationCoordinate2D(latitude: self.coordinates.latitude.rounded(), longitude: self.coordinates.longitude.rounded())
        let newWeatherRecord = WeatherRecord(temperature: self.temperature, date: self.date, coordinates: roundedCoords, distance: self.distance, flag: self.flag)
        return newWeatherRecord
    }
}
