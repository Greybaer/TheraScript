//
//  RxViewController.swift
//  TheraScript
//
//  Created by Greybear on 7/23/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit
import CoreData

class RxViewController: UITableViewController, UITextFieldDelegate {

    //Variables
    //Provider data struct
    var provider =  TSClient.Provider()
    
    var icon: UIImage?
    
    //The icon size
    var iconSize = CGSizeMake(64.0, 64.0)
    
    //Shorthand for the CoreData context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }


    //Outlets
    
    //Provider Info
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var providerName: UILabel!
    @IBOutlet weak var providerPractice: UILabel!
    @IBOutlet weak var providerAddress: UILabel!
    @IBOutlet weak var providerAddress2: UILabel!
    
    //Patient Data
    @IBOutlet weak var ptName: UITextField!
    @IBOutlet weak var ptAddress: UITextField!
    @IBOutlet weak var ptZip: UITextField!
    @IBOutlet weak var ptPhone: UITextField!
    
    //The table view
    @IBOutlet var RxTableView: UITableView!
    
    //Table View selections
    @IBOutlet weak var ptDiagnosis: UITableViewCell!
    @IBOutlet weak var therapyLocation: UITableViewCell!
    @IBOutlet weak var therapyRx: UITableViewCell!
    
    //The prescriptions labels
    @IBOutlet weak var diagnosis: UILabel!
    @IBOutlet weak var therapist: UILabel!
    @IBOutlet weak var prescription: UILabel!
    
    //Outlet for generate button
    @IBOutlet weak var generateRxButton: UIBarButtonItem!
    //And the clear button
    @IBOutlet weak var clearRxButton: UIBarButtonItem!
    //Show Favorites
    @IBOutlet weak var showFavoritesButton: UIBarButtonItem!
    //Will go away
    //Add Favorite button
    @IBOutlet weak var addFavoriteButton: UIBarButtonItem!
    
    //***************************************************
    // Class Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //We're our own textfield delegate
        ptName.delegate = self
        ptAddress.delegate = self
        ptZip.delegate = self
        ptPhone.delegate = self
        
