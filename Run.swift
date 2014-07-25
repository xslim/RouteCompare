//
//  Run.swift
//  RouteCompare
//
//  Created by Taras Kalapun on 24/07/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

//@objc(Run)
class Run: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var points: [NSString]?
    @NSManaged var route: Route
    @NSManaged var distance: Double
    @NSManaged var time: Double
    @NSManaged var speed: Double
    
    class func createInRoute(route:Route) -> Run {
        let obj = NSEntityDescription.insertNewObjectForEntityForName("Run", inManagedObjectContext: DB.shared.moc) as Run
        obj.route = route
        obj.date = NSDate()
        
        return obj
    }
    
    var coordinates:[CLLocationCoordinate2D] {
    get {
        var ca : [CLLocationCoordinate2D] = []
        if self.points {
            if self.points!.count == 0 {
                return ca
            }
            for s in self.points! {
                let sca = s.componentsSeparatedByString(",")
                ca += CLLocationCoordinate2DMake(sca[0].doubleValue, sca[1].doubleValue)
            }
        }
        
        return ca
    }
    set {
        var sa : [NSString] = []
        for coordinate in newValue {
            sa += "\(coordinate.latitude),\(coordinate.longitude)"
        }
        if (sa.count > 1) {
            self.points = sa
        }
        
    }
    }
}
