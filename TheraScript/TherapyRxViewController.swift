//
//  TherapyRxViewController.swift
//  TheraScript
//
//  Created by Greybear on 8/10/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit

class TherapyRxViewController: UITableViewController, UITableViewDelegate {
    
    //Variables
    
    //Outlets
    
    //The tableview
    @IBOutlet var therapyTableView: UITableView!
    
    //Eval cells
    @IBOutlet weak var visitIncrement: UIStepper!
    @IBOutlet weak var visitNumber: UILabel!
    
    //Specific Tx Cells
    @IBOutlet weak var returnReport: UITableViewCell!
    @IBOutlet weak var modalities: UITableViewCell!
    @IBOutlet weak var conditioning: UITableViewCell!
    @IBOutlet weak var coreStab: UITableViewCell!
    @IBOutlet weak var manualTherapy: UITableViewCell!
    @IBOutlet weak var poolTherapy: UITableViewCell!
    @IBOutlet weak var neckSchool: UITableViewCell!
    @IBOutlet weak var backSchool: UITableViewCell!
    @IBOutlet weak var cHardCollar: UITableViewCell!
    @IBOutlet weak var cSoftCollar: UITableViewCell!
    @IBOutlet weak var lso: UITableViewCell!
    @IBOutlet weak var tlso: UITableViewCell!
    @IBOutlet weak var ctlso: UITableViewCell!
    @IBOutlet weak var tns: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Add a completion button to the nav bar
        var acceptButton = UIBarButtonItem(title: "Accept", style: UIBarButtonItemStyle.Plain, target: self, action: "savePTRx")
        navigationItem.rightBarButtonItem = acceptButton
        
        //Set the min and max stepper values and the increment value
        visitIncrement.minimumValue = TSClient.Constants.minPTVisits
        visitIncrement.maximumValue = TSClient.Constants.maxPTVisits
        visitIncrement.stepValue = 1.0
        
