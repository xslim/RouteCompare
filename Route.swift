//
//  Route.swift
//  RouteCompare
//
//  Created by Taras Kalapun on 24/07/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import Foundation
import CoreData

//@objc(Route)
class Route: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var dateAdded: NSDate
    @NSManaged var runs: NSOrderedSet

    
    class func createWithName(name: String) -> Route {
        let obj = NSEntityDescription.insertNewObjectForEntityForName("Route", inManagedObjectContext: DB.shared.moc) as Route
        obj.dateAdded = NSDate()
        if name.isEmpty {
            obj.name = obj.dateAdded.description
        } else {
            obj.name = name
        }
        
        return obj
    }
    
}
