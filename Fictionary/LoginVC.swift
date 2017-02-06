//
//  LoginVC.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/7/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.pastelGreen()

        loginButton.layer.cornerRadius = 0.5 * loginButton.bounds.size.height
        loginButton.backgroundColor = UIColor.shamrock()

        errorMessageLabel.isHidden = true
        
        
    }
    
    func validateEmail(_ enteredEmail:String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
        
    }

    
    
    @IBAction func onLoginButtonTapped(_ sender: AnyObject) {
        
        self.errorMessageLabel.text = ""
        
        if emailTextField.text == "" {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "Your email address is required.\n"
        }
        
        if passwordTextField.text == "" {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "\(self.errorMessageLabel.text!) Your password is required.\n"
        }
        
        if validateEmail(self.emailTextField.text!) {
            // if true then email is valid format for Firebase Auth
            
        } else {
            // if false
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "\(self.errorMessageLabel.text!) Your email address is not the right format.\n"
            
        }
        
        let passwordLength = passwordTextField.text
        if passwordLength?.characters.count < 6 {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "\(self.errorMessageLabel.text!) Your password has to be at least 6 characters.\n"
        }


        
        if emailTextField.text != "" && passwordTextField.text != "" && validateEmail(emailTextField.text!) && passwordLength?.characters.count > 5  {
            
            // both fields are not empty so go ahead and see if the user exists in Firebase Auth...
            
            FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error != nil {
                    print("there was an error logging in the user into Firebase Auth: \n\(error!)")
                    self.errorMessageLabel.isHidden = false
                    self.errorMessageLabel.text = "We could not find a user with that info.\nPlease try again.\n"
                    self.passwordTextField.text = ""

                } else {
                    
                    // the user is logged in this block, so now grab the user info from Firebase Auth
                    if let user = FIRAuth.auth()?.currentUser {
                        
                        // User is signed in.
                        let email = user.email
                        let userID = user.uid
                        print("email: \(email!)")
                        print("userID: \(userID)")
                        
                        self.dismiss(animated: true, completion: nil)
                        
                        
                    } else {
                        
                        // No user is signed in.

                        
                    }
                    
                    
                }
            
            }
            
            
            
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onCancelButtonTapped(_ sender: AnyObject) {
        
        try! FIRAuth.auth()!.signOut()
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
}
