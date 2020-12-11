//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Steve on 27/11/2020.
//

import Foundation
import MapKit

enum ServiceError: Error {
    case cityNotFound
    case wrongCoordinates
    case timout
    case unableToComplete
    case accountBlocked
}

extension ServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cityNotFound:
            return NSLocalizedString("City was not found by the service", comment: "Service Error")
        default:
            return NSLocalizedString("Service couldnt finish request", comment: "Service error")
        }
    }
}

class WeatherService: ObservableObject {
    @Published var country = ""
    
    var OpenWeatherAPIkey: String {
        let dir = Bundle.main.path(forResource: "key", ofType: "txt")
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
        
        networkTask.resume()
    }
    
    func getWeatherBy(city: String, completion: @escaping (Result<WeatherRecord, ServiceError>) -> ()) {
        let cityNameTrimmed = (city as NSString).replacingOccurrences(of: " ", with: "+").lowercased()
        
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityNameTrimmed)&appid=\(self.OpenWeatherAPIkey)&units=metric")
        guard url != nil else { return }
        print(url!)

        let networkTask: URLSessionDataTask = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data else { return }
            var record: WeatherRecord?
            do {
                let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
                if (decoded.coord?.lat != nil) {
                    DispatchQueue.main.async {
                        record = WeatherRecord(temperature: Float(decoded.main!.temp), date: Date(), coordinates: CLLocationCoordinate2D(latitude: decoded.coord!.lat, longitude: decoded.coord!.lon), distance: 0.0)
                        completion(.success(record!))
                    }
                } else if (decoded.message != nil) {
                    print("Message: \(decoded.message!)")
                        if (String(describing: decoded.message!).contains("Your account is temporary blocked") == true) {
                            DispatchQueue.main.async {
                                completion(.failure(.accountBlocked))
                            }
                        }
                    
                        if String(describing: decoded.message!).contains("city not found") {
                            completion(.failure(.cityNotFound))
                        }
                        
                        if (decoded.message! != "Nothing to geocode") || String(describing: decoded.message!).contains("Your account is temporary blocked") != false {
                            
                        }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.cityNotFound))
                    }
                }
            } catch let error as NSError {
                NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
            }
        }
        
        DispatchQueue.global().async {
            networkTask.resume()
        }
    }
    
    func getWeatherBy(coordinates: CLLocationCoordinate2D,  completion: @escaping (Result<WeatherRecord, ServiceError>) -> ()) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&appid=\(self.OpenWeatherAPIkey)&units=metric")
        guard url != nil else { return }
        print(url!)
        print("Long: \(coordinates.longitude), Lat: \(coordinates.latitude)")

        let networkTask: URLSessionDataTask = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
                if (decoded.current?.temp != nil) {
                    DispatchQueue.main.async {
                        let record = WeatherRecord(temperature: decoded.current!.temp!, date: Date(), coordinates: CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude), distance: 0.0)
                        completion(.success(record))
                    }
                }

                
                if (decoded.message != nil) {
                    DispatchQueue.main.async {
                        completion(.failure(ServiceError.unableToComplete))
                    }
                }
            } catch let error as NSError {
                NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
            }
        }
        
        networkTask.resume()
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
