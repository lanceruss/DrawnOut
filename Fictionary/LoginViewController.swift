//
//  LoginViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/5/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var debugInfo: UITextView!
    @IBOutlet weak var deletePlayerObjectsButton: UIButton!
    @IBOutlet weak var loginAsGuestButton: UIButton!
    @IBOutlet weak var viewMyProfileButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var loginAsUserButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var howToPlayButton: UIButton!
    
    var player: Player!
    var ref = FIRDatabase.database().reference()
    
    var userIsLoggedIn: Bool?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.pastelGreen()
        
        var drawView: DesignTestView {
            return self.view as! DesignTestView
        }
        
        var drawViewTest: JoinGameRuleView {
            return self.view as! JoinGameRuleView
        }

        // ----------- RESET ALL LOGIN SESSION VALUES ----------- //
        print("RESET ALL LOGIN SESSION VALUES WHEN THIS PAGE LOADS\n")
        player = nil
        
        print("** REMINDER THAT WE LOG OUT ALL FIRAUTH SESSION - TESTING / DEBUGGING ***")
//        try! FIRAuth.auth()!.signOut()
        
        
        debugInfo.hidden = true
        deletePlayerObjectsButton.hidden = true
        
        logoutButton.hidden = true
        logoutButton.backgroundColor = UIColor.medAquamarine()
        logoutButton.layer.cornerRadius = 0.5 * logoutButton.bounds.size.height

        loginButton.backgroundColor = UIColor.medAquamarine()
        loginButton.layer.cornerRadius = 0.5 * loginButton.bounds.size.height
        
        loginAsGuestButton.layer.cornerRadius = 0.5 * loginAsGuestButton.bounds.size.height
        loginAsGuestButton.backgroundColor = UIColor.shamrock()
        
        loginAsUserButton.hidden = true
        loginAsUserButton.layer.cornerRadius = 0.5 * loginAsUserButton.bounds.size.height
        loginAsUserButton.backgroundColor = UIColor.shamrock()
        
        if userIsLoggedIn == true {
            viewMyProfileButton.hidden = false
        } else {
            viewMyProfileButton.hidden = true
        }
        
        viewMyProfileButton.layer.cornerRadius = 0.5 * viewMyProfileButton.bounds.size.height
        viewMyProfileButton.userInteractionEnabled = false
        //viewMyProfileButton.tintColor = UIColor.grayColor()
        //viewMyProfileButton.backgroundColor = UIColor.lightGrayColor()
        
        howToPlayButton.layer.cornerRadius = 0.5 * howToPlayButton.bounds.size.height
        howToPlayButton.backgroundColor = UIColor.medAquamarine()
        
        welcomeLabel.hidden = true
        welcomeLabel.text = ""
    
    
    }

