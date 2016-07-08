//
//  LoginVC.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/7/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorMessageLabel.hidden = true
        
        
    }
    
    
    @IBAction func onLoginButtonTapped(sender: AnyObject) {
        
        self.errorMessageLabel.text = ""
        
        if emailTextField.text == "" {
            errorMessageLabel.hidden = false
            errorMessageLabel.text = "Your email address is required.\n"
        }
        
        if passwordTextField.text == "" {
            errorMessageLabel.hidden = false
            errorMessageLabel.text = "\(self.errorMessageLabel.text!) Your password is required.\n"
        }
        
        if emailTextField.text != "" && passwordTextField.text != ""  {
            
            // both fields are not empty so go ahead and see if the user exists in Firebase Auth...
            
            FIRAuth.auth()?.signInWithEmail(self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error != nil {
                    print("there was an error logging in the user into Firebase Auth: \n\(error)")
                } else {
                    
                    // the user is logged in this block, so now grab the user info from Firbase Auth
                    if let user = FIRAuth.auth()?.currentUser {
                        
                        // User is signed in.
                        let email = user.email
                        let userID = user.uid
                        print("email: \(email)")
                        print("userID: \(userID)")
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                        
                    } else {
                        
                        // No user is signed in.
                        
                    }
                    
                    
                }
            
            }
            
            
            
        }
    }
    
    
    
    
    @IBAction func onCancelButtonTapped(sender: AnyObject) {
        
        try! FIRAuth.auth()!.signOut()
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
    
}