        //Load favorites if saved on disk
        loadFavorites()
    }//viewDidLoad

    override func viewWillAppear(animated: Bool) {
        //Add a settings button to the nav bar
        let settingsButton = UIBarButtonItem(image: UIImage(named:"gear"), style: UIBarButtonItemStyle.Plain, target: self, action: "showSettings")
        navigationItem.rightBarButtonItem = settingsButton
        
        //Load the provder data as we start up
        provider = TSClient.sharedInstance().getProviderInfo()

        //And the image
        icon = TSClient.Cache.imageCache.imageWithIdentifier(TSClient.Constants.userLogo)
        
        //Check to see if we have provider data. If not, we're in setup mode and need to show the Setup sequence
        //Empty field = no info
        if provider.firstName.isEmpty{
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("InfoViewController") as! InfoViewController
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            //Populate the provider header
            iconImage.image = TSClient.sharedInstance().createIcon(icon!, size: iconSize)
            
            providerName.text = "\(provider.firstName) \(provider.middleName) \(provider.lastName) \(provider.degreeType)"
            providerPractice.text = provider.practiceName
            providerAddress.text = "\(provider.streetAddress)"
            providerAddress2.text = "\(provider.cityName) \(provider.stateName) \(provider.zipCode) ・ \(provider.phoneNumber)"
        }//providerName.isEmpty
        
        //Set an accessory arrow for the tableview cells
        ptDiagnosis.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        therapyLocation.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        therapyRx.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        //deliveryMethod.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
               
        //Check the diagnosis list and display them if present
        if TSClient.sharedInstance().dxList.count > 0{
            var dxText: String = ""
            for var i = 0; i < TSClient.sharedInstance().dxList.count; ++i{
                dxText = dxText + TSClient.sharedInstance().dxList[i].icdCode + "  "
            }//for
            //Display the result
            self.diagnosis.text = dxText
        }//if
        
        //Check therapy struct, if there is data use the practice name to fill in the field
        if !TSClient.sharedInstance().therapy.practiceName.isEmpty{
            self.therapist.text = TSClient.sharedInstance().therapy.practiceName
        }//if
        //Check to see if the user modified the Therapy Prescription
        if TSClient.sharedInstance().prescription.rxSelected{
            self.therapyRx.detailTextLabel?.text = "Selected"
        }
        
        //Show the toolbar here
        self.navigationController?.toolbarHidden = false        
    }//viewWillAppear
    
    //***************************************************
    // Delegate Methods
    //***************************************************
    
    //Because this is a custom table with constant values, I'm doing everything manually.
    
    //If this is omitted, it screws up touch recognition
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9   //The total number of table rows in the view
        
    }//numberOfRows in Section
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Get the selected cell
        let cell = RxTableView.cellForRowAtIndexPath(indexPath)
        
        //Process the required action
        if cell == ptDiagnosis{
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("DxViewController") as UIViewController!
            controller.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
            self.navigationController?.pushViewController(controller, animated: true)
            //self.navigationController?.presentViewController(controller, animated: true, completion: nil)
        }else if cell == therapyLocation{
            //For the map to work we need the patient's address and zip,
            //so validate the user info here
            let ready = checkPatientData()
            if !ready {
                TSClient.sharedInstance().errorDialog(self, errTitle: "Incomplete Patient Information", action: "OK", errMsg: "Please complete patient information before proceeding")
            }else{
                //Make sure the info is available when we need it
                TSClient.sharedInstance().patient.Name = ptName.text!
                TSClient.sharedInstance().patient.Address = ptAddress.text!
                TSClient.sharedInstance().patient.Zip = ptZip.text!
                TSClient.sharedInstance().patient.Phone = ptPhone.text!
                //Launch the view
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PracticeViewController") as! UITabBarController
                controller.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
                //self.navigationController?.pushViewController(controller, animated: true)
                self.navigationController?.pushViewController(controller, animated: true)
            }//if/else
        }else if cell == therapyRx{
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TherapyRxViewController") as! TherapyRxViewController
            controller.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
            //self.navigationController?.pushViewController(controller, animated: true)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }//didSelectRow
    
    //***************************************************
    //Handle formatting in phone and zip fields
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        switch textField{
        case ptPhone:
            
            //Empty string? (backspace) allow it
            if string.isEmpty{
                return true
            }
            
            //Is the new input a number? If not, disallow it
            let isnum = Int(string)
            
            if isnum == nil{
                return false
            }
            
            // Adapted from http://stackoverflow.com/questions/27609104/xcode-swift-formatting-text-as-phone-number

            let newString = (textField.text as NSString!).stringByReplacingCharactersInRange(range, withString: string)
            //split the new string into it's character components if there are spaces or hyphens
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            //Rejoin them
            let decimalString = components.joinWithSeparator("")//"".join(components) as NSString
            //Get the string length
            let length = decimalString.characters.count
            //Is the first character a 1? true or false
            let hasLeadingOne = length > 0 && decimalString.characters.first == "1"
            //var hasLeadingOne = length > 0 && components[0] == "1"//decimalString.characterAtIndex(0) == 49 //unichar value of 1
            //Is the string empty, or if no leading one is the string longer than 10 numbers (11 with the 1)
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11{
                let newLength = (textField.text as NSString!).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            //this variable lets us move through the string
            var index = 0 as Int
            //create a mutable string that we can fill
            let formattedString = NSMutableString()
            
            //If no leading one add one
            if !hasLeadingOne{
                formattedString.appendString("1")
             }
            
            if hasLeadingOne{
                formattedString.appendString("1")
                index += 1
            }
            
            //add parentheses for areacode
            if (length - index) > 3{
                let areaCode = decimalString.substringWithRange(decimalString.startIndex.advancedBy(index)...decimalString.startIndex.advancedBy(index + 2))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            
            if length - index > 3{
                let prefix = decimalString.substringWithRange(decimalString.startIndex.advancedBy(index)...decimalString.startIndex.advancedBy(index + 2))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substringFromIndex(decimalString.startIndex.advancedBy(index))
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            return false
            
        case ptZip:
            //Empty string? return it (backspace)
            if string.isEmpty{
                return true
            }
            //Is the new input a number? If not, disallow it
            let isnum = Int(string)
            
            if isnum == nil{
                return false
            }
            
            //Is the length greater than 5? If so, disallow it
            let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
            if (newLength > 5){
                return false
            }
            return true
        default:
            return true
        }//switch
    }//shouldChangeCharactersInRange
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch(textField){
        case ptName:
            ptName.resignFirstResponder()
            ptAddress.becomeFirstResponder()
        case ptAddress:
            ptAddress.resignFirstResponder()
            ptZip.becomeFirstResponder()
        case ptZip:
            ptZip.resignFirstResponder()
            ptPhone.becomeFirstResponder()
        case ptPhone:
            ptPhone.resignFirstResponder()
        default:
            ptName.becomeFirstResponder()
        }//switch
        return false
    }//textFieldShouldReturn
    
    //***************************************************
    // Action Methods
    //***************************************************
    
    //***************************************************
    // Generate the prescription
    @IBAction func generateRx(sender: UIBarButtonItem) {
        //
        //println("Generate button pressed")
        //Make sure the info is available when we need it
        TSClient.sharedInstance().patient.Name = ptName.text!
        TSClient.sharedInstance().patient.Address = ptAddress.text!
        TSClient.sharedInstance().patient.Zip = ptZip.text!
        TSClient.sharedInstance().patient.Phone = ptPhone.text!
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("GeneratorViewController") as! GeneratorViewController
        controller.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        self.navigationController?.pushViewController(controller, animated: true)
        
    }

    //***************************************************
    // Clear the Prescription information, setting it back to blank
    @IBAction func clearRx(sender: UIBarButtonItem) {
        //This needs to all be done from here to properly clear the fields
        
        //Display a dialog to confirm this action
        //Create the basic alertcontroller
        let alert = UIAlertController(title: "Clear Prescription?", message: "This will delete all prescription data", preferredStyle: UIAlertControllerStyle.Alert)
        //Add the actions
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction) in
            //Clear the Data
            TSClient.sharedInstance().rxClear()
            //Reset the patient data
            self.ptName.text = ""
            self.ptAddress.text = ""
            self.ptZip.text = ""
            self.ptPhone.text = ""
            //Reset the diagnosis list
            self.diagnosis.text = ""
            TSClient.sharedInstance().dxList = []
            //Reset the prescription data
            self.ptDiagnosis.detailTextLabel?.text = "None Selected"
            self.therapyLocation.detailTextLabel?.text = "None Selected"
            self.therapyRx.detailTextLabel?.text = "None Selected"
            //self.deliveryMethod.detailTextLabel?.text = "None Selected"
            //We have to close from here as the handler controls the flow
            self.navigationController?.popToRootViewControllerAnimated(true)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
            //Don't do anything
            self.navigationController?.popToRootViewControllerAnimated(true)
        }))
        //Show the dialog
        self.presentViewController(alert, animated: true, completion: nil)
    }//clearRx
    
    //***************************************************
    // Show favorites
    @IBAction func showFavorites(){
        let FavoriteVC = self.storyboard?.instantiateViewControllerWithIdentifier("ManageFavoritesTableViewController") as! ManageFavoritesTableViewController
        self.navigationController?.pushViewController(FavoriteVC, animated: true)
    }//showFavorites
    
    //***************************************************
    // Display/edit the current Provider settings
    func showSettings(){
    
        //Get a controller handle
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("InfoViewController") as! InfoViewController

        //Pass the data in
        controller.provider = provider
        
        //show the settings controller
        self.navigationController?.pushViewController(controller, animated: true)
    }//showSettings
    
    //***************************************************
    // Helper Methods
    //***************************************************
    func checkPatientData() -> Bool{
        //Are all the fields complete?
        if (ptName.text!.isEmpty || ptAddress.text!.isEmpty  || ptZip.text!.isEmpty || ptPhone.text!.isEmpty) {
                //No, return false
                return false
        }else{
            return true
        }
    }//checkPatientData

    func loadFavorites(){
        //error object if fetch fails
        let error: NSErrorPointer = nil
        
        //build the fetchRequest
        let fetchRequest = NSFetchRequest(entityName: "PTPractice")
        //If there are results, grab them. If not move on

        do {
            let results = try sharedContext.executeFetchRequest(fetchRequest)
            if error != nil{
                //Nice alertview
                TSClient.sharedInstance().errorDialog(self, errTitle: "Favorites Load Error", action: "OK", errMsg: "Error loading favorites from disk")
            }else{
                TSClient.sharedInstance().practices = results as! [PTPractice] 
            }//if/else
        } catch let error1 as NSError {
            error.memory = error1
        }//if let
    }//loadFavorites
        

}//class
