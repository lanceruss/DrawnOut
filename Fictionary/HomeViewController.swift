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
    @IBOutlet weak var enterGameButton: UIButton!
    
    @IBAction func dismissButton(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = nil
        try! FIRAuth.auth()!.signOut()

        
        enterGameButton.hidden = true
        
        // add the Facebook Login button to the VC programmatically
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.view.addSubview(loginButton)

//        print("*------------------------- FBSDKAccessToken.currentAccessToken ------------------------*")
//        if(FBSDKAccessToken.currentAccessToken() != nil) {
//            //They are logged in so show another view
//            print("FB User logged in")
//            print("FBSDKAccessToken.currentAccessToken: \(FBSDKAccessToken.currentAccessToken())")
//            enterGameButton.hidden = false
//            
//            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
//            
//            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
//                // ...
//                print("*-------- FBSDKAccessToken.currentAccessToken > FIRAuth.auth()?.signInWithCredential ------------------------*")
//
//            }
//        } else {
//            //They need to log in
//            print("FB User not logged in")
//            enterGameButton.hidden = true
//            
//        }
        
//        print("*------------------------- FIRAuth.auth()?.currentUser ------------------------*")
        // for debugging purposes:
//        if let user = FIRAuth.auth()?.currentUser {
//            // User is signed in.
//            
//            enterGameButton.hidden = false
//            
//            print("user.displayName: \(user.displayName!)")
//            print("user.email: \(user.email!)")
//            print("user.uid: \(user.uid)")
//            
//            // CREATE PLAYER OBJECT:
//            player = Player(displayName: "\(user.displayName!)")
//            print("player.displayName: \(player.displayName!)")
//            
//            
//            
//        } else {
//            // No user is signed in.
//            enterGameButton.hidden = true
//        }
        
        
        
    }
    

    override func viewDidAppear(animated: Bool) {
       
        // added this to viewDidAppear as the FB SDK login process will come back to this VC so this request refreshes the status
        // was necessary during development & testing ,and I think it's useful for production
        
        print("\n\n*----------------VIEW-DID-APPEAR > Check for FBSDKAccessToken.currentAccessToken ------------------------*")

        if(FBSDKAccessToken.currentAccessToken() != nil) {
            
            //They are logged in so show another view
            print("FB ACCESS TOKEN IS *NOT* EMPTY - FACEBOOK USER LOGGED IN")
            print("FBSDKAccessToken.currentAccessToken: \(FBSDKAccessToken.currentAccessToken())")

            enterGameButton.hidden = false
            
            
            // TEST to see if the VIEW DID APPEAR we will test to see if the user is LOGGED INTO FIREBASE
            // IF NOT THEN WE WILL SET THE CREDENTIAL ONE TIME OTHERWISE WE WILL NOT SET ANY CREDENTIAL
            if let user = FIRAuth.auth()?.currentUser {
                // User is signed in.
                print("USER IS SIGNED INTO FIREBASE - DO NOT RE-SET ANOTHER CREDENTIAL")
                print("- FIRAuth.auth()?.currentUser \(FIRAuth.auth()?.currentUser)")
                print("- FBSDKAccessToken.currentAccessToken(): \(FBSDKAccessToken.currentAccessToken())")
//                print(player.email)
//                print(player.facebookUID)
//                print(player.firebaseUID)
//                print(player.photoURL)
            
            
            } else {
                
                // FIREBASE USER NOT LOGGED IN - SO LOG IN THE FIREBASE USER
                print("FIREBASE USER NOT LOGGED IN - SO LOG IN THE FIREBASE USER")
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                    // ...
                    self.enterGameButton.hidden = false
                    
                    for profile in user!.providerData {
                        
                        self.enterGameButton.hidden = false
                        
                        print("* ASSIGN PROIVDER VARIABLES TO PLAYER OBJECT")
                        
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
                        
                        print("* CREATE THE PLAYER OBJECT USING NAME *")
                        self.player = Player(displayName: name!)
                        
                        self.player.email = email
                        self.player.facebookUID = uid
                        self.player.firebaseUID = user!.uid
                        self.player.photoURL = photoURL
                        
                        print("player object created: \(self.player)")
                        
                        self.ref.child("users/\(user!.uid)/email").setValue("\(self.player.email!)")
                        self.ref.child("users/\(user!.uid)/facebookUID").setValue("\(self.player.facebookUID!)")
                        self.ref.child("users/\(user!.uid)/firebaseUID").setValue("\(self.player.firebaseUID!)")
                        self.ref.child("users/\(user!.uid)/photoURL").setValue("\(self.player.photoURL!)")
                    }
                }
            }
            
        } else {
            
            //FACEBOOK ACCESS TOKEN IS EMPTY - USER NOT LOGGED INTO FACEBOOK
            print("FACEBOOK ACCESS TOKEN IS EMPTY - USER NOT LOGGED INTO FACEBOOK")
            print("FBSDKAccessToken.currentAccessToken() * IS NIL *")
            player = nil
            enterGameButton.hidden = true

        }
        
