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
    var passDictionary = [String : AnyObject]()
    
    var captions = ["making a pizza",
                    "delivering mail",
                    "playing hopscotch",
                    "setting up a tent",
                    "the cow jumped over the moon",
                    "shopping at the mall",
                    "baking bread",
                    "decorating for a party",
                    "asking for an autograph",
                    "playing with play dough",
                    "flying a kite",
                    "being a flight attendant",
                    "walking with crutches",
                    "filming a movie",
                    "walking through a haunted house",
                    "milking a cow",
                    "operating a jackhammer"]
    
    var serverStatus: Server?
    var appDelegate: AppDelegate!
    var archiveHelper: ArchiverHelper!
    var messageHandler: MessageHandler!
    
    var stackArray: Array = [AnyObject]()
    var receivedArray: Array = [AnyObject]()
    
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
            // Find next player
            
            var indexOfCurrentPlayer: Int?
            
            // Get the index of the player in the playersInOrder array
            for i in 0 ..< serverStatus.playersInOrder.count {
                for (key, _) in serverStatus.playersInOrder[i] {
                    if key.isEqual(serverStatus.id) {
                        indexOfCurrentPlayer = i
                    }
                }
            }
            
            // Find the next player
            var nextPlayer: NSDictionary?
            
            if let indexOfCurrentPlayer = indexOfCurrentPlayer {
                if indexOfCurrentPlayer < serverStatus.playersInOrder.count - 1 {
                    nextPlayer = serverStatus.playersInOrder[indexOfCurrentPlayer + 1]
                } else if indexOfCurrentPlayer == serverStatus.playersInOrder.count - 1 {
                    nextPlayer = serverStatus.playersInOrder.first
                }
            }
            
            // Get next player's peerID
            if let nextPlayer = nextPlayer {
                for (key, _) in nextPlayer {
                    let nextPlayersPeerID = key as? MCPeerID
                    serverStatus.nextPlayer = nextPlayersPeerID
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
            if let caption = caption {
                stackArray.append(caption)
            }
            
            let message = messageHandler.createMessage(string: nil, object: stackArray, ready: nil)
            print("---------------- \n \(serverStatus?.nextPlayer)  \n --------------")
            if let nextPlayer = serverStatus?.nextPlayer {
                messageHandler.sendMessage(messageDictionary: message, toPeers: [nextPlayer], appDelegate: appDelegate)
                print(">>>>>>>>  \n  \(message)  \n >>>>>>>>>>>")
            }
        }
    }
    
    func handleReceivedData(notification: NSNotification) {
        let message = messageHandler.unwrapReceivedMessage(notification: notification)
        
        if let serverStatus = serverStatus {
            if let message = message {
                if message.objectForKey("object")?.isEqual("") != true {
                    let messageArray = message.objectForKey("object") as! Array<AnyObject>
                    receivedArray = messageArray
                    serverStatus.isReady()
                    print("111111111111111111")
                }
                
                if message.objectForKey("ready")?.isEqual("ready") == true {
                    if serverStatus.isServer == true {
                        serverStatus.checkReady()
                        print("222222222222222222")
                    }
                }
                
                
                if message.objectForKey("string")?.isEqual("segue") == true {
                    performSegueWithIdentifier("ToDrawing", sender: self)
                    print("3333333333333333333")
                    
                }
            }
        }
    }
    
    func performSegue() {
        if let serverStatus = serverStatus {
            serverStatus.countForReadyCheck = 0
        }
        
        let segueMessage = messageHandler.createMessage(string: "segue", object: nil, ready: nil)
        messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
        
        performSegueWithIdentifier("ToDrawing", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        if segue.identifier == "ToDrawing" {
            let dvc = segue.destinationViewController as! DrawViewController
            dvc.receivedArray = receivedArray
            dvc.serverStatus = serverStatus
        }
    }
    
}
