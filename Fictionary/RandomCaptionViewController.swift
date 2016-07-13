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
    
    @IBOutlet weak var captionTextField: UITextField!
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var timerBackView: UIView!
    
    @IBOutlet weak var randomButton: UIButton!
    
    var secondsAllowed = 10
    var seconds = 0
    var timer = NSTimer()
    
    var captions = ["beat around the bush", "burn the midnight oil", "cut the mustard", "elvis has left the building", "kill two birds with one stone", "piece of cake", "a ship lost in time", "new york minute", "a slap on the wrist", "a bird in the hand is worth two in the bush", "apple of my eye", "an arm and a leg", "back seat driver", "beating around the bush", "break a leg", "curiosity killed the cat", "don’t look a gift horse in the mouth", "everything but the kitchen sink", "flip the bird", "head over heels", "hocus pocus", "hit the books", "it’s a small world", "kick the bucket", "let the cat out of the bag", "nest egg", "out of the blue", "over my dead body", "put a sock in it", "saved by the bell", "son of a gun", "the best of both worlds", "water under the bridge", "bookworm", "kung fu", "milkshake", "funny bone", "mosquito bite", "pickpocket", "football field", "circus tent", "thunder and lightning", "ice breaker", "ace of spades", "carve a pumpkin", "rudolph the red-nosed reindeer", "astronaut", "cowboy", "teacher", "fire fighter", "police officer", "school bus", "doctor", "ballet dancer", "scientist", "athlete", "space ship", "basketball", "baseball", "pop star", "answer the phone", "surf the internet", "drive a car", "go fishing", "fly a plane", "paper airplane", "read a book", "listen to music", "play guitar", "play piano", "scary clown", "haunted house", "filming a movie", "take a picture", "over the moon"]
    
    var serverStatus: Server?
    var appDelegate: AppDelegate!
    var archiveHelper: ArchiverHelper!
    var messageHandler: MessageHandler!
    
    var arrayForOrder: Array<MCPeerID> = [MCPeerID]()
    var gameDictionary = [MCPeerID : [Int : AnyObject]]()
    
    var turnCounter = 1
    
    var deviceDropped = false
    var droppedPeers = [MCPeerID]()
    
    @IBAction func dismissButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        if let serverID = serverStatus?.serverPeerID {
        //            print("the server is: \(serverID)")
        //        }
        
        self.view.backgroundColor = UIColor.pastelGreen()
        
        timerBackView.backgroundColor = UIColor.shamrock()
        timerBackView.layer.cornerRadius = 0.5 * timerBackView.bounds.size.height
        
        randomButton.backgroundColor = UIColor.shamrock()
        randomButton.layer.cornerRadius = 0.5 * randomButton.bounds.size.height
        
        // Set up the AppDelegate to reference the MPCHandler and references to the ArchiverHelper and the MessageHandler
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.mpcHandlerDelegate = self
        
        archiveHelper = ArchiverHelper()
        messageHandler = MessageHandler()
        
        
        // Get a randomIndex and use it to display a random caption
        let randomIndex = Int(arc4random_uniform(UInt32(self.captions.count)))
        self.captionTextField.text = captions[randomIndex]
        
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
                let message = messageHandler.createMessage(string: "arrayForOrder", object: arrayForOrder, keyForDictionary: nil, ready: nil)
                messageHandler.sendMessage(messageDictionary: message, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleReceivedData), name: "MPC_DataReceived", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(performSegue), name: "Server_Ready", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleDroppedConnection), name: "MPC_NewPeerNotification", object: nil)
    }
    
    
    @IBAction func onShuffleButtonTapped(sender: AnyObject) {
        
        let randomIndex = Int(arc4random_uniform(UInt32(self.captions.count)))
        self.captionTextField.text = captions[randomIndex]
    }
    
    func subtractTime() {
        
        seconds-=1
        timerLabel.text = "\(seconds)"
        
        if seconds == 0 {
            timer.invalidate()
            let caption = captionTextField.text
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
                    
                    let receivedDictionary = message.objectForKey("object") as? [MCPeerID : [Int : AnyObject]]
                    if serverStatus.isServer == false {
                        if let receivedDictionary = receivedDictionary {
                            gameDictionary = receivedDictionary
                        }
                    }
                    
                    performSegueWithIdentifier("ToDrawing", sender: self)
                    
                } else if message.objectForKey("string")?.isEqual("arrayForOrder") == true {
                    let receivedArray = message.objectForKey("object") as! [MCPeerID]
                    arrayForOrder = receivedArray
                }
            }
        }
    }
    
    func performSegue() {
        if let serverStatus = serverStatus {
            serverStatus.countForReadyCheck = 0
        }
        
        let segueMessage = messageHandler.createMessage(string: "segue", object: gameDictionary, keyForDictionary: nil, ready: nil)
        messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
        
        performSegueWithIdentifier("ToDrawing", sender: self)
        
    }
    
    func handleDroppedConnection (notification: NSNotification) {
        let state = notification.userInfo!["state"] as? String
        let peerID = notification.userInfo!["peerID"] as? MCPeerID
        
        print("the dropped peer in handleDroppedConnection is \(peerID)")
        
        if state == MCSessionState.NotConnected.stringValue() {            deviceDropped = true
            if let peerID = peerID {
                droppedPeers.append(peerID)
                
                var peerToRemove: Int?
                for i in 0 ..< arrayForOrder.count {
                    if arrayForOrder[i] == peerID {
                        peerToRemove = i
                    }
                }
                if let peerToRemove = peerToRemove {
                    arrayForOrder.removeAtIndex(peerToRemove)
                }
                
                let newServer = arrayForOrder.first
                
                if let serverPeerID = serverStatus!.serverPeerID {
                    if peerID == serverPeerID {
                        
                        if appDelegate.mpcHandler.mcSession.myPeerID == newServer {
                            serverStatus?.isServer = true
                        }
                    }
                }
            }
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if deviceDropped == true {
            
            for peerID in droppedPeers {
                if let serverStatus = serverStatus {
                    if serverStatus.isServer == true {
                        gameDictionary.removeValueForKey(peerID)
                        
                        
                    }
                    
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        turnCounter = turnCounter + 1
        
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
