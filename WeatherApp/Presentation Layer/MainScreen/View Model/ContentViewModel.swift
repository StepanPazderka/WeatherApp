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

class ContentViewModel: ViewModel {
    private var subscriptions: Set<AnyCancellable> = []

    @Published var MapViewCoords = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50))
    @Published var CurrentLocationTemperature: String = "0"
    @Published var isAlertRaised: Bool = false
    @Published var alertDescription: String = String()
    @Published var currentCity: String = String()
    @Published var currentCountryFlag: String = String()

    private var repository: WeatherRecordsRepository
    private var useCase: CalculateCurrentLocationWeatherUseCase

    init(repository: WeatherRecordsRepository, useCase: CalculateCurrentLocationWeatherUseCase) {
        self.repository = container.resolve(WeatherRecordsRepository.self)!
        self.useCase = container.resolve(CalculateCurrentLocationWeatherUseCase.self)!
    }

    func mapViewChanged() {
        self.useCase.calculateTemperatureForCurrentLocation(currentCoordinates: MapViewCoords.center)
        .sink(receiveCompletion: { complete in }, receiveValue: { weightedTemperature in
            self.CurrentLocationTemperature = String.localizedStringWithFormat("%.2f °C", weightedTemperature)
            print(weightedTemperature)
        })
        .store(in: &subscriptions)
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
                    case ServiceError.cityNotFound:
                        self.isAlertRaised = true
                        self.alertDescription = "\(Localizable.cantFindCityCalled()) \(self.currentCity)"
                    case ServiceError.errorWith(let description):
                        self.isAlertRaised = true
                        self.alertDescription = description
                    case ServiceError.accountBlocked:
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
                        self.useCase.calculateTemperatureForCurrentLocation(currentCoordinates: self.MapViewCoords.center).sink(receiveCompletion: { complete in }, receiveValue: { value in }).store(in: &self.subscriptions)
                    case .failure(let error):
                        self.isAlertRaised = true
                        if let error = error as? ServiceError {
                            switch error {
                            case .errorWith(let description):
                                self.alertDescription = description
                            default:
                                self.alertDescription = "\(error)"
                            }
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
