//
//  ContainerBuilder.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 02.04.2021.
//

import Foundation
import Swinject

class ContainerBuilder {
    static func buildContainer() -> Container {
        let container: Container = Container.init(defaultObjectScope: .transient)

        container.register(WeatherService.self) { _ in
            WeatherServiceImpl()
        }

        container.register(CalculateCurrentLocationWeatherUseCase.self) { r in
            CalculateCurrentLocationWeatherUseCase(repository: r.resolve(WeatherRecordsRepository.self)!)
        }

        container.register(ContentViewModel.self) { r in
            ContentViewModel(repository: r.resolve(WeatherRecordsRepository.self)!, useCase: r.resolve(CalculateCurrentLocationWeatherUseCase.self)!)
        }

        container.register(WeatherRecordsRepository.self) { r in
            WeatherRecordsRepositoryImpl(service: r.resolve(WeatherService.self)!)
        }

        return container
    }
}
