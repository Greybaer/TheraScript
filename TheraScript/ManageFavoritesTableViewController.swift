//
//  ManageFavoritesTableViewController.swift
//  TheraScript
//
//  Created by Greybear on 10/15/15.
//  Copyright © 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit
import CoreData



class ManageFavoritesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    //Outlets
    @IBOutlet weak var favoritesTable: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var removeButton: UIBarButtonItem!
    
    //Indexes for operations using NSFetchController
    var insertedIndexPath: NSIndexPath!
    var deletedIndexPath: NSIndexPath!
    var updatedIndexPath: NSIndexPath!

    
    //Shorthand for the CoreData context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Pre-fetch the data
        do{
            try TSClient.sharedInstance().fetchedResultsController.performFetch()
        }catch{
            TSClient.sharedInstance().errorDialog(self, errTitle: "Data Load Failed", action: "OK", errMsg: "Unable to load favorites")
        }//try/catch

        //We're our own delegate
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        TSClient.sharedInstance().fetchedResultsController.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //Hide the toolbar here
        self.navigationController?.toolbarHidden = false
        
        //Force a reload
        self.favoritesTable.reloadData()
        
    }
    
    //***************************************************
    // Delegate Methods
    //***************************************************
    
    //TableView Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TSClient.sharedInstance().fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return TSClient.sharedInstance().practices.count
        let sectionInfo = TSClient.sharedInstance().fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }//numberOfRows
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PTCell") as UITableViewCell!
        
        //let practice = TSClient.sharedInstance().practices[indexPath.row]
        //FetchController way
        let practice = TSClient.sharedInstance().fetchedResultsController.objectAtIndexPath(indexPath) as! PTPractice
        cell.textLabel?.text = practice.name
        cell.detailTextLabel?.text = practice.address
        
        return cell
    }//cellForRow
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        //Editing entries opens a can of worms I'm not willing to deal with, so selecting is not useful
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }//didSelect
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //In delete mode?
        if editingStyle == UITableViewCellEditingStyle.Delete{
            //println("Before removal: \(TSClient.sharedInstance().practices)")
            //Remove it from CoreData
            sharedContext.deleteObject(TSClient.sharedInstance().practices[indexPath.row])
            //Remove from the local array
            //TSClient.sharedInstance().practices.removeAtIndex(indexPath.row)
            //println("After removal: \(TSClient.sharedInstance().practices)")
            //Save the context, which should do the trick for CoreData
            dispatch_async(dispatch_get_main_queue()) {
                CoreDataStackManager.sharedInstance().saveContext()
            }
            //Reset the button
            favoritesTable.setEditing(false, animated: true)
            removeButton.title = "Remove"
            //And reload the data
            //tableView.reloadData()
        }//delete
    }
    
    //FetchController Delegate
    //***************************************************
    // Content is going to change
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.favoritesTable.beginUpdates()
    }//controllerWillChangeContent

    
    //***************************************************
    //Changed a cell
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type{
        case .Insert:
            //println("Item added")
            if let insertedIndexPath = newIndexPath{
                self.favoritesTable.insertRowsAtIndexPaths([insertedIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        //case .Update:
            //println("Item updated")
            //updatedIndexPaths.append(indexPath!)
            //break
        case .Delete:
            //println("Item deleted")
            if let deletedIndexPath = indexPath{
                self.favoritesTable.deleteRowsAtIndexPaths([deletedIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        default:
            break
        }//switch
    }//didChangeObject
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
         self.favoritesTable.endUpdates()
    }
    //***************************************************
    // Action Methods
    //***************************************************
    
    //***************************************************
    // Add therapy practices to favorites
    @IBAction func addFavorite(sender: AnyObject) {
        let PTVC = self.storyboard?.instantiateViewControllerWithIdentifier("AddFavoriteViewController") as! AddFavoriteViewController
        self.navigationController?.pushViewController(PTVC
            , animated: true)
    }//addFavorites

    //***************************************************
    //editFavorites - Remove entries from favorites
    //TODO - Implement favorite removal
    
    @IBAction func editFavorites(sender: AnyObject) {
        //Check the button to determine what we're doing
        if removeButton.title == "Remove"{
            //Set editing on
            favoritesTable.setEditing(true, animated: true)
            removeButton.title = "Done"
        }else{
            //Set editing off
            favoritesTable.setEditing(false, animated: true)
            removeButton.title = "Remove"
        }
    }//editFavorites
    
}//class
