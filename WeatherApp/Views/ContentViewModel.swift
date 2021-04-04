//
//  WeatherMap.swift
//  WeatherApp
//
//  Created by Steve on 07/12/2020.
//

import Foundation
import CoreLocation
import MapKit

class ContentViewModel: ObservableObject {
    @Published var MapViewCoords = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50))
    @Published var CurrentLocationTemperature: String = ""
    @Published var isAlertRaised: Bool = false
    @Published var alertDescription: String = ""
    @Published var currentCity: String = ""
    @Published var currentCountryFlag: String = ""
    
    private var repository: WeatherRecordsRepository
    private var useCase: CalculateCurrentLocationWeatherUseCase
    
    init(repository: WeatherRecordsRepository, useCase: CalculateCurrentLocationWeatherUseCase) {
        self.repository = repository
        self.useCase = useCase
        addWeatherRecordsInGrid(latitudeModulo: 45, longitudeModulo: 40)
        
        
    }
    
    func mapViewChanged() {
        self.useCase.calculateTemperatureForCurrentLocation(currentCoordinates: MapViewCoords.center) { calculatedTemperature in
            self.CurrentLocationTemperature = String.localizedStringWithFormat("%.2f °C", calculatedTemperature)
        }
        
//        if OrdereredList[0].distance > 0.02 {
//            self.currentCountryFlag = OrdereredList[0].flag
//        } else {
//            self.currentCountryFlag = ""
//        }
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
    
    func getWeatherAt(city: String) {
        self.currentCity = city
        repository.getWeatherBy(city: city) { result in
            switch result {
            case .success(let record):
                self.MapViewCoords = self.NewCoordinateRegion(coordinates: CLLocationCoordinate2D(latitude: record.coordinates.latitude, longitude: record.coordinates.longitude))
                self.CurrentLocationTemperature = String.localizedStringWithFormat("%.2f °C", record.temperature)
            case .failure(let error):
                if error == .cityNotFound {
                    self.isAlertRaised = true
                    self.alertDescription = "Can't find city called \(self.currentCity)"
                }
                else if error == .wrongData {
                    self.isAlertRaised = true
                    self.alertDescription = "Request couldn't be completed. Are you connected to the internet?"
                }
            }
        }
    }
    
    func getWeatherAt(coordinates: CLLocationCoordinate2D) {
        repository.getWeatherBy(coordinates: coordinates) { result in
            switch result {
            case .success(let weatherRecord):
                print("Success")
            case .failure(let error):
                print("Could not have obtained the coordinates \(error)")
            }
        }
    }
    
    func NewCoordinateRegion(coordinates: CLLocationCoordinate2D) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
}

