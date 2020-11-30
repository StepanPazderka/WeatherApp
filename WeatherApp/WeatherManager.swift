//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Steve on 27/11/2020.
//

import Foundation
import MapKit

class WeatherManager: ObservableObject {
    var key = Config.key
    @Published var currentLocationTemp: String = ""
    @Published var coord = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100))
    
    func NewCoordinateRegion(latitude: Double, longtitude: Double) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longtitude), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
    
    func weather(for city: String) {
        let trimmedCityName = (city as NSString).replacingOccurrences(of: " ", with: "+")
        
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(trimmedCityName.lowercased())&appid=\(self.key)&units=metric")
        guard url != nil else { return }
        print(url!)

        let networkTask: URLSessionDataTask = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
                if (decoded.main != nil) {

                    DispatchQueue.main.async {
                        print("Temperature at \(city): \(decoded.main!.temp) °C")
                        print("Coords for \(city): \(decoded.coord!)")
                        
                        if (decoded.coord?.lat != nil) {
                            self.coord = self.NewCoordinateRegion(latitude: (decoded.coord!.lat), longtitude: (decoded.coord!.lon))
                        } else {
                            print("Cant find coord")
                            self.coord = self.NewCoordinateRegion(latitude: 0, longtitude: 0)
                        }

                        if decoded.sys?.country != nil {
                            self.currentLocationTemp = "\(String(describing: decoded.main!.temp)) °C \(self.flag(country: decoded.sys!.country))"
                        } else {
                            self.currentLocationTemp = "\(String(describing: decoded.main!.temp)) °C"
                        }
                        self.objectWillChange.send()
                    }
                }
                
                if (decoded.message != nil) {
                    print("Message: \(decoded.message!)")
                    
                    DispatchQueue.main.async {
                        if (decoded.message! != "Nothing to geocode") {
                            self.currentLocationTemp = String(describing: decoded.message!)
                            self.coord = self.NewCoordinateRegion(latitude: 0, longtitude: 0)
                        }
                        
                        self.objectWillChange.send()
                    }
                }
            } catch DecodingError.keyNotFound(let key, let context) {
                Swift.print("Could not find key \(key) in JSON: \(context.debugDescription)")
            } catch DecodingError.valueNotFound(let type, let context) {
                Swift.print("Could not find type \(type) in JSON: \(context.debugDescription)")
            } catch DecodingError.typeMismatch(let type, let context) {
                Swift.print("Type mismatch for type \(type) in JSON: \(context.debugDescription) \(context)")
            } catch DecodingError.dataCorrupted(let context) {
                Swift.print("Data found to be corrupted in JSON: \(context.debugDescription)")
            } catch let error as NSError {
                NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
            }
        }
        
        DispatchQueue.global().async {
            networkTask.resume()
        }
    }
    
    func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }
}
