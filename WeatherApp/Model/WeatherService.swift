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
    case noAPIkeyprovided
    case wrongData
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
    
    var OpenWeatherAPIkey: String? {
        let dir = Bundle.main.path(forResource: "key", ofType: "txt")
        do {
            let dataFromFile = try String(contentsOf: URL(fileURLWithPath: dir!), encoding: .utf8)
            let linesFromFile = dataFromFile.components(separatedBy: .newlines)
            
            guard linesFromFile.first != nil else { return "" }
            return linesFromFile.first!
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

        let networkTask: URLSessionDataTask = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(CountryData.self, from: data)
                
                if decoded.countryCode != nil {
                    DispatchQueue.main.async {
                        print(decoded.countryCode!)
                        self.country = self.GetFlagCodeToEmoji(country: decoded.countryCode!)
                    }
                }
                
                if decoded.description != nil {
                    DispatchQueue.main.async {
                        self.country = decoded.description!
                    }
                }
                
            } catch let error as NSError {
                NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            networkTask.resume()
        }
    }
    
    func getWeatherBy(city: String, completion: @escaping (Result<WeatherRecord, ServiceError>) -> ()) {
        let cityNameReformatted = (city as NSString).replacingOccurrences(of: " ", with: "+").lowercased()
        
        guard let APIkey = self.OpenWeatherAPIkey else { completion(.failure(ServiceError.noAPIkeyprovided)); return }
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityNameReformatted)&appid=\(APIkey)&units=metric")

        let networkTask: URLSessionDataTask = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data else { completion(.failure(ServiceError.wrongData));return }
            var record: WeatherRecord?
            do {
                let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
                if (decoded.coord?.lat != nil) {
                    DispatchQueue.main.async {
                        record = WeatherRecord(temperature: Float(decoded.main!.temp), date: Date(), coordinates: CLLocationCoordinate2D(latitude: decoded.coord!.lat, longitude: decoded.coord!.lon), distance: 0.0, flag: self.GetFlagCodeToEmoji(country: decoded.sys!.country))
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
        
        DispatchQueue.global(qos: .background).async {
            networkTask.resume()
        }
    }
    
    func getWeatherBy(coordinates: CLLocationCoordinate2D,  completion: @escaping (Result<WeatherRecord, ServiceError>) -> ()) {
        guard let APIkey = self.OpenWeatherAPIkey else { completion(.failure(ServiceError.noAPIkeyprovided)); return }

        let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&appid=\(APIkey)&units=metric")
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
                        let record = WeatherRecord(temperature: decoded.current!.temp!, date: Date(), coordinates: CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude), distance: 0.0, flag: "")
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
        
        DispatchQueue.global(qos: .background).async {
            networkTask.resume()
        }
    }
    
    func GetFlagCodeToEmoji(country:String) -> String {
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
