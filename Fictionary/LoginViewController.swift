//
//  LoginViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/5/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var debugInfo: UITextView!
    @IBOutlet weak var enterGameButton: UIButton!
    
    var player: Player!
    var ref = FIRDatabase.database().reference()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ----------- RESET ALL LOGIN SESSION VALUES ----------- //
        print("RESET ALL LOGIN SESSION VALUES WHEN THIS PAGE LOADS\n")
        player = nil
        try! FIRAuth.auth()!.signOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
        FBSDKProfile.setCurrentProfile(nil)
        
        enterGameButton.hidden = true
        
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]

    
    
    }
    

    
    
    
    override func viewDidAppear(animated: Bool) {
        
        // ----- DEBUG INFO ------ //
        debugInfo.text = ""
        
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            debugInfo.text = debugInfo.text + "FIRAuth.auth().currentUser: \(FIRAuth.auth()?.currentUser!)\n"
        } else {
            // No user is signed in.
            debugInfo.text = debugInfo.text + "FIRAuth.auth().currentUser: NONE\n"
        }
        
        if(FBSDKAccessToken.currentAccessToken() != nil) {
            debugInfo.text = debugInfo.text + "FBSDKAccessToken.currentAccessToken(): \(FBSDKAccessToken.currentAccessToken()!)\n"
        } else {
            debugInfo.text = debugInfo.text + "FBSDKAccessToken.currentAccessToken(): NONE\n"
        }
            self.debugInfo.text = self.debugInfo.text + "D-player: \(self.player)\n"
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("loginButton > didCompleteWithResult function running...")
        if let error = error {
            print(error.localizedDescription)
            return
        }

        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
       
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            if let user = FIRAuth.auth()?.currentUser {
                print(user.displayName)
                
                for profile in user.providerData {
                    
                    self.player = Player(displayName: profile.displayName!)
                    self.player.email = profile.email
                    self.player.facebookUID = profile.uid
                    self.player.firebaseUID = user.uid
                    self.player.photoURL = profile.photoURL
                    
                    
                    
                    
                    print(self.player)
                }
                
                self.debugInfo.text = self.debugInfo.text + "player: \(self.player)\n"
                
                self.enterGameButton.hidden = false
 
            }

        }
        
        
    }
    
    @IBAction func startAnonymousGameTapped(sender: AnyObject) {
        
        self.player = Player(displayName: "Anonymous")
        self.player.email = ""
        self.player.facebookUID = ""
        self.player.photoURL = NSURL(string: "")
        self.player.firebaseUID = ""
        
        FIRAuth.auth()?.signInAnonymouslyWithCompletion() { (user, error) in
            // ...
            self.player.firebaseUID = user!.uid
            self.player.isAnonymous = true
            self.performSegueWithIdentifier("anonymousSegue", sender: self)

            
        }
        

        
        
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dvc = segue.destinationViewController as! SeeMyProfileViewController
        dvc.player = player
    }
    
    @IBAction func enterGame(sender: AnyObject) {
    
    }
    
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("loginButtonDidLogOut running...")
    }
    
    
    @IBAction func deletePlayerAuthObjects(sender: AnyObject) {
        player = nil
        try! FIRAuth.auth()!.signOut()
        
        // start of trying to force logout user from FB

//        let cookie = NSHTTPCookie()
//        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
//        for cookie in storage {
//            var domainName: String = cookie.domain()
//            var domainRange: NSRange = domainName.rangeOfString("facebook")
//            if domainRange.length > 0 {
//                storage.deleteCookie(cookie)
//        }
//        
//        NSHTTPCookie *cookie;
//        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//        for (cookie in [storage cookies])
//        {
//            NSString* domainName = [cookie domain];
//            NSRange domainRange = [domainName rangeOfString:@"facebook"];
//            if(domainRange.length > 0)
//            {
//                [storage deleteCookie:cookie];
//            }
//        }
        // end
        
    }
    
    @IBAction func dismissButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
