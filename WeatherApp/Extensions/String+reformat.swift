//
//  String+reformat.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 08.04.2021.
//

import Foundation

extension String {
    var reformated: String {
        return (self as NSString).replacingOccurrences(of: " ", with: "+").lowercased()
    }
}
