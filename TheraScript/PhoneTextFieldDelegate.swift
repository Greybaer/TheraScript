//
//  PhoneTextFieldDelegate.swift
//  TheraScript
//
//  Created by Greybear on 7/16/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import Foundation
import UIKit

class phoneTextFieldDelegate : NSObject, UITextFieldDelegate {
    
    // Format phone number into correct US format from numbers
    // Adapted from http://stackoverflow.com/questions/27609104/xcode-swift-formatting-text-as-phone-number
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        
        //Let the nonstring characters through (I'm looking at you, backspace...)
        if string != ""{
            return true
        }else{
        
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
            
            if hasLeadingOne{
                formattedString.appendString("1 ")
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
        }
    }//textField shouldChange
    
    //We're our own delegate up in here, so we have to handle this
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}//class

      