//
//  AccountViewController.swift
//  Puzzlr
//
//
//  The account view controller
//
//  Created by Quentin Le Sceller on 26/02/2016.
//  Copyright © 2016 Quentin Le Sceller. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBAction func logOutAction(sender: AnyObject) {
        // Send a request to log out a user
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(false, forKey: "connected")
        AsymmetricCryptoManager.sharedInstance.deleteSecureKeyPair { (success) in
            print("deleted")
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
            self.presentViewController(viewController, animated: true, completion: nil)
        })
    }
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
