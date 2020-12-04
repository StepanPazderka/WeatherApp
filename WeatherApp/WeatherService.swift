//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Steve on 27/11/2020.
//

import Foundation
import MapKit

class WeatherService: ObservableObject {
    @Published var currentLocationTemp: String = ""
    @Published var MapViewCoordinates = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50))
    @Published var country = ""
    var records: [WeatherRecord] = []
    
    init() {
        self.getWeatherBy(coordinates: CLLocationCoordinate2D(latitude: 90, longitude: 180), completion: nil)
        self.getWeatherBy(coordinates: CLLocationCoordinate2D(latitude: -90, longitude: -180), completion: nil)
        self.getWeatherBy(coordinates: CLLocationCoordinate2D(latitude: -90, longitude: 180), completion: nil)
        self.getWeatherBy(coordinates: CLLocationCoordinate2D(latitude: 90, longitude: -180), completion: nil)
    }
    
    struct Coordinates {
        var lat: Float
        var long: Float
    }
    
    struct WeatherRecord {
        var temperature: Float
        var date: Date
        var coordinates: CLLocationCoordinate2D
        var distance: Float
    }
    
    func addWeatherRecord(coordinates: CLLocationCoordinate2D, temperature: Float) {
        print("Saving temp: \(temperature) on lat: \(coordinates.latitude) and long: \(coordinates.longitude)")
        records.append(WeatherRecord(temperature: temperature, date: Date(), coordinates: CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinates.latitude), longitude: CLLocationDegrees(coordinates.longitude)), distance: 0.0))
    }
    
    func calculateTemperatureForCurrentLocation(currentCoordinates: MKCoordinateRegion, completion: ((Float) -> ())?) {
        DispatchQueue.global(qos: .userInitiated).async {
            for index in self.records.indices {
//                let distance: Float = self.getDistanceTo(latitude: Double(self.records[record].coordinates.lat), longitude: Double(self.records[record].coordinates.long), currentMapCoord: currentCoordinates)
                let distance = self.getDistanceTo(coordinates: CLLocationCoordinate2D(latitude: CLLocationDegrees(self.records[index].coordinates.latitude), longitude: CLLocationDegrees(self.records[index].coordinates.longitude)))

                self.records[index].distance = Float(distance)
                    
                DispatchQueue.main.async {
                    print("Record #\(index+1): \(self.records[index].temperature) Distance: \(self.records[index].distance)")
                }
            }
            
            var OrdereredList: [WeatherRecord] = []
            
            // Sort records by from closest to furthest
            OrdereredList = self.records
            OrdereredList.sort {
                $0.distance > $1.distance
            }
            
            print(OrdereredList)
            
//            let summedUpValues = valuesForFinalCalculations.reduce(0, +)
            
            DispatchQueue.main.async {
                if self.records.count >= 3 {
//                    var summedTemperatureArray: [Float] = OrdereredList.reduce(0, +)
                    
                    let summedTemperature = (OrdereredList[0].distance * OrdereredList[0].temperature) + (OrdereredList[1].distance * OrdereredList[1].temperature) + (OrdereredList[2].distance * OrdereredList[2].temperature)
                    let summedDistance = OrdereredList[0].distance + OrdereredList[1].distance + OrdereredList[2].distance
                    let WeightedTemperature = summedTemperature / summedDistance
                    
                    print("Calculated temp: \(WeightedTemperature)")
//                    self.currentLocationTemp = String(describing: WeightedTemperature)
                    self.currentLocationTemp = String.localizedStringWithFormat("%.2f °C", WeightedTemperature)
                } else {
//                    self.currentLocationTemp = String.localizedStringWithFormat("%.2f °C", maxValue?.temperature ?? "No data")
                }

                if completion != nil {
//                    completion!(summedDistanceRecords)
                }
            }
        }
    }
    
    func getDistanceTo(coordinates: CLLocationCoordinate2D) -> Double {
        let currentCoordinate: CLLocationCoordinate2D = self.MapViewCoordinates.center

        var result2 = coordinates.distance(from: currentCoordinate)/2000 as Double
        
        if result2 != 0 {
            result2 = 1 / result2
        }
        return result2
    }
    
    var OpenWeatherAPIkey: String {
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
    
    func getWeatherInLoop() {
        _ = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            self.getWeatherBy(coordinates: CLLocationCoordinate2D(latitude: self.MapViewCoordinates.center.latitude, longitude: self.MapViewCoordinates.center.longitude), completion: nil)
//            print("Timer fired")
        }
    }
    
    func getWeatherBy(city: String) {
        let trimmedCityName = (city as NSString).replacingOccurrences(of: " ", with: "+")
        
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(trimmedCityName.lowercased())&appid=\(self.OpenWeatherAPIkey)&units=metric")
        guard url != nil else { return }
        print(url!)

        let networkTask: URLSessionDataTask = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
                if (decoded.main != nil) {
                    self.addWeatherRecord(coordinates: CLLocationCoordinate2D(latitude: decoded.coord!.lat, longitude: decoded.coord!.lon), temperature: Float(decoded.main!.temp))
                    DispatchQueue.main.async {
                        print("Temperature at \(city): \(decoded.main!.temp) °C")
                        print("Coords for \(city): \(decoded.coord!)")

                        if (decoded.coord?.lat != nil) {
                            self.MapViewCoordinates = self.NewCoordinateRegion(latitude: (decoded.coord!.lat), longitude: (decoded.coord!.lon))
                        } else {
                            print("Cant find coord")
                            self.MapViewCoordinates = self.NewCoordinateRegion(latitude: 0, longitude: 0)
                        }

                        self.currentLocationTemp = "\(String(describing: decoded.main!.temp)) °C"
                        
//                        if decoded.sys?.country != nil {
//                            self.country = self.flag(country: decoded.sys!.country)
//                        }
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
                            self.MapViewCoordinates = self.NewCoordinateRegion(latitude: 0, longitude: 0)
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
    
    func getWeatherBy(coordinates: CLLocationCoordinate2D,  completion: ((Float) -> ())?) {
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
                    self.addWeatherRecord(coordinates: CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude), temperature: Float(decoded.current!.temp!))
                    DispatchQueue.main.async {
                        let temperatureAsString = decoded.current!.temp!
                        self.currentLocationTemp = "\(temperatureAsString) °C"
                        if completion != nil {
                            completion!(temperatureAsString)
                        }
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
