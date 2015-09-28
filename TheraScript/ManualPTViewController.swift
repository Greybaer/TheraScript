//
//  ManualPTViewController.swift
//  TheraScript
//
//  Created by Greybear on 8/31/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit

class ManualPTViewController: UIViewController, UITextFieldDelegate {

    //Variables
    

    
    //Outlets
    @IBOutlet weak var PTPractice: UITextField!
    @IBOutlet weak var PTAddress: UITextField!
    @IBOutlet weak var PTCity: UITextField!
    @IBOutlet weak var PTState: UITextField!
    @IBOutlet weak var PTZip: UITextField!
    @IBOutlet weak var PTPhone: UITextField!
    
    override func viewDidLoad() {
        //We're our own delegate
        PTPractice.delegate = self
        PTAddress.delegate = self
        PTCity.delegate = self
        PTState.delegate = self
        PTZip.delegate = self
        PTPhone.delegate = self
    }//viewDidLoad
    
    override func viewWillAppear(animated: Bool) {
        //Add a completion button to the nav bar
        //Adding nav items has to be done here because tabs don't reload on navigation between views

        var acceptButton = UIBarButtonItem(title: "Accept", style: UIBarButtonItemStyle.Plain, target: self, action: "savePTInfo")
        self.tabBarController!.navigationItem.rightBarButtonItem = acceptButton
        
        //Set the title of the view
        self.tabBarController!.navigationItem.title = "Manual Practice Entry"
        
        //Hide the toolbar here
        self.navigationController?.toolbarHidden = true
    }//viewWillAppear
    
    //***************************************************
    // Delegate Functions
    //***************************************************

    //***************************************************
    // Handle returns by shifting focus
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField{
        case PTPractice:
            PTPractice.resignFirstResponder()
            PTAddress.becomeFirstResponder()
        case PTAddress:
            PTAddress.resignFirstResponder()
            PTCity.becomeFirstResponder()
        case PTCity:
            PTCity.resignFirstResponder()
            PTState.becomeFirstResponder()
        case PTState:
            PTState.resignFirstResponder()
            PTZip.becomeFirstResponder()
        case PTZip:
            PTZip.resignFirstResponder()
            PTPhone.becomeFirstResponder()
        case PTPhone:
            PTPhone.resignFirstResponder()
        default:
            PTPractice.becomeFirstResponder()
        }//switch
        return false
    }//shouldReturn
    
    //***************************************************
    //Handle formatting in phone and zip fields
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        switch textField{
        case PTPhone:
            
            //Empty string? (backspace) allow it
            if string.isEmpty{
                return true
            }
            //Is the new input a number? If not, disallow it
            let isnum = string.toInt()
            
            if isnum == nil{
                return false
            }
            
            // Adapted from http://stackoverflow.com/questions/27609104/xcode-swift-formatting-text-as-phone-number
            var newString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            var components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            var decimalString = "".join(components) as NSString
            var length = decimalString.length
            var hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == 49 //unichar value of 1
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11{
                var newLength = (textField.text as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            var formattedString = NSMutableString()

            //If no leading one add one
            if !hasLeadingOne{
                formattedString.appendString("1")
            }
            
            if hasLeadingOne{
                formattedString.appendString("1")
                index += 1
            }
            
            if (length - index) > 3{
                var areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            
            if length - index > 3{
                var prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            var remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            return false

        case PTState:
            //Empty string? return it (backspace)
            if string.isEmpty{
                return true
            }
            
            //2 letters only
            let isnum = string.toInt()
            if isnum != nil{
                return false
            }
            
            //An make it 2 chars long
            let newLength = count(textField.text) + count(string) - range.length
            if (newLength > 2){
                return false
            }
            //Make sure it's all uppercase
            textField.text = textField.text + string.uppercaseString
            return false

        case PTZip:
            //Empty string? return it (backspace)
            if string.isEmpty{
                return true
            }
            //Is the new input a number? If not, disallow it
            let isnum = string.toInt()
            
            if isnum == nil{
                return false
            }
            
            //Is the length greater than 5? If so, disallow it
            let newLength = count(textField.text) + count(string) - range.length
            if (newLength > 5){
                return false
            }
            return true
        default:
            return true
        }//switch
    }//shouldChangeCharactersInRange

    //***************************************************
    // Action Functions
    //***************************************************

    //***************************************************
    // savePTInfo - Save the manually entered practice info
    func savePTInfo(){
        if(PTPractice.text.isEmpty || PTAddress.text.isEmpty || PTCity.text.isEmpty || PTState.text.isEmpty || PTZip.text.isEmpty || PTPhone.text.isEmpty){
        //Pop an error and return
        TSClient.sharedInstance().errorDialog(self, errTitle: "PT Information Entry Incomplete", action: "OK", errMsg: "One or more PT practice fields are incomplete. Please ensure that all fields are completed")
        }else{
            //Save the data for later Core Data storage
            TSClient.sharedInstance().therapy.practiceName = PTPractice.text
            TSClient.sharedInstance().therapy.practiceAddress = "\(PTAddress.text) \(PTCity.text) \(PTState.text) \(PTZip.text)"
            TSClient.sharedInstance().therapy.practicePhone = PTPhone.text
            //Ask to save info in favorites
            TSClient.sharedInstance().confirmationDialog(self)
        }//if/else
    }//savePTInfo
    
}//class
