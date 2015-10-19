//
//  ManageFavoritesTableViewController.swift
//  TheraScript
//
//  Created by Greybear on 10/15/15.
//  Copyright © 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit
import CoreData



class ManageFavoritesTableViewController: UITableViewController {
    //Outlets
    @IBOutlet weak var favoritesTable: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var removeButton: UIBarButtonItem!
    
    //Shorthand for the CoreData context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Display an add and a remove button
        //let addButton = UIBarButtonItem(image: UIImage(named: "add"), style: UIBarButtonItemStyle.Plain, target: self, action: "addFavorite")
        //UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addFavorite")
        //let removeButton = UIBarButtonItem(image: UIImage(named: "remove"), style: UIBarButtonItemStyle.Plain, target: self, action: "editFavorites")
        //UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "editFavorites")
        //self.navigationController?.
        // navigationItem.setRightBarButtonItems([addButton, removeButton], animated: true)
        
        
        //We're our own delegate
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //Hide the toolbar here
        self.navigationController?.toolbarHidden = false
        self.favoritesTable.reloadData()
        
    }
    
    //***************************************************
    // Delegate Methods
    //***************************************************
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println("Table Rows: \(TSClient.sharedInstance().practices.count)")
        return TSClient.sharedInstance().practices.count
    }//numberOfRows
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PTCell") as UITableViewCell!
        
        let practice = TSClient.sharedInstance().practices[indexPath.row]
        
        cell.textLabel?.text = practice.name
        cell.detailTextLabel?.text = practice.address
        
        return cell
    }//cellForRow
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        //Selecting an entry should probably let you edit it
/*
        //println("Selected cell")
        
        //Get the practice info for the row chosen
        let practice = TSClient.sharedInstance().practices[indexPath.row]
        
        //Grab the data for display. It's already saved, so no dialog and no Core Data save
        TSClient.sharedInstance().therapy.practiceName = practice.name
        TSClient.sharedInstance().therapy.practiceAddress = practice.address
        TSClient.sharedInstance().therapy.practicePhone = practice.phone
        
        //And pop back to the RX controller
        self.navigationController?.popToRootViewControllerAnimated(true)
*/
    }//didSelect
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //In delete mode?
        if editingStyle == UITableViewCellEditingStyle.Delete{
            //println("Before removal: \(TSClient.sharedInstance().practices)")
            //Remove it from CoreData
            sharedContext.deleteObject(TSClient.sharedInstance().practices[indexPath.row])
            //Remove from the local array
            TSClient.sharedInstance().practices.removeAtIndex(indexPath.row)
            //println("After removal: \(TSClient.sharedInstance().practices)")
            //Save the context, which should do the trick for CoreData
            CoreDataStackManager.sharedInstance().saveContext()
            //Reset the button
            favoritesTable.setEditing(false, animated: true)
            removeButton.title = "Remove"
            //And reload the data
            tableView.reloadData()
        }//delete
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
