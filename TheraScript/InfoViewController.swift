//
//  InfoViewController.swift
//  TheraScript
//
//  Created by Greybear on 7/14/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//
//  Gather the user's information and store using NSKeyArchiver

import UIKit

class InfoViewController: UIViewController, UITextFieldDelegate {
    
    //Outlets
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var middleName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var degreeType: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!

    @IBOutlet weak var practiceName: UITextField!
    @IBOutlet weak var streetAddress: UITextField!
    @IBOutlet weak var cityName: UITextField!
    @IBOutlet weak var stateName: UITextField!
    @IBOutlet weak var zipCode: UITextField!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!

    //Variables
    //Struct holding the provider date we're inputting
    var provider = TSClient.Provider()
    
    //Keyboard up?
    var kbUp = false

    //***************************************************
    // Class Functions
    //***************************************************

    override func viewDidLoad() {
        super.viewDidLoad()
        // Handle textfield delegate duties here
        firstName.delegate = self
        middleName.delegate = self
        lastName.delegate = self
        degreeType.delegate = self
        phoneNumber.delegate = self //phoneTextDelegate
        practiceName.delegate = self
        streetAddress.delegate = self
        cityName.delegate = self
        stateName.delegate = self
        zipCode.delegate = self //zipTextDelegate
        self.navigationController?.toolbarHidden = true
    }//viewDidLoad


