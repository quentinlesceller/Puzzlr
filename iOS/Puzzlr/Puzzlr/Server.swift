//
//  Server.swift
//  Puzzlr
//
//  Created by Quentin Le Sceller on 07/04/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import Foundation

class Server {
    static let sharedInstance = Server()
    
    internal let ip = "169.254.196.117"
    
    func getIP() -> String {
        return ip
    }
}