//
//  SignUpViewController.swift
//  Puzzlr
//
//  The sign up view controller.
//
//  Created by Quentin Le Sceller on 15/02/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    
    @IBAction func signupAction(sender: AnyObject) {
        let userBlockchain = UserBlockchain(ip: Server.sharedInstance.getIP(), port: 3000)
        let publickeyBlockchain = PublicKeyBlockchain(ip: Server.sharedInstance.getIP(), port: 3000)
        
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
            let success = userBlockchain.registerUser(username!, password: password!, sync: Bool(true))
            print(Server.sharedInstance.getIP())
            // Stop the spinner
            
            if !success {
                let alert = UIAlertView(title: "Error", message: "Error", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                
            } else {
                let alert = UIAlertView(title: "Success", message: "Signed Up", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                sleep(1)
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true, forKey: "connected")
                defaults.setValue(username, forKey: "username")
                
                AsymmetricCryptoManager.sharedInstance.createSecureKeyPair({ (success, error) in
                    if success {
                        
                        print("createdkey")
                        let cryptoImportExportManager = CryptoExportImportManager()
                        let swiftyRSA = SwiftyRSA()
                        
                        
                        let publicKeyData = AsymmetricCryptoManager.sharedInstance.getPublicKeyData()
                        let publicKeyPEM = cryptoImportExportManager.exportRSAPublicKeyToPEM(publicKeyData!, keyType: kSecAttrKeyTypeRSA as String, keySize: 2048)
                        
                        do {
                            
                            let publicKeyBase64 = try swiftyRSA.base64FromPEMKey(publicKeyPEM)
                            print(publicKeyBase64)
                            publickeyBlockchain.registerPublicKey(username!, publickey: publicKeyBase64, sync: true)
                        } catch _ {
                            print("fail")
                        }
                    }
                })
                spinner.stopAnimating()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Reveal")
                    self.presentViewController(viewController, animated: true, completion: nil)
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.autocorrectionType = .No
        passwordField.autocorrectionType = .No
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let _ = touches.first {
            
            self.view.endEditing(true)
            
            super.touchesBegan(touches , withEvent:event)
        }
    }
}

