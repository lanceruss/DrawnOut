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
    @IBOutlet weak var firebaseIDLabel: UILabel!
    @IBOutlet weak var profileImageview: UIImageView!
    
    var player: Player!
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("player: \(player)")
        
        displayNameLabel.text = "\(player.displayName!)"
        
        emailLabel.text = "\(player.email!)"
        firebaseIDLabel.text = "\(player.firebaseUID!)"
        
        
    }
    
    @IBAction func seeAllStacks(sender: AnyObject) {
        
        print("seeAllStacks > player.firebaseUID \(player.firebaseUID!)")
        print("seeAllStatcks > player.isAnonymous \(player.isAnonymous)")
        
    }
    
    
    
    
    
}
