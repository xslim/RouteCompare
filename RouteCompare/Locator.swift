//
//  Locator.swift
//  RouteCompare
//
//  Created by Taras Kalapun on 24/07/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

@objc protocol LocatorDelegate : NSObjectProtocol {
    
    optional func locatorRecordedLocation(locator: Locator, location: CLLocation)
    optional func locatorAuthorized(locator: Locator, authorized: Bool)
}

@objc class Locator : NSObject, CLLocationManagerDelegate {
    
    class var shared : Locator {
    struct Static {
        static let instance : Locator = Locator()
        }
        return Static.instance
    }
    
    lazy var locationManager:CLLocationManager = {
        var manager = CLLocationManager()
        manager.delegate = self
        manager.activityType = .Fitness
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.disallowDeferredLocationUpdates()
        
        return manager;
    }()
    
    var desiredAccuracy = 20.0
    var delegate: LocatorDelegate?
    
    var recordingInProgress = false
    var recordedLocations : [CLLocation] = []
    var recordedCoordinates : [CLLocationCoordinate2D] = []
    var recordedDistance : CLLocationDistance = 0.0
    var recordStartedAt : NSDate?
    var recordedTime : NSTimeInterval = 0.0
    var recordedSpeed : CLLocationSpeed = 0.0
    
    var defersLocationUpdates = false
    
    var nLocations:Int {
        return self.recordedLocations.count
    }
    
//    var isAuthorized:Bool {
//        return (self.locationManager.authorizationStatus() == 
//    }
    
    // Location Manager helper stuff
    func record() {
        self.reset()
        self.locationManager.requestAlwaysAuthorization()
        self.recordingInProgress = true
        self.locationManager.startUpdatingLocation()
    }
    
    func stop() {
        self.recordingInProgress = false
        self.locationManager.stopUpdatingLocation()
        self.defersLocationUpdates = false
        self.locationManager.disallowDeferredLocationUpdates()
    }
    
    func reset() {
        self.recordedLocations = []
        self.recordedCoordinates = []
        self.recordedDistance = 0.0
        self.recordedTime = 0.0
        self.recordedSpeed = 0.0
        self.recordStartedAt = nil
    }
    
    // Location Manager Delegate stuff
    // If failed
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        Alerter.UIAlert("Location", msg: "Error getting location")
    }
    // if success
    // Assumptions: locations is an array, locationObj is a CLLocation
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if !self.recordingInProgress {
            return
        }
        
        for location in locations as [CLLocation] {
            
            //NSLog("incoming location \(location)")
            if location.horizontalAccuracy > self.desiredAccuracy {
                //NSLog("Bad accuracy for \(location)")
                continue
            }
            
            if !self.recordStartedAt {
                self.recordStartedAt = location.timestamp
            }
            self.recordedTime = NSDate().timeIntervalSinceDate(self.recordStartedAt!)
            
            // First, calculate distance
            if self.recordedCoordinates.count > 0 {
                self.recordedDistance += location.distanceFromLocation(self.recordedLocations.last)
            }
            
            if (self.recordedCoordinates.count > 1 && self.recordedDistance > 0 && self.recordedTime > 0) {
                self.recordedSpeed = self.recordedDistance / self.recordedTime
            }
        
            // Then add a new location to array
            self.recordedLocations += location
            self.recordedCoordinates += location.coordinate
            
            delegate?.locatorRecordedLocation!(self, location: location)
        }
        
        if (!self.defersLocationUpdates && CLLocationManager.deferredLocationUpdatesAvailable()) {
            self.defersLocationUpdates = true
            locationManager.allowDeferredLocationUpdatesUntilTraveled(100000, timeout: 10000)
        }
    }
    
    var isAuthorized:Bool {
        let enabled = CLLocationManager.locationServicesEnabled()
        let status = CLLocationManager.authorizationStatus()
        NSLog("Enabled: \(enabled), status: \(status)")
    
        return locationManagerIsAuthorized(status)
    }
    
    func locationManagerIsAuthorized(status: CLAuthorizationStatus) -> Bool {
        switch status {
        case .Restricted:
            return false
        case .Denied:
            return false
        case .NotDetermined:
            return false
        default:
            return true
        }
    }
    
    // authorization status
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if locationManagerIsAuthorized(status) {
            delegate?.locatorAuthorized!(self, authorized: true)
            locationManager.startUpdatingLocation()
        } else {
            delegate?.locatorAuthorized!(self, authorized: false)
        }
//            var shouldIAllow = false
//            var locationStatus = ""
//            
//            switch status {
//            case .Restricted:
//                locationStatus = "Restricted Access"
//            case .Denied:
//                locationStatus = "User denied access"
//            case .NotDetermined:
//                locationStatus = "Status not determined"
//            default:
//                locationStatus = "Allowed Access"
//                shouldIAllow = true
//            }
//            
//            if (shouldIAllow == true) {
//                //NSLog("Location Allowed")
//                // Start location services
//                delegate?.locatorAuthorized!(self, authorized: true)
//                locationManager.startUpdatingLocation()
//            } else {
//                NSLog("Denied access: \(locationStatus)")
//                delegate?.locatorAuthorized!(self, authorized: false)
//            }
    }
    
    func locationManager(manager: CLLocationManager!, didFinishDeferredUpdatesWithError error: NSError!) {
        //NSLog("Deferred locations error: \(error)")
        self.defersLocationUpdates = false
    }
    
    // MARK: - Helpers
    
//    class func coordinates2Poligon(coordinates:[CLLocationCoordinate2D]) -> MKPolyline {
//        
//    }
}