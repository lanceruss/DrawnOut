//
//  JoinGameViewController.swift
//  Fictionary
//
//  Created by Caleb Talbot on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class JoinGameViewController: UIViewController, MPCHandlerDelegate, MCBrowserViewControllerDelegate {
    
    var userName: String!
    
    var imageData: NSData?
    
    var appDelegate: AppDelegate!
    var archiverHelper: ArchiverHelper!
    var messageHandler: MessageHandler!
    
    var serverStatus: Server?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get an instance of the appDelegate (which houses the mpcHandler so the whole app has access to it) and set the mpcHandlerDelegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.mpcHandlerDelegate = self
        
        // Instantiate instances of the ArchiverHelper and MessageHandler so that they can be used to send and receive messages
        archiverHelper = ArchiverHelper()
        messageHandler = MessageHandler()
        
        // Get the current devices name to use as the displayName for the peerID
        userName = UIDevice.currentDevice().name
        
        // Set up a session and start advertising that the device is available for connections through MPC
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.startAdvertising(true)
        
        // Create an observer in order to be notified if new data has been received by the mpcHandler. This observer fires the handleReceivedData function when new data is received.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleReceivedData), name: "MPC_DataReceived", object: nil)
    }
    
    // Present the view controller to allow the devices to invite other devices to connect
    @IBAction func joinGameButtonTapped(sender: AnyObject) {
        if appDelegate.mpcHandler.mcSession != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.serviceBrowser.delegate = self
            
            self.presentViewController(appDelegate.mpcHandler.serviceBrowser, animated: true, completion: nil)
        }
    }
    
    // Dismiss the MPC Browser view controller when the user taps the "done" button in the same.
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.serviceBrowser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Dismiss the MPC Browser view controller when the user taps the "cancel" button in the same.
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.serviceBrowser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Start the game and assign the phone that taps the button to be the server. This sends a message to the other devices to performSegue and does the same locally.
    @IBAction func startGameButtonTapped(sender: AnyObject) {
        let alert = UIAlertController(title: "Wait!", message: "Has everyone been invited to play?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okButton = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (UIAlertAction) in
            
            // Set phone which taps button to act as Server
            self.serverStatus = Server(serverStatus: true, peerID: self.appDelegate.mpcHandler.mcSession.myPeerID)
            
            if let serverStatus = self.serverStatus {
                if let peerID = serverStatus.id {
                    serverStatus.playersInOrder = [[peerID : []]]
                    for peer in self.appDelegate.mpcHandler.mcSession.connectedPeers {
                        serverStatus.playersInOrder.append([peer : []])
                    }
                }
                
                //send message to trigger segue on Client phones and perform segue on Server phone
                let message = self.messageHandler.createMessage(string: "start_game", object: serverStatus.playersInOrder, ready: nil)
                self.messageHandler.sendMessage(messageDictionary: message, toPeers: self.appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: self.appDelegate)
            }
            self.performSegueWithIdentifier("startGame", sender: self)
        }
        
        let cancelButton = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // When a notification comes in that data has been received, this function is run.
    func handleReceivedData(notification: NSNotification) {
        
        // Because the first data that is sent among phones is the message to start the game, I set the "client" status of the non-server phones here. Only the "client" phones receive the "start_game" message, so any phone that receives that message declares itself as a server by instantiating a serverStatus object with false for the isServer bool.
        self.serverStatus = Server(serverStatus: false, peerID: self.appDelegate.mpcHandler.mcSession.myPeerID)
        
        // Retreive the NSDictionary in the received data
        let message = messageHandler.unwrapReceivedMessage(notification: notification)
        
        // Handle the message to "start_game".
        if let message = message {
            
            if message.objectForKey("object")?.isEqual("") != true {
                let playersInOrder = message.objectForKey("object") as! Array<NSDictionary>
                if let serverStatus = serverStatus {
                    serverStatus.playersInOrder = playersInOrder
                }
            }
            
            if message.objectForKey("string")?.isEqual("start_game") == true {
                performSegueWithIdentifier("startGame", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        // Pass along the serverStatus object so that we can keep checking the server/client status of each device. This object should be passed along for the duration fo the game!!!
        let dvc = segue.destinationViewController as! RandomCaptionViewController
        dvc.serverStatus = serverStatus
        
    }
}
