//
//  DataBlockchain.swift
//  Puzzlr
//
//  The blockchain which contains the data.
//
//  Created by Quentin Le Sceller on 09/03/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import Foundation

class DataBlockchain {
    
    // The main blokchain:
    let blockchain : OpenBlockchain
    
    // The language used for the chaincode.
    let type : String
    
    // The name of the chaincode (usually hash value).
    let name : String
    
    // The hash value.
    let hash : Hash
    
    // Initializer
    init(ip: String,port : Int) {
        blockchain = OpenBlockchain(ip: ip, port: port)
        type = "GOLANG";
        name = "1ce07c739447a8abea238dfe9dc90b94bc32d56c2ea2f81af773cc11e9bfc9fc4b68a7cd7fccd418cd5da90fdfa6a72e5f72357bfc7b96ac8af251fd5f746a42";
        
        hash = Hash()
    }
    
    /**
     Send Message to the blockchain
     
     - parameter username: the username of the recipient
     - parameter data:     the data to send
     - parameter sync:     synchronous or asynchronous request
     */
    func sendMessage(username : String, data : String, sync : Bool){
        let hashValue = hash.getSHA256(data)
        print(hashValue)
        let argsUserMessages = [username, String(hashValue)]
        let argsMessage = [String(hashValue), data]
        
        blockchain.invoke(type, name: name, function: "invoke", args: argsUserMessages, sync: sync)
        blockchain.invoke(type, name: name, function: "invoke", args: argsMessage, sync: sync)
    }
    
    /**
     Get all the messages sent to an user.
     
     - parameter username: the username of the user.
     - parameter sync:     synchronous or asynchronous request
     
     - returns: all the messages in a dictionnary.
     */
    func getAllMessages(username : String, sync : Bool) -> [String : String] {
        var messages = [String : String]()
        
        let args = [username]
        
        let hashesJSON = blockchain.query(type, name: name, function: "query", args: args, sync: sync)
        
        var rawHashes = hashesJSON.substringFromIndex(7)
        let indexHash = rawHashes.endIndex.advancedBy(-2)
        rawHashes = rawHashes.substringToIndex(indexHash)
        
        for i in 0 ..< rawHashes.characters.count/64 {
            let hash = rawHashes.substringWithRange(Range<String.Index>(start: rawHashes.startIndex.advancedBy(64*i), end: rawHashes.startIndex.advancedBy(64*(i+1))))
            let argHash = [hash]
            
            let dataJSON = blockchain.query(type, name: name, function: "query", args: argHash, sync: sync)
            
            var value = dataJSON.substringFromIndex(7)
            let indexValue = value.endIndex.advancedBy(-2)
            value = value.substringToIndex(indexValue)
            
            messages[hash] = value
            deleteData(hash,sync: sync)
        }
        deleteData(username,sync: sync)
        
        return messages
    }
    
    /**
     Delete data from server
     
     - parameter key:  the key
     - parameter sync:     synchronous or asynchronous request
     */
    func deleteData(key : String, sync :Bool) {
        let args = [key]
        blockchain.invoke(type, name: name, function: "delete", args: args, sync: sync)
    }
    
}