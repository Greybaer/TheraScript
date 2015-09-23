//
//  IconViewController.swift
//  TheraScript
//
//  Created by Greybear on 7/20/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//
//  Presents a controller that utilizes an imagePicker to select an image for use as an icon

import UIKit

class IconViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    //Variables
    //Flag to indicate whether the user chose a custom image
    //Required to determine image save format - JPG or PNG
    var defaultImage: Bool = true
    
    //Struct holding the provider date we're inputting
    var provider = TSClient.Provider()

    //Outlets
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var photoButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var defaultIconButton: UIBarButtonItem!

    //Text labels for icon selection - These get disappeared after the user
    //selects an image
    @IBOutlet weak var iconTopText: UILabel!
    @IBOutlet weak var iconBottomText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add a completion button to the nav bar
        var acceptButton = UIBarButtonItem(title: "Accept", style: UIBarButtonItemStyle.Plain, target: self, action: "saveIcon")
        navigationItem.rightBarButtonItem = acceptButton
    }//viewDidLoad
    
    override func viewWillAppear(animated: Bool) {
        //Is there a cammera on this device? Enable/disable button depending
        cameraButton.enabled=UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        //Are we setting up (empty provider data) or editing?
        if provider.icon != nil{
            //We're editing so load the user's icon
            imageView.image = TSClient.Cache.imageCache.imageWithIdentifier(TSClient.Constants.userLogo)
        }else{
           //First time, so set the default icon
           setDefaultIcon(self)
        }
        
   }//viewWillAppear

    //***************************************************
    // Delegate Methods
    //***************************************************
    //We got an image, so show it
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        //Clear out the instruction text once the user has selected his own icon image
        iconTopText.text = ""
        iconBottomText.text = ""
        //Did we get an edited image?
        provider.icon = (info[UIImagePickerControllerEditedImage] as! UIImage)
        self.imageView.image = (info[UIImagePickerControllerEditedImage] as! UIImage)
        //Save it so we have it in storage for when the view re-appears
        TSClient.Cache.imageCache.storeImageJPG(imageView.image, withIdentifier: TSClient.Constants.userLogo)
        //OK set the flag
        defaultImage = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //***************************************************
    // Action Methods
    //***************************************************
    
    //***************************************************
    //Get an image from the camera if enabled
    @IBAction func imageFromCamera(sender: UIBarButtonItem) {
        //The button works when enabled and causes the appropriate crash when it finds no
        //camera in the simulator... =\
        //println("Camera button pressed")
        let pickController = UIImagePickerController()
        pickController.delegate = self
        pickController.sourceType=UIImagePickerControllerSourceType.Camera
        pickController.allowsEditing = true
        self.presentViewController(pickController, animated: true, completion: nil)
    }//imageFromCamera

    //***************************************************
    // Get an image from saved photos on the phone
    @IBAction func imageFromPhotos(sender: UIBarButtonItem) {
        let pickController = UIImagePickerController()
        //println("Album button pressed")
        //println("Frame Y Origin pre-picture: \(self.view.frame.origin.y)")
        pickController.delegate = self
        pickController.sourceType=UIImagePickerControllerSourceType.PhotoLibrary
        pickController.allowsEditing = true

        self.presentViewController(pickController, animated: true, completion: nil)
    }//imageFromPhotos
    
    @IBAction func setDefaultIcon(sender: AnyObject) {
        //The user wants to use the default ISI logo
        self.imageView.image = UIImage(named: TSClient.Constants.isiLogo)
        //set the flag
        defaultImage = true
        //Insert into the provider structure
        provider.icon = imageView.image
    }//setDefaultIcon
    
    //***************************************************
    // saveIcon - action method from the programmatically added nav bar button
    func saveIcon(){
        //If the flag isn't set save the default image as a PNG
        if defaultImage{
            TSClient.Cache.imageCache.storeImagePNG(imageView.image, withIdentifier: TSClient.Constants.userLogo)
        }else{
            //Otherwise, save a photo image as a JPG
            TSClient.Cache.imageCache.storeImageJPG(imageView.image, withIdentifier: TSClient.Constants.userLogo)
        }
        //Now save the provider data
        TSClient.sharedInstance().saveProviderInfo(provider)
        //And dismiss the image controller
        self.navigationController?.popToRootViewControllerAnimated(true)
    }//saveIcon
    

}//class
