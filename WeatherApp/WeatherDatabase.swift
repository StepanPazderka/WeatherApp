//
//  WeatherMap.swift
//  WeatherApp
//
//  Created by Steve on 07/12/2020.
//

import Foundation
import CoreLocation
import MapKit

class WeatherDatabase: ObservableObject {
    @Published var MapViewCoordinates = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50))
    @Published var currentLocationTemp: String = ""
    
    var records: [WeatherRecord] = []
    var service: WeatherService = WeatherService()
    
    init() {
//        CreateSamples(latitudeModulo: 30, longitudeModulo: 40)
        CreateSamples(latitudeModulo: 45, longitudeModulo: 40)

    }
    
    fileprivate func CreateSamples(latitudeModulo: Int, longitudeModulo: Int) {
        var iterator = 0
        for latitude in -90...90 {
            if latitude % latitudeModulo == 0 {
                iterator += 1
                print("Divison of latitude happened \(latitude)")
                for longitude in -180...180 {
                    if longitude % longitudeModulo == 0 {
                        iterator += 1
                        print("Divison of longitude happened \(longitude)")
                        self.getWeatherBy(coordinates: CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude)))
                    }
                }
            }
        }
        print("API has been called \(iterator) times")
    }
    
    func addWeatherRecord(record: WeatherRecord) {
        print("Saving temp: \(record.temperature) on lat: \(record.coordinates.latitude) and long: \(record.coordinates.longitude)")
        let roundedCoordinates = CLLocationCoordinate2D(latitude: record.coordinates.latitude.rounded(), longitude: record.coordinates.longitude.rounded())
        
        if let existingRecord = self.loadWeatherRecord(coordinates: record.coordinates) {
            if let index = records.firstIndex(of: existingRecord) {
                print("Weather record for these coordinates has already existed, old record will be replaced with new one")
                records[index] = record
                return
            }
        }
        
        var roundedRecord = record
        roundedRecord.coordinates = roundedCoordinates
        
        records.append(roundedRecord)
    }

    func loadWeatherRecord(coordinates: CLLocationCoordinate2D) -> WeatherRecord?  {
        let roundedCoordinates = CLLocationCoordinate2D(latitude: coordinates.latitude.rounded(), longitude: coordinates.longitude.rounded())
        
        for record in self.records {
            if record.coordinates == roundedCoordinates {
                return record
            }
        }
        return nil
    }
    
    func getWeatherBy(city: String) {
        service.getWeatherBy(city: city) { record in
            self.addWeatherRecord(record: record)
            self.MapViewCoordinates = self.NewCoordinateRegion(latitude: record.coordinates.latitude, longitude: record.coordinates.longitude)
            self.currentLocationTemp = String.localizedStringWithFormat("%.2f °C", record.temperature)
        }
    }
    
    func getWeatherBy(coordinates: CLLocationCoordinate2D) {
        service.getWeatherBy(coordinates: coordinates) { record in
            self.addWeatherRecord(record: record)
        }
    }
    
    func NewCoordinateRegion(latitude: Double, longitude: Double) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
    
    func calculateTemperatureForCurrentLocation(currentCoordinates: MKCoordinateRegion) {
        DispatchQueue.global(qos: .userInitiated).async {
            for index in self.records.indices {
                let distance = getDistanceTo(coordinates: CLLocationCoordinate2D(latitude: CLLocationDegrees(self.records[index].coordinates.latitude), longitude: CLLocationDegrees(self.records[index].coordinates.longitude)))

                self.records[index].distance = Float(distance)
                    
                DispatchQueue.main.async {
                    print("Record #\(index+1): \(self.records[index].temperature) Distance: \(self.records[index].distance)")
                }
            }
            
            var OrdereredList: [WeatherRecord] = []
            
            // Sort records by from closest to furthest
            OrdereredList = self.records
            OrdereredList.sort {
                $0.distance > $1.distance
            }
            
            DispatchQueue.main.async {
                if self.records.count >= 3 {
                    let summedTemperature = (OrdereredList[0].distance * OrdereredList[0].temperature) + (OrdereredList[1].distance * OrdereredList[1].temperature) + (OrdereredList[2].distance * OrdereredList[2].temperature)
                    let summedDistance = OrdereredList[0].distance + OrdereredList[1].distance + OrdereredList[2].distance
                    let WeightedTemperature = summedTemperature / summedDistance
                    
                    print("Calculated temp: \(WeightedTemperature)")
                    self.currentLocationTemp = String.localizedStringWithFormat("%.2f °C", WeightedTemperature)
                }
            }
        }
        
        func getDistanceTo(coordinates: CLLocationCoordinate2D) -> Double {
            let currentCoordinate: CLLocationCoordinate2D = self.MapViewCoordinates.center

            var result2 = coordinates.distance(from: currentCoordinate)/2000 as Double
            
            if result2 != 0 {
                result2 = 1 / result2
            }
            return result2
        }
    }
}
