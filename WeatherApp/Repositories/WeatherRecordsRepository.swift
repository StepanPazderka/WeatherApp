//
//  WeatherRecordsRepository.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 02.04.2021.
//

import Foundation
import Combine
import MapKit

protocol WeatherRecordsRepository {
    var records: [WeatherRecord] { get set }

    func getWeatherBy(coordinates: CLLocationCoordinate2D) -> AnyPublisher<WeatherRecord, ServiceError>
    func getWeatherBy(city: String) -> AnyPublisher<WeatherRecord, ServiceError>
    func addWeatherRecord(record: WeatherRecord)
    func updateWeatherRecords()
}

@objcMembers class WeatherRecordsRepositoryImpl: WeatherRecordsRepository {
    private var subscriptions: Set<AnyCancellable> = []
    private var service: WeatherService
    internal var records: [WeatherRecord] = []

    init(service: WeatherService) {
        self.service = service
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateWeatherRecords), userInfo: nil, repeats: true)
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
        let roundedCoordinates = CLLocationCoordinate2D(latitude: record.coordinates.latitude.rounded(), longitude: record.coordinates.longitude.rounded())

        if let existingRecord = self.loadWeatherRecord(coordinates: record.coordinates) {
            if let index = records.firstIndex(of: existingRecord) {
                print("Weather record for these coordinates already exists, old record will be replaced with new one")
                records[index] = record
                return
            }
        }

        records.append(record.rounded)
    }

    func updateWeatherRecords() {
        for record in records {
            let currentDate = Date()

            if (record.date - currentDate) > 120 {
                print("\(record) is older than two minutes, will be updated")
                self.getWeatherBy(coordinates: record.coordinates)
            }
        }
    }
}
