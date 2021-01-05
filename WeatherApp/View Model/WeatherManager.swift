//
//  WeatherMap.swift
//  WeatherApp
//
//  Created by Steve on 07/12/2020.
//

import Foundation
import CoreLocation
import MapKit

class WeatherManager: ObservableObject {
    @Published var MapViewCoordinates = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50))
    @Published var currentLocationTemp: String = ""
    @Published var alertRaised: Bool = false
    @Published var alertDescription: String = ""
    @Published var chosenCity: String = ""
    @Published var countryFlag: String = ""
    
    private var records: [WeatherRecord] = []
    var service: WeatherService = WeatherService()
    
    init() {
        addWeatherRecordsInGrid(latitudeModulo: 45, longitudeModulo: 40)
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateWeatherRecords), userInfo: nil, repeats: true)
    }
    
    func addWeatherRecordsInGrid(latitudeModulo: Int, longitudeModulo: Int) {
        var iterator = 0
        for latitude in -90...90 {
            if latitude % latitudeModulo == 0 {
                iterator += 1
                print("Divison of latitude happened \(latitude)")
                for longitude in -180...180 {
                    if longitude % longitudeModulo == 0 {
                        iterator += 1
                        print("Divison of longitude happened \(longitude)")
                        self.getWeatherAt(coordinates: CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude)))
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
                print("Weather record for these coordinates already exists, old record will be replaced with new one")
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
    
    func getWeatherAt(city: String) {
        self.chosenCity = city
        service.getWeatherBy(city: city) { result in
            switch result {
            case .success(let record):
                self.addWeatherRecord(record: record)
                self.MapViewCoordinates = self.NewCoordinateRegion(coordinates: CLLocationCoordinate2D(latitude: record.coordinates.latitude, longitude: record.coordinates.longitude))
                self.currentLocationTemp = String.localizedStringWithFormat("%.2f °C", record.temperature)
                self.countryFlag = record.flag
            case .failure(let error):
                DispatchQueue.main.async {
                    if error == .cityNotFound {
                        self.alertRaised = true
                        self.alertDescription = "Can't find city called \(self.chosenCity)"
                    }
                    else if error == .timeout {
                        self.alertRaised = true
                        self.alertDescription = "Request couldn't be completed. Are you connected to the internet?"
                    }
                    print("Error: \(error)")
    //                self.chosenCity = ""
                }
            }
        }
    }
    
    func getWeatherAt(coordinates: CLLocationCoordinate2D) {
        service.getWeatherBy(coordinates: coordinates) { result in
            switch result {
            case .success(let weatherRecord):
                self.addWeatherRecord(record: weatherRecord)
            case .failure(let error):
                print("Could not have obtained the coordinates \(error)")
            }
        }
    }
    
    func NewCoordinateRegion(coordinates: CLLocationCoordinate2D) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
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
                    
                    if OrdereredList[0].distance > 0.02 {
                        self.countryFlag = OrdereredList[0].flag
                    } else {
                        self.countryFlag = ""
                    }
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
    
    @objc func updateWeatherRecords() {
        for record in records {
            let currentDate = Date()
            
            if (record.date - currentDate) > 120 {
                print("\(record) is older than two minutes, will be updated")
                self.getWeatherAt(coordinates: record.coordinates)
            }
        }
    }
}

