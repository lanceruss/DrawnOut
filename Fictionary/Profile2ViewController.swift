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
    let storageRef = FIRStorage.storage().reference(forURL: "gs://drawnout-81702.appspot.com")
    let userID = FIRAuth.auth()?.currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()

        //view
        self.view.backgroundColor = UIColor.shamrock()
        
        //header properties
        bigHeader.backgroundColor = UIColor.pastelGreen()
        bigHeader.layer.shadowColor = UIColor.black.cgColor
        bigHeader.layer.shadowOpacity = 0.25
        bigHeader.layer.shadowOffset = CGSize(width: 0, height: 1)
        bigHeader.layer.shadowRadius = 3.5
        
        //collection view
        collectionView.backgroundColor = UIColor.shamrock()
        
        //back button view
        backButtonView.backgroundColor = UIColor.shamrock()
        backButtonView.layer.cornerRadius = 0.5 * backButtonView.bounds.size.height
        
        self.backButton.setTitle("<", for: UIControlState())

        
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let name = snapshot.value(forKey: "name") as? String
            if name != nil {
                self.nameLabel.text = "\(name!)"
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }

        // ---------------- GET ANY IMAGES SAVED IN FIREBASE STORAGE ------------------- //
        
        // GET LIST OF FILES FROM FIREBASE DATABASE
        ref.child("users").child(userID!).child("saved-image").observeSingleEvent(of: .value, with: { (snapshot) in
            
            print("firebase > database > users > saved-image: \n")
            print(snapshot)
            
            let dictionaryToCheck = snapshot.value as? NSDictionary
            if let dictionaryToCheck = dictionaryToCheck {
            for item in dictionaryToCheck {
                //print("-\(item)")
                
                if let imageFilename = (item.value as AnyObject).value(forKey: "filename")  {
                //if let imageFilename = item.value.va {
                //if let imageFilename = item.value["filename"] {
                    print(imageFilename)
                    self.imageFilenames.append(imageFilename as! String)
                    
                    DispatchQueue.main.async(execute: {
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageFilenames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: Profile2CustomCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Profile2CustomCollectionViewCell
        
        // Create a reference to the file you want to download
        // NEED TO FINISH THIS BY PUTTING THE FILENAME BELOW ON NEXT LINE.....
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.isHidden = false
        
        let userStorageRef = storageRef.child(self.userID!)
        let userImageFilename = userStorageRef.child("\(self.imageFilenames[indexPath.row])")

        userImageFilename.data(withMaxSize: 3 * 1024 * 1024) { (data, error) -> Void in
            
            if (error != nil) {
                print(error!)
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
        
        cell.cardImageView.image = UIImage(named: self.imageFilenames[indexPath.row])
        cell.cardImageView.layer.shadowOpacity = 0.3
        cell.cardImageView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        cell.cardImageView.layer.shadowRadius = 4.0
        
        cell.activityIndicator.stopAnimating()
        cell.activityIndicator.isHidden = true

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        /* device screen size */
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        /* calculate and return cell size */
        return CGSize(width: ((width / 2) - 15), height: (height / 2.5) - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell: \(indexPath.row) selected")
    }

    
    @IBAction func onBackButtonTapped(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }
        
}



