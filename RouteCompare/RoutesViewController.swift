//
//  RoutesViewController.swift
//  RouteCompare
//
//  Created by Taras Kalapun on 23/07/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import UIKit
import CoreData

class RoutesViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var newRoute:Route?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        performFetchAndReload(false)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.newRoute = nil
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        var fetch: NSFetchRequest = NSFetchRequest(entityName: "Route")
        fetch.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: true)]
        
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
    
    func updateCell(cell: UITableViewCell, object: Route) {
        cell.textLabel.text = object.name
        cell.detailTextLabel.text = object.dateAdded.description
    }

    
    func createNewRoute(name:String) {
        self.newRoute = Route.createWithName(name)
        DB.shared.save()
        performSegueWithIdentifier("showRuns", sender: self.newRoute)
    }
    
    
    // MARK: - Actions
    
    @IBAction func addAction(sender: AnyObject) {
        var alert = UIAlertController(title: "Create new Route", message: nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ textField in
            textField.placeholder = "Route Name"
            })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel){_ in})
        alert.addAction(UIAlertAction(title: "Create", style: .Default){action in
            let textf = alert.textFields[0] as UITextField
            self.createNewRoute(textf.text)
            })
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        switch segue.identifier! {
            case "showRuns":
                var vc = segue.destinationViewController as CompareViewController
                if (self.newRoute) {
                    vc.route = self.newRoute
                } else {
                    let indexPath = self.tableView.indexPathForSelectedRow()
                    vc.route = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Route
                }
            
            case "newRun":
                
                var vc = segue.destinationViewController as CompareViewController
//                vc0.route = self.newRoute
//                self.navigationController.pushViewController(vc0, animated: false)
//                
//                var vc = segue.destinationViewController as RunViewController
                vc.route = self.newRoute
            
            default:()
        }
    }
    
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return fetchedResultsController.sections.count
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections[section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        var item: Route = fetchedResultsController.objectAtIndexPath(indexPath) as Route
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
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            let item = fetchedResultsController.objectAtIndexPath(indexPath) as Route
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
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return false
    }
    
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
            updateCell(tableView.cellForRowAtIndexPath(indexPath), object: anObject as Route)
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

}
