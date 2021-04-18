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

class MockWeatherServiceImpl: WeatherService {
    var records: [WeatherRecord] = []
    var OpenWeatherAPIkey: String?
    private var cache: WeatherDataCache
    
    // MARK: - Init
    internal init(cache: WeatherDataCache) {
        self.cache = cache
    }
    
    func getCountryCodeBy(longitude: Double, latitude: Double) -> AnyPublisher<String, Error> {
        Future<String, Error> { promise in
            promise(.success("CZ"))
        }
        .eraseToAnyPublisher()
    }
    
    func getWeatherBy(city: String) -> AnyPublisher<WeatherRecord, Error> {
        Deferred {
            Future<WeatherRecord, Error> { promise in
                let newRecord: WeatherRecord!
                if city.reformated == "prague" {
                    newRecord = WeatherRecord(temperature: 0, date: Date(), coordinates: CLLocationCoordinate2D(latitude: 50.08804, longitude: 14.42076), distance: 0, flag: "CZ")
                    self.cache.add(newRecord)
                    promise(.success(newRecord))
                } else if city == "berlin" {
                    newRecord = WeatherRecord(temperature: 10, date: Date(), coordinates: CLLocationCoordinate2D(latitude: 52.520008, longitude: 13.404954), distance: 0, flag: "CZ")
                    self.cache.add(newRecord)
                    promise(.success(newRecord))
                } else if city == "paris" {
                    newRecord = WeatherRecord(temperature: 20, date: Date(), coordinates: CLLocationCoordinate2D(latitude: 48.864716, longitude: 2.349014), distance: 0, flag: "CZ")
                    self.cache.add(newRecord)
                    promise(.success(newRecord))
                }
//                promise(.success(newRecord))
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
