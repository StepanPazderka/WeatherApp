//
//  @Registered.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 09.04.2021.
//

import Foundation

@propertyWrapper
struct Registered<T> {
    let type: T.Type
    private let container = ContainerBuilder.buildContainer()
    // swiftlint:disable force_unwrapping
    var wrappedValue: T { container.resolve(type)! }
}
