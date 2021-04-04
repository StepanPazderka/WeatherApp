//
//  CalculateCurrentLocationWeather.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 02.04.2021.
//

import Foundation
import MapKit

class CalculateCurrentLocationWeatherUseCase {
    var repository: WeatherRecordsRepository
    
    init(repository: WeatherRecordsRepository) {
        self.repository = repository
    }
    
    func calculateTemperatureForCurrentLocation(currentCoordinates: CLLocationCoordinate2D, completion: @escaping ((Float)->()?)) {
        DispatchQueue.global(qos: .userInitiated).async {
            for index in self.repository.records.indices {
                let distance = self.getDistanceTo(from: CLLocationCoordinate2D(latitude: CLLocationDegrees(self.repository.records[index].coordinates.latitude), longitude: CLLocationDegrees(self.repository.records[index].coordinates.longitude)), to: currentCoordinates)

                self.repository.records[index].distance = Float(distance)
                    
                DispatchQueue.main.async {
                    print("Record #\(index+1): \(self.repository.records[index].temperature) Distance: \(self.repository.records[index].distance)")
                }
            }
            
            var OrdereredList: [WeatherRecord] = []
            
            // Sort records by from closest to furthest
            OrdereredList = self.repository.records
            OrdereredList.sort {
                $0.distance > $1.distance
            }
            
            DispatchQueue.main.async {
                if self.repository.records.count >= 3 {
                    let summedTemperature = (OrdereredList[0].distance * OrdereredList[0].temperature) + (OrdereredList[1].distance * OrdereredList[1].temperature) + (OrdereredList[2].distance * OrdereredList[2].temperature)
                    let summedDistance = OrdereredList[0].distance + OrdereredList[1].distance + OrdereredList[2].distance
                    let WeightedTemperature = summedTemperature / summedDistance
                    
                    print("Calculated temp: \(WeightedTemperature)")
                    completion(WeightedTemperature)
                }
            }
        }
    }
        
    func getDistanceTo(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let currentCoordinate: CLLocationCoordinate2D = to
        
        var result2 = from.distance(from: currentCoordinate)/2000 as Double
        
        if result2 != 0 {
            result2 = 1 / result2
        }
        return result2
    }
}
