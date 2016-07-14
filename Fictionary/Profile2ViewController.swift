//
//  Profile2ViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/13/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase

class Profile2ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var bigHeader: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backButtonView: UIView!
    
    var imageFilenames = [String]()
    
    var ref = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://fictionary-7d24c.appspot.com")
    let userID = FIRAuth.auth()?.currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.shamrock()
        
        bigHeader.backgroundColor = UIColor.pastelGreen()
        
        bigHeader.layer.shadowColor = UIColor.blackColor().CGColor
        bigHeader.layer.shadowOpacity = 0.25
        bigHeader.layer.shadowOffset = CGSize(width: 0, height: 1)
        bigHeader.layer.shadowRadius = 3.5
        
        collectionView.backgroundColor = UIColor.shamrock()
        
        backButtonView.backgroundColor = UIColor.shamrock()
        backButtonView.layer.cornerRadius = 0.5 * backButtonView.bounds.size.height
        
        self.backButton.setTitle("<", forState: UIControlState.Normal)

        
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
            
            let dictionaryToCheck = snapshot.value as? NSDictionary
            if let dictionaryToCheck = dictionaryToCheck {
            for item in dictionaryToCheck {
                //print("-\(item)")
                
                
                if let imageFilename = item.value["filename"] {
                    print(imageFilename!)
                    self.imageFilenames.append(imageFilename! as! String)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView.reloadData()
                    })
                }
                
                //print(item.value["filename"])
            }
            
            print(self.imageFilenames)
            print(self.userID!)
            
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        collectionView.reloadData()
        
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageFilenames.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: Profile2CustomCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! Profile2CustomCollectionViewCell
        
        // Create a reference to the file you want to download
        // NEED TO FINISH THIS BY PUTTING THE FILENAME BELOW ON NEXT LINE.....
    
        
        let userStorageRef = storageRef.child(self.userID!)
        let userImageFilename = userStorageRef.child("\(self.imageFilenames[indexPath.row])")

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

        cell.cardImageView.image = UIImage(named: self.imageFilenames[indexPath.row])
        cell.cardImageView.layer.shadowOpacity = 0.3
        cell.cardImageView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        cell.cardImageView.layer.shadowRadius = 4.0

        return cell
        
        
        
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //device screen size
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        //calculation of cell size
        return CGSize(width: ((width / 2) - 15), height: (height / 2.5) - 10)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("cell: \(indexPath.row) selected")
    }

    
    @IBAction func onBackButtonTapped(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
        
}



