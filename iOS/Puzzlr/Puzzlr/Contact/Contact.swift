//
//  Contact.swift
//  Puzzlr
//
//  The contact object.
//
//  Created by Quentin Le Sceller on 15/02/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import UIKit

class Contact: NSObject, NSCoding {
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("contacts")
    
    
    // MARK: Properties
    var name: String
    var publickey: String

    
    // MARK: Initialization
    init?(name: String, publickey: String) {
        // Initialize stored properties.
        self.name = name
        self.publickey = publickey
        
        super.init()
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty {
            return nil
        }
    }
    
    // MARK: Types
    struct PropertyKey {
        static let nameKey = "name"
        static let publicKeyKey = "publickey"
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(publickey, forKey: PropertyKey.publicKeyKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        let publickey = aDecoder.decodeObjectForKey(PropertyKey.publicKeyKey)  as! String
        
        // Must call designated initializer.
        self.init(name: name, publickey: publickey)
    }
}