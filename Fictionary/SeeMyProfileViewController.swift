//
//  SeeMyProfileViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/5/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase

class SeeMyProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cardTableView: UITableView!
    @IBOutlet weak var cardsButton: UIButton!
    @IBOutlet weak var stacksButton: UIButton!
    @IBOutlet weak var recentMatchesButton: UIButton!
    
    var stacks: [String] = ["stack1.jpg", "stack2.jpg", "stack3.jpg"]
    
    var imageFilenames = [String]()
    
    var ref = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://fictionary-7d24c.appspot.com")
    let userID = FIRAuth.auth()?.currentUser?.uid

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // July 10, 2016:
        // get user from firebase now that we are NOT using a player object
        
        self.view.backgroundColor = UIColor.pastelGreen()
        self.collectionView.backgroundColor = UIColor.shamrock()
        
        cardTableView.hidden = false
        cardsButton.backgroundColor = UIColor.shamrock()
        stacksButton.backgroundColor = UIColor.medAquamarine()
        recentMatchesButton.backgroundColor = UIColor.medAquamarine()
        
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            let name = snapshot.value!["name"] as! String
            self.nameLabel.text = "\(name)"
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // ---------------- GET ANY IMAGES SAVED IN FIREBASE STORAGE ------------------- //
        
        // GET LIST OF FILES FROM FIREBASE DATABASE
        ref.child("users").child(userID!).child("saved-image").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            print("firebase > database > users > saved-image: \n")
            print(snapshot)
            
            for item in snapshot.value as! NSDictionary {
                //print("-\(item)")
                
                
                if let imageFilename = item.value["filename"] {
                    print(imageFilename!)
                    self.imageFilenames.append(imageFilename! as! String)
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.cardTableView.reloadData()
                    })
                }
                
                //print(item.value["filename"])
            }
            
            print(self.imageFilenames)
            print(self.userID!)
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    cardTableView.reloadData()
        
    }
    
    
    // ----------------- CARD TABLE VIEW ------------------------- //
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.imageFilenames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCellWithIdentifier("cardCell", forIndexPath: indexPath) as! CardCustomTableViewCell
        
        cell.cardImageView.image = nil
        
        // Create a reference to the file you want to download
        // NEED TO FINISH THIS BY PUTTING THE FILENAME BELOW ON NEXT LINE.....
        
        let userStorageRef = storageRef.child(self.userID!)
        let userImageFilename = userStorageRef.child("\(self.imageFilenames[indexPath.row])")

        //let imageRef = storageRef.child("\(FIRAuth.auth()?.currentUser?.uid)/\(self.imageFilenames[indexPath.row])")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        //print(imageRef)
        userImageFilename.dataWithMaxSize(3 * 1024 * 1024) { (data, error) -> Void in
            
            if (error != nil) {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                // Data for "images/island.jpg" is returned
                // ... let islandImage: UIImage! = UIImage(data: data!)
                cell.cardImageView.image = UIImage(data: data!)
                dispatch_async(dispatch_get_main_queue(), {
                    cell.layoutSubviews()

                })
            }
            
            
            //self.cardTableView.reloadData()
        }
        
        
    
        //cell.textLabel!.text = self.imageFilenames[indexPath.row]
        //cell.imageView!.image = UIImage(named: "kitten")
        print("*** INSIDE CELL LOOP ***")
        print(self.imageFilenames[indexPath.row])
        //cell.backgroundColor = UIColor.redColor()
        
        return cell
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
    
    @IBAction func onCardsButtonTapped(sender: AnyObject) {
        
        cardTableView.hidden = false
        cardsButton.backgroundColor = UIColor.shamrock()
        stacksButton.backgroundColor = UIColor.medAquamarine()
        recentMatchesButton.backgroundColor = UIColor.medAquamarine()

    }
    
    
    @IBAction func onStacksButtonTapped(sender: AnyObject) {
        
        cardTableView.hidden = true
        cardsButton.backgroundColor = UIColor.medAquamarine()
        stacksButton.backgroundColor = UIColor.shamrock()
        recentMatchesButton.backgroundColor = UIColor.medAquamarine()


    }
    
    
}
