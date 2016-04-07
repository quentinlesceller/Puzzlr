//
//  LoginViewController.swift
//  Puzzlr
//
//  The controller used for login.
//
//  Created by Quentin Le Sceller on 15/02/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginAction(sender: AnyObject) {
        
        let userBlockchain = UserBlockchain(ip: Server.sharedInstance.getIP(), port: 3000)
        
        let username = self.usernameField.text
        
        let password = self.passwordField.text
        
        // Validate the text fields
        if username!.characters.count < 5 {
            let alert = UIAlertView(title: "Invalid", message: "Username must be greater than 5 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        } else if password!.characters.count < 8 {
            let alert = UIAlertView(title: "Invalid", message: "Password must be greater than 8 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        } else {
            
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            let success = userBlockchain.login(username!, password: password!, sync: Bool(true))
            
            spinner.stopAnimating()
            
            if success {
                let alert = UIAlertView(title: "Success", message: "Logged In", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true, forKey: "connected")
                defaults.setValue(username, forKey: "username")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Reveal")
                    self.presentViewController(viewController, animated: true, completion: nil)
                })
                
            } else {
                let alert = UIAlertView(title: "Error", message: "Error", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
        }
    }
    @IBOutlet weak var usernameField: UITextField!
    override func viewDidLoad() {
        usernameField.autocorrectionType = .No
        passwordField.autocorrectionType = .No
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToLogInScreen(segue:UIStoryboardSegue) {
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let _ = touches.first {
            
            self.view.endEditing(true)
            
            super.touchesBegan(touches , withEvent:event)
            
        }
        
    }
}
