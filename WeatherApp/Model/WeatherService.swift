//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Steve on 27/11/2020.
//

import Foundation
import MapKit
import Alamofire
import Combine

enum ServiceError: Error {
    case cityNotFound
    case wrongCoordinates
    case timout
    case unableToComplete
    case accountBlocked
    case noAPIkeyprovided
    case errorWith(description: String)
    case wrongURL
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
    let backgroundQueue = DispatchQueue(label: "WeatherService", qos: .background)
    
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

        AF.request(url!).response(queue: backgroundQueue) { response in
            if response.error != nil {
                print(response.error!)
            }
            
            guard let data = response.data else { return }
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
    }
    
    func getWeatherBy(city: String) -> Just<Result<WeatherRecord, ServiceError>> {
        var returnValue: Just<Result<WeatherRecord, ServiceError>>!
        
        let cityNameReformatted = (city as NSString).replacingOccurrences(of: " ", with: "+").lowercased()
        
        returnValue = .init(.success(WeatherRecord(temperature: 2.0, date: Date(), coordinates: CLLocationCoordinate2D(latitude: 20.0, longitude: 10.0), distance: 20.0, flag: "CZ")))
        
        guard let APIkey = self.OpenWeatherAPIkey else { return .init(.failure(ServiceError.noAPIkeyprovided)) }
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityNameReformatted)&appid=\(APIkey)&units=metric")
//
//        AF.request(url!).response(queue: backgroundQueue) { response in
//            guard let data = response.data else { returnValue = .init(.failure(ServiceError.wrongData)) }
//            var record: WeatherRecord?
//            do {
//                let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
//                if (decoded.coord?.lat != nil) {
//                    DispatchQueue.main.async {
//                        record = WeatherRecord(temperature: Float(decoded.main!.temp), date: Date(), coordinates: CLLocationCoordinate2D(latitude: decoded.coord!.lat, longitude: decoded.coord!.lon), distance: 0.0, flag: self.GetFlagCodeToEmoji(country: decoded.sys!.country))
//                        returnValue = .success(record!)
//                    }
//                } else if (decoded.message != nil) {
//                    print("Message: \(decoded.message!)")
//                        if (String(describing: decoded.message!).contains("Your account is temporary blocked") == true) {
//                            DispatchQueue.main.async {
//                                returnValue = .failure(.accountBlocked)
//                            }
//                        }
//
//                        if String(describing: decoded.message!).contains("city not found") {
//                            returnValue = .failure(.cityNotFound)
//                        }
//
//                        if (decoded.message! != "Nothing to geocode") || String(describing: decoded.message!).contains("Your account is temporary blocked") != false {
//
//                        }
//                } else {
//                    DispatchQueue.main.async {
//                        returnValue = .init(.failure(.cityNotFound))
//                    }
//                }
//            } catch let error as ServiceError {
//                DispatchQueue.main.async {
//                    returnValue = .init(.failure(error))
//                }
//                NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
//            }
//        }
        
        return returnValue
    }
    
    func getWeatherBy(coordinates: CLLocationCoordinate2D) -> Deferred<Future<WeatherRecord, ServiceError>> {
        return Deferred {
            Future<WeatherRecord, ServiceError> { promise in
                guard let APIkey = self.OpenWeatherAPIkey else { return promise(.failure(.noAPIkeyprovided)) }

                let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&appid=\(APIkey)&units=metric")

                guard url != nil else { return promise(.failure(.wrongURL)) }

                AF.request(url!).response(queue: self.backgroundQueue) { response in
                    guard let data = response.data else { return }
                    do {
                        let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
                        if (decoded.current?.temp != nil) {
                            let record = WeatherRecord(temperature: decoded.current!.temp!, date: Date(), coordinates: CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude), distance: 0.0, flag: "")
                            promise(.success(record))
                        }

                        if let message = decoded.message {
                            let error: ServiceError = .errorWith(description: message)
                            promise(.failure(error))
                        }
                    } catch let error as NSError {
                        NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                    }
                }
            }
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
