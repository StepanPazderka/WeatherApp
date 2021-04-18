//
//  WeatherDataEntity.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 13.04.2021.
//

import Foundation
import MapKit
//import RealmSwift

protocol WeatherDataEntity {
    var temp: Float { get }
    var coordinates: CLLocationCoordinate2D { get }
    var flag: String { get }
}
