//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Steve on 27/11/2020.
//

import Foundation

class WeatherManager: ObservableObject {
    @Published var currentLocationTemp: String = "Loading"
    
    func weather(for city: String) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=40e20e4c03043747c438b85bdd9cd808&units=metric")
        let networkTask: URLSessionDataTask = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
                print("Temperature at \(city): \(decoded.main.temp)")
                DispatchQueue.main.async {
                    self.currentLocationTemp = String(describing: decoded.main.temp)
                    self.objectWillChange.send()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        networkTask.resume()
    }
}
