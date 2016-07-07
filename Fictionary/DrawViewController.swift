//
//  DrawViewController.swift
//  Fictionary
//
//  Created by Lance Russ on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class DrawViewController: UIViewController, MPCHandlerDelegate {
    
    private var drawController: FreehandDrawController!
    
    var receivedArray: Array = [AnyObject]()
    
    var recievedCaption: String?
    
    @IBOutlet var captionLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    
    var secondsAllowed = 25
    var seconds = 0
    var timer = NSTimer()
    
    var serverStatus: Server?
    var appDelegate: AppDelegate!
    var archiveHelper: ArchiverHelper!
    var messageHandler: MessageHandler!
    
    var countdownFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.mpcHandlerDelegate = self
        
        archiveHelper = ArchiverHelper()
        messageHandler = MessageHandler()
        
        self.drawController = FreehandDrawController(canvas: self.drawView, view: self.drawView)
        self.drawController.width = 4.2
        self.drawView.multipleTouchEnabled = true
        
        
        seconds = secondsAllowed
        timerLabel.text = "\(seconds)"
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(subtractTime), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleReceivedData), name: "MPC_DataReceived", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(performSegue), name: "Server_Ready", object: nil)
        
        recievedCaption = receivedArray.last as? String
        if let recievedCaption = recievedCaption {
            captionLabel.text = recievedCaption
        }
        
    }
    
    var drawView: DrawView {
        return self.view as! DrawView
    }
    
    func subtractTime() {
        
        seconds-=1
        timerLabel.text = "\(seconds)"
        
        if seconds == 0 {
            timer.invalidate()
            
            if !countdownFinished {
                
                countdownFinished = true
                
                // We need to fix this so it will still transition if a person draws nothing.
                if self.drawView.buffer != nil {
                    let passImage = UIImage(CGImage: self.drawView.buffer!.CGImage!)
                    receivedArray.append(passImage)
                    print("DVC - receivedArray.count at append draw: \(receivedArray.count)")
                    
                    let message = messageHandler.createMessage(string: nil, object: receivedArray, ready: nil)
                    if let nextPlayer = serverStatus?.nextPlayer {
                        messageHandler.sendMessage(messageDictionary: message, toPeers: [nextPlayer], appDelegate: appDelegate)
                    }
                    
                }
            }
        }
    }
    
    func handleReceivedData(notification: NSNotification){
        
        let message = messageHandler.unwrapReceivedMessage(notification: notification)
        
        if let serverStatus = serverStatus {
            if let message = message {
                
                if message.objectForKey("object")?.isEqual("") != true {
                    let messageArray = message.objectForKey("object") as! Array<AnyObject>
                    
                    print("DVC - messageArray.count when message received: \(messageArray.count)")
                    receivedArray = messageArray
                    serverStatus.isReady()
                }
                
                if message.objectForKey("ready")?.isEqual("ready") == true {
                    if serverStatus.isServer == true {
                        serverStatus.checkReady()
                    }
                }
                
                if message.objectForKey("string")?.isEqual("ExitSegue") == true {
                    
                    performSegueWithIdentifier("ExitSegue", sender: self)
                
                } else if message.objectForKey("string")?.isEqual("ToCaption") == true {
                
                    performSegueWithIdentifier("ToCaption", sender: self)
                
                }
            }
        }
    }
    
    func performSegue() {
        if let serverStatus = serverStatus {
            serverStatus.countForReadyCheck = 0
        }
        
        segueSwitch()
        
    }
    
    func segueSwitch() {
        
        print("DVC - receivedArray.count at segue switch: \(receivedArray.count)")
        
        if let serverStatus = serverStatus {
            
            let switchForSeque = serverStatus.gameOverCheck(receivedArray)
            print("DVC - receivedArray.count after gOC: \(receivedArray.count)")
            
            if switchForSeque {
                
                let segueMessage = messageHandler.createMessage(string: "ExitSegue", object: nil, ready: nil)
                messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                
                performSegueWithIdentifier("ExitSegue", sender: self)
            } else {
                
                let segueMessage = messageHandler.createMessage(string: "ToCaption", object: nil, ready: nil)
                messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                
                performSegueWithIdentifier("ToCaption", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        if segue.identifier == "ToCaption" {
            let dvc = segue.destinationViewController as! CaptionPhotoViewController
            dvc.receivedArray = receivedArray
            dvc.serverStatus = serverStatus
            
            print("DVC - receivedArray.count at segue from draw: \(receivedArray.count)")
            print("DVC - \(receivedArray)")
            
        } else if segue.identifier == "ExitSegue" {
            // do something different
            print("DVC - receivedArray.count at exit segue: \(receivedArray.count)")
            print("DVC - \(receivedArray)")
        }
    }
    
    
    
}
