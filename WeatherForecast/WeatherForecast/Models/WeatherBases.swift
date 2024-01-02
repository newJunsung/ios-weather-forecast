//
//  WeatherBases.swift
//  WeatherForecast
//
//  Created by 김준성 on 11/20/23.
//

import Foundation

struct MainInfo: Decodable {
    let temperature: Double
    let feelsLike: Double
    let temperatureMin: Double
    let temperatureMax: Double
    let pressure: Double
    let humidity: Double
    let seaLevel: Double?
    let groundLevel: Double?
    let tempKF: Double?
    
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLike = "feels_like"
        case temperatureMin = "temp_min"
        case temperatureMax = "temp_max"
        case pressure, humidity
        case seaLevel = "sea_level"
        case groundLevel = "grnd_level"
        case tempKF = "temp_kf"
    }
}

struct Coordinate: Decodable {
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Wind: Decodable {
    let speed: Double?
    let deg: Int?
    let gust: Double?
}

struct Clouds: Decodable {
    let all: Int?
}

struct Rain: Decodable {
    let oneHour: Double?
    let threeHour: Double?
    
    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
        case threeHour = "3h"
    }
}

struct Snow: Decodable {
    let oneHour: Double?
    let threeHoure: Double?
    
    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
        case threeHoure = "3h"
    }
}

struct City: Decodable {
    let id: Int
    let name: String
    let coordinate: Coordinate
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: Int
    let sunset: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case coordinate = "coord"
        case country
        case population
        case timezone
        case sunrise
        case sunset
    }
}

struct Forecast: Decodable, Hashable {
    static func == (lhs: Forecast, rhs: Forecast) -> Bool {
        return lhs.timeOfData == rhs.timeOfData && lhs.mainInfo.temperature == rhs.mainInfo.temperature
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.timeOfData)
    }
    
    let timeOfData: Int
    let mainInfo: MainInfo
    let weather: [Weather]
    let wind: Wind
    let clouds: Clouds
    let visibility: Double
    let probabilityOfPrecipitation: Double
    let system: Self.System
    let dtTXT: String
    
    struct System: Decodable {
        let partOfDay: String
        enum CodingKeys: String, CodingKey {
            case partOfDay = "pod"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case timeOfData = "dt"
        case mainInfo = "main"
        case weather
        case wind
        case clouds
        case visibility
        case probabilityOfPrecipitation = "pop"
        case system = "sys"
        case dtTXT = "dt_txt"
    }
}
