//
//  SeeMyProfileViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/5/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase

class SeeMyProfileViewController: UIViewController {
    
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var facebookIDLabel: UILabel!
    @IBOutlet weak var firebaseIDLabel: UILabel!
    @IBOutlet weak var profileImageview: UIImageView!
    
    var player: Player!
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("player: \(player)")
        
        displayNameLabel.text = "\(player.displayName!)"
        
        emailLabel.text = "\(player.email!)"
        facebookIDLabel.text = "\(player.facebookUID!)"
        firebaseIDLabel.text = "\(player.firebaseUID!)"
        
        
        
        // start of profile pic
        if let data = NSData(contentsOfURL: player.photoURL!) {
            
            profileImageview.clipsToBounds = true
            //profileImageview.layer.cornerRadius = profileImageview.frame.size.width/2
            profileImageview.image = UIImage(data: data)
            
            let profilePic = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height":250, "width": 250, "redirect":false], HTTPMethod: "GET")
            profilePic.startWithCompletionHandler({ (connection, result, error) in
                
                if (error == nil) {
                    
                    let dict = result as! NSDictionary
                    let data = dict.objectForKey("data")
                    
                    let picURL = (data?.objectForKey("url")) as! String
                    
                    if let imageData = NSData(contentsOfURL: NSURL(string: picURL)!) {
                        self.profileImageview.image = UIImage(data:imageData)
                    }
                    print(dict)
                }
            })
        } else {
            profileImageview.backgroundColor = UIColor.redColor()
        }
        // end of profile pic
    }
    
    @IBAction func seeAllStacks(sender: AnyObject) {
        
        print("seeAllStacks > player.firebaseUID \(player.firebaseUID!)")
        print("seeAllStatcks > player.isAnonymous \(player.isAnonymous)")
        
    }
    
    
    
    
    
}
