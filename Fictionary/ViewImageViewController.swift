//
//  ViewImageViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 6/29/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase

class ViewImageViewController: UIViewController {

    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var debugLabel: UILabel!
    
    var imageNamePassed = ""
    
    var ref = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().reference(forURL: "gs://fictionary-7d24c.appspot.com")
    var firebaseUID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            firebaseUID = user.uid
            debugLabel.text = user.uid
        } else {
            // No user is signed in.
        }
        
        

        
        print("*%*%*%*%*%*%*%* View Image VC Loaded *%*%*%**%*%*%*%*%*%*%*")

        print("\n\n ******ViewImageVC > imageNamePressed > \n\(imageNamePassed)")
        
    imagePreview.image = UIImage(named: "\(imageNamePassed)")
    
    
    }
    @IBAction func onShareButtonTapped(_ sender: AnyObject) {
        let textToShare = "Fictionary Favorite Drawing!"
        let cardPhoto = imagePreview.image
        
        let activityViewController = UIActivityViewController(activityItems: [textToShare, cardPhoto!], applicationActivities: nil)
        
        //activityViewController.excludedActivityTypes = [UIActivityTypeMail]
        
        self.present(activityViewController, animated: true, completion: nil)

    }
    
    @IBAction func onSaveButtonTapped(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(UIImage(named: imageNamePassed)!, self, nil, nil)
    }
    
    @IBAction func onSaveToMyProfileButtonTapped(_ sender: AnyObject) {
        
        // Data in memory
        let data: Data = UIImagePNGRepresentation(imagePreview.image!)!
        
        // create random filename
        let dateformatter = DateFormatter()
        let randomNumber = arc4random_uniform(1000)
        
        dateformatter.dateFormat = "yyMMdd-hhmmss"
        
        let now = dateformatter.string(from: Date())
        let filename = ("\(now)-\(randomNumber)")
        
        // Create a reference to the file you want to upload
        let uploadRef = storageRef.child(firebaseUID).child("\(filename).jpg")
        
        // Upload the file to the path 
        let uploadTask = uploadRef.put(data, metadata: nil) { metadata, error in
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

    @IBAction func onCloseButtonTapped(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }

}
