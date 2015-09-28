//
//  TSData.swift
//  TheraScript
//
//  Created by Greybear on 7/22/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//  
//  Constant/Data structures and variables

import UIKit
import CoreData

extension TSClient{
    
    //Constant name data
    struct Constants{
        //Default ISI logo
        static let isiLogo = "isilogosquare"
        //The filename of the user's selected logo
        static let userLogo = "icon"
        //The Aqua.io constants
        //Currently we're searching for either name or code
        static let AQUA_BASE_URL = "https://api.aqua.io/codes/beta/"
        static let AQUA_TOKEN_URL = "https://api.aqua.io/oauth/token"
        static let ICD9 = "icd9.json"
        static let ICD10 = "icd10.json"
        //Aqua.io credentials
        static let AQUA_ID = "2af78a71823fb87776835056165bae8939a3b8d6017844cabe0c66aad47557dd"
        static let AQUA_SECRET = "cd1f147bca1c2f622c0ee53043ff09e315c20d1d32e03d184b2c18a932bbc213"
        //Ziptastic API constants
        static let ZIP_BASE_URL = "http://ziptasticapi.com/"
        //The max number of Diagnoses allowed
        static let diagnoses = 2
        static let PTVisits = 4.0
        static let minPTVisits = 1.0
        static let maxPTVisits = 20.0
        static let PTMessage = "Physical Therapy Prescription for "
    }//Constants
    
    //Token
    struct Aqua{
        var token: String = ""
        var searchResults: NSArray = []
    }//aqua
    
    //The provider information dictionary structure for the NSArchiver Dictionary
    struct ProviderInfo{
        static let firstName = "firstName"
        static let middleName = "middleName"
        static let lastName = "lastName"
        static let degreeType = "degreeType"
        static let phoneNumber = "phoneNumber"
        static let practiceName = "practiceName"
        static let streetAddress = "streetAddress"
        static let cityName = "cityName"
        static let stateName = "stateName"
        static let zipCode = "zipCode"
        static let icon = "icon"
        static let fileName = "providerinfo"
    }//provder info
    
    //Provider data
    struct Provider{
        var firstName: String = ""
        var middleName: String = ""
        var lastName: String = ""
        var degreeType: String = ""
        var phoneNumber: String = ""
        var practiceName: String = ""
        var streetAddress: String = ""
        var cityName: String = ""
        var stateName: String = ""
        var zipCode: String = ""
        var icon: UIImage? = nil
    }//Provider
    
    //Therapy Info
    //Temp holder for Core Data saves
    struct Therapy{
        var practiceName: String = ""
        var practiceAddress: String = ""
        var practicePhone: String = ""
    }//Therapy
    
    //The patient data
    struct Patient{
        var Name: String = ""
        var Address: String = ""
        //var patientCity: String = ""
        //var State: String = ""
        var Zip: String = ""
        var Phone: String = ""
    }//patient
    
    //Diagnosis data
    struct Diagnosis{
        var icdCode: String = ""
        var description: String = ""
        
        init(icdCode: String, description: String){
            self.icdCode = icdCode
            self.description = description
        }//init
    }//Diagnosis
    
    //Prescription Data
    struct Prescription{
        var visits: Double = 0.0
        var report: Bool = false
        var modalities: Bool = false
        var conditioning: Bool = false
        var coreStab: Bool = false
        var manualTherapy: Bool = false
        var poolTherapy: Bool = false
        var neckSchool: Bool = false
        var backSchool: Bool = false
        var cSoftCollar: Bool = false
        var lso: Bool = false
        var cHardCollar: Bool = false
        var tlso: Bool = false
        var ctlso: Bool = false
        var tns: Bool = false
        //If we accepted a prescription trip this flag
        var rxSelected: Bool = false
    }//Prescription

    //Path to the save location of the map region data
    var providerFilePath: String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent(ProviderInfo.fileName).path!
    }//providerFilePath
    
}//extension

