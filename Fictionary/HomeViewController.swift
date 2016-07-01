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


class HomeViewController: UIViewController, FBSDKLoginButtonDelegate {

    var player: Player!
    var ref = FIRDatabase.database().reference()
    
    @IBAction func dismissButton(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add the Facebook Login button to the VC programmatically
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.view.addSubview(loginButton)

        print("*------------------------- FBSDKAccessToken.currentAccessToken ------------------------*")
        if(FBSDKAccessToken.currentAccessToken() != nil) {
            //They are logged in so show another view
            print("FB User logged in")
            
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                // ...
                print("*-------- FBSDKAccessToken.currentAccessToken > FIRAuth.auth()?.signInWithCredential ------------------------*")

            }
        } else {
            //They need to log in
            print("FB User not logged in")
            
        }
        
        print("*------------------------- FIRAuth.auth()?.currentUser ------------------------*")
        // for debugging purposes:
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            print("user.displayName: \(user.displayName!)")
            print("user.email: \(user.email!)")
            print("user.uid: \(user.uid)")
            
            // CREATE PLAYER OBJECT:
            player = Player(displayName: "\(user.displayName!)")
            print("player.displayName: \(player.displayName!)")
            
            
            
        } else {
            // No user is signed in.
        }
        
        
        
    }
    

    override func viewDidAppear(animated: Bool) {
       
        // added this to viewDidAppear as the FB SDK login process will come back to this VC so this request refreshes the status
        // was necessary during development & testing ,and I think it's useful for production
        
        print("*----------------VIEW-DID-APPEAR > FBSDKAccessToken.currentAccessToken ------------------------*")

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
        
        print("*----------------VIEW-DID-APPEAR > FIRAuth.auth()?.currentUser ------------------------*")
        // for debugging
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            print("user.displayName: \(user.displayName)")
            print("user.email: \(user.email)")
            print("user.uid: \(user.uid)")
            
        } else {
            // No user is signed in.
        }
        
        print("*----------------VIEW-DID-APPEAR > 2nd > FIRAuth.auth()?.currentUser ------------------------*")
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
                
                // add to player object
                player.email = email
                player.facebookUID = uid
                player.firebaseUID = user.uid
                player.photoURL = photoURL
                
                ref.child("users/\(user.uid)/email").setValue("\(player.email!)")
                ref.child("users/\(user.uid)/facebookUID").setValue("\(player.facebookUID!)")
                ref.child("users/\(user.uid)/firebaseUID").setValue("\(player.firebaseUID!)")
                ref.child("users/\(user.uid)/photoURL").setValue("\(player.photoURL!)")

                
                

            }
        } else {
            // No user is signed in.
        }

    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        /*
         Check for successful login and act accordingly.
         Perform your segue to another UIViewController here.
         */
        performSegueWithIdentifier("enterGameSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dvc = segue.destinationViewController as! EnterGameViewController
        dvc.player = player
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // Actions for when the user logged out goes here
    }

    @IBAction func onDeletePlayerTapped(sender: AnyObject) {
        player = nil
        
    }
    
    @IBAction func onEnterGameButtonTapped(sender: AnyObject) {
        
        
    }
    
}
