//
//  UserBlockchain.swift
//  Puzzlr
//
//  This class represent the Blockchain containing user pseudonym and password.
//
//  Created by Quentin Le Sceller on 09/03/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import Foundation

class UserBlockchain {
    
    // Var used to know if the user is connected.
    var connected : Bool
    
    // Use to store variable on the iDevice.
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // The blockchain main object.
    let blockchain : OpenBlockchain
    
    // The language used for the chaincode.
    let type : String
    
    // The name of the chaincode (usually hash value).
    let name : String
    
    // Initializer
    init(ip: String,port : Int) {
        blockchain = OpenBlockchain(ip: ip, port: port)
        type = "GOLANG";
        name = "e72785e0db781f0f37914d5279e26cb001c098fc1f79dfad1220a3e780ba253fea6703755556d072aeb57a939fe9804ee1d80037f41534bb29718da3978e977e";
        
        if defaults.boolForKey("connected") == Bool(true) {
            connected = defaults.boolForKey("connected")
        }
        else {
            connected = Bool(false)
        }
        
    }
    
    
    /**
     Get if an user is registered
     
     - parameter user: the username
     - parameter sync: synchronous or asynchronous request
     
     - returns: true if the user is registered, false otherwise:
     */
    func getRegistered(user : String, sync : Bool) -> Bool {
        var registered = Bool(false)
        let args : [String] = [user]
        
        let response = blockchain.query(type, name: name, function: "query", args: args, sync: sync)
        
        if response.containsString("isRegisteredTrue"){
            registered = Bool(true)
        }
        return registered
    }
    
    /**
     Register an user
     
     - parameter user:     the username
     - parameter password: the password
     - parameter sync:     synchronous or asynchronous request
     
     - returns: true if successfully registered, false otherwise.
     */
    func registerUser(user : String, password : String, sync : Bool) -> Bool {
        var success = Bool(true)
        let args : [String] = [user,password]
        
        if !getRegistered(user, sync: sync) {
            blockchain.invoke(type, name: name, function: "invoke", args: args, sync: sync)
        } else {
            success = Bool(false)
        }
        return success
    }
    
    
    /**
     Delete an user from the database.
     
     - parameter user:     the username
     - parameter password: the password
     - parameter sync:     synchronous or asynchronous request
     
     - returns: true if successfully deleted, false otherwise.
     */
    func deleteUser(user : String,password : String, sync : Bool) -> Bool {
        var success = Bool(true)
        let args : [String] = [user]
        
        if login(user, password: password, sync: sync) {
            blockchain.invoke(type, name: name, function: "delete", args: args, sync: sync)
        } else {
            success = Bool(false)
        }
        
        return success
    }
    
    /**
     Log the user:
     
     - parameter user:     the username
     - parameter password: the password
     - parameter sync:     synchronous or asynchronous request
     
     - returns: true if successfully logged, false otherwise.
     */
    func login(user : String, password : String, sync : Bool) -> Bool {
        var retrievedHashedPassword : NSString?
        var success = Bool(false)
        let args : [String] = [user,""]
        
        // Checking if the user is registered.
        if getRegistered(user, sync: sync){
            
            let result = blockchain.query(type, name: name, function: "query", args: args, sync: sync)
            retrievedHashedPassword = result.substringFromIndex(7)
            let index = retrievedHashedPassword!.length.advancedBy(-2)
            retrievedHashedPassword = retrievedHashedPassword!.substringToIndex(index)
            if (JKBCrypt.verifyPassword(password, matchesHash: String(retrievedHashedPassword!)) == Bool(true)) {
                success = Bool(true)
            }
        }
        return success
    }
    
    
}
