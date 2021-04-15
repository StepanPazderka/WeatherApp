//
//  MockWeatherService.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 15.04.2021.
//

import Foundation
import Combine
import MapKit
//import RxSwift
//
//class MockWeatherService: WeatherService {
//    var records: [WeatherRecord] = []
//    var OpenWeatherAPIkey: String?
//    
//    func getCountryCodeBy(longitude: Double, latitude: Double) -> Future<String, ServiceError> {
//        
//    }
//    
//    func getWeatherBy(city: String) -> AnyPublisher<WeatherRecord, ServiceError> {
//        let city = city.reformated
//        let newWeatherRecord: WeatherRecord!
//        return AnyPublisher<WeatherRecord, ServiceError> {
//            if city == "prague" {
//                newWeatherRecord = WeatherRecord(temperature: 2.0, date: Date(), coordinates: CLLocationCoordinate2D(latitude: 50.073658, longitude: 14.418540), distance: 0.0, flag: "CZ")
//            }
//        }
//    }
//    
//    func getWeatherBy(coordinates: CLLocationCoordinate2D) -> Deferred<Future<WeatherRecord, ServiceError>> {
//        
//    }
//    
//    func getAllCachedData() -> Observable<[WeatherDataDBEntity]> {
//    }
//    
//    
//}
