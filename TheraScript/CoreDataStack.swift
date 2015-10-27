//***************************************************
//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Greybear on 6/2/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//
//  Adapted an modified from Jason's CoreDataStack File
//  used in Udacity's Core Data Training Module
//
// This will be my standard Core Data Stack code
// for all future app projects
//***************************************************


import Foundation
import CoreData

//***************************************************
// Declare the database and model names here so 
// they are easy to change for future projects
//***************************************************

// This is usually SQL, but may be XML or something else so make
// the handle a bit more generic
private let FILENAME = "TheraScript.sqlite"

// The name for the model file. Usually matches the filename
private let MODELNAME = "TheraScript"


//***************************************************
// Create the stack in a class to provide easy access
//***************************************************

class CoreDataStackManager{
    
    //class variable to return a shared instance of the Stack
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
        return Static.instance
    }//sharedInstance()
    
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.infiniteloop-slc.TheraScript" in the application's documents Application Support directory
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()//applicationDocumentsDirectory
    
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(MODELNAME, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()//managedObjectModel
    
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(FILENAME)
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "com.infiniteloop-slc.ErrorDomain", code: 9999, userInfo: dict)
            // NOTE: a graceful alertview here would be nice.
            
            // abort() causes the application to generate a crash log and terminate. 
            // Retained for development - REMOVE FOR SHIPPING APPS!!!
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        return coordinator
        }()//persistentStoreCoordinator
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()//managedObjectContext
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // NOTE: a graceful alertview here would be nice.

                    // abort() causes the application to generate a crash log and terminate. 
                    // Retained for development - REMOVE FOR SHIPPING APPS!!!
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }//saveContext
}//CoreData class