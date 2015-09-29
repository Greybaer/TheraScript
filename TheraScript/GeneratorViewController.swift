//
//  GeneratorViewController.swift
//  TheraScript
//
//  Created by Greybear on 9/22/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit
import MessageUI

class GeneratorViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    //Variables
    //Provider data struct
    var provider =  TSClient.Provider()
    
    var icon: UIImage?
    
    //The icon size
    var iconSize = CGSizeMake(64.0, 64.0)

    //Outlets
    //Provider info
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var providerName: UILabel!
    @IBOutlet weak var providerPractice: UILabel!
    @IBOutlet weak var providerAddress: UILabel!
    @IBOutlet weak var providerAddress2: UILabel!
    
    //Patient Info
    @IBOutlet weak var ptName: UILabel!
    @IBOutlet weak var ptPhone: UILabel!
    
    //Therapy Practice info
    @IBOutlet weak var PTPractice: UILabel!
    @IBOutlet weak var PTAddress: UILabel!
    @IBOutlet weak var PTPhone: UILabel!
    
    //Diagnosis list
    @IBOutlet weak var diagnosisList: UILabel!
    
    
    //Prescription info
    @IBOutlet weak var visits: UILabel!
    @IBOutlet weak var report: UILabel!
    @IBOutlet weak var modalities: UIImageView!
    @IBOutlet weak var conditioning: UIImageView!
    @IBOutlet weak var coreStab: UIImageView!
    @IBOutlet weak var manualTherapy: UIImageView!
    @IBOutlet weak var pool: UIImageView!
    @IBOutlet weak var neckSchool: UIImageView!
    @IBOutlet weak var backSchool: UIImageView!
    @IBOutlet weak var LSO: UIImageView!
    @IBOutlet weak var TLSO: UIImageView!
    @IBOutlet weak var CTLSO: UIImageView!
    @IBOutlet weak var TNS: UIImageView!
    @IBOutlet weak var cSoftCollar: UIImageView!
    @IBOutlet weak var cHardCollar: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide the toolbar
        self.navigationController?.toolbarHidden = true
    }//viewDidLoad
    
    override func viewWillAppear(animated: Bool) {
        //Add a settings button to the nav bar
        var settingsButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "sendSMS")
        self.navigationItem.rightBarButtonItem = settingsButton
        
        //Now, are we text enabled? 
        var sms = MFMessageComposeViewController.canSendText()
        var mms = MFMessageComposeViewController.canSendAttachments()
        
        if sms || mms == false{
            settingsButton.enabled = false
        }
        //These are done here because the data may need to change between views
        //rather than loads
        
        //Load the provder data as we start up
        provider = TSClient.sharedInstance().getProviderInfo()
        
        //And the image
        icon = TSClient.Cache.imageCache.imageWithIdentifier(TSClient.Constants.userLogo)

        //We *should* always have provider info to get here, but just in case...
        //Empty field = no info
        if provider.firstName.isEmpty{
            //Pop an error dialog
            TSClient.sharedInstance().errorDialog(self, errTitle: "No Provider", action: "OK", errMsg: "Please set up provider information")
            //and return to the base screen
            self.navigationController?.popToRootViewControllerAnimated(true)
            
            //The user can elect to look at an empty prescription, so continue
        }else{
            //Populate the provider header
            iconImage.image = TSClient.sharedInstance().createIcon(icon!, size: iconSize)
            
            providerName.text = "\(provider.firstName) \(provider.middleName) \(provider.lastName) \(provider.degreeType)"
            providerPractice.text = provider.practiceName
            providerAddress.text = "\(provider.streetAddress)"
            providerAddress2.text = "\(provider.cityName) \(provider.stateName) \(provider.zipCode) ・ \(provider.phoneNumber)"
            
            //Populate the patient info
            ptName.text = TSClient.sharedInstance().patient.Name
            ptPhone.text = TSClient.sharedInstance().patient.Phone
            
            //Populate the therapist info
            PTPractice.text = TSClient.sharedInstance().therapy.practiceName
            PTAddress.text = TSClient.sharedInstance().therapy.practiceAddress
            PTPhone.text = TSClient.sharedInstance().therapy.practicePhone
            //println("|\(PTPhone.text)|")
            
            //Populate the diagnosis list
            for diagnosis in TSClient.sharedInstance().dxList{
                diagnosisList.text = diagnosisList.text! + diagnosis.icdCode + " "
            }
            
            //Populate the prescription
            visits.text = String(Int(TSClient.sharedInstance().prescription.visits))
            report.text  = TSClient.sharedInstance().prescription.report ? "Yes" : "No"
            //Checkmark city!
            //Values are the inverse of the saved state
            //(e.g. user selects a field = true, but hidden is the inverse)
            modalities.hidden = !TSClient.sharedInstance().prescription.modalities
            conditioning.hidden = !TSClient.sharedInstance().prescription.conditioning
            coreStab.hidden = !TSClient.sharedInstance().prescription.coreStab
            manualTherapy.hidden = !TSClient.sharedInstance().prescription.manualTherapy
            pool.hidden = !TSClient.sharedInstance().prescription.poolTherapy
            neckSchool.hidden = !TSClient.sharedInstance().prescription.neckSchool
            backSchool.hidden = !TSClient.sharedInstance().prescription.backSchool
            LSO.hidden = !TSClient.sharedInstance().prescription.lso
            TLSO.hidden = !TSClient.sharedInstance().prescription.tlso
            CTLSO.hidden = !TSClient.sharedInstance().prescription.ctlso
            TNS.hidden = !TSClient.sharedInstance().prescription.tns
            cSoftCollar.hidden = !TSClient.sharedInstance().prescription.cSoftCollar
            cHardCollar.hidden = !TSClient.sharedInstance().prescription.cHardCollar
        }//if
    }//viewWillAppear
    
    //***************************************************
    // Delegate functions
    //***************************************************

    //***************************************************
    //Determines whether device is SMS enabled
    class func canSendText() -> Bool{
        return MFMessageComposeViewController.canSendText()
    }//canSendText
 
    //***************************************************
    //The message delegate handler
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        switch (result.value) {
        case MessageComposeResultCancelled.value:
            TSClient.sharedInstance().errorDialog(controller, errTitle: "Message Cancelled", action: "OK", errMsg: "Message will not be sent")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.value:
            TSClient.sharedInstance().errorDialog(controller, errTitle: "Message Send Failed", action: "OK", errMsg: "Message unable to be sent")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.value:
            TSClient.sharedInstance().errorDialog(controller, errTitle: "Message Cancelled", action: "OK", errMsg: "Message will not be sent")
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }//switch
    }//MessageControllerDidFinish
    
    //***************************************************
    // Action functions
    //***************************************************
    
    //***************************************************
    // Send a text message if device enabled
    func sendSMS(){
        //Adapted from http://www.ioscreator.com/tutorials/send-sms-messages-tutorial-ios8-swift
        
        //create a message controller object
        var messageVC = MFMessageComposeViewController()
        messageVC.body = TSClient.Constants.PTMessage + TSClient.sharedInstance().patient.Name
        //Create an NSData object from the view
        var attachment = dataFromView()
        //And attach it to the message
        messageVC.addAttachmentData(attachment, typeIdentifier: "images/png", filename: "PTRx.jpg")
        //We default to sending to the therapist and the patient
        messageVC.recipients = [TSClient.sharedInstance().therapy.practicePhone, TSClient.sharedInstance().patient.Phone]
        //Handle things ourselves
        messageVC.messageComposeDelegate = self;
        //Present a modal view to complete the process
        self.presentViewController(messageVC, animated: false, completion: nil)
    }//sendSMS
   
    //***************************************************
    // Helper functions
    //***************************************************
    
    //***************************************************
    // Transform the view into NSData for attachment
    func dataFromView() -> NSData {
        
        var image: UIImage?
        
        //Hide the tool and nav bar
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //Render the view to a single image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Transform the image into NSData
        var data: NSData = UIImagePNGRepresentation(image)
        
        //Show tool and nav bar
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        //return the NSData object
        return data
    }//dataFromView
}//class

