//
//  CompareViewController.swift
//  RouteCompare
//
//  Created by Taras Kalapun on 23/07/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CompareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var route:Route?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.route {
            performFetchAndReload(false)
            
            if self.fetchedResultsController.fetchedObjects.count == 0 {
                //  let delay = 0.5 * Double(NSEC_PER_SEC)
                //  let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                //  dispatch_after(time, dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("newRun", sender: self)
                //  })
                
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    

    lazy var fetchedResultsController: NSFetchedResultsController = {
        var fetch: NSFetchRequest = NSFetchRequest(entityName: "Run")
        fetch.predicate = NSPredicate(format: "route = %@", self.route!)
        fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        var frc: NSFetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetch,
            managedObjectContext: DB.shared.moc,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
        }()
    
    func performFetchAndReload(reload: Bool) {
        var moc = fetchedResultsController.managedObjectContext
        
        moc.performBlockAndWait {
            var error: NSErrorPointer = nil
            if !self.fetchedResultsController.performFetch(error) {
                println("\(error)")
            }
            
            if reload {
                self.tableView.reloadData()
            }
        }
    }
    
    func updateCell(cell: UITableViewCell, object: Run) {
        cell.textLabel.text = object.date.description
        cell.detailTextLabel.text = NSString(format: "%.2f m, %.2f min, %.2f m/s", object.distance, object.time/60, object.speed)
    }
    
    // MARK - Actions
    
    @IBAction func addAction(sender: AnyObject) {
    }
    
    @IBAction func segmentChangedAction(sender: UISegmentedControl) {
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        switch segue.identifier! {
        case "showRun":
            let indexPath = self.tableView.indexPathForSelectedRow()
            var vc = segue.destinationViewController as RunViewController
            vc.run = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Run
            vc.route = self.route
        case "newRun":
            var vc = segue.destinationViewController as RunViewController
            vc.route = self.route
            
        default:()
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return fetchedResultsController.sections.count
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections[section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell...
        var item: Run = fetchedResultsController.objectAtIndexPath(indexPath) as Run
        updateCell(cell, object: item)
        
        return cell
    }
    
    //    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    //    {
    //        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
    //
    //        // TODO: push VC w/ selected item
    //
    //        self.storyboard
    //    }
    
    
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            let item = fetchedResultsController.objectAtIndexPath(indexPath) as Run
            DB.shared.deleteObject(item)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            //performFetchAndReload(true)
        }
    }
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {
    
    }
    */
    
    
    // Override to support conditional rearranging of the table view.
    func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return false
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: NSFetchedResultsController
    
    func controllerWillChangeContent(controller: NSFetchedResultsController!) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController!, didChangeSection sectionInfo: NSFetchedResultsSectionInfo!, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        if type == .Insert {
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
        }
        else if type == .Delete {
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController!, didChangeObject anObject: AnyObject!, atIndexPath indexPath: NSIndexPath!, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath!) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Update:
            updateCell(tableView.cellForRowAtIndexPath(indexPath), object: anObject as Run)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        default:
            println("unhandled didChangeObject update type \(type)")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        tableView.endUpdates()
    }
    
    // MARK: - Map
    
    

}
