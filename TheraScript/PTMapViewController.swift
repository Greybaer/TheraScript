//
//  PTMapViewController.swift
//  TheraScript
//
//  Created by Greybear on 8/24/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PTMapViewController: UIViewController, MKMapViewDelegate {
    
    //Variables
    
    //The placemark for the patient's address
    var placemark: CLPlacemark!
    
    //Array of map annotations
    var annotations = [MKPointAnnotation]()
    
    //Outlets
    //Map View
    @IBOutlet weak var PTMapView: MKMapView!
    //Activity Indicator
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide the spinner when not needed
        self.spinner.hidesWhenStopped = true
        //We're our own delegate
        PTMapView.delegate = self
        //Set up the map region
        mapSetup()

    }//viewDidLoad
    
    override func viewWillAppear(animated: Bool) {
        //No Accept button here please
        self.tabBarController!.navigationItem.rightBarButtonItem = nil
        
        //Set the title of the view
        self.tabBarController!.navigationItem.title = "Practice Map Locations"

        //Hide the toolbar here
        self.navigationController?.toolbarHidden = true

    }//viewWillAppear
    
    //***************************************************
    // Map delegate Functions
    //***************************************************
    
    
    //***************************************************
    // Re-use method for displaying pins -
    // ripped from the PinSample code. I have plenty to do without re-inventing the wheel
    //***************************************************
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Green
            //Create a custom UIButton for the callout
            //Custom image - selected and unselected varieties
            let imageUnselected = UIImage(named: "OK.png") as UIImage!
            let imageSelected = UIImage(named: "OKSel.png") as UIImage!
            //Create a button
            let button = UIButton(type: UIButtonType.Custom)
            button.frame = CGRectMake(25,25,25,25)
            //Set the images
            button.setImage(imageUnselected, forState: .Normal)
            button.setImage(imageSelected, forState: .Highlighted)
            //Add the button
            pinView?.rightCalloutAccessoryView = button
            //pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }//viewForAnnotation
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //println("User selected \(view.annotation.title!)")

        //Split the subtitle string into address and phone
        let splitString: String = view.annotation!.subtitle!!
        var splitArray = splitString.componentsSeparatedByString(" ∙ ")

        //Save the data for later Core Data storage
        TSClient.sharedInstance().therapy.practiceName = view.annotation!.title!!
        TSClient.sharedInstance().therapy.practiceAddress = splitArray[0]
        TSClient.sharedInstance().therapy.practicePhone = splitArray[1]

        //Is this entry already saved to favoirites?
        let duplicate = TSClient.sharedInstance().checkDuplicate()
        
        if !duplicate{
            //Show a dialog to allow the user to save this practice to favorites if desired
            TSClient.sharedInstance().confirmationDialog(self)
        }else{
            //Just return to Rx View
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }//callout selected
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        //Perform the search for nearby Therapy Practices
        doTherapySearch()
    }//mapDidFinishRender

    //***************************************************
    // Helper Functions
    //***************************************************

    //***************************************************
    // Set up the Therapy Search map with the pins we need
    func mapSetup(){
        //Address
        let address = "\(TSClient.sharedInstance().patient.Address),\(TSClient.sharedInstance().patient.Zip)"
        dispatch_async(dispatch_get_main_queue()){
            //Start the spinner
            self.spinner.startAnimating()
        }//main queue
        //Call the geocoder network function
        TSClient.sharedInstance().geocodeAddress(address) { (placemark, error) in
            if error != nil{
                dispatch_async(dispatch_get_main_queue()){
                    TSClient.sharedInstance().errorDialog(self, errTitle: "Location Error", action: "OK", errMsg: error!)
                    self.spinner.stopAnimating()
                }//main_queue
            }else{
                self.placemark = placemark as! CLPlacemark
                //Then use the location data to set the region centered on the patient's address
                //get the coordinates
                let longitude = self.placemark.location!.coordinate.longitude
                let latitude = self.placemark.location!.coordinate.latitude
                //set the center of the map view
                let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                //20K (about 12 mile) span to start for region
                let region = MKCoordinateRegionMakeWithDistance(center, 20000, 20000)
                //set the map region
                dispatch_async(dispatch_get_main_queue()){
                    self.PTMapView.setRegion(region, animated: false)
                    self.spinner.stopAnimating()
                }//main_queue         
            }//if/else
        }//completionhandler
    }//mapSetup
    
    //***************************************************
    // Perform a local search for therapy practices
    // Lives here because of its tight integration into the map
        func doTherapySearch(){
            dispatch_async(dispatch_get_main_queue()){
                //Start the spinner
                self.spinner.startAnimating()
            }//main queue
            
            //Build the request
            let request = MKLocalSearchRequest()
            //Adding the zip really makes this work right
            request.naturalLanguageQuery = "Physical Therapy \(TSClient.sharedInstance().patient.Zip)"
            request.region = self.PTMapView.region
            //Execute the search
            let search = MKLocalSearch(request: request)
            search.startWithCompletionHandler {(response, error) in
                if response == nil{
                    dispatch_async(dispatch_get_main_queue()){
                        //self.spinner.stopAnimating()
                        TSClient.sharedInstance().errorDialog(self, errTitle: "Therapy Search Error", action: "OK", errMsg: error!.localizedDescription)
                    }//main_queue
                }else{
                    //println(response.mapItems)
                    for item in response!.mapItems {
                        let pin = MKPointAnnotation()
                        pin.coordinate = item.placemark.coordinate
                        //Massage the phonenumber into the right format
                        let phone = self.formatPhone(item.phoneNumber!)
                        //Title will be practice name and phone so we can split it later
                        pin.title = (item.name)
                        
                        //Build the address manually.
                        let address = "\(item.placemark.subThoroughfare!) \(item.placemark.thoroughfare!) \(item.placemark.locality!), \(item.placemark.administrativeArea!) \(item.placemark.postalCode!)"
                        pin.subtitle = "\(address) ∙ \(phone)"
                        self.annotations.append(pin)
                    }//for
                    dispatch_async(dispatch_get_main_queue()){
                        self.PTMapView.addAnnotations(self.annotations)
                        self.spinner.stopAnimating()
                    }//main_queue
                }//if/else
            }//completionhandler
            //Stop the spinner
        }//doTherapySearch
    
    func formatPhone(var number: String) -> String {
        //The new format of the phone is a unicode string with garbage in front and the other chars already inserted.
        //Now all we need to do is strip that out and add the 1
        //Get the index of the areacode opening paren
        let index = number.characters.indexOf("(")
        //Start by removing anything before the areacode paren
        number.removeRange(Range<String.Index>(start: number.startIndex, end: index!))
        // Create a variable string we can modify
        var newNumber = number
        //Prepend a 1 to the front
        newNumber.insert("1", atIndex: newNumber.startIndex)
        //Transform it back into a string
        //and return the result
        return newNumber
    }//formatPhone

}//class
