//
//  WeatherMap.swift
//  WeatherApp
//
//  Created by Steve on 07/12/2020.
//

import Foundation
import CoreLocation
import Combine
import MapKit

class ContentViewModel: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
    
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
//        useCase.addWeatherRecordsInGrid(latitudeModulo: 45, longitudeModulo: 40)
        self.getWeatherAt(coordinates: CLLocationCoordinate2D(latitude: 10, longitude: 10))
    }
    
    func mapViewChanged() {
        self.useCase.calculateTemperatureForCurrentLocation(currentCoordinates: MapViewCoords.center) { calculatedTemperature in
            self.CurrentLocationTemperature = String.localizedStringWithFormat("%.2f °C", calculatedTemperature)
        }
    }
    
    func getWeatherAt(city: String) {
        self.currentCity = city
        repository.getWeatherBy(city: city)
            .sink { (result) in
            switch result {
            case .success(let record):
                self.MapViewCoords = self.NewCoordinateRegion(coordinates: CLLocationCoordinate2D(latitude: record.coordinates.latitude, longitude: record.coordinates.longitude))
                self.CurrentLocationTemperature = String.localizedStringWithFormat("%.2f °C", record.temperature)
            case .failure(let error):
                switch error {
                case .cityNotFound:
                    self.isAlertRaised = true
                    self.alertDescription = "Can't find city called \(self.currentCity)"
                case .errorWith(let description):
                    self.isAlertRaised = true
                    self.alertDescription = description
                case .accountBlocked:
                    self.isAlertRaised = true
                    self.alertDescription = "Service is unavailable, because API have been overhelmed with requstests. \n\nPlease try again later."
                default:
                    self.isAlertRaised = true
                    self.alertDescription = "Error"
                }
            }
            }
            .store(in: &subscriptions)
    }
    
    //TOM: Prosim review
    func getWeatherAt(coordinates: CLLocationCoordinate2D) {
        repository.getWeatherBy(coordinates: coordinates)
            .sink(receiveCompletion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .finished:
                        break
                    case .failure(let error):
                        switch error {
                        case .errorWith(let description):
                            self.alertDescription = "\(description)"
                        default:
                            break
                        }
                        self.isAlertRaised = true
                        self.alertDescription = "\(error)"
                    }
                }
            }, receiveValue: { result in
                print("Got results from coordinates: \(result)")
            })
            .store(in: &subscriptions)
    }
    
    func NewCoordinateRegion(coordinates: CLLocationCoordinate2D) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
}

