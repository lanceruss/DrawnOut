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

    @IBOutlet weak var debugTextView: UITextView!
    @IBOutlet weak var facebookStatusTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if let user = FIRAuth.auth()?.currentUser {
            for profile in user.providerData {
                let providerID = profile.providerID
                let uid = profile.uid;  // Provider-specific UID
                let name = profile.displayName
                let email = profile.email
                let photoURL = profile.photoURL
                
                self.debugTextView.text = "ProviderID: \(providerID) \nUID: \(uid)\nName: \(name!)\nEmail: \(email!)\nPhotoURL: \(photoURL!)\nFirebase-user-email: \(user.email!) "
                
            }
        } else {
            // No user is signed in.
        }

    
        if(FBSDKAccessToken.currentAccessToken() != nil) {
            //They are logged in so show another view
            print("FB User logged in")
            
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            
            self.facebookStatusTextView.text = "FB USER *IS* LOGGED IN with \(credential)"

            
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                // ...
            }
        } else {
            //They need to log in
            print("FB User not logged in")
            self.facebookStatusTextView.text = "FACEBOOK USER *NOT* LOGGED IN!!!"
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


}
