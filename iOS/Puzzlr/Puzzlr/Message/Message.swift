//
//  Message.swift
//  Puzzlr
//
//  The message object
//
//  Created by Quentin Le Sceller on 15/02/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import UIKit

class Message: NSObject, NSCoding {
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("messages")
    
    
    // MARK: Properties
    var icon : UIImage?
    var name: String
    var type : Int
    var photo: UIImage?
    
    // MARK: Initialization
    init?(icon : UIImage? ,name: String, type : Int, photo: UIImage?) {
        // Initialize stored properties.
        self.icon = icon
        self.name = name
        self.type = type
        self.photo = photo
        
        super.init()
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty {
            return nil
        }
    }
    
    // MARK: Types
    struct PropertyKey {
        static let iconKey = "icon"
        static let nameKey = "name"
        static let typeKey = "type"
        static let photoKey = "photo"
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(icon, forKey: PropertyKey.iconKey)
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(type, forKey: PropertyKey.typeKey)
        aCoder.encodeObject(photo, forKey: PropertyKey.photoKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let icon = aDecoder.decodeObjectForKey(PropertyKey.iconKey) as? UIImage
        
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        let type = aDecoder.decodeObjectForKey(PropertyKey.typeKey) as! Int
        
        // Because photo is an optional property of Message, use conditional cast.
        let photo = aDecoder.decodeObjectForKey(PropertyKey.photoKey) as? UIImage
        
        // Must call designated initializer.
        self.init(icon : icon, name: name,type : type, photo: photo)
    }
}