        //Set the default number of visits if needed
        if TSClient.sharedInstance().prescription.visits == 0.0{
            //set to default number of visits
            visitIncrement.value = TSClient.Constants.PTVisits
        }else{
            //Pull the saved number
            visitIncrement.value = TSClient.sharedInstance().prescription.visits
        }//if else
        self.visitNumber.text = String(format: "%d", Int(visitIncrement.value))
    }//viewDidLoad

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Sign up for Keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        //KB Hide Notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillDisappear:", name: UIKeyboardWillHideNotification,
            object: nil)

        //get the prescription data
        getRxInfo()
        
        //Hide the toolbar here
        self.navigationController?.toolbarHidden = true
    }//viewWillAppear
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Remove us from keyboard notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "keyboardWillShow:", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "keyboardWillDisappear:", object: nil)
    }//viewWillDisappear

    //***************************************************
    // Delegate Functions
    //***************************************************
    
    //Because this is a custom table with constant values, I'm doing everything manually.
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        //Get the selected cell
        let cell = therapyTableView.cellForRowAtIndexPath(indexPath)
        
        //We need to preserve user interaction for the first cell, but don't want a check mark
        //println("Index section/path: \(indexPath.section)/\(indexPath.row)")
        if indexPath.section == 0 && indexPath.row == 0{
            //No flash on the first cell of the first section, it's for the visit
            //button
            cell?.selectionStyle = .None
        }else{
            //Toggle the checkmark for the selected cell
            switch cell!.accessoryType {
               case UITableViewCellAccessoryType.None:
                    cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            default:
                    cell!.accessoryType = UITableViewCellAccessoryType.None
            }//switch
        }//if/else
        
        //Remove the highlight please (gives a nice flash as visual feedback)
        //May need to re-think this unless I can grab a list of cells with checkmarks
        cell?.selected = false
    }//didSelectRow

    
    //***************************************************
    // Action Functions
    //***************************************************
    //***************************************************
    // incrementVisits - Change the number of PT visits prescribed - defaults to 4
    @IBAction func incrementVisits(sender: UIStepper) {
        //Convert float to int and then to string for display
        var visits = String(format: "%d", Int(sender.value))
        //Stepper makes this dead simple - just return the sender value
        self.visitNumber.text = visits
    }

    //***************************************************
    // savePTRx - Save the Therapy Prescription
    func savePTRx() {
        //println("Accept pressed")
        //Save the state of the prescription data
        setRxInfo()
        self.navigationController?.popToRootViewControllerAnimated(true)
        //self.dismissViewControllerAnimated(true, completion: nil)
    }//savePTRx
    
    //***************************************************
    // getRxInfo - get prescription info and load it
    func getRxInfo(){
        //Make sure to set the value to match the default if no visits specified
        if TSClient.sharedInstance().prescription.visits == 0.0{
            visitIncrement.value = 4.0
        }else{
            visitIncrement.value = TSClient.sharedInstance().prescription.visits
        }//if else
        //Set the value of all the table entries
        if TSClient.sharedInstance().prescription.report{
            returnReport.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            returnReport.accessoryType = UITableViewCellAccessoryType.None
        }
        if TSClient.sharedInstance().prescription.modalities{
            modalities.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
             modalities.accessoryType = UITableViewCellAccessoryType.None
        }
        if TSClient.sharedInstance().prescription.conditioning{
            conditioning.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            conditioning.accessoryType = UITableViewCellAccessoryType.None
        }
        if TSClient.sharedInstance().prescription.coreStab{
            coreStab.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            coreStab.accessoryType = UITableViewCellAccessoryType.None
        }
        if TSClient.sharedInstance().prescription.manualTherapy{
            manualTherapy.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            manualTherapy.accessoryType = UITableViewCellAccessoryType.None
        }
         if TSClient.sharedInstance().prescription.poolTherapy{
            poolTherapy.accessoryType = UITableViewCellAccessoryType.Checkmark
         }else{
            poolTherapy.accessoryType = UITableViewCellAccessoryType.None
        }
        if TSClient.sharedInstance().prescription.neckSchool{
            neckSchool.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            neckSchool.accessoryType = UITableViewCellAccessoryType.None
        }
        if TSClient.sharedInstance().prescription.backSchool{
            backSchool.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            backSchool.accessoryType = UITableViewCellAccessoryType.None
        }
       if TSClient.sharedInstance().prescription.cSoftCollar{
            cHardCollar.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            cHardCollar.accessoryType = UITableViewCellAccessoryType.None
        }
        if TSClient.sharedInstance().prescription.tlso{
            tlso.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            tlso.accessoryType = UITableViewCellAccessoryType.None
        }
        if TSClient.sharedInstance().prescription.ctlso{
            ctlso.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            ctlso.accessoryType = UITableViewCellAccessoryType.None
        }
        
        if TSClient.sharedInstance().prescription.lso{
            lso.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            lso.accessoryType = UITableViewCellAccessoryType.None
        }
        if TSClient.sharedInstance().prescription.cHardCollar{
            cSoftCollar.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            cSoftCollar.accessoryType = UITableViewCellAccessoryType.None
        }
        if TSClient.sharedInstance().prescription.tns{
            tns.accessoryType = UITableViewCellAccessoryType.Checkmark
        }else{
            tns.accessoryType = UITableViewCellAccessoryType.None
        }
    }//getRxInfo
    
    //Save the Prescription Data
    func setRxInfo(){
        //First, zero out the data
        TSClient.sharedInstance().prescription = TSClient.Prescription()
        
        //The user wants to save the data here, so set the flag to alert the RxViewController
        TSClient.sharedInstance().prescription.rxSelected = true
        
        //This always gets saved
        TSClient.sharedInstance().prescription.visits = visitIncrement.value
        
        //The rest are conditional
        if returnReport.accessoryType == UITableViewCellAccessoryType.Checkmark{
            TSClient.sharedInstance().prescription.report = true
        }else{
            TSClient.sharedInstance().prescription.report = false
        }
        
        if modalities.accessoryType == UITableViewCellAccessoryType.Checkmark{
            TSClient.sharedInstance().prescription.modalities = true
        }else{
            TSClient.sharedInstance().prescription.modalities = false
        }
        
        if conditioning.accessoryType == UITableViewCellAccessoryType.Checkmark{
            TSClient.sharedInstance().prescription.conditioning = true
        }else{
            TSClient.sharedInstance().prescription.conditioning = false
        }
        
        if coreStab.accessoryType == UITableViewCellAccessoryType.Checkmark{
            TSClient.sharedInstance().prescription.coreStab = true
        }else{
            TSClient.sharedInstance().prescription.coreStab = false
        }

        if manualTherapy.accessoryType == UITableViewCellAccessoryType.Checkmark{
            TSClient.sharedInstance().prescription.manualTherapy = true
        }else{
            TSClient.sharedInstance().prescription.manualTherapy = false
        }

        if poolTherapy.accessoryType == UITableViewCellAccessoryType.Checkmark{
            TSClient.sharedInstance().prescription.poolTherapy = true
        }else{
            TSClient.sharedInstance().prescription.poolTherapy = false
        }

        if neckSchool.accessoryType == UITableViewCellAccessoryType.Checkmark{
            TSClient.sharedInstance().prescription.neckSchool = true
        }else{
            TSClient.sharedInstance().prescription.neckSchool = false
        }
        
        if backSchool.accessoryType == UITableViewCellAccessoryType.Checkmark{
            TSClient.sharedInstance().prescription.backSchool = true
        }else{
            TSClient.sharedInstance().prescription.backSchool = false
        }

        if cSoftCollar.accessoryType == UITableViewCellAccessoryType.Checkmark{
            TSClient.sharedInstance().prescription.cSoftCollar = true
        }else{
            TSClient.sharedInstance().prescription.cSoftCollar = false
        }
        if tlso.accessoryType == UITableViewCellAccessoryType.Checkmark{
            TSClient.sharedInstance().prescription.tlso = true
        }else{
            TSClient.sharedInstance().prescription.tlso = false
        }
        if ctlso.accessoryType == UITableViewCellAccessoryType.Checkmark{
            TSClient.sharedInstance().prescription.ctlso = true
        }else{
            TSClient.sharedInstance().prescription.ctlso = false
        }
        if lso.accessoryType == UITableViewCellAccessoryType.Checkmark{
            TSClient.sharedInstance().prescription.lso = true
        }else{
            TSClient.sharedInstance().prescription.tlso = false
        }
        if cHardCollar.accessoryType == UITableViewCellAccessoryType.Checkmark{
            TSClient.sharedInstance().prescription.cHardCollar = true
        }else{
            TSClient.sharedInstance().prescription.cHardCollar = false
        }


 

        if tns.accessoryType == UITableViewCellAccessoryType.Checkmark{
            TSClient.sharedInstance().prescription.tns = true
        }else{
            TSClient.sharedInstance().prescription.tns = false
        }
    }//setRxInfo
    
}//class
