//
//  RandomCaptionViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 6/29/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class RandomCaptionViewController: UIViewController, MPCHandlerDelegate {
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet var timerLabel: UILabel!
    
    var secondsAllowed = 10
    var seconds = 0
    var timer = NSTimer()
    
    var captions = ["iPad", "iPhone", "Sim"]
    
    var serverStatus: Server?
    var appDelegate: AppDelegate!
    var archiveHelper: ArchiverHelper!
    var messageHandler: MessageHandler!
    
    var arrayForOrder: Array<MCPeerID> = [MCPeerID]()
    var gameDictionary = [MCPeerID : [Int : AnyObject]]()
    
    var turnCounter = 1
    
    @IBAction func dismissButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the AppDelegate to reference the MPCHandler and references to the ArchiverHelper and the MessageHandler
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.mpcHandlerDelegate = self
        
        archiveHelper = ArchiverHelper()
        messageHandler = MessageHandler()
        
        
        // Get a randomIndex and use it to display a random caption
        let randomIndex = Int(arc4random_uniform(UInt32(self.captions.count)))
        self.captionLabel.text = captions[randomIndex]
        
        // Set up timer
        seconds = secondsAllowed
        timerLabel.text = "\(seconds)"
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(TimerViewController.subtractTime), userInfo: nil, repeats: true)
        
        // Find the next player and store that player's PeerID
        if let serverStatus = serverStatus {
            if serverStatus.isServer == true {
                for (key, _) in gameDictionary {
                    arrayForOrder.append(key)
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleReceivedData), name: "MPC_DataReceived", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(performSegue), name: "Server_Ready", object: nil)
        
    }
    
    
    @IBAction func onShuffleButtonTapped(sender: AnyObject) {
        
        let randomIndex = Int(arc4random_uniform(UInt32(self.captions.count)))
        self.captionLabel.text = captions[randomIndex]
    }
    
    func subtractTime() {
        
        seconds-=1
        timerLabel.text = "\(seconds)"
        
        if seconds == 0 {
            timer.invalidate()
            let caption = captionLabel.text
            if let serverStatus = serverStatus {
                
                if let caption = caption {
                    if serverStatus.isServer == true {
                        let myPeerID = appDelegate.mpcHandler.mcSession.myPeerID
                        gameDictionary[myPeerID]![turnCounter] = caption
                    } else {
                        let message = messageHandler.createMessage(string: nil, object: caption, keyForDictionary: nil, ready: nil)
                        messageHandler.sendMessage(messageDictionary: message, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                        serverStatus.isReady()
                    }
                }
            }
        }
    }
    
    func handleReceivedData(notification: NSNotification) {
        let message = messageHandler.unwrapReceivedMessage(notification: notification)
        let userID = notification.userInfo!["peerID"] as! MCPeerID
        
        if let serverStatus = serverStatus {
            if let message = message {
                if serverStatus.isServer == true {
                    if message.objectForKey("object")?.isEqual("") != true {
                        let receivedCaption = message.objectForKey("object")
                        if let receivedCaption = receivedCaption {
                        gameDictionary[userID]![turnCounter] = receivedCaption
                        }
                    }
                }
                
                if message.objectForKey("ready")?.isEqual("ready") == true {
                    if serverStatus.isServer == true {
                        serverStatus.checkReady()
                    }
                }
                
                
                if message.objectForKey("string")?.isEqual("segue") == true {
                    performSegueWithIdentifier("ToDrawing", sender: self)
                    
                }
            }
        }
    }
    
    func performSegue() {
        if let serverStatus = serverStatus {
            serverStatus.countForReadyCheck = 0
        }
        
        let segueMessage = messageHandler.createMessage(string: "segue", object: nil, keyForDictionary: nil, ready: nil)
        messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
        
        performSegueWithIdentifier("ToDrawing", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        turnCounter = turnCounter + 1
        
        print("Rando Caption - \(turnCounter) - \n \(gameDictionary) \n")
        print("arrayForOrder - \(arrayForOrder)")
        
        if segue.identifier == "ToDrawing" {
            let dvc = segue.destinationViewController as! NewDrawViewController
            dvc.serverStatus = serverStatus
            dvc.turnCounter = turnCounter
            dvc.gameDictionary = gameDictionary
            dvc.arrayForOrder = arrayForOrder
            dvc.shiftingOrderArray = arrayForOrder
        }
    }
    
}
