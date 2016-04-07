//
//  MessageViewController.swift
//  Puzzlr
//
//  The message view controller.
//
//  Created by Quentin Le Sceller on 15/02/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import UIKit
import Security

class MessageViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
     This value is either passed by `MessageTableViewController` in `prepareForSegue(_:sender:)`
     or constructed as part of adding a new message.
     */
    var message: Message?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        nameTextField.autocorrectionType = .No
        // Set up views if editing an existing Message.
        if let message = message {
            navigationItem.title = message.name
            nameTextField.text   = message.name
            photoImageView.image = message.photo
        }
        if let type = message?.type {
            if type == 3 {
                message!.type = 2
                message!.icon = UIImage(named: "read")!
            }
        }
        
        // Enable the Save button only if the text field has a valid Message name.
        checkValidMessageName()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidMessageName()
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
    }
    
    func checkValidMessageName() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        
        let photo = photoImageView.image
        let defaultImage = UIImage(named: "defaultPhoto")!
        
        saveButton.enabled = !text.isEmpty && photo != defaultImage
    }
    
    
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
        checkValidMessageName()
    }
    
    // MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .Camera
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
        
        
        
        
    }
    
    // MARK: Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        
        let isPresentingInAddMessageMode = presentingViewController is SWRevealViewController
        
        if isPresentingInAddMessageMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
        
    }
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if saveButton === sender {
            let icon = UIImage(named: "sent")!
            let name = nameTextField.text ?? ""
            let image = photoImageView.image
            let type = 1
        

            let crypto = CryptoMessage()
            crypto.sendImage(name, image: image!)
            
            
            // Set the message to be passed to MessageTableViewController after the unwind segue.
            message = Message(icon : icon, name: name,type: type, photo: image)
        }
    }
    
    
}

