//
//  WeatherRecordsRepository.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 02.04.2021.
//

import Foundation
import Combine
import MapKit
import RxSwift

protocol WeatherRecordsRepository {
    var records: [WeatherRecord] { get set }

    func getWeatherBy(coordinates: CLLocationCoordinate2D) -> AnyPublisher<WeatherRecord, ServiceError>
    func getWeatherBy(city: String) -> AnyPublisher<WeatherRecord, ServiceError>
    func addWeatherRecord(record: WeatherRecord)
    func updateWeatherRecords()
    func getAllWeatherRecords() -> Observable<[WeatherDataDBEntity]>
}

class WeatherRecordsRepositoryImpl: WeatherRecordsRepository {
    private var subscriptions: Set<AnyCancellable> = []
    private var service: WeatherService
    var records: [WeatherRecord] = []

    init(service: WeatherService) {
        self.service = service
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateWeatherRecords), userInfo: nil, repeats: true)
    }
    
    func getAllWeatherRecords() -> Observable<[WeatherDataDBEntity]> {
        service.getAllCachedData()
    }

    func getWeatherBy(coordinates: CLLocationCoordinate2D) -> AnyPublisher<WeatherRecord, ServiceError> {
        service.getWeatherBy(coordinates: coordinates).handleEvents(receiveOutput: { value in
            self.addWeatherRecord(record: value)
        })
        .eraseToAnyPublisher()
    }

    func getWeatherBy(city: String) -> AnyPublisher<WeatherRecord, ServiceError> {
        return service.getWeatherBy(city: city).handleEvents(receiveOutput: { record in
            self.addWeatherRecord(record: record)
        })
        .eraseToAnyPublisher()
    }

    func loadWeatherRecord(coordinates: CLLocationCoordinate2D) -> WeatherRecord? {
        let roundedCoordinates = CLLocationCoordinate2D(latitude: coordinates.latitude.rounded(), longitude: coordinates.longitude.rounded())

        for record in self.records {
            if record.coordinates == roundedCoordinates {
                return record
            }
        }
        return nil
    }

    func addWeatherRecord(record: WeatherRecord) {
        print("Saving temp: \(record.temperature) on lat: \(record.coordinates.latitude) and long: \(record.coordinates.longitude)")

        if let existingRecord = self.loadWeatherRecord(coordinates: record.coordinates) {
            if let index = records.firstIndex(of: existingRecord) {
                print("Weather record for these coordinates already exists, old record will be replaced with new one")
                records[index] = record
                return
            }
        }

        print(record.rounded)
        records.append(record.rounded)
    }

    @objc func updateWeatherRecords() {
        service.getAllCachedData().subscribe(onNext: { records in
            records.filter({ entity in
                if (entity.date - Date()) > 120 {
                    return true
                }
                return false
            }).forEach { entity in
                self.service.getWeatherBy(coordinates: entity.coordinates).sink(receiveCompletion: { _ in }, receiveValue: { _ in }).store(in: &self.subscriptions)
            }
        }).dispose()
    }
}
