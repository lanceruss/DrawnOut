//
//  EndGameViewImageVC.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/11/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase

class EndGameViewImageVC: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var saveMyProfileButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet var headerView: UIView!
    
    var imagePassed: UIImage = UIImage()
    
    var ref = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://fictionary-7d24c.appspot.com")
    var firebaseUID = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.medAquamarine()
        
        headerView.backgroundColor = UIColor.pastelGreen()
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOpacity = 0.25
        headerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headerView.layer.shadowRadius = 3.5
        
        closeButton.backgroundColor = UIColor.shamrock()
        saveMyProfileButton.backgroundColor = UIColor.shamrock()
        shareButton.backgroundColor = UIColor.shamrock()
        
        closeButton.layer.cornerRadius = 0.5 * closeButton.bounds.size.height
        saveMyProfileButton.layer.cornerRadius = 0.5 * saveMyProfileButton.bounds.size.height
        shareButton.layer.cornerRadius = 0.5 * shareButton.bounds.size.height

        
        saveMyProfileButton.hidden = true
        
        // Display image on the VC:
        imagePreview.image = imagePassed
        
        // Check to see if user is logged into Firebase Auth to allow to save to profile:
        if let user = FIRAuth.auth()?.currentUser {
            
            // User is signed in.
            firebaseUID = user.uid
            print("firebaseUID: \(firebaseUID)")
            saveMyProfileButton.hidden = false

        } else {
            // No user is signed in.
            
            
        }

    
    
    }
    
    
    // ----------------- SAVE TO MY PROFILE ON FIREBASE STORAGE -------------------- //
    @IBAction func onSaveToMyProfileButtonTapped(sender: AnyObject) {
        
        // Data in memory
        let data: NSData = UIImagePNGRepresentation(imagePreview.image!)!
        
        // create random filename
        let dateformatter = NSDateFormatter()
        let randomNumber = arc4random_uniform(1000)
        
        dateformatter.dateFormat = "yyMMdd-hhmmss"
        
        let now = dateformatter.stringFromDate(NSDate())
        let filename = ("\(now)-\(randomNumber)")
        
        // Create a reference to the file you want to upload
        let uploadRef = storageRef.child(firebaseUID).child("\(filename).jpg")
        
        // Upload the file to the path
        let uploadTask = uploadRef.putData(data, metadata: nil) { metadata, error in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL
            }
        }
        
        // Save filename to database
        ref.child("users").child(firebaseUID).child("saved-image").childByAutoId().setValue(["filename":"\(filename).jpg"])
        
    }

    
    
    @IBAction func onShareButtonTapped(sender: AnyObject) {
        let textToShare = "Fictionary Favorite Drawing!"
        let cardPhoto = imagePreview.image
        
        let activityViewController = UIActivityViewController(activityItems: [textToShare, cardPhoto!], applicationActivities: nil)
        
        //activityViewController.excludedActivityTypes = [UIActivityTypeMail]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func onSaveButtonTapped(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(imagePassed, self, nil, nil)
    }
    



    
    @IBAction func onCloseButtonTapped(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    

}
