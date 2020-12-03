//
//  CLLocation+Distance.swift
//  WeatherApp
//
//  Created by Steve on 03/12/2020.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    //distance in meters, as explained in CLLoactionDistance definition
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination=CLLocation(latitude: from.latitude, longitude: from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}
