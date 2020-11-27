//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Steve on 27/11/2020.
//

import Foundation

class WeatherManager {
    func weather(for city: String) -> Double? {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=kladno&appid=40e20e4c03043747c438b85bdd9cd808&units=metric")
        
        var returnTemp: Double?
        
        URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            
            guard let data = data else { return }
            
            let dataAsString = String(data: data, encoding: .utf8)
            print(dataAsString!)
            
            do {
                let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
                returnTemp = decoded.main.temp
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
        
        return returnTemp
    }
}
