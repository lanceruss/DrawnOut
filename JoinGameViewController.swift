//
//  JoinGameViewController.swift
//  Fictionary
//
//  Created by Caleb Talbot on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class JoinGameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MPCHandlerDelegate {
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    var userName: String!
    
    var imageData: NSData?
    
    var appDelegate: AppDelegate!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.mpcHandlerDelegate = self
        
        userName = UIDevice.currentDevice().name
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onProfilePickerTapped(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.allowsEditing = true
            
            picker.viewWillAppear(true)
            self.presentViewController(picker, animated: true, completion: nil)
            picker.viewDidAppear(true)
        } else {
            print("No camera available")
        }
    }


    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        profilePictureImageView.image = selectedImage
        dismissViewControllerAnimated(true, completion: nil)
        
        saveImage(selectedImage)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func saveImage(image: UIImage) {
        
         imageData = UIImageJPEGRepresentation(image, 0.3)!
        
        }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dvc = segue.destinationViewController as! StartGameViewController
        
        if let imageData = imageData {
        dvc.userInfoToSend = imageData
        }
    }
}
