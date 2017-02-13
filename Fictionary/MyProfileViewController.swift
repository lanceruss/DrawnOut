//
//  MyProfileViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/1/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase

class MyProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var profileDisplayName: UILabel!
    
    var player: Player!

    let ref = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().reference(forURL: "gs://fictionary-7d24c.appspot.com")
    
    var imageFilenames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //profileDisplayName.text = player.displayName
        

        /* get all my saved images */
        ref.child("users").child(player.firebaseUID!).child("saved-image").observe(FIRDataEventType.value, with: { (snapshot) in
            //print(self.player.firebaseUID)
            //print(self.player.description)
            //print(snapshot)
            
            let photoDict = snapshot.value as! [String : AnyObject]
            print(photoDict)
            
            self.imageFilenames = []
            
            for (key,value) in photoDict {
                //let userid = key
                //let photo = value
                let imageFilename = value.object(forKey: "filename") as! String
                print(value.object(forKey: "filename")!)
                self.imageFilenames.append(imageFilename)
                print("self.imageFilenames: \(self.imageFilenames)")
                
                self.collectionView.reloadData()
            }
            
            
        })
    
        
        
        
        // ------------------------- FACEBOOK PROFILE PHOTO --------------------------- //
        // get photo http://everythingswift.com/blog/2015/12/26/swift-facebook-ios-sdk-retrieve-profile-picture/
//        if FBSDKAccessToken.current() != nil {
//            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
//            graphRequest?.start(completionHandler: {
//                (connection, result, error) -> Void in
//                if ((error) != nil)
//                {
//                    print("Error: \(error)")
//                }
//                else if error == nil
//                {
//                    let facebookID: NSString = (result.valueForKey("id")
//                        as? NSString)!
//                    
//                    let pictureURL = "https://graph.facebook.com/\(facebookID)/picture?type=large&return_ssl_resources=1"
//                    
//                    self.profileNameLbl.text = (result.valueForKey("name")             as? String)!
//                    
//                    let URLRequest = NSURL(string: pictureURL)
//                    let URLRequestNeeded = NSURLRequest(URL: URLRequest!)
//                    
//                    NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?, error: NSError?) -> Void in
//                        
//                        if error == nil {
//                            let picture = UIImage(data: data!)
//                            self.profileImageView.image = picture
//                        }
//                        else {
//                            print("Error: \(error!.localizedDescription)")
//                        }
//                    })
//                }
//            })
//        }
        
        
    
    
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageFilenames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProfileCardCollectionViewCell
        
        // download files into memory
        // Create a reference to the file you want to download
        let imageRef = self.storageRef.child(self.player.firebaseUID!).child("\(self.imageFilenames[indexPath.row])")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.data(withMaxSize: 3 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                // ... let islandImage: UIImage! = UIImage(data: data!)
                let finalImage: UIImage! = UIImage(data: data!)
                cell.imageView.contentMode = .scaleAspectFit
                cell.imageView.image = finalImage

            }
        }

        
        
        
        return cell
    }


}
