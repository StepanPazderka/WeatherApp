//
//  WeatherRecordsRepository.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 02.04.2021.
//

import Foundation
import Combine
import MapKit
import CombineDatabase

protocol WeatherRecordsRepository {
    var records: [WeatherRecord] { get set }

    func getWeatherBy(coordinates: CLLocationCoordinate2D) -> AnyPublisher<WeatherRecord, Error>
    func getWeatherBy(city: String) -> AnyPublisher<WeatherRecord, Error>
    func addWeatherRecord(record: WeatherRecord)
    func updateWeatherRecords()
    func getAllWeatherRecords() -> AnyPublisher<[WeatherRecord], Error>
}

class WeatherRecordsRepositoryImpl: WeatherRecordsRepository {

    let realm: CombineDatabase = CombineDatabaseImpl(databaseSchemaVersion: 1)
    private var subscriptions: Set<AnyCancellable> = []
    private var service: WeatherService
    var records: [WeatherRecord] = []
//    let realm = try! Realm()

    init(service: WeatherService) {
        self.service = service
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateWeatherRecords), userInfo: nil, repeats: true)
    }

    func getAllWeatherRecords() -> AnyPublisher<[WeatherRecord], Error> {
        return realm.getAll(WeatherDataDBEntity.self)
            .map { Array($0) }
            .flatMap { (entities: [WeatherDataDBEntity]) in
                Publishers.MergeMany(
                    entities.filter{ entity in
                        if (entity.date - Date()) > 120 {
                            return true
                        } else {
                            return false
                        }
                    }.map { (entity: WeatherDataDBEntity) in
                        self.getWeatherBy(coordinates: entity.coordinates)
                    }
                )
                .collect()
            }
            .map { $0 }
            .eraseToAnyPublisher()
    }

    func getWeatherBy(coordinates: CLLocationCoordinate2D) -> AnyPublisher<WeatherRecord, Error> {
        service.getWeatherBy(coordinates: coordinates).handleEvents(receiveOutput: { value in
            self.addWeatherRecord(record: value)
        })
        .eraseToAnyPublisher()
    }

    func getWeatherBy(city: String) -> AnyPublisher<WeatherRecord, Error> {
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
//        service.getAllCachedData().subscribe(onNext: { records in
//            records.filter({ entity in
//                if (entity.date - Date()) > 120 {
//                    return true
//                }
//                return false
//            }).forEach { entity in
//                self.service.getWeatherBy(coordinates: entity.coordinates).sink(receiveCompletion: { _ in }, receiveValue: { _ in }).store(in: &self.subscriptions)
//            }
//        }).dispose()
    }
}