//    override func viewWillAppear(animated: Bool) {
//        
//        let userID = FIRAuth.auth()?.currentUser?.uid
//        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
//            // Get user value
//            let name = snapshot.value!["name"] as! String
//            
//            if snapshot.value!["isAnonymous"] as! String  == "1" {
//                //self.viewMyProfileButton.backgroundColor = UIColor.lightGrayColor()
//                //self.viewMyProfileButton.userInteractionEnabled = false
//                self.viewMyProfileButton.hidden = true
//                self.logoutButton.titleLabel?.text = "LOGIN"
//                print("Logged in as Guest")
//                
//            } else {
//                self.viewMyProfileButton.backgroundColor = UIColor.medAquamarine()
//                self.viewMyProfileButton.userInteractionEnabled = true
//                self.welcomeLabel.text = "Hi, \(name)!"
//                self.logoutButton.titleLabel?.text = "LOGOUT"
//                self.createAccountButton.hidden = true
//                self.viewMyProfileButton.hidden = false
//            }
//            
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//
//    }
    
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
            
            self.viewMyProfileButton.backgroundColor = UIColor.medAquamarine()

            self.debugInfo.text = self.debugInfo.text + "FIRDatabase > uid, email, pass & name: \(userID!) \(email), \(password), \(name), \(isAnonymous)"
            
            
        }) { (error) in
            print(error.localizedDescription)
            print("-from getLoggedInUserInfo")
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        // ----- DEBUG INFO ------ //
        debugInfo.text = ""
        debugInfo.hidden = true
        
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            print("user is signed in: \(user.uid)")
            debugInfo.text = debugInfo.text + "FIRAuth.auth().currentUser: \(FIRAuth.auth()!.currentUser!.uid)\n"
            
            getLoggedInUserInfo()
            
            //self.loginButton.hidden = true
            //self.createAccountButton.hidden = true
            self.loginAsGuestButton.hidden = true
            
            viewMyProfileButton.backgroundColor = UIColor.medAquamarine()
            viewMyProfileButton.userInteractionEnabled = true
            
            welcomeLabel.hidden = false
            
            loginAsUserButton.hidden = false

            
            let userID = FIRAuth.auth()?.currentUser?.uid
            ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                // Get user value
                let name = snapshot.value!["name"] as! String
                
                if snapshot.value!["isAnonymous"] as! String  == "1" {
                    //self.viewMyProfileButton.backgroundColor = UIColor.lightGrayColor()
                    //self.viewMyProfileButton.userInteractionEnabled = false
                    
                    dispatch_async(dispatch_get_main_queue(),{
                        self.logoutButton.setTitle("LOGIN", forState: UIControlState.Normal)
                        self.logoutButton.hidden = false

                    })

                    self.viewMyProfileButton.hidden = true
                    print("Logged in as Guest")
                    self.userIsLoggedIn = false
                    
                } else {
                    self.viewMyProfileButton.backgroundColor = UIColor.medAquamarine()
                    self.viewMyProfileButton.userInteractionEnabled = true
                    self.welcomeLabel.text = "Hi, \(name)!"
                    self.logoutButton.setTitle("LOGOUT", forState: UIControlState.Normal)
                    self.logoutButton.hidden = false
                    self.createAccountButton.hidden = true
                    self.viewMyProfileButton.hidden = false
                    self.userIsLoggedIn = true
                }
                
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
        
        } else {
            // No user is signed in.
            print("user is not signed in")
            debugInfo.text = debugInfo.text + "FIRAuth.auth().currentUser: NONE\n"
            self.viewMyProfileButton.hidden = true
            self.logoutButton.hidden = true
            self.userIsLoggedIn = false
        }
        
            self.debugInfo.text = self.debugInfo.text + "D-player: \(self.player)\n"
    }
    
    @IBAction func startAnonymousGameTapped(sender: AnyObject) {
        
        self.player = Player(displayName: "Guest")
        self.player.email = ""
        self.player.facebookUID = ""
        self.player.photoURL = NSURL(string: "")
        self.player.firebaseUID = ""
        
        //self.loginButton.hidden = true
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
            
            self.viewMyProfileButton.backgroundColor = UIColor.medAquamarine()

        }
    }
    
    @IBAction func startGameAsUserLoggedIn(sender: AnyObject) {
        
    }
    
    @IBAction func onLogoutTapped(sender: AnyObject) {

        deleteAllUsersAuthObjects()
        self.logoutButton.hidden = true
        self.loginAsGuestButton.hidden = false
        self.loginButton.hidden = false
        self.createAccountButton.hidden = false
        
        welcomeLabel.hidden = true
        welcomeLabel.text = "Hi, "
        
        //viewMyProfileButton.backgroundColor = UIColor.lightGrayColor()
        //viewMyProfileButton.userInteractionEnabled = false
        viewMyProfileButton.hidden = true
        
        self.debugInfo.text = "NO USER AUTH OBJECTS!"
        print("USER LOGGED OUT")
        
        if logoutButton.titleLabel?.text == "LOGIN" {
            performSegueWithIdentifier("toLoginVC", sender: sender)
        }
        
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewProfileSegue" {
            
        // let dvc = segue.destinationViewController as! SeeMyProfileViewController
        // let dvc = segue.destinationViewController as! Profile2ViewController
        // dvc.player = player
            
        } else if segue.identifier == "joinGame" {
            // let dvc = segue.destinationViewController as! JoinGameViewController
            // dvc.player = player
        }
        
    }
    
    
    
    /*
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("loginButtonDidLogOut running...")
        loginAsGuestButton.hidden = false
        viewMyProfileButton.userInteractionEnabled = false
        // viewMyProfileButton.tintColor = UIColor.grayColor()
    }
    */
    
    
    func deleteAllUsersAuthObjects() {
        player = nil
        try! FIRAuth.auth()!.signOut()
    }
    
    /*
    @IBAction func deletePlayerAuthObjects(sender: AnyObject) {
        deleteAllUsersAuthObjects()
    }
    */

    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        
    }
    
}
