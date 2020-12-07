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
        self.getWeatherBy(coordinates: CLLocationCoordinate2D(latitude: 90, longitude: 180))
        self.getWeatherBy(coordinates: CLLocationCoordinate2D(latitude: -90, longitude: -180))
        self.getWeatherBy(coordinates: CLLocationCoordinate2D(latitude: -90, longitude: 180))
        self.getWeatherBy(coordinates: CLLocationCoordinate2D(latitude: 90, longitude: -180))
        self.getWeatherBy(coordinates: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    }
    
    func addWeatherRecord(record: WeatherRecord) {
        print("Saving temp: \(record.temperature) on lat: \(record.coordinates.latitude) and long: \(record.coordinates.longitude)")
        records.append(record)
    }
//
//    func getWeatherInLoop() {
//        _ = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
//            self.getWeatherBy(coordinates: CLLocationCoordinate2D(latitude: self.MapViewCoordinates.center.latitude, longitude: self.MapViewCoordinates.center.longitude), completion: nil)
//        }
//    }
    
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
