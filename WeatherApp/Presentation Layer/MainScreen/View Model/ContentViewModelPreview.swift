//
//  ContentViewModelPreview.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 19.04.2021.
//

import Foundation

class ContentViewModelPreviewImpl: ViewModel {
    @Published var CurrentLocationTemperature: String = "10.0"
    @Published var isAlertRaised: Bool = false
}