//        print("*----------------VIEW-DID-APPEAR > FIRAuth.auth()?.currentUser ------------------------*")
//        // for debugging
//        if let user = FIRAuth.auth()?.currentUser {
//            // User is signed in.
//            
//            enterGameButton.hidden = false
//            
//            
//            print("user.displayName: \(user.displayName)")
//            print("user.email: \(user.email)")
//            print("user.uid: \(user.uid)")
//            
//        } else {
//            // No user is signed in.
//            enterGameButton.hidden = true
//        }
        
        print("*----------------VIEW-DID-APPEAR > 2nd > FIRAuth.auth()?.currentUser ------------------------*")
        // I believe this logic will SAVE the current provider information into Firebase Auth
        // As I've developed this process, I saw that if you are currently NOT logged into Facebook
        // and have previously logged in using your Facebook, Firebase remembers your Facebook profile
        // information and stores it in Firebase/
//        if let user = FIRAuth.auth()?.currentUser {
//            for profile in user.providerData {
//                
//                enterGameButton.hidden = false
//                
//                let providerID = profile.providerID
//                let uid = profile.uid;  // Provider-specific UID
//                let name = profile.displayName
//                let email = profile.email
//                let photoURL = profile.photoURL
//                print("providerID: \(providerID)")
//                print("uid: \(uid)")
//                print("name: \(name)")
//                print("email: \(email)")
//                print("photoURL: \(photoURL)")
//                
//                // add to player object
//                
//                let player = Player(displayName: name!)
//                
//                player.email = email
//                player.facebookUID = uid
//                player.firebaseUID = user.uid
//                player.photoURL = photoURL
//                
//                ref.child("users/\(user.uid)/email").setValue("\(player.email!)")
//                ref.child("users/\(user.uid)/facebookUID").setValue("\(player.facebookUID!)")
//                ref.child("users/\(user.uid)/firebaseUID").setValue("\(player.firebaseUID!)")
//                ref.child("users/\(user.uid)/photoURL").setValue("\(player.photoURL!)")
//
//                
//                
//
//            }
//        } else {
//            // No user is signed in.
//            enterGameButton.hidden = true
//        }

    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
       
        print("loginButton > didCompleteWithResult")
        
        /*
         Check for successful login and act accordingly.
         Perform your segue to another UIViewController here.
         */
       // performSegueWithIdentifier("enterGameSegue", sender: self)
        
//        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
//        
//        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
//            // ...
//        }
//        
//        enterGameButton.hidden = false
//
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dvc = segue.destinationViewController as! EnterGameViewController
        print("pass the dvc.player = player")
        print("player object: \(player)")
        dvc.player = player
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // Actions for when the user logged out goes here
    }

    @IBAction func onDeletePlayerTapped(sender: AnyObject) {
        player = nil
        try! FIRAuth.auth()!.signOut()
        
    }
    
    @IBAction func onEnterGameButtonTapped(sender: AnyObject) {
        
        
    }
    
}
