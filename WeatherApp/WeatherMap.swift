//
//  WeatherDatabase.swift
//  WeatherApp
//
//  Created by Steve on 30/11/2020.
//

import Foundation

class WeatherMap {
    var map: [[Float]] = [[]]
    
    init() {
        self.map = Array(repeating: Array(repeating: 0.0, count: 360), count: 180)
        // Array of empty values, first index is latitude with MAX value of 179, second is LONGITUDE with max index of 359
    }
    
    func addWeatherRecord(latitude: Double, longitude: Double, temperature: Float) {
        let remapedLatitude = Int((latitude+90)-1)
//        print(remapedLatitude)
        
        let remapedLongitude = Int((longitude+180)-1)
//        print(remapedLongitude)
        
        self.map[remapedLatitude][remapedLongitude] = temperature
    }
    
    func loadWeatherRecord(latitude: Double, longitude: Double) -> Float{
//        let remapedLatitude = Int((latitude+1)/2)
        let remapedLatitude = Int((latitude+90)-1)
//        print(remapedLatitude)
        
//        let remapedLongitude = Int((longitude+1)/2)
        let remapedLongitude = Int((longitude+180)-1)
//        print(remapedLongitude)
        
        return self.map[remapedLatitude][remapedLongitude]
    }
}
