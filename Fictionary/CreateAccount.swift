//
//  CreateAccount.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/7/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase

class CreateAccount: UIViewController {
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    let refRoot = FIRDatabase.database().reference()
    var firebaseUID = FIRAuth.auth()?.currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.pastelGreen()
        createAccountButton.layer.cornerRadius = 0.5 * createAccountButton.bounds.size.height
        createAccountButton.backgroundColor = UIColor.shamrock()
        
        errorMessageLabel.hidden = true
        cancelButton.hidden = true
        
        print("viewDidLoad > firebaseUID: \(self.firebaseUID)")
        
    }
    
    @IBAction func onCancelButtonTapped(sender: UIButton) {
        
        try! FIRAuth.auth()!.signOut()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func validateEmail(enteredEmail:String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluateWithObject(enteredEmail)
        
    }
    
    
    
    @IBAction func onCreateAccountButtonTapped(sender: AnyObject) {
        
        self.errorMessageLabel.text = ""
        
        // check to see if user already has an email address account in the Firebase database
        
        print("userID: \(self.firebaseUID)")
        
        // check to see if the userID is nil from the current Firebase Auth session.
        // Error catching....
        // If so then create a FIR userID
        if firebaseUID != nil {
            
            print("there is a firebase userid: \(self.firebaseUID)")
            
            // check to see if there is a record in the firebase database
            refRoot.child("users").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                print("checking to see if there is a user in Firebase Database:")
                
                if snapshot.hasChild(self.firebaseUID!) {
                    
                    print("- YES, user exists: \(self.firebaseUID!)")
                    print("- USER ALREADY HAS ACCOUNT")
                    
                }else{
                    
                    print("- NO, user doesn't exist")
                }
                
                
            })
            
        } else {
            
            // ------ THIS CREATES A NEW USER IN FIREBASE DATABASE ----------//
            
            // check to see if the 3 fields below are empty and show an errorMessage if necessary
            if emailAddressTextField.text == "" {
                errorMessageLabel.hidden = false
                errorMessageLabel.text = "Your email address is required.\n"
            }
            
            if passwordTextField.text == "" {
                errorMessageLabel.hidden = false
                errorMessageLabel.text = "\(self.errorMessageLabel.text!) Your password is required.\n"
            }
            
            if confirmPasswordTextField.text == "" {
                errorMessageLabel.hidden = false
                errorMessageLabel.text = "\(self.errorMessageLabel.text!) Your confirm password is required.\n"
            }
            
            if nameTextField.text == "" {
                errorMessageLabel.hidden = false
                errorMessageLabel.text = "\(self.errorMessageLabel.text!) Your name is required.\n"
            }
            
            if passwordTextField.text != "" && confirmPasswordTextField.text != "" {
                
                if passwordTextField.text != confirmPasswordTextField.text {
                    errorMessageLabel.hidden = false
                    errorMessageLabel.text = "\(self.errorMessageLabel.text!) Your passwords do not match.\n"
                }
                
            }
            
            let passwordLength = passwordTextField.text
            if passwordLength?.characters.count < 6 {
                errorMessageLabel.hidden = false
                errorMessageLabel.text = "\(self.errorMessageLabel.text!) Your password has to be at least 6 characters.\n"
            }
            
            if validateEmail(self.emailAddressTextField.text!) {
                // if true then email is valid format for Firebase Auth
                
            } else {
                // if false
                errorMessageLabel.hidden = false
                errorMessageLabel.text = "\(self.errorMessageLabel.text!) Your email address is not the right format.\n"

            }
            
            
            
            
            // if all fields are not empty, then proceed with logging in and creating a record in firebase database:
            if emailAddressTextField.text != "" && passwordTextField.text != "" && nameTextField.text != "" && passwordTextField.text == confirmPasswordTextField.text && confirmPasswordTextField.text != "" && validateEmail(emailAddressTextField.text!) && passwordLength?.characters.count > 5 {
                
                print("All required fields are filled in and passwords match!")
                // ---------- NEED TO CHECK AND SEE IF EMAIL/PASS ALREADY EXIST THEN JUST DISMISS VC AS LOGGED IN --------- //
                
                //                let mySearchRoot = refRoot.child("users")
                //
                //                let query = mySearchRoot.queryOrderedByChild("email").queryEqualToValue(self.emailAddressTextField.text!)
                //
                //                query.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                let usersRef = refRoot.child("users")
                let email = self.emailAddressTextField.text
                
                
                // create an anonymous Firebase UserID
                FIRAuth.auth()?.signInAnonymouslyWithCompletion() { (user, error) in
                    
                    // query the database after sign in with anonymous auth as we need that in order to query the firebase database
                    usersRef.queryOrderedByChild("email").queryEqualToValue(email)
                        .observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            
                            if snapshot.childrenCount > 0 {
                                
                                // ------ IF THERE IS AT LEAST 1 MATCH OF EMAIL & PASSWORD THEN DO THIS -------- //
                                print("There are \(snapshot.childrenCount) snapshot.childrenCount")
                                
                                self.errorMessageLabel.text = "Sorry, but you already have an account. Please try to login."
                                self.cancelButton.hidden = false
                                self.createAccountButton.hidden = true
                                self.errorMessageLabel.hidden = false
                                
                                
                            } else {
                                
                                // ------ THERE WAS NO EXISTING MATCH OF ANY EMAIL / PASSWORD IN FIREBASE DATABASE ------ //
                                print("There are no children: \(snapshot.childrenCount)")
                                
                                self.errorMessageLabel.hidden = true
                                self.cancelButton.hidden = true

                                self.firebaseUID  = user!.uid
                                print ("created a new user ID in firebase Auth: \(self.firebaseUID!)")
                                
                                // create a date to insert into firebase database
                                let dateformatter = NSDateFormatter()
                                
                                dateformatter.dateFormat = "MM-dd-yyyy hh:mm"
                                
                                let now = dateformatter.stringFromDate(NSDate())
                                let final = ("\(now)")
                                
                                self.refRoot.child("users/\(self.firebaseUID!)/dateTimeCreated").setValue(final)
                                self.refRoot.child("users/\(self.firebaseUID!)/email").setValue(self.emailAddressTextField.text!)
                                self.refRoot.child("users/\(self.firebaseUID!)/password").setValue(self.passwordTextField.text!)
                                self.refRoot.child("users/\(self.firebaseUID!)/name").setValue(self.nameTextField.text!)
                                self.refRoot.child("users/\(self.firebaseUID!)/isAnonymous").setValue("0")
                                
                                
                                print("added record to firebase database")
                                
                                // --------- CONVERT THE FIREBASE ANONYMOUS AUTH TO A FIREBASE EMAIL/PASSWORD ACCOUNT -------- //
                                let credential = FIREmailPasswordAuthProvider.credentialWithEmail(self.emailAddressTextField.text!, password: self.passwordTextField.text!)
                                
                                FIRAuth.auth()?.currentUser!.linkWithCredential(credential) { (user, error) in
                                    
                                    self.errorMessageLabel.hidden = true
                                    self.cancelButton.hidden = true

                                    self.dismissViewControllerAnimated(true, completion: nil)
                                    
                                    if error != nil {
                                        print("there was an error trying to link the Firebase anonymous auth with a Firebase email/password.  The error is:\n\(error)")
                                    }
                                }

                                
                                // ------------ NOW TIME TO TAKE USER BACK TO HOME PAGE AFTER CREATING THEIR ACCOUNT ---------------- //
                                
                                
                                
                            } // end of if snapshot.childrenCount > 0
                            
                            }, withCancelBlock: { (error) in
                                print(error.localizedDescription)
                        })
                    
                    
                } // end create an anonymous Firebase UID
                
                
                // ------------ END OF CHECK TO SEE IF EMAIL / PASS ALREADY EXISTS ----------------//
                
                
            } // end of non-empty field check
            
        } // end of creating new user in firebase database
        
    } // end of onButtonTapped to Create Account
    
}
