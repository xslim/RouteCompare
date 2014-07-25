//
//  RunViewController.swift
//  RouteCompare
//
//  Created by Taras Kalapun on 24/07/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class RunViewController: UIViewController, LocatorDelegate, MKMapViewDelegate {
    var route:Route?
    var run:Run?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var barHhaderView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subheaderLabel: UILabel!
    
    var isNewRun = true
    var mapZoomedOnArea = false
    var mapHasUserInteraction = false
    var userInteractionActive = false
    var userInteractionTimer:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if self.route && !self.run {
            self.run = Run.createInRoute(self.route!)
            DB.shared.save()
            
            //NSLog("Created run \(self.run) in route \(self.route)")
            
            startRecording()
        } else if (self.run) {
            self.route = self.run?.route
            
            dumpRun(self.run!)
            
            stopRecording()
            mapRun()
        }
        
        self.barHhaderView.frame = CGRectMake(0, 0, 200, 40);
        
        let gr = WildcardGestureRecognizer(target: self, action: "userInteractedWithMap")
        self.mapView.addGestureRecognizer(gr)
        
        self.mapView.showsUserLocation = Locator.shared.isAuthorized
        
    }
    
    override func viewWillDisappear(animated: Bool)  {
        super.viewWillDisappear(animated)
        self.userInteractionTimer?.invalidate()
    }
    
    func configureNavBar() {
        if self.isNewRun {
            self.navigationItem.hidesBackButton = true
            //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Stop Recording", style: .Plain, target: self, action: "stopRecording")
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "stopRecording")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelRecording")
        } else {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.hidesBackButton = false
        }
    }
    
    func startRecording() {
        self.isNewRun = true
        configureNavBar()
        Locator.shared.delegate = self
        Locator.shared.record()
        
    }
    
    func stopRecording() {
        var l = Locator.shared
        l.stop()
        l.delegate = nil
        self.isNewRun = false
        configureNavBar()
        
        if (l.recordedCoordinates.count > 1) {
            self.run!.distance = l.recordedDistance
            self.run!.coordinates = l.recordedCoordinates
            self.run!.speed = l.recordedSpeed
            self.run!.time = l.recordedTime
            self.run!.date = l.recordStartedAt!
            DB.shared.save()
            
            dumpRun(self.run!)
            mapRun()
        } else {
            Alerter.UIAlert("Nothing recorded", msg: "Record will be deleted")
            self.cancelRecording()
        }
        
        
    }
    
    func cancelRecording() {
        Locator.shared.stop()
        Locator.shared.delegate = nil
        Locator.shared.reset()
        self.isNewRun = false
        configureNavBar()
        
        DB.shared.deleteObject(self.run!)
        self.navigationController.popViewControllerAnimated(true)
    }
    
    func userInteractedWithMap() {
        self.userInteractionActive = true
        self.mapHasUserInteraction = true
        if !self.userInteractionTimer {
            self.userInteractionTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "userInteractionUpdate", userInfo: nil, repeats: true)
        }
    }
    
    func userInteractionUpdate() {
        if self.userInteractionActive {
            self.userInteractionActive = false
        } else {
            self.userInteractionTimer?.invalidate()
            self.userInteractionTimer = nil
            self.mapHasUserInteraction = false
        }
    }
    
    func dumpRun(run:Run) {
        //dump(run.coordinates)
    }
    
    func mapLine(line:MKPolyline) {
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.addOverlay(line)
        
        if !self.mapHasUserInteraction {        
            self.mapZoomedOnArea = true
            let rect = line.boundingMapRect
            self.mapView.setVisibleMapRect(rect, animated: true)
        }
    }
    
    func updateViewWithData(#line:MKPolyline, distance:Double = 0.0, time:Double = 0.0, speed:Double = 0.0) {
        mapLine(line)
        self.headerLabel.text = NSString(format: "%.2f m", distance)
        self.subheaderLabel.text = NSString(format: "%.2f min, %.2f m/s", time/60, speed)
    }
    
    func mapRun() {
        var run = self.run!
//        let coordinates = self.run!.coordinates
        var coordinates = self.run!.coordinates.map({
            (c:CLLocationCoordinate2D) -> CLLocationCoordinate2D in
            return c
            })
        
        var line = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        updateViewWithData(line: line, distance: run.distance, time: run.time, speed: run.speed)
        
        //var region = MKCoordinateRegionMakeWithDistance(coordinates[0], 500, 500)
        //mapView.setRegion(region, animated: true)
    }
    
    func mapRecording() {
        
        var l = Locator.shared
        
        var coordinates = l.recordedCoordinates.map({
            (c:CLLocationCoordinate2D) -> CLLocationCoordinate2D in
            return c
            })
        var line = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        updateViewWithData(line: line, distance: l.recordedDistance, time: l.recordedTime, speed: l.recordedSpeed)
        
        //var region = MKCoordinateRegionMakeWithDistance(coordinates[0], 500, 500)
        //mapView.setRegion(region, animated: true)
    }
    
    func locatorRecordedLocation(locator: Locator, location: CLLocation) {
        //NSLog("incoming location \(location)")
        mapRecording()
    }
    
    func locatorAuthorized(locator: Locator, authorized: Bool)  {
        if authorized {
            self.mapView.showsUserLocation = true
        }
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        if !self.mapZoomedOnArea {
            var region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500)
            mapView.setRegion(region, animated: true)
            self.mapZoomedOnArea = true
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if (overlay.isKindOfClass(MKPolyline)) {
            let line = overlay as MKPolyline
            var renderer = MKPolylineRenderer(polyline: line)
            renderer.strokeColor = UIColor.redColor()
            renderer.lineWidth = 2.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    //func mapView(mapView: MKMapView!, viewForOverlay overlay: MKOverlay!) -> MKOverlayView!
}
