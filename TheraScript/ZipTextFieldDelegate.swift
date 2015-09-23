//
//  ZipTextFieldDelegate.swift
//  TheraScript
//
//  Created by Greybear on 7/16/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import Foundation
import UIKit

class zipTextFieldDelegate : NSObject, UITextFieldDelegate {
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        println("String: \(string)")
        println("Text: \(textField.text)")
        
        // Is this a backspace/delete char? If so let it go
        //Yes, it's a kuldge, but it works so go with it!
        if string == ""{
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
    }
    
}
