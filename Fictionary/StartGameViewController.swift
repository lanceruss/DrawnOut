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
        
    var connectedUsers = [MCPeerID]()
    
    var serverStatus: Server?
    
    @IBOutlet weak var serverClientStatusLabel: UILabel!
    @IBOutlet weak var connectedDevicesLabel: UILabel!
    
    // DEMO ONLY
    @IBOutlet weak var changeBackgroundButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Get instance of the AppDelegate and the MPCHandler that was instantiated there for global use
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mpcHandler?.mpcHandlerDelegate = self
        
        // Instantiate a MessageHandler object, which is used to wrap and unwrap meessage dictionaries when sent and received among devices
        messageHandler = MessageHandler()
        
        //Display a list of the connected users (DEMO ONLY)
        connectedUsers = appDelegate.mpcHandler.mcSession.connectedPeers
        connectedDevicesLabel.text = connectedUsers.description
        connectedDevicesLabel.numberOfLines = 0
        
        // Observe for notification of incoming data
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleReceivedData), name: NSNotification.Name(rawValue: "MPC_DataReceived"), object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: <#T##Selector#>, name: "Server_Ready", object: nil)
        
         // DEMO ONLY- If device is a server, show the changeBackgroundButton and set the label to show that it is a server. If device is a client, hide changeBackgroundButton and set label to show that it is a client.
        if let serverStatus = serverStatus {
            if serverStatus.isServer == true {
                serverClientStatusLabel.text = "I am the server."
                changeBackgroundButton.isHidden = false
                print(serverStatus.playersInOrder)
            } else {
                serverClientStatusLabel.text = "I am a client."
                changeBackgroundButton.isHidden = true
                print(serverStatus.playersInOrder)
            }
        }
    }
    
    func handleReceivedData(_ notification: Notification) {
        
        // Use archiverHelper to unwrap the received data and return an NSDictionary
        let message = messageHandler.unwrapReceivedMessage(notification: notification)
        if let message = message {
            
            // Check the key of the received dictionary to see how to handle the data and handle it accordingly
            if (message.object(forKey: "string") as AnyObject).isEqual("change_background") == true {
                self.view.backgroundColor = UIColor.blue
            } else if (message.object(forKey: "string") as AnyObject).isEqual("dismiss_vc") == true {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // DEMO ONLY
    @IBAction func dismissViewControllerButtonTapped(_ sender: AnyObject) {
        
        // Check whether a device is the server. If the device is the server, send a message to dismiss the view controller and do the same action locally. If device is a client, alert the user that they can't use the button.
        if let serverStatus = serverStatus {
            if serverStatus.isServer {
                let message = ["string" : "dismiss_vc"]
                messageHandler.sendMessage(messageDictionary: message as [String : AnyObject], toPeers:appDelegate.mpcHandler.mcSession.connectedPeers,  appDelegate: appDelegate)
                dismiss(animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Uh Oh!", message: "Looks like you're only a client :-(", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "OK, I guess", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //DEMO ONLY - Only the server can see and use this button.
    @IBAction func backgroundColorButtonTapped(_ sender: AnyObject) {

        // Change the background color on the server device locally and send a message to the other devices to let them know to do the same.
        self.view.backgroundColor = UIColor.blue
        
        let message = ["string" : "change_background"]
        messageHandler.sendMessage(messageDictionary: message as [String : AnyObject], toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
    }
    

}




