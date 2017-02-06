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
    
    @IBAction func dismissButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
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

    
        if(FBSDKAccessToken.current() == nil) {

            print("FB User not logged in")
            self.facebookStatusTextView.text = "FACEBOOK USER *NOT* LOGGED IN!!!"
        } else {
            print("FB User *IS LOGGED IN*")
            self.facebookStatusTextView.text = "FACEBOOK USER *IS* LOGGED IN!!!"
        }
        
        // get photo http://everythingswift.com/blog/2015/12/26/swift-facebook-ios-sdk-retrieve-profile-picture/
        if FBSDKAccessToken.current() != nil {
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            graphRequest?.start(completionHandler: {
                (connection, result, error) -> Void in
                if ((error) != nil)
                {
                    print("Error: \(error)")
                }
                else if error == nil
                {
                    let facebookID: NSString = (result.value(forKey: "id")
                        as? NSString)!
                    
                    let pictureURL = "https://graph.facebook.com/\(facebookID)/picture?type=large&return_ssl_resources=1"
                    
                    let URLRequest = URL(string: pictureURL)
                    let URLRequestNeeded = Foundation.URLRequest(url: URLRequest!)
                    
                    NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: OperationQueue.main, completionHandler: {(response: URLResponse?,data: Data?, error: NSError?) -> Void in
                        
                        if error == nil {
                            let picture = UIImage(data: data!)
                            self.profileImageView.image = picture
                        }
                        else {
                            print("Error: \(error!.localizedDescription)")
                        }
                    } as! (URLResponse?, Data?, Error?) -> Void)
                }
            })
        }


    
    
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as! MyProfileViewController
        dvc.player = player
    }



}
