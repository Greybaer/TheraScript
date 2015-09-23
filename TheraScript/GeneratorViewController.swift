//
//  GeneratorViewController.swift
//  TheraScript
//
//  Created by Greybear on 9/22/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit

class GeneratorViewController: UIViewController {
    
    //Variables
    //Provider data struct
    var provider =  TSClient.Provider()
    
    var icon: UIImage?
    
    //The icon size
    var iconSize = CGSizeMake(64.0, 64.0)

    //Outlets
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var providerName: UILabel!
    @IBOutlet weak var providerPractice: UILabel!
    @IBOutlet weak var providerAddress: UILabel!
    @IBOutlet weak var providerAddress2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }//viewDidLoad
    
    override func viewWillAppear(animated: Bool) {
        //Add a settings button to the nav bar
        var settingsButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = settingsButton
        
        //Load the provder data as we start up
        provider = TSClient.sharedInstance().getProviderInfo()
        
        //And the image
        icon = TSClient.Cache.imageCache.imageWithIdentifier(TSClient.Constants.userLogo)
        //We *should* always have info to get here, but just in case...
        //Empty field = no info
        if provider.firstName.isEmpty{
            //Pop an error dialog
            TSClient.sharedInstance().errorDialog(self, errTitle: "No Provider", action: "OK", errMsg: "Please set up provider information")
            //and return to the base screen
            self.navigationController?.popToRootViewControllerAnimated(true)
        }else{
            //Populate the provider header
            iconImage.image = TSClient.sharedInstance().createIcon(icon!, size: iconSize)
            
            providerName.text = "\(provider.firstName) \(provider.middleName) \(provider.lastName) \(provider.degreeType)"
            providerPractice.text = provider.practiceName
            providerAddress.text = "\(provider.streetAddress)"
            providerAddress2.text = "\(provider.cityName) \(provider.stateName) \(provider.zipCode) ・ \(provider.phoneNumber)"
        }//if

    }//viewWillAppear
}//class

