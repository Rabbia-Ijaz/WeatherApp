//
//  MainViewModel.swift
//  WeatherApp
//
//  Created by Rabbia Ijaz on 30/04/2024.
//

import Foundation
import UIKit
import CoreData

class MainViewModel: NSObject {
    var resultsList:[WeatherResponse] = []
    var weatherResponse: WeatherResponse?
    var backgroundColor: UIColor?
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override init() {
        super.init()
    }
    
    
    
    func fetchWeather(forCity city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        OpenWeatherMapAPI.shared.fetchWeatherData(forCity: city) { result in
            switch result {
            case .success(let weatherData):
                if let _ = weatherData.name {
                    self.weatherResponse = weatherData
                    self.setBackgroundColor()
                    
                    self.convertAndSave(weatherData: weatherData)
                    self.resultsList = self.fetchAllWeather()
                }
//                self.batchDelete()
                completion(.success(weatherData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchWeatherForCurrentLocation(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        OpenWeatherMapAPI.shared.fetchCurrentWeather(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let weatherData):
                if let _ = weatherData.name {
                    self.weatherResponse = weatherData
                    self.setBackgroundColor()
                    
                    self.convertAndSave(weatherData: weatherData)
                    self.resultsList = self.fetchAllWeather()
                }
//                self.batchDelete()
                completion(.success(weatherData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func setBackgroundColor() {
        if weatherResponse?.main?.temp ?? 0 < 10 {
            backgroundColor = UIColor(red: 0.00, green: 0.65, blue: 0.86, alpha: 1.00)
        } else if weatherResponse?.main?.temp ?? 0 >= 10 && weatherResponse?.main?.temp ?? 0 <= 25 {
            backgroundColor = UIColor(red: 1.00, green: 0.53, blue: 0.22, alpha: 1.00)
        } else {
            backgroundColor = UIColor(red: 1.00, green: 0.14, blue: 0.14, alpha: 1.00)
        }
    }
    
    func convertAndSave(weatherData: WeatherResponse) {
        let weatherEntity = Weather(context: context)
        weatherEntity.name = weatherData.name
        weatherEntity.date = weatherData.date
        
        if let coord = weatherData.coord {
            let coordEntity = CoordData(context: context)
            coordEntity.lat = coord.lat ?? 0
            coordEntity.lon = coord.lon ?? 0
            weatherEntity.coord = coordEntity
        }
        
        if let main = weatherData.main {
            let mainEntity = MainData(context: context)
            mainEntity.temp = main.temp ?? 0
            mainEntity.tempMin = main.tempMin ?? 0
            mainEntity.tempMax = main.tempMax ?? 0
            mainEntity.tempInFahrenheit = main.tempInFahrenheit
            weatherEntity.main = mainEntity
        }
        
        do {
            try context.save()
            print("Saved successfully!")
        } catch {
            print("Failed to save data: \(error)")
        }
    }
    
    func fetchAllWeather() -> [WeatherResponse] {
        let request: NSFetchRequest<Weather> = Weather.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results.reversed().map { weather in
                // Convert each Weather NSManagedObject back into a WeatherResponse (simplified)
                return convertToWeatherResponse(weather) ?? WeatherResponse()
            }
        } catch {
            print("Failed to fetch weather data: \(error)")
            return []
        }
    }

    func convertToWeatherResponse(_ weather: Weather) -> WeatherResponse? {
        guard let name = weather.name, let date = weather.date else {
        return nil
    }
        
        var coord: Coord? = nil
        if let weatherCoord = weather.coord {
            coord = Coord()
            coord?.lat = weatherCoord.lat
            coord?.lon = weatherCoord.lon
        }
        
        var main: Main? = nil
        if let weatherMain = weather.main {
            main = Main()
            main?.temp = weatherMain.temp
            main?.tempMax = weatherMain.tempMax
            main?.tempMin = weatherMain.tempMin
        }
        
        var weatherResponse = WeatherResponse()
        weatherResponse.main = main
        weatherResponse.coord = coord
        weatherResponse.name = name
        weatherResponse.date = date
        return weatherResponse
    }


    func batchDelete() {
        let fetchRequest: NSFetchRequest<Weather> = Weather.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)

        do {
            try context.execute(batchDeleteRequest)
            try context.save()
        } catch let error as NSError {
            print("Error during batch deletion: \(error), \(error.userInfo)")
        }
    }
}
