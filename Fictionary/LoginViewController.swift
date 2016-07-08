//
//  LoginViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/5/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var debugInfo: UITextView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var deletePlayerObjectsButton: UIButton!
    @IBOutlet weak var loginAsGuestButton: UIButton!
    @IBOutlet weak var viewMyProfileButton: UIButton!
    @IBOutlet weak var enterGameButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    var player: Player!
    var ref = FIRDatabase.database().reference()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ----------- RESET ALL LOGIN SESSION VALUES ----------- //
        print("RESET ALL LOGIN SESSION VALUES WHEN THIS PAGE LOADS\n")
        player = nil
        
        print("** REMINDER THAT WE LOG OUT ALL FIRAUTH SESSION - TESTING / DEBUGGING ***")
        try! FIRAuth.auth()!.signOut()
        
        debugInfo.hidden = true
        dismissButton.hidden = true
        deletePlayerObjectsButton.hidden = false
        
        viewMyProfileButton.userInteractionEnabled = false
        viewMyProfileButton.tintColor = UIColor.grayColor()
        
        enterGameButton.hidden = true
        logoutButton.hidden = true
    
    
    }
    
    @IBAction func enterGameButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("joinGame", sender: self)
    }

    
    @IBAction func onViewMyProfileTapped(sender: AnyObject) {
        
    }
    
    func getLoggedInUserInfo() {
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            let email = snapshot.value!["email"] as! String
            let password = snapshot.value!["password"] as! String
            let name = snapshot.value!["name"] as! String
            let isAnonymous = snapshot.value!["isAnonymous"] as! String

            self.debugInfo.text = self.debugInfo.text + "FIRDatabase > uid, email, pass & name: \(userID!) \(email), \(password), \(name), \(isAnonymous)"

            // ...
        }) { (error) in
            print(error.localizedDescription)
            print("-from getLoggedInUserInfo")
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        // ----- DEBUG INFO ------ //
        debugInfo.text = ""
        debugInfo.hidden = false
        
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            print("user is signed in: \(user.uid)")
            debugInfo.text = debugInfo.text + "FIRAuth.auth().currentUser: \(FIRAuth.auth()!.currentUser!.uid)\n"
            
            getLoggedInUserInfo()
            
            self.loginButton.hidden = true
            self.createAccountButton.hidden = true
            self.loginAsGuestButton.hidden = true
            self.logoutButton.hidden = false
            
            
        
        } else {
            // No user is signed in.
            print("user is not signed in")
            debugInfo.text = debugInfo.text + "FIRAuth.auth().currentUser: NONE\n"
        }
        
            self.debugInfo.text = self.debugInfo.text + "D-player: \(self.player)\n"
    }
    
    @IBAction func startAnonymousGameTapped(sender: AnyObject) {
        
        self.player = Player(displayName: "Guest")
        self.player.email = ""
        self.player.facebookUID = ""
        self.player.photoURL = NSURL(string: "")
        self.player.firebaseUID = ""
        
        FIRAuth.auth()?.signInAnonymouslyWithCompletion() { (user, error) in
            // ...
            self.player.firebaseUID = user!.uid
            self.player.isAnonymous = true
            self.performSegueWithIdentifier("joinGame", sender: self)
            
            self.ref.child("users/\(user!.uid)/dateTimeCreated").setValue("")
            self.ref.child("users/\(user!.uid)/email").setValue("")
            self.ref.child("users/\(user!.uid)/password").setValue("")
            self.ref.child("users/\(user!.uid)/name").setValue("Guest")
            self.ref.child("users/\(user!.uid)/isAnonymous").setValue("1")

        }
        
    }
    
    
    @IBAction func onLogoutTapped(sender: AnyObject) {
        deleteAllUsersAuthObjects()
        self.logoutButton.hidden = true
        self.loginAsGuestButton.hidden = false
        self.loginButton.hidden = false
        self.createAccountButton.hidden = false
        
        self.debugInfo.text = "NO USER AUTH OBJECTS!"
        print("USER LOGGED OUT")
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewProfileSegue" {
            let dvc = segue.destinationViewController as! SeeMyProfileViewController
            dvc.player = player
            
        } else if segue.identifier == "joinGame" {
            let dvc = segue.destinationViewController as! JoinGameViewController
            dvc.player = player
        }
        
    }
    
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("loginButtonDidLogOut running...")
        loginAsGuestButton.hidden = false
        viewMyProfileButton.userInteractionEnabled = false
        viewMyProfileButton.tintColor = UIColor.grayColor()
        enterGameButton.hidden = true
    }
    
    func deleteAllUsersAuthObjects() {
        player = nil
        try! FIRAuth.auth()!.signOut()
    }
    
    
    @IBAction func deletePlayerAuthObjects(sender: AnyObject) {
        deleteAllUsersAuthObjects()
    }
    
    @IBAction func dismissButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
