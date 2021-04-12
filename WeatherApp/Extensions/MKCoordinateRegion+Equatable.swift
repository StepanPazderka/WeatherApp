//
//  MKCoordinates.swift
//  WeatherApp
//
//  Created by Steve on 01/12/2020.
//

import Foundation
import MapKit

// This extensions allows MKCoordinateRegion class to be comparable
// We do this so that we can check, whether the region inside of Map view have changed and catch it in onChange method

extension MKCoordinateRegion: Equatable {
   public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
       if lhs.center.latitude != rhs.center.latitude || lhs.center.longitude != rhs.center.longitude {
           return false
       }
       if lhs.span.latitudeDelta != rhs.span.latitudeDelta || lhs.span.longitudeDelta != rhs.span.longitudeDelta {
           return false
       }
       return true
   }
}
