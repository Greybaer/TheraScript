//
//  PTPractice.swift
//  TheraScript
//
//  Created by Greybear on 9/24/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//
//  Therapy practice CoreData object

import CoreData


class PTPractice : NSManagedObject{

    //Key/Value dictionary
    struct Keys{
        static let Name = "name"
        static let Address = "address"
        static let Phone = "phone"
    }//Keys
    
    //Promote to Core Data variables
    @NSManaged var name: String
    @NSManaged var address : String
    @NSManaged var phone : String
    
    //Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }//override init

    //our init method - allows insertion of data and initialization
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        //Get the entity information from the model file
        let entity = NSEntityDescription.entityForName("PTPractice", inManagedObjectContext: context)!
        
        //Call the super.init function to insert our object into the context
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        name = dictionary[Keys.Name] as! String
        address = dictionary[Keys.Address] as! String
        phone = dictionary[Keys.Phone] as! String
    }//init
    
}//class
