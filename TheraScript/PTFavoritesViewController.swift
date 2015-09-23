//
//  PTFavoritesViewController.swift
//  TheraScript
//
//  Created by Greybear on 9/1/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit

class PTFavoritesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //Add a completion button to the nav bar
        //Has to be done here because tabs don't reload on navigation between views
        
        var acceptButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editFavorites")
        self.tabBarController!.navigationItem.rightBarButtonItem = acceptButton
        
        //Set the title of the view
        self.tabBarController!.navigationItem.title = "Favorite Practices"

    }
    
    override func viewWillAppear(animated: Bool) {
        //Hide the toolbar here
        self.navigationController?.toolbarHidden = true
    }

}//class

