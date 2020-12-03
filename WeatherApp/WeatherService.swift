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
    @Published var MapViewCoordinates = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100))
    @Published var country = ""
    @Published var records: [WeatherRecord] = []
    
    struct Coordinates {
        var lat: Float
        var long: Float
    }
    
    struct WeatherRecord {
        var temperature: Float
        var date: Date
        var coordinates: Coordinates
        var distance: Float
    }
    
    func addWeatherRecord(latitude: Double, longitude: Double, temperature: Float) {
        print("Saving temp: \(temperature) on lat: \(latitude) and long: \(longitude)")
        records.append(WeatherRecord(temperature: temperature, date: Date(), coordinates: Coordinates(lat: Float(latitude), long: Float(longitude)), distance: 0.0))
    }
    
    func calculateTemperatureForCurrentLocation(currentCoordinates: MKCoordinateRegion, completion: ((Float) -> ())?) {
        DispatchQueue.global(qos: .userInitiated).async {
            for index in self.records.indices {
//                let distance: Float = self.getDistanceTo(latitude: Double(self.records[record].coordinates.lat), longitude: Double(self.records[record].coordinates.long), currentMapCoord: currentCoordinates)
                let distance = self.getDistanceTo(coordinates: CLLocationCoordinate2D(latitude: CLLocationDegrees(self.records[index].coordinates.lat), longitude: CLLocationDegrees(self.records[index].coordinates.long)))

                self.records[index].distance = Float(distance)
                    
                DispatchQueue.main.async {
                    print("Record #\(index+1): \(self.records[index].temperature) Distance: \(self.records[index].distance)")
                }
            }

            var valuesForFinalCalculations: [Float] = []
            for record in self.records {
                let temperatureRecordCalibrated: Float = record.temperature * (record.distance / Float(self.records.count))
                valuesForFinalCalculations.append(temperatureRecordCalibrated)
            }
            
            let maxValue = self.records.max(by: { a, b in
                a.distance < b.distance
            })
            
            let summedUpValues = valuesForFinalCalculations.reduce(0, +)
            
            DispatchQueue.main.async {
                self.currentLocationTemp = String.localizedStringWithFormat("%.2f °C", maxValue?.temperature ?? "No data")
                
                if completion != nil {
//                    completion!(summedDistanceRecords)
                }
            }
        }
    }
    
    func getDistanceTo(coordinates: CLLocationCoordinate2D) -> CLLocationDistance {
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let currentCoordinate: CLLocationCoordinate2D = self.MapViewCoordinates.center
        
        let maximumDistance = CLLocation(latitude: 90, longitude: 180).distance(from: CLLocation(latitude: -90, longitude: -180))
        print("Maximum possible distance is: \(maximumDistance)")
        let normalizedDistance = coordinate.distance(from: currentCoordinate)/20003920.289225627
        let invertedDistance = abs(normalizedDistance-1)
        return invertedDistance
    }
    
    func getDistanceTo(latitude: Double, longitude: Double, currentMapCoord: MKCoordinateRegion) -> Float {
        // Calculation happens in lat and long with abs values (we are calculating over spherical object, in that sense -90 and 90, are actually the same thing)
        let latitudeDifference = abs(latitude - currentMapCoord.center.latitude)
        let longitudeDifference = abs(longitude - currentMapCoord.center.longitude)
        print("Record Lat: \(latitude), View Lat: \(currentMapCoord.center.latitude)")
        
        let squared: Double = Double(sqrt((latitudeDifference * latitudeDifference) + (longitudeDifference * longitudeDifference)))
//        let hypotResult = hypot(latitudeDifference, longitudeDifference)
//        let normalized = (hypotResult/201.25) //Normalizes value to maximum value (remaps value between 0 and 1)
          
//        let inverted = (((squared)/130)-1)*(-1) // Inverts value (closer to the original is 1 and furthest is 0
//        let toPowerOf3 = pow(inverted, 15).truncate(places: 6)
        let normalized = max(squared, 0) //Normalizes value to maximum value (remaps value between 0 and 1)
        let result = normalized
        
        let lat1 = latitude * Double.pi/180
        let lat2 = currentMapCoord.center.latitude * Double.pi/180
        
        let DifLat1 = (lat2-lat1) * Double.pi/180
        
        return Float(result)
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
        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            self.getWeatherBy(latitude: self.MapViewCoordinates.center.latitude, longitude: self.MapViewCoordinates.center.longitude, completion: nil)
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
                    self.addWeatherRecord(latitude: decoded.coord!.lat, longitude: decoded.coord!.lon, temperature: Float(decoded.main!.temp))
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
    
    func getWeatherBy(latitude: Double, longitude: Double,  completion: ((Float) -> ())?) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&appid=\(self.OpenWeatherAPIkey)&units=metric")
        guard url != nil else { return }
        print(url!)
        print("Long: \(longitude), Lat: \(latitude)")

        let networkTask: URLSessionDataTask = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
                if (decoded.current?.temp != nil) {
                    self.addWeatherRecord(latitude: latitude, longitude: longitude, temperature: Float(decoded.current!.temp!))
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
