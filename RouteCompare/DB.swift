//
//  DB.swift
//  RouteCompare
//
//  Created by Taras Kalapun on 24/07/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import Foundation
import CoreData

class DB {
    
    var dbName : String = "DB"
    
    class var shared : DB {
    struct Static {
        static let instance : DB = DB()
        }
        return Static.instance
    }
    
    init(){
        //super.init()
        
        // all CoreDataHelper share one CoreDataStore defined in AppDelegate
        //let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        //self.store = appDelegate.cdstore
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextDidSaveContext:", name: NSManagedObjectContextDidSaveNotification, object: nil)
    }
    
    deinit{
        save()
        //NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.kalapun.RouteCompare" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let url = NSBundle.mainBundle().URLForResource(self.dbName, withExtension: "momd")
        let mom = NSManagedObjectModel(contentsOfURL: url)
        return mom
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var psc = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.dbName + ".sqlite")
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        let error: NSErrorPointer = nil
        if !psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options, error: error) {
            println("\(error)")
        }
        return psc
        }()
    
    
    // Returns the managed object context for the application.
    // Normally, you can use it to do anything.
    // But for bulk data update, acording to Florian Kugler's blog about core data performance, [Concurrent Core Data Stacks – Performance Shootout](http://floriankugler.com/blog/2013/4/29/concurrent-core-data-stack-performance-shootout) and [Backstage with Nested Managed Object Contexts](http://floriankugler.com/blog/2013/5/11/backstage-with-nested-managed-object-contexts). We should better write data in background context. and read data from main queue context.

    lazy var managedObjectContext: NSManagedObjectContext? = {
        let moc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        moc.undoManager = nil
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator?
        
        return moc
        }()
    
    lazy var moc: NSManagedObjectContext = {
        return self.managedObjectContext!
        }()
    
    
    func save () {
        let moc = self.managedObjectContext!
        
        moc.performBlockAndWait({
            let error: NSErrorPointer = nil
            if moc.hasChanges && !moc.save(error) {
                println("\(error)")
            }
        })
    }
    
    
    func objectWithID(objectID: NSManagedObjectID) -> NSManagedObject {
        return managedObjectContext!.objectWithID(objectID)
    }
    
    func deleteObject(object: NSManagedObject) {
        let moc = self.managedObjectContext!
        moc.performBlockAndWait {
            moc.deleteObject(object)
        }
    }

}