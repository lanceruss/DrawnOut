//
//  EnterGameViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 6/29/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase

class EnterGameViewController: UIViewController {
    
    var player: Player!
    var ref = FIRDatabase.database().reference()

    @IBOutlet weak var debugTextView: UITextView!
    @IBOutlet weak var facebookStatusTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBAction func dismissButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("users/\(player.firebaseUID!)/email").setValue("\(player.email!)")
        ref.child("users/\(player.firebaseUID!)/facebookUID").setValue("\(player.facebookUID!)")
        ref.child("users/\(player.firebaseUID!)/firebaseUID").setValue("\(player.firebaseUID!)")
        ref.child("users/\(player.firebaseUID!)/photoURL").setValue("\(player.photoURL!)")

        
        if player == nil {
            print("******************************* ERROR! PLAYER IS NIL!!!!! *******************************")
        }
        
        print("player: \(player.displayName)")

//        if let user = FIRAuth.auth()?.currentUser {
//            for profile in user.providerData {
//                let providerID = profile.providerID
//                let uid = profile.uid;  // Provider-specific UID
//                let name = profile.displayName
//                let email = profile.email
//                let photoURL = profile.photoURL
//                

        
        self.debugTextView.text = "\nFROM PLAYER OBJECT:\nProviderID: \(player.facebookUID) \nUID: \(player.firebaseUID)\nName: \(player.displayName!)\nEmail: \(player.email!)\nPhotoURL: \(player.photoURL!)"
//
//            }
//        } else {
//            // No user is signed in.
//        }

    
        if(FBSDKAccessToken.currentAccessToken() == nil) {

            print("FB User not logged in")
            self.facebookStatusTextView.text = "FACEBOOK USER *NOT* LOGGED IN!!!"
        } else {
            print("FB User *IS LOGGED IN*")
            self.facebookStatusTextView.text = "FACEBOOK USER *IS* LOGGED IN!!!"
        }
        
        // get photo http://everythingswift.com/blog/2015/12/26/swift-facebook-ios-sdk-retrieve-profile-picture/
        if FBSDKAccessToken.currentAccessToken() != nil {
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            graphRequest.startWithCompletionHandler({
                (connection, result, error) -> Void in
                if ((error) != nil)
                {
                    print("Error: \(error)")
                }
                else if error == nil
                {
                    let facebookID: NSString = (result.valueForKey("id")
                        as? NSString)!
                    
                    let pictureURL = "https://graph.facebook.com/\(facebookID)/picture?type=large&return_ssl_resources=1"
                    
                    let URLRequest = NSURL(string: pictureURL)
                    let URLRequestNeeded = NSURLRequest(URL: URLRequest!)
                    
                    NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?, error: NSError?) -> Void in
                        
                        if error == nil {
                            let picture = UIImage(data: data!)
                            self.profileImageView.image = picture
                        }
                        else {
                            print("Error: \(error!.localizedDescription)")
                        }
                    })
                }
            })
        }


    
    
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dvc = segue.destinationViewController as! MyProfileViewController
        dvc.player = player
    }



}
