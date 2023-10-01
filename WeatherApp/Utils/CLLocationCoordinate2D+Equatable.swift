//
//  File.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 08.12.2020.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Equatable
{
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool
    {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
