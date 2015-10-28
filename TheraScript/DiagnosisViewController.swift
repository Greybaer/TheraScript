//
//  DiagnosisViewController.swift
//  TheraScript
//
//  Created by Greybear on 8/18/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit

class DiagnosisViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    //Variables
    
    
    //Outlets
    @IBOutlet weak var icdSelector: UISegmentedControl!
    @IBOutlet weak var searchTerm: UITextField!
    @IBOutlet weak var DxTableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    //The ICD code and description for selected diagnoses
    @IBOutlet weak var code0: UILabel!
    @IBOutlet weak var desc0: UILabel!
    @IBOutlet weak var code1: UILabel!
    @IBOutlet weak var desc1: UILabel!
    @IBOutlet weak var code2: UILabel!
    @IBOutlet weak var desc2: UILabel!
    @IBOutlet weak var clearDxButton: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spinner.hidesWhenStopped = true
        
        //Set the selector to ICD10 to start now that it's live
        icdSelector.selectedSegmentIndex = 1
        //Handle our own text
        searchTerm.delegate = self
        DxTableView.delegate = self
        
        //Add a completion button to the nav bar
        let acceptButton = UIBarButtonItem(title: "Accept", style: UIBarButtonItemStyle.Plain, target: self, action: "saveDx")
        navigationItem.rightBarButtonItem = acceptButton
        //Load the display
        self.DxTableView.reloadData()
        

    }//viewDidLoad
    
    override func viewWillAppear(animated: Bool) {
        //Nuke the aqua io results if present. This gives a fresh search every time
        TSClient.sharedInstance().aqua.searchResults = []
        
        //Hide the toolbar here
        self.navigationController?.toolbarHidden = true
        
        //Populate the diagnosis list if there is one
        dxListPopulate()
    }//viewWillAppear

    //***************************************************
    //Delegate functions
    //***************************************************
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dispatch_async(dispatch_get_main_queue()){
            //Textfield resigns focus to hide the keyboard
            self.searchTerm.resignFirstResponder()
            
            //Start the spinner
            self.spinner.startAnimating()
        }//main queue

        //Which ICD code set are we searching?
        let codeType = self.icdSelector.selectedSegmentIndex
        
        //Get a token
        TSClient.sharedInstance().getAquaToken(){(success,errorString) in
            if !success{
                TSClient.sharedInstance().errorDialog(self, errTitle: "Connection Error", action: "OK", errMsg: errorString!)
            }else{
                //println("Token: \(TSClient.sharedInstance().aqua.token)")
                let token = TSClient.sharedInstance().aqua.token                //Do a search using the textfield entry using the token
                TSClient.sharedInstance().getDx(codeType, searchTerm: textField.text!, token: token){(success,errorString) in
                    if !success{
                        dispatch_async(dispatch_get_main_queue()){
                        TSClient.sharedInstance().errorDialog(self, errTitle: "Search Result", action: "OK", errMsg: errorString!)
                        }//queue
                    }else{
                        //populate the table
                        //println("Cells to display: \(TSClient.sharedInstance().aqua.searchResults.count)")
                        dispatch_async(dispatch_get_main_queue()){
                            self.DxTableView.reloadData()
                        }
                    }
                }//getDx
            }//else
            dispatch_async(dispatch_get_main_queue()){
                //Start the spinner
                self.spinner.stopAnimating()
            }//main queue

        }//getAquaToken
        return false
    }//textFieldShouldReturn
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TSClient.sharedInstance().aqua.searchResults.count
    }//numberOfRows
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("diagnosisCell") as UITableViewCell!
        let code = TSClient.sharedInstance().aqua.searchResults[indexPath.row] as! NSDictionary
        cell.textLabel?.text = code["name"] as? String
        cell.detailTextLabel?.text = code["description"] as? String
        return cell
    }//cellForRow
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        //nix the highlight
        //Note that either the generic (tableview) or the specific (DxTableView) works
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        //No more than three total, so previously selected dxs count against this
        print("Current diagnoses: \(TSClient.sharedInstance().dxList.count)")
        if TSClient.sharedInstance().dxList.count > TSClient.Constants.diagnoses{
            //Let the user know what's up
            let dxTxt: String = "Diagnosis List is limited to " + String(TSClient.Constants.diagnoses + 1)
            TSClient.sharedInstance().errorDialog(self, errTitle: "Diagnosis List", action: "OK", errMsg: dxTxt)
            return nil
        }else{
            return indexPath
        }
        
    }//willSelectRow
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Get the selected cell
        let cell = DxTableView.cellForRowAtIndexPath(indexPath)
        
        //Show the checkmark
        //cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        let code = cell?.textLabel?.text as String!
        let desc = cell?.detailTextLabel?.text as String!
        let diagnosis: TSClient.Diagnosis = TSClient.Diagnosis(icdCode: code, description: desc)
        TSClient.sharedInstance().dxList.append(diagnosis)
 
        //Populate the diagnosis list
        dxListPopulate()
        
        //deselect the cell
        cell?.selected = false
        
        //Get the list of selections to this point
        //_ = tableView.indexPathsForSelectedRows
    }//didSelectRow


    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        //Get the selected cell
        //let cell = DxTableView.cellForRowAtIndexPath(indexPath)

        //Remove the check
        //cell!.accessoryType = UITableViewCellAccessoryType.None
        //let selected = tableView.indexPathsForSelectedRows
    }//didDeselect
    
    //***************************************************
    //Action functions
    //***************************************************

    //***************************************************
    // saveDx - The list is now saved in the delegate, so we're just returning here
    func saveDx() {
        self.navigationController?.popToRootViewControllerAnimated(true)
        //self.dismissViewControllerAnimated(true, completion: nil)
    }//saveDx

    @IBAction func clearDx(sender: UIButton) {
        //Clear out all the fields and the dxList
        TSClient.sharedInstance().dxList = []
        code0.text = ""
        code1.text = ""
        code2.text = ""
        desc0.text = ""
        desc1.text = ""
        desc2.text = ""
    }//clearDx
    
    //***************************************************
    //Helper functions
    //***************************************************
    
    //***************************************************
    // populate the diagnosis list
    func dxListPopulate() {
        //Stuff the values in
        switch TSClient.sharedInstance().dxList.count{
        case 1:
            code0.text = TSClient.sharedInstance().dxList[0].icdCode
            desc0.text = TSClient.sharedInstance().dxList[0].description
        case 2:
            code0.text = TSClient.sharedInstance().dxList[0].icdCode
            desc0.text = TSClient.sharedInstance().dxList[0].description
            code1.text = TSClient.sharedInstance().dxList[1].icdCode
            desc1.text = TSClient.sharedInstance().dxList[1].description
        case 3:
            code0.text = TSClient.sharedInstance().dxList[0].icdCode
            desc0.text = TSClient.sharedInstance().dxList[0].description
            code1.text = TSClient.sharedInstance().dxList[1].icdCode
            desc1.text = TSClient.sharedInstance().dxList[1].description
            code2.text = TSClient.sharedInstance().dxList[2].icdCode
            desc2.text = TSClient.sharedInstance().dxList[2].description
        default:
            break
        }//switch
    }//dxListPopulate
    
}//class
