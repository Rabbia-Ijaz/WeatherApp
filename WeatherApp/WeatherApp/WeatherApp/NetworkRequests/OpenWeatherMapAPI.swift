//
//  OpenWeatherMapAPI.swift
//  WeatherApp
//
//  Created by Rabbia Ijaz on 29/04/2024.
//

import Foundation

class OpenWeatherMapAPI {
    typealias WeatherCompletionHandler = (Result<WeatherResponse, Error>) -> Void
    
    static let shared = OpenWeatherMapAPI()
    
    private init() {}
    
    // Function to fetch weather data for a specific city
    func fetchWeatherData(forCity city: String, completion: @escaping WeatherCompletionHandler) {
        let apiKey = "841d9e1ece38b5033002efc6579f293b"
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(.success(weatherData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Function to fetch current weather data using latitude and longitude
    func fetchCurrentWeather(latitude: Double, longitude: Double, completion: @escaping WeatherCompletionHandler) {
        let apiKey = "841d9e1ece38b5033002efc6579f293b"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(.success(weatherData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
