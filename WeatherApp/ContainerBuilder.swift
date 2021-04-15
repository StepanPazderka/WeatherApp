//
//  ContainerBuilder.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 02.04.2021.
//

import Foundation
import Swinject

let container: Container = Container.init(defaultObjectScope: .container)

class ContainerBuilder {

    // MARK: - Build
    static func buildContainer() -> Container {
        
        withUnsafePointer(to: self) {
            print("Container Address: \($0)")
        }

        container.register(WeatherDataCache.self) { _ in
            WeatherDataCache()
        }

        container.register(WeatherService.self) { r in
            WeatherServiceImpl(cache: r.resolve(WeatherDataCache.self)!)
        }
        
        container.register(WeatherRecordsRepository.self) { r in
            WeatherRecordsRepositoryImpl(service: r.resolve(WeatherService.self)!)
        }

        container.register(CalculateCurrentLocationWeatherUseCase.self) { r in
            CalculateCurrentLocationWeatherUseCase(repository: r.resolve(WeatherRecordsRepository.self)!)
        }

        container.register(ContentViewModel.self) { r in
            ContentViewModel(repository: r.resolve(WeatherRecordsRepository.self)!, useCase: r.resolve(CalculateCurrentLocationWeatherUseCase.self)!)
        }

        return container
    }
}
