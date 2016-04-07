//
//  ContactTableViewController.swift
//  Puzzlr
//
//  The contact table view controller.
//
//  Created by Quentin Le Sceller on 29/02/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import UIKit

class ContactTableViewController: UITableViewController {
    
    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    let publickeyBlockchain = PublicKeyBlockchain(ip: Server.sharedInstance.getIP(), port: 3000)
    
    var contacts = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if let savedContacts = loadContacts() {
            contacts += savedContacts
            loadSampleContacts()
        } else {
            // Load the sample data.
            loadSampleContacts()
        }
    }
    
    /**
     Load sample contacts
     */
    func loadSampleContacts() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let username = String(defaults.valueForKey("username")!)
        let contactMe = Contact(name: username, publickey : String(publickeyBlockchain.queryPublicKey(username, sync: true)))!
        contacts += [contactMe]
    }
    
    
    /**
     Load refresh data
     */
    func refreshData(){
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
        return contacts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ContactTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ContactTableViewCell
        
        // Fetches the appropriate contacts for the data source layout.
        let contact = contacts[indexPath.row]
        
        cell.nameLabel.text = contact.name
        
        
        return cell
    }
    
    @IBAction func unwindToContactList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? ContactViewController, contact = sourceViewController.contact {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing contact.
                contacts[selectedIndexPath.row] = contact
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            }
            else {
                // Add a new contact.
                //let newIndexPath = NSIndexPath(forRow: contacts.count, inSection: 0)
                let newIndexPath = NSIndexPath(forRow: contacts.count, inSection: 0)
                contacts.append(contact)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
            // Save the contacts.
            saveContacts()
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
            contacts.removeAtIndex(indexPath.row)
            saveContacts()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let contactDetailViewController = segue.destinationViewController as! ContactViewController
            // Get the cell that generated this segue.
            if let selectedContactCell = sender as? ContactTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedContactCell)!
                let selectedContact = contacts[indexPath.row]
                contactDetailViewController.contact = selectedContact
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new contact.")
        }
    }
    
    // MARK: NSCoding
    func saveContacts() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(contacts, toFile: Contact.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save contacts...")
        }
    }
    func loadContacts() -> [Contact]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Contact.ArchiveURL.path!) as? [Contact]
    }
    
}
