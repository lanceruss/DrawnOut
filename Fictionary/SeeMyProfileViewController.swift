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
    let storageRef = FIRStorage.storage().reference(forURL: "gs://fictionary-7d24c.appspot.com")
    let userID = FIRAuth.auth()?.currentUser?.uid

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // July 10, 2016:
        // get user from firebase now that we are NOT using a player object
        
        self.view.backgroundColor = UIColor.pastelGreen()
        self.collectionView.backgroundColor = UIColor.shamrock()
        
        cardTableView.isHidden = false
        cardsButton.backgroundColor = UIColor.shamrock()
        stacksButton.backgroundColor = UIColor.medAquamarine()
        recentMatchesButton.backgroundColor = UIColor.medAquamarine()
        
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let name = snapshot.value!["name"] as! String
            self.nameLabel.text = "\(name)"
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // ---------------- GET ANY IMAGES SAVED IN FIREBASE STORAGE ------------------- //
        
        // GET LIST OF FILES FROM FIREBASE DATABASE
        ref.child("users").child(userID!).child("saved-image").observeSingleEvent(of: .value, with: { (snapshot) in
            
            print("firebase > database > users > saved-image: \n")
            print(snapshot)
            
            for item in snapshot.value as! NSDictionary {
                //print("-\(item)")
                
                
                if let imageFilename = item.value["filename"] {
                    print(imageFilename!)
                    self.imageFilenames.append(imageFilename! as! String)
                    
                    DispatchQueue.main.async(execute: { 
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.imageFilenames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! CardCustomTableViewCell
        
        cell.cardImageView.image = nil
        
        // Create a reference to the file you want to download
        // NEED TO FINISH THIS BY PUTTING THE FILENAME BELOW ON NEXT LINE.....
        
        let userStorageRef = storageRef.child(self.userID!)
        let userImageFilename = userStorageRef.child("\(self.imageFilenames[indexPath.row])")

        //let imageRef = storageRef.child("\(FIRAuth.auth()?.currentUser?.uid)/\(self.imageFilenames[indexPath.row])")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        //print(imageRef)
        userImageFilename.data(withMaxSize: 3 * 1024 * 1024) { (data, error) -> Void in
            
            if (error != nil) {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                // Data for "images/island.jpg" is returned
                // ... let islandImage: UIImage! = UIImage(data: data!)
                cell.cardImageView.image = UIImage(data: data!)
                DispatchQueue.main.async(execute: {
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
    
    
    
    
    @IBAction func onBackButtonTapped(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stacks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Custom2CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Custom2CollectionViewCell
        cell.imageView.image = UIImage(named: stacks[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell: \(indexPath.row) selected")
    }
    
    @IBAction func seeAllStacks(_ sender: AnyObject) {
        
        
    }
    
    @IBAction func onCardsButtonTapped(_ sender: AnyObject) {
        
        cardTableView.isHidden = false
        cardsButton.backgroundColor = UIColor.shamrock()
        stacksButton.backgroundColor = UIColor.medAquamarine()
        recentMatchesButton.backgroundColor = UIColor.medAquamarine()

    }
    
    
    @IBAction func onStacksButtonTapped(_ sender: AnyObject) {
        
        cardTableView.isHidden = true
        cardsButton.backgroundColor = UIColor.medAquamarine()
        stacksButton.backgroundColor = UIColor.shamrock()
        recentMatchesButton.backgroundColor = UIColor.medAquamarine()


    }
    
    
}
