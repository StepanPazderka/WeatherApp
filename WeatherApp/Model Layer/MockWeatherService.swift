//
//  MockWeatherService.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 15.04.2021.
//

import Foundation
import Combine
import MapKit
import RxSwift

class MockWeatherService: WeatherService {
    var records: [WeatherRecord] = []
    var OpenWeatherAPIkey: String?
    
    func getCountryCodeBy(longitude: Double, latitude: Double) -> AnyPublisher<String, Error> {
        Future<String, Error> { promise in
            promise(.success("CZ"))
        }
        .eraseToAnyPublisher()
    }
    
    func getWeatherBy(city: String) -> AnyPublisher<WeatherRecord, Error> {
        Deferred {
            Future<WeatherRecord, Error> { promise in
                let newRecord = WeatherRecord(temperature: 0, date: Date(), coordinates: CLLocationCoordinate2D(latitude: 0, longitude: 0), distance: 10, flag: "CZ")
                promise(.success(newRecord))
            }
        }.eraseToAnyPublisher()
    }
    
    func getWeatherBy(coordinates: CLLocationCoordinate2D) -> AnyPublisher<WeatherRecord, Error> {
        Deferred {
            Future<WeatherRecord, Error> { promise in
                let newRecord = WeatherRecord(temperature: 0, date: Date(), coordinates: CLLocationCoordinate2D(latitude: 0, longitude: 0), distance: 10, flag: "CZ")
                promise(.success(newRecord))
            }
        }.eraseToAnyPublisher()
    }
    
    func getAllCachedData() -> AnyPublisher<[WeatherDataDBEntity], Error> {
        let origArray: [WeatherDataDBEntity] = []
        return Result<[WeatherDataDBEntity], Error>.Publisher(origArray).eraseToAnyPublisher()
    }
}
