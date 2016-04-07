//
//  PublicKeyBlockchain.swift
//  Puzzlr
//
//  This class represent the Blockchain containing user's public key.
//
//  Created by Quentin Le Sceller on 09/03/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import Foundation

class PublicKeyBlockchain {
    
    // The main blokchain:
    let blockchain : OpenBlockchain
    
    // The user blockchain:
    let userBlockchain : UserBlockchain
    
    // The language used for the chaincode.
    let type : String
    
    // The name of the chaincode (usually hash value).
    let name : String
    
    // Initializer
    init(ip: String,port : Int) {
        blockchain = OpenBlockchain(ip: ip, port: port)
        type = "GOLANG";
        name = "7e60d53a09aff0a72728b64decb0600ceae25339ca5389e6b3c5d48116a00df3c753c06da58b4c906bd6cd71d1f91827938b50f468be43b27bb1dc700bd0df7f";
        userBlockchain = UserBlockchain(ip: ip, port: port)
    }
    
    /**
     Register public key on blockchain.
     
     - parameter user:      the username
     - parameter publickey: user's publickey
     - parameter sync:      synchronous or asynchronous request
     
     - returns: true if successfully registered, false otherwise:
     */
    func registerPublicKey(user : String, publickey : String, sync : Bool) -> Bool {
        var success = Bool(true)
        let args = [user, publickey]
        
        if userBlockchain.getRegistered(user, sync: sync) {
            blockchain.invoke(type, name: name, function: "invoke", args: args, sync: sync)
        } else {
            success = Bool(false)
            print("User is not registered")
        }
        print("success!")
        return success
    }
    
    /**
     Delete public key on blockchain.
     
     - parameter user:      the username
     - parameter publickey: user's publickey
     - parameter sync:      synchronous or asynchronous request
     
     - returns: true if successfully deleted, false otherwise:
     */
    func deletePublicKey(user : String, password : String, sync : Bool)-> Bool {
        var success = Bool(true)
        let args = [user]
        
        if (userBlockchain.login(user, password: password, sync: sync)){
            blockchain.invoke(type, name: name, function: "delete", args: args, sync: sync)
        } else {
            success = Bool(false)
        }
        return success
    }
    
    /**
     Query public key linked to an username.
     
     - parameter user: the username
     - parameter sync: synchronous or asynchronous request
     
     - returns:  true if successfully retrieved, false otherwise:
     */
    func queryPublicKey(user : String, sync : Bool) -> NSString {
        var publickey : NSString?
        let args = [user]
        
        if userBlockchain.getRegistered(user, sync: sync){
            let result = blockchain.query(type, name: name, function: "query", args: args, sync: sync)
            publickey = result.substringFromIndex(7)
            let index1 = publickey?.length.advancedBy(-2)
            publickey = publickey?.substringToIndex(index1!)
        } else {
            publickey = "null"
        }
        
        return publickey!
    }
    
    
}