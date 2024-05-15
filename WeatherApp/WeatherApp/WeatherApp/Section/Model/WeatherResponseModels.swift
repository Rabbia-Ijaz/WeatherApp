//
//  WeatherResponseModels.swift
//  WeatherApp
//
//  Created by Rabbia Ijaz on 30/04/2024.
//

import Foundation

// Main model representing the entire response
class WeatherResponse: Codable {
    var coord: Coord?
    var main: Main?
    var name: String?
    var date: String?
    
    init() {
        name = ""
        coord = Coord()
        main = Main()
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        self.date = dateFormatter.string(from: currentDate)
    }
    
    enum CodingKeys: String, CodingKey {
        case coord, main, name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.coord = try container.decodeIfPresent(Coord.self, forKey: .coord)
        self.main = try container.decodeIfPresent(Main.self, forKey: .main)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        self.date = dateFormatter.string(from: currentDate)
    }
}

class Coord: Codable {
    var lon: Double?
    var lat: Double?
    
    init() {
        lat = 0
        lon = 0
    }
    
    enum CodingKeys: String, CodingKey {
        case lat, lon
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lat = try container.decodeIfPresent(Double.self, forKey: .lat) ?? 0
        self.lon = try container.decodeIfPresent(Double.self, forKey: .lon) ?? 0
    }
}

class Main: Codable {
    var temp: Double?
    var tempMin: Double?
    var tempMax: Double?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode each property. If the property is missing from the JSON, use a default value of 0.
        self.temp = try container.decodeIfPresent(Double.self, forKey: .temp) ?? 0
        self.tempMin = try container.decodeIfPresent(Double.self, forKey: .tempMin) ?? 0
        self.tempMax = try container.decodeIfPresent(Double.self, forKey: .tempMax) ?? 0
    }
    
    var tempInFahrenheit: Double {
        // Calculate Fahrenheit only when needed using the potentially default Celsius value.
        let fahrenheit = (temp ?? 0) * 9 / 5 + 32
        return (fahrenheit * 100).rounded() / 100
    }
    
    init() {
        temp = 0
        tempMax = 0
        tempMin = 0
    }
}
