//
//  StartGameViewController.swift
//  Fictionary
//
//  Created by Caleb Talbot on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class StartGameViewController: UIViewController, MPCHandlerDelegate {
    
    let archiverHelper = ArchiverHelper()
    var messageHandler: MessageHandler!
    var appDelegate: AppDelegate!
    
    var profilePicture: NSData?
    
    var connectedUsers = [MCPeerID]()
    var receivedImages = [UIImage]()
    
    var serverStatus: Server?
    
    @IBOutlet weak var serverClientStatusLabel: UILabel!
    @IBOutlet weak var connectedDevicesLabel: UILabel!
    @IBOutlet var peerImageView: [UIImageView]!
    
    
    @IBOutlet weak var changeBackgroundButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Get instance of the AppDelegate and the MPCHandler that was instantiated there for global use
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler?.mpcHandlerDelegate = self
        
        messageHandler = MessageHandler()
        
        connectedUsers = appDelegate.mpcHandler.mcSession.connectedPeers
        
        connectedDevicesLabel.text = connectedUsers.description
        
        // Observe for notification of incoming data
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleReceivedData), name: "MPC_DataReceived", object: nil)
        
        if let profilePicture = profilePicture {
            appDelegate.mpcHandler.sendDataToDevice(data: profilePicture, peerIDs: connectedUsers)
        }
        
        if let serverStatus = serverStatus {
            if serverStatus.isServer == true {
                serverClientStatusLabel.text = "I am the server."
                changeBackgroundButton.hidden = false
            } else {
                serverClientStatusLabel.text = "I am a client."
                changeBackgroundButton.hidden = true
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if let profilePicture = profilePicture {
            
            appDelegate.mpcHandler.sendDataToDevice(data: profilePicture, peerIDs: connectedUsers)
        }
        
    }
    
    func handleReceivedData(notification: NSNotification) {
        
        let message = messageHandler.unwrapReceivedMessage(notification: notification)
        if let message = message {
            if message.objectForKey("string")?.isEqual("change_background") == true {
                self.view.backgroundColor = UIColor.blueColor()
            } else if message.objectForKey("string")?.isEqual("dismiss_vc") == true {
                dismissViewControllerAnimated(true, completion: nil)
            }
        }
        //            if let data = data {
        //                let image = UIImage(data: data)
        //                receivedImages.append(image!)
        //            }
        //
        //            displayConnectedUsers()
    }
    
    @IBAction func dismissViewControllerButtonTapped(sender: AnyObject) {
        if let serverStatus = serverStatus {
            if serverStatus.isServer {
                let message = ["string" : "dismiss_vc"]
                messageHandler.sendMessage(messageDictionary: message, appDelegate: appDelegate)
                dismissViewControllerAnimated(true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Uh Oh!", message: "Looks like you're only a client :-(", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK, I guess", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(action)
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func backgroundColorButtonTapped(sender: AnyObject) {
        self.view.backgroundColor = UIColor.blueColor()
        
        let message = ["string" : "change_background"]
        messageHandler.sendMessage(messageDictionary: message, appDelegate: appDelegate)
    }
    
    //    func displayConnectedUsers() {
    //
    //        for index in 0 ..< connectedUsers.count {
    //
    //            let image = receivedImages[index]
    //
    //            let imageToDisplay = image
    //
    //            peerImageView[index].hidden = false
    //            peerImageView[index].image = imageToDisplay
    //        }
    //
    //    }
}




