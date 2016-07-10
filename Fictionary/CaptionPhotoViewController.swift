//
//  CaptionPhotoViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class CaptionPhotoViewController: UIViewController, UITextFieldDelegate, MPCHandlerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    
    var receivedArray: Array = [AnyObject]()
    
    @IBOutlet var timerLabel: UILabel!
    var secondsAllowed = 25
    var seconds = 0
    var timer = NSTimer()
    
    var serverStatus: Server?
    var appDelegate: AppDelegate!
    var archiveHelper: ArchiverHelper!
    var messageHandler: MessageHandler!
    
    var turnCounter = Int()
    var arrayForOrder: Array<MCPeerID> = [MCPeerID]()
    var shiftingOrderArray: Array<MCPeerID> = [MCPeerID]()
    
    var gameDictionary = [MCPeerID : [Int : AnyObject]]()
    var exitDictionary = [MCPeerID : [Int : AnyObject]]()
    
    var dictionaryToDisplay = [Int : AnyObject]()
    var dictToDisplayReceivedFrom: MCPeerID?
    
    var keyForReceivedDictionary: MCPeerID?
    
    var countdownFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.mpcHandlerDelegate = self
        
        archiveHelper = ArchiverHelper()
        messageHandler = MessageHandler()
        
        if let serverStatus = serverStatus {
            if serverStatus.isServer == true {
                // Find the next player
                var nextPlayer: MCPeerID!
                
                for i in 0 ..< arrayForOrder.count {
                    let currentPlayer = arrayForOrder[i]
                    
                    if i == (arrayForOrder.count - 1) {
                        nextPlayer = shiftingOrderArray[0]
                    } else {
                        nextPlayer = shiftingOrderArray[i + 1]
                    }
                    let dictionaryToSend = gameDictionary[currentPlayer]
                    
                    print("\n dictionaryToSend from \(currentPlayer) \(dictionaryToSend) \n")
                    
                    let message = messageHandler.createMessage(string: "viewDidLoad", object: dictionaryToSend, keyForDictionary: currentPlayer, ready: nil)
                    messageHandler.sendMessage(messageDictionary: message, toPeers: [nextPlayer], appDelegate: appDelegate)
                    
                    if nextPlayer == appDelegate.mpcHandler.mcSession.myPeerID {
                        dictionaryToDisplay = dictionaryToSend!
                        dictToDisplayReceivedFrom = currentPlayer
                        
                        let drawnImage = dictionaryToDisplay[turnCounter - 1] as? UIImage
                        imageView.image = drawnImage
                    }
                    
                }
            }
        }
        
        
        
        seconds = secondsAllowed
        timerLabel.text = "\(seconds)"
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(subtractTime), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CaptionPhotoViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CaptionPhotoViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: self.view.window)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleReceivedData), name: "MPC_DataReceived", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(performSegue), name: "Server_Ready", object: nil)
    }
    
    func subtractTime() {
        
        seconds-=1
        timerLabel.text = "\(seconds)"
        
        if seconds == 0 {
            timer.invalidate()
            
            if !countdownFinished {
                
                countdownFinished = true
                
                var caption = ""
                
                if captionTextField.text != nil {
                    caption = captionTextField.text!
                }
                
                if serverStatus?.isServer == true {
                    gameDictionary[dictToDisplayReceivedFrom!]![turnCounter] = caption
                } else {
                    let message = messageHandler.createMessage(string: "timer_up", object: caption, keyForDictionary: keyForReceivedDictionary, ready: nil)
                    messageHandler.sendMessage(messageDictionary: message, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                    
                    serverStatus?.isReady()
                    
                }
            }
        }
    }
    
    func handleReceivedData(notification: NSNotification){
        let message = messageHandler.unwrapReceivedMessage(notification: notification)
        
        if let serverStatus = serverStatus {
            if let message = message {
                
                if message.objectForKey("string")?.isEqual("viewDidLoad") == true {
                    let messageDict = message.objectForKey("object") as! [Int : AnyObject]
                    let receivedKey = message.objectForKey("key") as! MCPeerID
                    keyForReceivedDictionary = receivedKey
                    
                    print("handleReceivedData: messageArray = \(messageDict) and receivedKey = \(receivedKey)")
                    
                    imageView.image = messageDict[turnCounter - 1] as? UIImage
                    
                }
                
                if message.objectForKey("string")?.isEqual("timer_up") == true {
                    if serverStatus.isServer == true {
                        let caption = message.objectForKey("object") as! String
                        let receivedKey = message.objectForKey("key") as! MCPeerID
                        
                        gameDictionary[receivedKey]![turnCounter] = caption
                    }
                }
                
                if message.objectForKey("ready")?.isEqual("ready") == true {
                    if serverStatus.isServer == true {
                        serverStatus.checkReady()
                    }
                }
                
                if message.objectForKey("string")?.isEqual("ExitSegue") == true {
                    let messageDict = message.objectForKey("object") as! [MCPeerID : [Int : AnyObject]]
                    exitDictionary = messageDict
                    
                    performSegueWithIdentifier("ExitSegue", sender: self)
                    
                } else if message.objectForKey("string")?.isEqual("ToDraw") == true {
                    
                    performSegueWithIdentifier("ToDraw", sender: self)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.captionTextField.resignFirstResponder()
        return true
    }
    
    
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        self.view.frame.origin.y += keyboardSize.height
    }
    
    func keyboardWillShow(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
        if keyboardSize.height == offset.height {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y -= keyboardSize.height
            })
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    func segueSwitch() {
        
        if let serverStatus = serverStatus {
            let switchForSeque = serverStatus.gameOverCheck(turnCounter)
            
            if switchForSeque {
                
                let segueMessage = messageHandler.createMessage(string: "ExitSegue", object: gameDictionary, keyForDictionary: nil, ready: nil)
                messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                performSegueWithIdentifier("ExitSegue", sender: self)
            } else {
                
                let segueMessage = messageHandler.createMessage(string: "ToDraw", object: nil, keyForDictionary: nil, ready: nil)
                messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                performSegueWithIdentifier("ToDraw", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        turnCounter = turnCounter + 1
        
        
        if segue.identifier == "ToDraw" {
            let dvc = segue.destinationViewController as! DrawViewController
            dvc.serverStatus = serverStatus
            dvc.turnCounter = turnCounter
            dvc.gameDictionary = gameDictionary
            dvc.arrayForOrder = arrayForOrder
            
            if serverStatus?.isServer == true {
                dvc.shiftingOrderArray = (serverStatus?.reorderArray(shiftingOrderArray))!
            }
            
        } else if segue.identifier == "ExitSegue" {
            //do something different
            let dvc = segue.destinationViewController as! DemoExitViewController
            dvc.exitDictionary = exitDictionary
        }
        
    }
}
