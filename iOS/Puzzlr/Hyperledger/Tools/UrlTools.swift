//
//  UrlTools.swift
//  Swift-OBC
//
//  Tools to make GET and POST request.
//
//  Created by Quentin Le Sceller on 08/03/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import Foundation

public class UrlTools {
    
    /**
     GET synchronous request
     
     - parameter url: the url
     
     - returns: the response
     */
    func getSynchronous(url : NSURL) -> NSString{
        var output : NSString?
        let request: NSURLRequest = NSURLRequest(URL: url)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse? >= nil
        
        do {
            let dataVal: NSData =  try NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
            output = (NSString(data: dataVal, encoding: NSUTF8StringEncoding))!
        } catch {
            
        }
        return output!
    }
    
    
    /**
     GET asynchronous request:
     
     - parameter url: the url
     */
    func get(url : NSURL) {
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            let output = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(output!)
        }
        
        task.resume()
    }
    
    /**
     POST synchronous request.
     
     - parameter url:      the url
     - parameter jsonBody: the body to send in JSON
     
     - returns: the response
     */
    func postSynchronous(url : NSURL, jsonBody : NSString) -> NSString {
        var output : NSString?
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding);
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse? >= nil
        
        do {
            let dataVal: NSData =  try NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
            output = (NSString(data: dataVal, encoding: NSUTF8StringEncoding))!
        } catch {
            print("error sync post http")
        }
        
        return output!
    }
    
    
    
    /**
     POST asynchronous request.
     
     - parameter url:      the url
     - parameter jsonBody: the body to send in JSON
     */
    func post(url : NSURL, jsonBody : NSString ) {
        
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        let postString = jsonBody
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
}

