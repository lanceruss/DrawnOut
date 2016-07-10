//
//  SeeMyProfileViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/5/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase

class SeeMyProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    
    var stacks: [String] = ["stack1.jpg", "stack2.jpg", "stack3.jpg"]
    
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // July 10, 2016:
        // get user from firebase now that we are NOT using a player object
        
        self.view.backgroundColor = UIColor.pastelGreen()
        self.collectionView.backgroundColor = UIColor.shamrock()
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            let name = snapshot.value!["name"] as! String
            self.nameLabel.text = "\(name)"
            
        }) { (error) in
            print(error.localizedDescription)
        }

        
    }
    
    @IBAction func onBackButtonTapped(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stacks.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: Custom2CollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! Custom2CollectionViewCell
        cell.imageView.image = UIImage(named: stacks[indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("cell: \(indexPath.row) selected")
    }
    
    @IBAction func seeAllStacks(sender: AnyObject) {

        
    }
    
    
    
    
    
}
