//
//  HomeViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 6/29/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase


class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // add the Facebook Login button to the VC programmatically
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.view.addSubview(loginButton)

        if(FBSDKAccessToken.currentAccessToken() != nil) {
            //They are logged in so show another view
            print("FB User logged in")
            
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                // ...
            }
        } else {
            //They need to log in
            print("FB User not logged in")
        }
        
        // for debugging purposes:
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            print("user.displayName: \(user.displayName)")
            print("user.email: \(user.email)")
            print("user.uid: \(user.uid)")
            
        } else {
            // No user is signed in.
        }
        
        
        
    }
    

    override func viewDidAppear(animated: Bool) {
       
        // added this to viewDidAppear as the FB SDK login process will come back to this VC so this request refreshes the status
        // was necessary during development & testing ,and I think it's useful for production
        
        if(FBSDKAccessToken.currentAccessToken() != nil) {
            //They are logged in so show another view
            print("FB User logged in")
            
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                // ...
            }
        } else {
            //They need to log in
            print("FB User not logged in")
        }
        
        // for debugging
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            print("user.displayName: \(user.displayName)")
            print("user.email: \(user.email)")
            print("user.uid: \(user.uid)")
            
        } else {
            // No user is signed in.
        }
        
        // I believe this logic will SAVE the current provider information into Firebase Auth
        // As I've developed this process, I saw that if you are currently NOT logged into Facebook
        // and have previously logged in using your Facebook, Firebase remembers your Facebook profile
        // information and stores it in Firebase/
        if let user = FIRAuth.auth()?.currentUser {
            for profile in user.providerData {
                let providerID = profile.providerID
                let uid = profile.uid;  // Provider-specific UID
                let name = profile.displayName
                let email = profile.email
                let photoURL = profile.photoURL
                print("providerID: \(providerID)")
                print("uid: \(uid)")
                print("name: \(name)")
                print("email: \(email)")
                print("photoURL: \(photoURL)")

            }
        } else {
            // No user is signed in.
        }

        

    }

    @IBAction func onEnterGameButtonTapped(sender: AnyObject) {
        
        
    }
    
}
