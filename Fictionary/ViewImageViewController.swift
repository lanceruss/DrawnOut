//
//  ViewImageViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 6/29/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class ViewImageViewController: UIViewController {

    @IBOutlet weak var imagePreview: UIImageView!
    
    var imageNamePassed = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("*%*%*%*%*%*%*%* View Image VC Loaded *%*%*%**%*%*%*%*%*%*%*")

        print("\n\n ******ViewImageVC > imageNamePressed > \n\(imageNamePassed)")
        
    imagePreview.image = UIImage(named: "\(imageNamePassed)")
    
    
    }
    @IBAction func onShareButtonTapped(sender: AnyObject) {
        let textToShare = "Fictionary Favorite Drawing!"
        let cardPhoto = imagePreview.image
        
        let activityViewController = UIActivityViewController(activityItems: [textToShare, cardPhoto!], applicationActivities: nil)
        
        //activityViewController.excludedActivityTypes = [UIActivityTypeMail]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)

    }
    
    @IBAction func onSaveButtonTapped(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(UIImage(named: imageNamePassed)!, self, nil, nil)
    }
    

    @IBAction func onCloseButtonTapped(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }

}
