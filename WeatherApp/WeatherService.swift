//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Steve on 27/11/2020.
//

import Foundation
import MapKit

class WeatherService: ObservableObject {
    var key: String {
        let dir = Bundle.main.path(forResource: "key", ofType: "txt")
        //reading
        do {
            let dataFromFile = try String(contentsOf: URL(fileURLWithPath: dir!), encoding: .utf8)
            let linseFromFile = dataFromFile.components(separatedBy: .newlines)
            
            guard linseFromFile.first != nil else { return "" }
            print(linseFromFile.first!)
            return linseFromFile.first!
        }
        catch {
            print(error.localizedDescription)
        }
        return ""
    }
    @Published var currentLocationTemp: String = ""
    @Published var coord = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100))
    @Published var country = ""
    
    func NewCoordinateRegion(latitude: Double, longitude: Double) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
    
    func getCountryCodeBy(longitude: Double, latitude: Double) {
        let url = URL(string: "https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=\(latitude)&longitude=\(longitude)")
        
        guard url != nil else { return }
        print(url!)

        let networkTask: URLSessionDataTask = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(CountryData.self, from: data)
                
                if decoded.countryCode != nil {
                    DispatchQueue.main.async {
                        print(decoded.countryCode!)
                        self.country = self.flag(country: decoded.countryCode!)
                    }
                }
                
                if decoded.description != nil {
                    DispatchQueue.main.async {
                        self.country = decoded.description!
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
    
    func getWeatherBy(city: String) {
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
                            self.coord = self.NewCoordinateRegion(latitude: (decoded.coord!.lat), longitude: (decoded.coord!.lon))
                        } else {
                            print("Cant find coord")
                            self.coord = self.NewCoordinateRegion(latitude: 0, longitude: 0)
                        }

                        self.currentLocationTemp = "\(String(describing: decoded.main!.temp)) °C"
                        if decoded.sys?.country != nil {
                            self.country = self.flag(country: decoded.sys!.country)
                        }
                    }
                }
                
                if (decoded.message != nil) {
                    print("Message: \(decoded.message!)")
                    
                    DispatchQueue.main.async {
                        if (String(describing: decoded.message!).contains("Your account is temporary blocked") == true) {
                            self.currentLocationTemp = "No Data"
                        }
                        
                        if (decoded.message! != "Nothing to geocode") || String(describing: decoded.message!).contains("Your account is temporary blocked") != false {
                            self.currentLocationTemp = String(describing: decoded.message!)
                            self.coord = self.NewCoordinateRegion(latitude: 0, longitude: 0)
                        }
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
    
    func getWeatherBy(latitude: Double, longitude: Double) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&appid=\(self.key)&units=metric")
        guard url != nil else { return }
        print(url!)
        print("Long: \(longitude), Lat: \(latitude)")

        let networkTask: URLSessionDataTask = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
                if (decoded.current?.temp != nil) {
                    DispatchQueue.main.async {
                        self.currentLocationTemp = "\(String(describing: decoded.current!.temp!)) °C"
                    }
                }
                
                if (decoded.message != nil) {
                    print("Message: \(decoded.message!)")
                    
                    DispatchQueue.main.async {
                        if (decoded.message! != "Nothing to geocode") {
                            self.currentLocationTemp = String(describing: decoded.message!)
                        }
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
        if (country == "__") {
            return "  "
        }
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }
}
