//
//  TSClient.swift
//  TheraScript
//
//  Created by Greybear on 7/22/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//
//  Network and helper functions - Shared session

import Foundation
import UIKit
import CoreData
import CoreLocation


class TSClient: NSObject{

    //Variables
    //The Aqua.io token
    var aqua = Aqua()
    
    
    //***************************************************
    //The prescription components
    //***************************************************
    
    //The patient info
    var patient = Patient()
    
    //Diagnosis List
    var dxList: [Diagnosis] = []
    
    //Therapy practice info
    var therapy = Therapy()
    
    //Core Data PT Practice info
    var practices = [PTPractice]()
    
    //Therapy Prescription
    var prescription = Prescription()

    //The URL Session
    var session: NSURLSession

    //Shorthand for the CoreData context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }

    //***************************************************
    // Shared Object Methods
    //***************************************************

    //***************************************************
    //Create a shared session for the NSURLSession calls
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }//init


    //***************************************************
    //Shared Instance
    class func sharedInstance() -> TSClient {
    
        struct Singleton {
            static var sharedInstance = TSClient()
        }
    
        return Singleton.sharedInstance
    }//sharedInstance

    //***************************************************
    //Shared Image Cache
    struct Cache {
        static let imageCache = ImageCache()
    }//cache
    
    //***************************************************
    // Network Functions
    //***************************************************
    
    //***************************************************
    // getAquaToken - Authenticate and get an aqua.io token
    func getAquaToken(completionHandler: (success: Bool, errorString: String?) -> Void){
        
        //Create the request
        let request = NSMutableURLRequest(URL: NSURL(string: TSClient.Constants.AQUA_TOKEN_URL)!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        request.HTTPBody = "{\"client_id\": \"\(TSClient.Constants.AQUA_ID)\", \"client_secret\": \"\(TSClient.Constants.AQUA_SECRET)\", \"grant_type\": \"client_credentials\"}".dataUsingEncoding(NSUTF8StringEncoding)
        //Execute the task
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if downloadError != nil{
                completionHandler(success: false, errorString: String(stringInterpolationSegment: downloadError!.localizedDescription))
            }else{
                // Parse the data into readable form
                TSClient.parseJSONWithCompletionHandler(data!) { (JSONData, parseError) in
                    if parseError != nil{
                        completionHandler(success: false, errorString: parseError?.localizedDescription)
                    }else{
                        //println(JSONData)
                        TSClient.sharedInstance().aqua.token = (JSONData["access_token"] as! String)
                        completionHandler(success: true, errorString: nil)
                    }
                }//parseJSONData
            }//else
        }//task request
        task.resume()
    }//getAquaToken
    
    //***************************************************
    // getDx - Get a diagnosis code and description from Aqua.io
    func getDx(codeType: Int, searchTerm: String, token: String, completionhandler: (success: Bool, error: String?) -> Void) {
        
        //Determine whether we're searching ICD9 or 10
        var codeSearch: String
        
        switch codeType{
            case 0:
                codeSearch = TSClient.Constants.ICD9
            case 1:
                codeSearch = TSClient.Constants.ICD10
            default:
                codeSearch = TSClient.Constants.ICD9
        }//switch
        
        //Single term, so it's easiest to put it here
        let search = [
            "utf8": "true",
            "q[name_or_description_cont]": searchTerm as String,
            "access_token": TSClient.sharedInstance().aqua.token as String
        ]
        
        //Build a session request
        let session = NSURLSession.sharedSession()
        let urlString = TSClient.Constants.AQUA_BASE_URL + codeSearch + escapedParameters(search as [String : AnyObject])
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        //println(request)
        
        //Now make the request and parse the results
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let taskError = downloadError {
                //Fail - the calling code will display the errDialog()
                completionhandler(success: false, error: "Unable to complete data transfer")
            }//if
            else {
                //Success - save the data in struct for collection display
                var parsingError: NSError? = nil
                //The data comes as an array of NSDictionaries
                let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSArray
                //println(parsedResult)
                //Check for an empty return set
                if parsedResult.count < 1{
                    completionhandler(success: false, error: "No results found")
                }else{
                    //Save the result and return success
                    TSClient.sharedInstance().aqua.searchResults = parsedResult
                    //println(TSClient.sharedInstance().aqua.searchResults)
                    completionhandler(success: true, error: nil)
                }//parsedResult check
           }//else
        }//task
        task.resume()
    }//getDx
    
    //***************************************************
    // Geocode function for user's location
    func geocodeAddress(address: String!, completionHandler: (placemark: AnyObject?, error: String?)-> Void) {
        //call the geocoding function
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error != nil{
                completionHandler(placemark: nil, error: error!.localizedDescription)
            }else if placemarks!.count > 0{
                //Only want one for this app
                let placemark = placemarks?[0]
              completionHandler(placemark: placemark, error: nil)
            }//if/else
        }//completionhandler
    }//geocodeAddress
    
    //***************************************************
    // Helper Functions
    //***************************************************

    //***************************************************
    // rxClear - Clear the Prescription page, resetting it to the default state
    func rxClear(){
        //Clear the patient info
        self.patient = Patient()
        //Diagnosis info
        
        //Therapy info
        self.therapy = Therapy()
        
        //Prescriotion Info
        self.prescription = Prescription()
    }//rxClear
    
    //***************************************************
    // Create an icon of arbitrary size from a passed image
    //This code works! Save it for later when we need to resize for the PDF
    func createIcon(image: UIImage, size: CGSize)-> UIImage{
        //Already the right size? Bail!
        if image.size == size{
            return image
        }
        //Create a drawing context
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        //draw the rect
        image.drawInRect(CGRectMake(0.0,0.0, size.width, size.height))
        //and grab the resulting image
        let icon: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        //release the context
        UIGraphicsEndImageContext()
        //and return the icon
        return icon
    }//createIcon

    //***************************************************
    // Save Provider info
    func saveProviderInfo(info: Provider){
        //println("entered saveProvider")
        //Create a dictionary
        let providerDictionary = [
            ProviderInfo.firstName : info.firstName,
            ProviderInfo.middleName : info.middleName,
            ProviderInfo.lastName : info.lastName,
            ProviderInfo.degreeType : info.degreeType,
            ProviderInfo.phoneNumber : info.phoneNumber,
            ProviderInfo.practiceName : info.practiceName,
            ProviderInfo.streetAddress : info.streetAddress,
            ProviderInfo.cityName : info.cityName,
            ProviderInfo.stateName : info.stateName,
            ProviderInfo.zipCode : info.zipCode,
            //The image is really saved separately, this is used to test presence
            ProviderInfo.icon : info.icon! as UIImage
        ]
        //Save string data to disk
        NSKeyedArchiver.archiveRootObject(providerDictionary, toFile: providerFilePath)
    }//saveProviderInfo
    
    //***************************************************
    // Retrieve Provider info
    func getProviderInfo()-> Provider{
        //Create a provider data item
        var provider = Provider()
        //Attempt to retrieve the stored data
        if let providerDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(providerFilePath) as? [String:AnyObject]{
            //Get the data
            provider.firstName = providerDictionary["firstName"] as! String
            provider.middleName = providerDictionary["middleName"]as! String
            provider.lastName = providerDictionary["lastName"]as! String
            provider.degreeType = providerDictionary["degreeType"] as! String
            provider.phoneNumber = providerDictionary["phoneNumber"] as! String
            provider.practiceName = providerDictionary["practiceName"] as! String
            provider.streetAddress = providerDictionary["streetAddress"] as! String
            provider.cityName = providerDictionary["cityName"] as! String
            provider.stateName = providerDictionary["stateName"] as! String
            provider.zipCode = providerDictionary["zipCode"] as! String
            provider.icon = providerDictionary["icon"] as? UIImage
        }
        //return the data, or an empty set
        return provider
    }//getProviderInfo
    
   //***************************************************
    // Given a dictionary of parameters,
    // convert to a string for a url
    // GB - Lifted from the original class app example
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* FIX: Replace spaces with '+' */
            let replaceSpaceValue = stringValue.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            /* Append it */
            urlVars += [key + "=" + "\(replaceSpaceValue)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }//escapedParameters
    
    //***************************************************
    // Given raw JSON, return a usable Foundation object
    //***************************************************
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }

    func checkDuplicate() -> Bool {
       
        //Build predicates for name and address so we can look for them
        let predicate1 = NSPredicate(format: "name = %@", self.therapy.practiceName)
        let predicate2 = NSPredicate(format: "address = %@", self.therapy.practiceAddress)
        
        //Now perform a fetch, looking for results that match
        let request = NSFetchRequest(entityName: "PTPractice")
        request.returnsObjectsAsFaults = false
        
        //Form the predicate search term
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2]) //NSCompoundPredicate.andPredicateWithSubpredicates([predicate1, predicate2])
        
        let result: NSArray = try! sharedContext.executeFetchRequest(request)
        
        //If we get a result, just close and continue
        if result.count != 0{
            //Let's look at them to check...
            var practices = result as! [PTPractice]
            //viewController.navigationController?.popToRootViewControllerAnimated(true)
            return true
        }else{
            return false
        }
   }//checkDuplicates
    
    //***************************************************
    // Create an AlertView to allow user to save to favorites if desired
    func confirmationDialog(viewController: UIViewController) -> Void{
        //Make sure the data actually got to the right place...
        //println("Therapy Info: \(therapy.practiceName) \(therapy.practiceAddress) \(therapy.practicePhone)")

        //Before we present, we check for an existing entry. If present, we go away without presenting the dialog
        //Create a dictionary of the new data
        let dictionary: [String : AnyObject] = [
            PTPractice.Keys.Name : self.therapy.practiceName as String,
            PTPractice.Keys.Address : self.therapy.practiceAddress as String,
            PTPractice.Keys.Phone : self.therapy.practicePhone as String
        ]//dictionary

        //And a new object to hold the data
        let newPractice = PTPractice(dictionary: dictionary, context: self.sharedContext)
 /*
        //Build predicates for name and address so we can look for them
        let predicate1 = NSPredicate(format: "name = %@", self.therapy.practiceName)
        let predicate2 = NSPredicate(format: "address = %@", self.therapy.practiceAddress)
        
        //Now perform a fetch, looking for results that match
        let request = NSFetchRequest(entityName: "PTPractice")
        request.returnsObjectsAsFaults = false
        
        //Form the predicate search term
        request.predicate = NSCompoundPredicate.andPredicateWithSubpredicates([predicate1, predicate2])
        
        var result: NSArray = sharedContext.executeFetchRequest(request, error: nil)!
        
        //If we get a result, just close and continue
        if result.count != 0{
            //Let's look at them to check...
            var practices = result as! [PTPractice]
            viewController.navigationController?.popToRootViewControllerAnimated(true)
            return
        }
        
        //No match, pop the dialog to allow the user to save to favorites
*/
        //Create the basic alertcontroller
        let alert = UIAlertController(title: "Save Therapist", message: "Save this therapy practice to favorites?", preferredStyle: UIAlertControllerStyle.Alert)
        //Add the actions
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction) in
            //println("Handle Ok logic here")
            
            //And save it
            dispatch_async(dispatch_get_main_queue()) {
                CoreDataStackManager.sharedInstance().saveContext()
            }

            //Append the the array so it shows up immediately
            self.practices.append(newPractice)
            
            //We have to close from here as the handler controls the flow
            viewController.navigationController?.popToRootViewControllerAnimated(true)
       }))
        
        alert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
            //Just dismiss, no action required
            viewController.navigationController?.popToRootViewControllerAnimated(true)
        }))
        //Show the dialog
        viewController.presentViewController(alert, animated: true, completion: nil)
    }//confirmationDialog
    
    //***************************************************
    // Create an AlertView to allow user to clear Prescription Data
    func clearDialog(viewController: UIViewController) -> Void{
        //Create the basic alertcontroller
        let alert = UIAlertController(title: "Clear Prescription?", message: "This will delete all prescription data", preferredStyle: UIAlertControllerStyle.Alert)
        //Add the actions
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction) in
            //Clear the Prescription
            self.rxClear()
            //viewController.RxTableView.setNeedsDisplay()
            //We have to close from here as the handler controls the flow
            viewController.navigationController?.popToRootViewControllerAnimated(true)
            viewController.viewDidLoad()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
            //Don't do anything
            viewController.navigationController?.popToRootViewControllerAnimated(true)
        }))
        //Show the dialog
        viewController.presentViewController(alert, animated: true, completion: nil)
    }//confirmationDialog

    
    //***************************************************
    // Create an AlertView to display an error message
    func errorDialog(viewController:UIViewController, errTitle: String, action: String, errMsg:String) -> Void{
        let alertController = UIAlertController(title: errTitle, message: errMsg, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(alertAction)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }//errDialog
    

    //***************************************************
    // Determine and return keyboard size
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo=notification.userInfo
        let keyboardSize=userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        //println("Keyboard Height: \(keyboardSize.CGRectValue().height)")
        return keyboardSize.CGRectValue().height
    }//getKeyboardHeight
    
}//class