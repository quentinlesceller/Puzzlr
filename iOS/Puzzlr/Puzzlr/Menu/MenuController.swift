//
//  MenuController.swift
//  Puzzlr
//
//  Created by Quentin Le Sceller on 15/02/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = NSUserDefaults.standardUserDefaults()
        tableView.scrollEnabled = false;
        // Show the current visitor's username
        if let pUserName =  defaults.valueForKey("username") as? String {
            self.userNameLabel.text = pUserName
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
