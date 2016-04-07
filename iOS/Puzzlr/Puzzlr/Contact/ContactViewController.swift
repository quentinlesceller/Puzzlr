//
//  ContactViewController.swift
//  Puzzlr
//
//  The contact view controller.
//
//  Created by Quentin Le Sceller on 29/02/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var pbkeyLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
     This value is either passed by `ContactTableViewController` in `prepareForSegue(_:sender:)`
     or constructed as part of adding a new contact.
     */
    var contact: Contact?
    
    let publickeyBlockchain = PublicKeyBlockchain(ip: Server.sharedInstance.getIP(), port: 3000)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.autocorrectionType = .No
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        // Set up views if editing an existing Contact.
        if let contact = contact {
            navigationItem.title = contact.name
            nameTextField.text   = contact.name
            pbkeyLabel.text = contact.publickey
            
        }
        
        // Enable the Save button only if the text field has a valid Contact name.
        checkValidContactName()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidContactName()
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
    }
    
    func checkValidContactName() {
        // Disable the Save button if the text field is empty.
        
        let text = nameTextField.text ?? ""
        
        if !text.isEmpty {
            
            pbkeyLabel.text = String(publickeyBlockchain.queryPublicKey(text, sync: true))
            
            if !(pbkeyLabel.text?.isEmpty)!{
                
                let retrievedPublicKeyString = pbkeyLabel.text!
                print(retrievedPublicKeyString)
                RSAUtils.addRSAPublicKey(retrievedPublicKeyString, tagName: text)
        
                
                if (!self.pbkeyLabel.text!.containsString("null")) {
                    self.saveButton.enabled = true
                }
            }
        }
    }
    
    // MARK: Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        
        let isPresentingInAddContactMode = presentingViewController is SWRevealViewController
        
        if isPresentingInAddContactMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let name = nameTextField.text ?? ""
            let publickey = ""
            
            // Set the contact to be passed to ContactTableViewController after the unwind segue.
            contact = Contact(name: name, publickey: publickey)
        }
    }
}
