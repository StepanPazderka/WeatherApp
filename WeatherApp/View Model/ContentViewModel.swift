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
    @Published var CurrentLocationTemperature: String = String()
    @Published var isAlertRaised: Bool = false
    @Published var alertDescription: String = ""
    @Published var currentCity: String = ""
    @Published var currentCountryFlag: String = ""
    @Registered(type: WeatherRecordsRepository.self) private var repository: WeatherRecordsRepository
    @Registered(type: CalculateCurrentLocationWeatherUseCase.self) private var useCase: CalculateCurrentLocationWeatherUseCase

    init(repository: WeatherRecordsRepository, useCase: CalculateCurrentLocationWeatherUseCase) {
//        useCase.addWeatherRecordsInGrid(latitudeModulo: 45, longitudeModulo: 40)
    }

    func mapViewChanged() {
        self.useCase.calculateTemperatureForCurrentLocation(currentCoordinates: MapViewCoords.center).sink(receiveValue: { value in
            self.CurrentLocationTemperature = String(describing: value)
        }).store(in: &subscriptions)
    }

    func getWeatherAt(city: String) {
        self.currentCity = city
        repository.getWeatherBy(city: city)
            .sink(receiveCompletion: { (result) in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    switch error {
                    case .cityNotFound:
                        self.isAlertRaised = true
                        self.alertDescription = "\(Localizable.cantFindCityCalled()) \(self.currentCity)"
                    case .errorWith(let description):
                        self.isAlertRaised = true
                        self.alertDescription = description
                    case .accountBlocked:
                        self.isAlertRaised = true
                        self.alertDescription = Localizable.serviceIsUnavailableBecasuseOverhelmedAPI()
                    default:
                        self.isAlertRaised = true
                        self.alertDescription = "Error"
                    }
                }
            }, receiveValue: { value in
                self.MapViewCoords = self.NewCoordinateRegion(coordinates: CLLocationCoordinate2D(latitude: value.coordinates.latitude, longitude: value.coordinates.longitude))
                self.CurrentLocationTemperature = String.localizedStringWithFormat("%.2f °C", value.temperature)
            })
            .store(in: &subscriptions)
    }

    // TOM: Prosim review
    func getWeatherAt(coordinates: CLLocationCoordinate2D) {
        repository.getWeatherBy(coordinates: coordinates)
            .sink(receiveCompletion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .finished:
                        self.useCase.calculateTemperatureForCurrentLocation(currentCoordinates: self.MapViewCoords.center).sink(receiveValue: { value in
                            self.CurrentLocationTemperature = String(describing: value)
                        }).store(in: &self.subscriptions)
                    case .failure(let error):
                        self.isAlertRaised = true
                        switch error {
                        case .errorWith(let description):
                            self.alertDescription = description
                        default:
                            self.alertDescription = "\(error)"
                        }
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
