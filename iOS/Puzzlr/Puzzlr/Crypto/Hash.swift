//
//  Hash.swift
//  Puzzlr
//
//  Class used for Hashing
//
//  Created by Quentin Le Sceller on 09/03/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import Foundation
import CryptoSwift

class Hash {
    
    /**
     Get the SHA256 of a String
     
     - parameter message: the string to hash
     
     - returns: the SHA256 value
     */
    func getSHA256(message : String) -> NSString {
        
        let data = NSData()
        
        let hash = data.sha256()
        
        let dataString = hash?.toHexString()
        
        return dataString!
    }
    
    /**
     Get the SHA512 of a String
     
     - parameter message: the string to hash
     
     - returns: the SHA512 value
     */
    func getSHA512(message : String) -> NSString {
        
        let data = NSData()
        
        let hash = data.sha512()
        
        let dataString = String(data: hash!, encoding: NSUTF8StringEncoding)
        
        return dataString!
    }
}