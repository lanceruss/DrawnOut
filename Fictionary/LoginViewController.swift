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
        
        
        debugInfo.isHidden = true
        deletePlayerObjectsButton.isHidden = true
        
        logoutButton.isHidden = true
        logoutButton.backgroundColor = UIColor.medAquamarine()
        logoutButton.layer.cornerRadius = 0.5 * logoutButton.bounds.size.height

        loginButton.backgroundColor = UIColor.medAquamarine()
        loginButton.layer.cornerRadius = 0.5 * loginButton.bounds.size.height
        
        loginAsGuestButton.layer.cornerRadius = 0.5 * loginAsGuestButton.bounds.size.height
        loginAsGuestButton.backgroundColor = UIColor.shamrock()
        
        loginAsUserButton.isHidden = true
        loginAsUserButton.layer.cornerRadius = 0.5 * loginAsUserButton.bounds.size.height
        loginAsUserButton.backgroundColor = UIColor.shamrock()
        
        if userIsLoggedIn == true {
            viewMyProfileButton.isHidden = false
        } else {
            viewMyProfileButton.isHidden = true
        }
        
        viewMyProfileButton.layer.cornerRadius = 0.5 * viewMyProfileButton.bounds.size.height
        viewMyProfileButton.isUserInteractionEnabled = false
        //viewMyProfileButton.tintColor = UIColor.grayColor()
        //viewMyProfileButton.backgroundColor = UIColor.lightGrayColor()
        
        howToPlayButton.layer.cornerRadius = 0.5 * howToPlayButton.bounds.size.height
        howToPlayButton.backgroundColor = UIColor.medAquamarine()
        
        welcomeLabel.isHidden = true
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
    
    @IBAction func onViewMyProfileTapped(_ sender: AnyObject) {
        
    }
    
    
    func getLoggedInUserInfo() {
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let snapVal = snapshot.value as? Dictionary<String, String>
            // Get user value
            let email = snapVal?["email"]
            let password = snapVal?["password"]
            let name = snapVal?["name"]
            let isAnonymous = snapVal?["isAnonymous"]
            
            //let email = snap.value(forKey: "email") as? String
            //let password = snap.value(forKey: "password") as? String
            //let name = snap.value(forKey: "name") as? String
            //let isAnonymous = snap.value(forKey: "isAnonymous") as? String
            
            self.viewMyProfileButton.backgroundColor = UIColor.medAquamarine()

            self.debugInfo.text = self.debugInfo.text + "FIRDatabase > uid, email, pass & name: \(userID!) \(email), \(password), \(name), \(isAnonymous)"
            
            
        }) { (error) in
            print(error.localizedDescription)
            print("-from getLoggedInUserInfo")
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        // ----- DEBUG INFO ------ //
        debugInfo.text = ""
        debugInfo.isHidden = true
        
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            print("user is signed in: \(user.uid)")
            debugInfo.text = debugInfo.text + "FIRAuth.auth().currentUser: \(FIRAuth.auth()!.currentUser!.uid)\n"
            
            getLoggedInUserInfo()
            
            //self.loginButton.hidden = true
            //self.createAccountButton.hidden = true
            loginAsGuestButton.isHidden = true
            
            viewMyProfileButton.backgroundColor = UIColor.medAquamarine()
            viewMyProfileButton.isUserInteractionEnabled = true
            
            welcomeLabel.isHidden = false
            
            loginAsUserButton.isHidden = false

            
            let userID = FIRAuth.auth()?.currentUser?.uid
            ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let snapVal = snapshot.value as? NSDictionary
                // Get user value
                let name = snapVal?["name"] as? String
                //let name = snapshot.value!["name"] as! String
                
                if ((snapVal?["isAnonymous"] as? String)! == "1") {
                //if snapshot.value(forKey: "isAnonymous") as! String == "1" {
                //if snapshot.value!["isAnonymous"] as! String  == "1" {
                    //self.viewMyProfileButton.backgroundColor = UIColor.lightGrayColor()
                    //self.viewMyProfileButton.userInteractionEnabled = false
                    
                    DispatchQueue.main.async(execute: {
                        self.logoutButton.setTitle("LOGIN", for: UIControlState())
                        self.logoutButton.isHidden = false

                    })

                    self.viewMyProfileButton.isHidden = true
                    print("Logged in as Guest")
                    self.userIsLoggedIn = false
                    
                } else {
                    self.viewMyProfileButton.backgroundColor = UIColor.medAquamarine()
                    self.viewMyProfileButton.isUserInteractionEnabled = true
                    self.welcomeLabel.text = "Hi, \(name!)!"
                    self.logoutButton.setTitle("LOGOUT", for: UIControlState())
                    self.logoutButton.isHidden = false
                    self.createAccountButton.isHidden = true
                    self.viewMyProfileButton.isHidden = false
                    self.userIsLoggedIn = true
                }
                
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
        
        } else {
            // No user is signed in.
            print("user is not signed in")
            debugInfo.text = debugInfo.text + "FIRAuth.auth().currentUser: NONE\n"
            self.viewMyProfileButton.isHidden = true
            self.logoutButton.isHidden = true
            self.userIsLoggedIn = false
        }
        
            self.debugInfo.text = self.debugInfo.text + "D-player: \(self.player)\n"
    }
    
    @IBAction func startAnonymousGameTapped(_ sender: AnyObject) {
        
        self.player = Player(displayName: "Guest")
        self.player.email = ""
        self.player.facebookUID = ""
        self.player.photoURL = URL(string: "")
        self.player.firebaseUID = ""
        
        //self.loginButton.hidden = true
        FIRAuth.auth()?.signInAnonymously() { (user, error) in
            // ...
            self.player.firebaseUID = user!.uid
            self.player.isAnonymous = true
            self.performSegue(withIdentifier: "joinGame", sender: self)
            
            self.ref.child("users/\(user!.uid)/dateTimeCreated").setValue("")
            self.ref.child("users/\(user!.uid)/email").setValue("")
            self.ref.child("users/\(user!.uid)/password").setValue("")
            self.ref.child("users/\(user!.uid)/name").setValue("Guest")
            self.ref.child("users/\(user!.uid)/isAnonymous").setValue("1")
            
            self.viewMyProfileButton.backgroundColor = UIColor.medAquamarine()

        }
    }
    
    @IBAction func startGameAsUserLoggedIn(_ sender: AnyObject) {
        
    }
    
    @IBAction func onLogoutTapped(_ sender: AnyObject) {

        deleteAllUsersAuthObjects()
        self.logoutButton.isHidden = true
        self.loginAsGuestButton.isHidden = false
        self.loginButton.isHidden = false
        self.createAccountButton.isHidden = false
        
        welcomeLabel.isHidden = true
        welcomeLabel.text = "Hi, "
        
        //viewMyProfileButton.backgroundColor = UIColor.lightGrayColor()
        //viewMyProfileButton.userInteractionEnabled = false
        viewMyProfileButton.isHidden = true
        
        self.debugInfo.text = "NO USER AUTH OBJECTS!"
        print("USER LOGGED OUT")
        
        if logoutButton.titleLabel?.text == "LOGIN" {
            performSegue(withIdentifier: "toLoginVC", sender: sender)
        }
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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

    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
        
    }
    
}
