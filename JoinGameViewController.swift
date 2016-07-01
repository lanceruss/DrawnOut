//
//  JoinGameViewController.swift
//  Fictionary
//
//  Created by Caleb Talbot on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class JoinGameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MPCHandlerDelegate, MCBrowserViewControllerDelegate {
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    var userName: String!
    
    var imageData: NSData?
    
    var appDelegate: AppDelegate!
    var archiverHelper: ArchiverHelper!
    var messageHandler: MessageHandler!
    
    var serverStatus: Server?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.mpcHandlerDelegate = self
        
        archiverHelper = ArchiverHelper()
        messageHandler = MessageHandler()
        
        userName = UIDevice.currentDevice().name
        
        appDelegate.mpcHandler.setupPeerWithDisplayName(userName)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.startAdvertising(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleReceivedData), name: "MPC_DataReceived", object: nil)
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

    @IBAction func joinGameButtonTapped(sender: AnyObject) {
        if appDelegate.mpcHandler.mcSession != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.serviceBrowser.delegate = self
            
            self.presentViewController(appDelegate.mpcHandler.serviceBrowser, animated: true, completion: nil)
        }
    }
    
    @IBAction func startGameButtonTapped(sender: AnyObject) {
        let alert = UIAlertController(title: "Wait!", message: "Has everyone been invited to play?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okButton = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (UIAlertAction) in
            
            // Set phone which taps button to act as Server
            self.serverStatus = Server(serverStatus: true, peerID: self.appDelegate.mpcHandler.mcSession.myPeerID)
            
            //send message to trigger segue on Client phones and perform segue on Server phone
            let messageString = ["string" : "start_game"]
            self.messageHandler.sendMessage(messageDictionary: messageString, appDelegate: self.appDelegate)
            self.performSegueWithIdentifier("startGame", sender: self)
        }
        
        let cancelButton = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.serviceBrowser.dismissViewControllerAnimated(true, completion: nil)
    }

    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.serviceBrowser.dismissViewControllerAnimated(true, completion: nil)
    }

    func handleReceivedData(notification: NSNotification) {
        
        self.serverStatus = Server(serverStatus: false, peerID: self.appDelegate.mpcHandler.mcSession.myPeerID)
        
        let message = messageHandler.unwrapReceivedMessage(notification: notification)
        
        if let message = message {
        if message.objectForKey("string")?.isEqual("start_game") == true {
                performSegueWithIdentifier("startGame", sender: self)
        }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dvc = segue.destinationViewController as! StartGameViewController
        
        dvc.serverStatus = serverStatus
        
        if let imageData = imageData {
        dvc.profilePicture = imageData
        }
    }
}
