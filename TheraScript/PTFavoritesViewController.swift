//
//  PTFavoritesViewController.swift
//  TheraScript
//
//  Created by Greybear on 9/1/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit
import CoreData

class PTFavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //Outlets
    @IBOutlet weak var favoritesTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Add a completion button to the nav bar
        //Has to be done here because tabs don't reload on navigation between views
        
        var editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editFavorites")
        self.tabBarController!.navigationItem.rightBarButtonItem = editButton
        
        //Set the title of the view
        self.tabBarController!.navigationItem.title = "Favorite Practices"
        
        //We're our own delegate
        favoritesTable.delegate = self
        favoritesTable.dataSource = self

    }
    
    override func viewWillAppear(animated: Bool) {
        //Hide the toolbar here
        self.navigationController?.toolbarHidden = true
        self.favoritesTable.reloadData()

   }

    //***************************************************
    // Delegate Methods
    //***************************************************
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TSClient.sharedInstance().practices.count
    }//numberOfRows
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PTCell") as! UITableViewCell
        
        let practice = TSClient.sharedInstance().practices[indexPath.row]
        
        cell.textLabel?.text = practice.name
        cell.detailTextLabel?.text = practice.address
        
        return cell
    }//cellForRow
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Selected cell")
        
        //Get the practice info for the row chosen
        var practice = TSClient.sharedInstance().practices[indexPath.row]
        
        //Grab the data for display. It's already saved, so no dialog and no Core Data save
        TSClient.sharedInstance().therapy.practiceName = practice.name
        TSClient.sharedInstance().therapy.practiceAddress = practice.address
        TSClient.sharedInstance().therapy.practicePhone = practice.phone
        
        //And pop back to the RX controller
        self.navigationController?.popToRootViewControllerAnimated(true)
    }//didSelect
    
    //***************************************************
    // Action Methods
    //***************************************************

    //***************************************************
    //editFavorites - Remove entries from favorites
    func editFavorites(){
            //Check the button to determine what we're doing
            if self.tabBarController!.navigationItem.rightBarButtonItem?.title == "Edit"{
                //Set editing on
                favoritesTable.setEditing(true, animated: true)
                self.tabBarController!.navigationItem.rightBarButtonItem?.title = "Done"
            }else{
                //Set editing off
                favoritesTable.setEditing(false, animated: true)
                self.tabBarController!.navigationItem.rightBarButtonItem?.title = "Edit"
            }

    }//editFavorites
    
}//class

