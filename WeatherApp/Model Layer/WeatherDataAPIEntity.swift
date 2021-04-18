import Foundation
import MapKit

struct CountryData: Codable {
    let countryCode: String?
    let description: String?
}

enum ChangeableType: Codable {
    func encode(to encoder: Encoder) throws {

    }

    case double(Double), string(String)

    init(from decoder: Decoder) throws {
        if let double = try? decoder.singleValueContainer().decode(Double.self) {
            self = .double(double)
            return
        }

        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }

        throw ChangeableType.missingValue
    }

    enum ChangeableType: Error {
        case missingValue
    }
}

// MARK: - Welcome
struct WeatherDataAPIEntity: Codable {

    let coord: Coord?
    let weather: [Weather]?
    let base: String?
    let main: Main?
    let visibility: Int?
    let wind: Wind?
    let clouds: Clouds?
    let dt: Int?
    let sys: Sys?
    let timezone: Double?
    let id: Int?
    let name: String?
    let cod: Int?
    let message: String?
    let current: Current?
}

extension WeatherDataAPIEntity: Equatable {
    static func == (lhs: WeatherDataAPIEntity, rhs: WeatherDataAPIEntity) -> Bool {
        if (lhs.base == rhs.base) && (lhs.coord == rhs.coord) {
            return true
        }
        return false
    }
}

extension WeatherDataAPIEntity: WeatherDataEntity {

    var temp: Float {
        return Float(main?.temp ?? 0)
    }
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: coord?.lat ?? 0, longitude: coord?.lon ?? 0)
    }
    
    var flag: String {
        return sys?.country ?? String("")
    }
}

struct Current: Codable {
    let temp: Float?
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - Coord
struct Coord: Codable, Equatable {
    let lon, lat: Double
}

// MARK: - Main
struct Main: Codable {
    let temp, feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure, humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Sys
struct Sys: Codable {
    let type, id: Int
    let country: String
    let sunrise, sunset: Int
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main, weatherDescription, icon: String

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Int
}
