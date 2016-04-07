//
//  MessageTableViewController.swift
//  Puzzlr
//
//  The message table view controller.
//
//  Created by Quentin Le Sceller on 15/02/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import UIKit

class MessageTableViewController: UITableViewController {
    // MARK: Properties
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var messages = [Message]()
    
    let cryptoMessage = CryptoMessage()
    let dataBlockchain = DataBlockchain(ip: Server.sharedInstance.getIP(), port: 3000)
    
    let userBlockchain = UserBlockchain(ip: Server.sharedInstance.getIP(), port: 3000)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if user is regsitered
        if !userBlockchain.connected {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                self.presentViewController(viewController, animated: true, completion: nil)
            })
        }
        
        // Use the edit button item provided by the table view controller.
        //navigationItem.leftBarButtonItem = editButtonItem()
        
        // Test pull down to refresh.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshData"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        // Load any saved messages, otherwise load sample data.
        if let savedMessages = loadMessages() {
            messages += savedMessages
        }
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    /**
     Refresh data
     */
    func refreshData(){
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let username =  defaults.valueForKey("username") as? String {
            let ciphertextArray = dataBlockchain.getAllMessages(username, sync: Bool(true))
            
            for ciphertext in ciphertextArray {
                if (!(ciphertext.0.containsString("Error")) && !(ciphertext.1.containsString("Error"))){
                    let message = cryptoMessage.retrieveImage(ciphertext.1)!
                    messages += [message]
                    saveMessages()
                }
            }
            
        }
        
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func refreshIcons(){
        
        tableView.reloadData()
        refreshControl?.endRefreshing()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MessageTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MessageTableViewCell
        
        // Fetches the appropriate messages for the data source layout.
        let message = messages[indexPath.row]
        
        cell.nameLabel.text = message.name
        cell.photoImageView.image = message.icon
        
        return cell
    }
    
    @IBAction func unwindToMessageList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? MessageViewController, message = sourceViewController.message {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing message.
                messages[selectedIndexPath.row] = message
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            }
            else {
                // Add a new message.
                let newIndexPath = NSIndexPath(forRow: messages.count, inSection: 0)
                messages.append(message)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
            // Save the messages.
            saveMessages()
        }
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            messages.removeAtIndex(indexPath.row)
            saveMessages()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let messageDetailViewController = segue.destinationViewController as! MessageViewController
            // Get the cell that generated this segue.
            if let selectedMessageCell = sender as? MessageTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedMessageCell)!
                let selectedMessage = messages[indexPath.row]
                messageDetailViewController.message = selectedMessage
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new message.")
            
        }
    }
    
    // MARK: NSCoding
    func saveMessages() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(messages, toFile: Message.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save messages...")
        }
    }
    func loadMessages() -> [Message]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Message.ArchiveURL.path!) as? [Message]
    }
    
    //MARK: Forcing reload
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        refreshIcons()
        saveMessages()
    }
    
}
