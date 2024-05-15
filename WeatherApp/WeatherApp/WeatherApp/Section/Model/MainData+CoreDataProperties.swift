//
//  MainData+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Rabbia Ijaz on 04/05/2024.
//
//

import Foundation
import CoreData


extension MainData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MainData> {
        return NSFetchRequest<MainData>(entityName: "MainData")
    }

    @NSManaged public var temp: Double
    @NSManaged public var tempInFahrenheit: Double
    @NSManaged public var tempMax: Double
    @NSManaged public var tempMin: Double

}

extension MainData : Identifiable {

}
