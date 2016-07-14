//
//  RandomCaptionViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 6/29/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class RandomCaptionViewController: UIViewController, MPCHandlerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var captionTextField: UITextField!
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var timerBackView: UIView!
    
    @IBOutlet weak var randomButton: UIButton!
    
    var secondsAllowed = 20
    var seconds = 0
    var timer = NSTimer()
    
    var captions = ["beat around the bush", "burn the midnight oil", "cut the mustard", "elvis has left the building", "kill two birds with one stone", "piece of cake", "a ship lost in time", "new york minute", "a slap on the wrist", "a bird in the hand is worth two in the bush", "apple of my eye", "an arm and a leg", "back seat driver", "beating around the bush", "break a leg", "curiosity killed the cat", "don’t look a gift horse in the mouth", "everything but the kitchen sink", "flip the bird", "head over heels", "hocus pocus", "hit the books", "it’s a small world", "kick the bucket", "let the cat out of the bag", "nest egg", "out of the blue", "over my dead body", "put a sock in it", "saved by the bell", "son of a gun", "the best of both worlds", "water under the bridge", "bookworm", "kung fu", "milkshake", "funny bone", "mosquito bite", "pickpocket", "football field", "circus tent", "thunder and lightning", "ice breaker", "ace of spades", "pumpkin carving", "rudolph the red-nosed reindeer", "astronaut", "cowboy", "teacher", "fire fighter", "police officer", "school bus", "doctor", "ballet dancer", "scientist", "athlete", "space ship", "basketball", "baseball", "pop star", "answer the phone", "surf the internet", "drive a car", "go fishing", "fly a plane", "paper airplane", "read a book", "listen to music", "play guitar", "play piano", "scary clown", "haunted house", "filming a movie", "take a picture", "over the moon"]
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleDroppedConnection), name: "MPC_NewPeerNotification", object: nil)
        
    }
    
    
    @IBAction func onShuffleButtonTapped(sender: AnyObject) {
        
        let randomIndex = Int(arc4random_uniform(UInt32(self.captions.count)))
        self.captionTextField.text = captions[randomIndex]
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
                    performSegueWithIdentifier("ToDrawing", sender: self)
                    
                } else if message.objectForKey("string")?.isEqual("Start Over") == true {
                    performSegueWithIdentifier("RestartSegue", sender: self)
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
    
    func handleDroppedConnection (notification: NSNotification) {
        let state = notification.userInfo!["state"] as? String
        let peerID = notification.userInfo!["peerID"] as? MCPeerID
        
        print("the dropped peer in handleDroppedConnection is \(peerID)")
        
        if state == MCSessionState.NotConnected.stringValue() {
            let alert = UIAlertController(title: "Uh oh!", message: "It looks like someone left the game.", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Start a New Game", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
                
                self.performSegueWithIdentifier("RestartSegue", sender: self)

            })
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
