//
//  Weather+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Rabbia Ijaz on 04/05/2024.
//
//

import Foundation
import CoreData


extension Weather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Weather> {
        return NSFetchRequest<Weather>(entityName: "Weather")
    }

    @NSManaged public var date: String?
    @NSManaged public var name: String?
    @NSManaged public var coord: CoordData?
    @NSManaged public var main: MainData?

}

extension Weather : Identifiable {

}