    override func viewWillAppear(animated: Bool) {
        /* Not needed for iPad version
        // Sign up for Keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        //KB Hide Notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillDisappear:", name: UIKeyboardWillHideNotification,
            object: nil)
        */
        //Are we in data entry or edit mode? Check the provider data to see
        if !(provider.firstName.isEmpty){
            //We're in edit mode, populate those fields
            self.firstName.text = provider.firstName
            self.middleName.text = provider.middleName
            self.lastName.text = provider.lastName
            self.degreeType.text = provider.degreeType
            self.phoneNumber.text = provider.phoneNumber
            self.practiceName.text = provider.practiceName
            self.streetAddress.text = provider.streetAddress
            self.cityName.text = provider.cityName
            self.stateName.text = provider.stateName
            self.zipCode.text = provider.zipCode
        }
    }//viewWillAppear
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        /* Not needed for iPad version
        //Remove us from keyboard notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "keyboardWillShow:", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "keyboardWillDisappear:", object: nil)
        */
    }//viewWillDisappear

    
    //***************************************************
    // Delegate Functions
    //***************************************************

    /* Not needed for iPad version

    //Slide the picture up to show bottom textfields when the keyboard slides in
    func keyboardWillShow(notification: NSNotification){
        //Getting multiple notifications, so we'll add a test to make sure we only respond to the first one
        if (practiceName.editing || streetAddress.editing || cityName.editing || stateName.editing || zipCode.editing) && !kbUp{
            self.view.frame.origin.y -= TSClient.sharedInstance().getKeyboardHeight(notification)
            //Set the flag to block additional notifications for this session
            kbUp = true
            //println("Sliding Frame up: \(self.view.frame.origin.y)")
        }//if
    }//keyboardWillShow
    
    //...and slide it back down when the view requires
    func keyboardWillDisappear(notification: NSNotification){
        if (zipCode.isFirstResponder() || firstName.isFirstResponder() || middleName.isFirstResponder() || lastName.isFirstResponder() || degreeType.isFirstResponder() ||
            phoneNumber.isFirstResponder()) && kbUp{
            //just reset the origin to zero since we're getting multiple notifications
            self.view.frame.origin.y = 0
            //reset the flag
            kbUp = false
            //self.view.frame.origin.y += getKeyboardHeight(notification)
            //println("Sliding Frame down: \(self.view.frame.origin.y)")
        }
    }//keyboardWillDisappear
    */

    
    //***************************************************
    // Handle the return key, iterating through the fields like a tab key
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch(textField){
        case firstName:
            firstName.resignFirstResponder()
            middleName.becomeFirstResponder()
        case middleName:
            middleName.resignFirstResponder()
            lastName.becomeFirstResponder()
        case lastName:
            lastName.resignFirstResponder()
            degreeType.becomeFirstResponder()
        case degreeType:
            degreeType.resignFirstResponder()
            phoneNumber.becomeFirstResponder()
        case phoneNumber:
            phoneNumber.resignFirstResponder()
            practiceName.becomeFirstResponder()
        case practiceName:
            practiceName.resignFirstResponder()
            streetAddress.becomeFirstResponder()
        case streetAddress:
            streetAddress.resignFirstResponder()
            cityName.becomeFirstResponder()
        case cityName:
            cityName.resignFirstResponder()
            stateName.becomeFirstResponder()
        case stateName:
            stateName.resignFirstResponder()
            zipCode.becomeFirstResponder()
        case zipCode:
            zipCode.resignFirstResponder()
            //firstName.becomeFirstResponder()
        default:
            firstName.becomeFirstResponder()
        }//switch
        //throw the return away
        return false
    }//textFieldSHouldReturn
    
    //***************************************************
    //Handle formatting in phone and zip fields
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        switch textField{
            case phoneNumber:
                
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
                let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
                let decimalString = components.joinWithSeparator("") //"".join(components) as NSString
                let length = decimalString.characters.count //decimalString.length
                let hasLeadingOne = length > 0 && decimalString.characters.first == "1" //decimalString.characterAtIndex(0) == 49 //unichar value of 1
            
                if length == 0 || (length > 10 && !hasLeadingOne) || length > 11{
                    let newLength = (textField.text as NSString!).length + (string as NSString).length - range.length as Int
                
                    return (newLength > 10) ? false : true
                }
                var index = 0 as Int
                let formattedString = NSMutableString()
            
                //If no leading one add one
                if !hasLeadingOne{
                    formattedString.appendString("1")
                }
                
                if hasLeadingOne{
                    formattedString.appendString("1")
                    index += 1
                }
            
                if (length - index) > 3{
                    let areaCode = decimalString.substringWithRange(decimalString.startIndex.advancedBy(index)...decimalString.startIndex.advancedBy(index + 2))
                    //var areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                    formattedString.appendFormat("(%@)", areaCode)
                    index += 3
                }
            
                if (length - index) > 3{
                    let prefix = decimalString.substringWithRange(decimalString.startIndex.advancedBy(index)...decimalString.startIndex.advancedBy(index + 2))
                    //var prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                    formattedString.appendFormat("%@-", prefix)
                    index += 3
                }
            
                let remainder = decimalString.substringFromIndex(decimalString.startIndex.advancedBy(index))
                //var remainder = decimalString.substringFromIndex(index)
                formattedString.appendString(remainder)
                textField.text = formattedString as String
                return false

            case zipCode:
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
                //let newLength = count(textField.text) + count(string) - range.length
                if (newLength > 5){
                    return false
                }
                return true

        case stateName:
                //Empty string? return it (backspace)
                if string.isEmpty{
                    return true
                }
                
                //2 letters only
                let isnum = Int(string)
                if isnum != nil{
                    return false
                }

                //An make it 2 chars long
                let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
                //let newLength = count(textField.text) + count(string) - range.length
                if (newLength > 2){
                    return false
                }
                //Make sure it's all uppercase
                textField.text = textField.text! + string.uppercaseString
                return false
            
            default:
                return true
        }//switch
    }//shouldChangeCharactersInRange
    
     //***************************************************
    // Action Functions
    //***************************************************
    
    //***************************************************
    // User clicked the Next button
    // Validate input info - if correct save and transition
    // to the graphic view
    @IBAction func nextButtonClicked(sender: AnyObject) {
        if (firstName.text!.isEmpty || middleName.text!.isEmpty || lastName.text!.isEmpty || degreeType.text!.isEmpty || phoneNumber.text!.isEmpty || practiceName.text!.isEmpty || streetAddress.text!.isEmpty || cityName.text!.isEmpty || stateName.text!.isEmpty || zipCode.text!.isEmpty){
            //Pop an error and return
            TSClient.sharedInstance().errorDialog(self, errTitle: "Information Entry Incomplete", action: "OK", errMsg: "One or more information fields are incomplete. Please ensure that all fields are completed")
        }else{
            //Populate the provider data structure for passing on
            provider.firstName = firstName.text!
            provider.middleName  = middleName.text!
            provider.lastName = lastName.text!
            provider.degreeType = degreeType.text!
            provider.phoneNumber = phoneNumber.text!
            provider.practiceName = practiceName.text!
            provider.streetAddress = streetAddress.text!
            provider.cityName = cityName.text!
            provider.stateName = stateName.text!
            provider.zipCode = zipCode.text!
        
            //Display a controller to grab the icon
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("IconViewController") as! IconViewController
            //Pass the data to the new view for completion
            controller.provider = provider
            //Push the controller, because we might not be back here
            self.navigationController?.pushViewController(controller, animated: true)
        }//if/else
    }//nextButtonClicked
}//class

