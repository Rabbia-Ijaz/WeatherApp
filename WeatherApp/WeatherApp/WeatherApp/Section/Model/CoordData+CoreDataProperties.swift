//
//  CoordData+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Rabbia Ijaz on 04/05/2024.
//
//

import Foundation
import CoreData


extension CoordData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoordData> {
        return NSFetchRequest<CoordData>(entityName: "CoordData")
    }

    @NSManaged public var lat: Double
    @NSManaged public var lon: Double

}

extension CoordData : Identifiable {

}
