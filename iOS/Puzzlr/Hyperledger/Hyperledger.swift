//
//  Hyperledger.swift
//  Puzzlr
//
//  The shared method for all the chaincodes.
//
//  Created by Quentin Le Sceller on 08/03/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import Foundation

class OpenBlockchain {
    
    // The url tools.
    let urlTools = UrlTools()
    
    // The server ip and port:
    let server: String
    
    // The enroll ID.
    let enrollID : String
    
    // The enroll Secret.
    let enrollSecret : String
    
    // Use openSSL
    var useOpenSSL : Bool
    
    // Security Enabled
    var securityEnabled : Bool
    
    // Initializer
    init(ip: String,port : Int) {
        self.server = ip + ":" + String(port)
        self.enrollID = "NA"
        self.enrollSecret = "NA"
        useOpenSSL = false
        securityEnabled = false
    }
    
    // Initializer for security enabled
    init(ip : String, port : Int, enrollID : String, enrollSecret : String) {
        self.server = ip + ":" + String(port)
        self.enrollID = enrollID
        self.enrollSecret = enrollSecret
        useOpenSSL = false
        securityEnabled = true
    }
    /**
     Enable OpenSSL
     */
    func enableOpenSSL () {
        useOpenSSL = true
    }
    
    /**
     Create URL Request
     
     - parameter request: the request
     
     - returns: return the full request
     */
    private func createURLRequest(request : String) -> NSURL{
        var url : NSURL
        if useOpenSSL {
            url = NSURL(string: "https:" + server + request)!
        } else {
            url = NSURL(string: "http:" + server + request)!
        }
        return url
    }
    
    
    /**
     Query the chaincode
     
     - parameter type:     the language of the chaincode
     - parameter name:     the name of the chaincode
     - parameter function: the function to invoke
     - parameter args:     the arguments
     - parameter sync:     synchronous or asynchronous request
     
     - returns: the response
     */
    func query (type : String, name : String, function : String, args : [String], sync :Bool ) -> NSString {
        let request = "/devops/query"
        let url = createURLRequest(request)
        
        var response = NSString(UTF8String: "async")
        
        let chaincodeSpecJSON : NSMutableDictionary = NSMutableDictionary()
        
        chaincodeSpecJSON.setValue(type, forKey: "type")
        
        let chaincodeIDJSON : NSMutableDictionary = NSMutableDictionary()
        
        chaincodeIDJSON.setValue(name, forKey: "name")
        
        chaincodeSpecJSON.setValue(chaincodeIDJSON, forKey: "chaincodeID")
        let ctorMsgJSON : NSMutableDictionary = NSMutableDictionary()
        ctorMsgJSON.setValue(function, forKey: "function")
        
        ctorMsgJSON.setValue(args, forKey: "args")
        
        chaincodeSpecJSON.setValue(ctorMsgJSON, forKey: "ctorMsg")
        
        if securityEnabled {
            chaincodeSpecJSON.setValue(enrollID, forKey : "secureContext");
        }
        
        let bodyJSON : NSMutableDictionary = NSMutableDictionary()
        bodyJSON.setValue(chaincodeSpecJSON, forKey: "chaincodeSpec")
        
        let jsonData: NSData
        
        let jsonBody : NSString?
        
        do{
            jsonData = try NSJSONSerialization.dataWithJSONObject(bodyJSON, options: NSJSONWritingOptions())
            jsonBody = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            
            if sync {
                response = urlTools.postSynchronous(url, jsonBody: jsonBody!)
            } else {
                urlTools.post(url, jsonBody: jsonBody!)
            }
        } catch _ {
            print ("JSONFailed")
        }
        return response!
        
    }
    
    /**
     Invoke the chaincode.
     
     - parameter type:     the language of the chaincode
     - parameter name:     the name of the chaincode
     - parameter function: the function to invoke
     - parameter args:     the arguments
     - parameter sync:     asynchronous or synchronous request
     
     - returns: the response
     */
    func invoke (type : String, name : String, function : String, args : [String], sync :Bool ) -> NSString {
        let request = "/devops/invoke"
        let url = createURLRequest(request)
        
        var response = NSString(UTF8String: "async")
        
        let chaincodeSpecJSON : NSMutableDictionary = NSMutableDictionary()
        chaincodeSpecJSON.setValue(type, forKey: "type")
        
        let chaincodeIDJSON : NSMutableDictionary = NSMutableDictionary()
        chaincodeIDJSON.setValue(name, forKey: "name")
        
        chaincodeSpecJSON.setValue(chaincodeIDJSON, forKey: "chaincodeID")
        
        // cTorMsg
        let ctorMsgJSON : NSMutableDictionary = NSMutableDictionary()
        ctorMsgJSON.setValue(function, forKey: "function")
        
        ctorMsgJSON.setValue(args, forKey: "args")
        
        chaincodeSpecJSON.setValue(ctorMsgJSON, forKey: "ctorMsg")
        
        if securityEnabled {
            chaincodeSpecJSON.setValue(enrollID, forKey : "secureContext");
        }
        
        let bodyJSON : NSMutableDictionary = NSMutableDictionary()
        bodyJSON.setValue(chaincodeSpecJSON, forKey: "chaincodeSpec")
        
        let jsonData: NSData
        
        let jsonBody : NSString?
        
        do{
            
            jsonData = try NSJSONSerialization.dataWithJSONObject(bodyJSON, options: NSJSONWritingOptions())
            jsonBody = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            
            if sync {
                response = urlTools.postSynchronous(url, jsonBody: jsonBody!)
            } else {
                urlTools.post(url, jsonBody: jsonBody!)
            }
        } catch _ {
            print ("JSONFailed")
        }
        return response!
        
    }
    
}

