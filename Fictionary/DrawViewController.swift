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
    
    fileprivate var drawController: FreehandDrawController!
    
    @IBOutlet var captionLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    
    var secondsAllowed = 25
    var seconds = 0
    var timer = Timer()
    
    var serverStatus: Server?
    var appDelegate: AppDelegate!
    var archiveHelper: ArchiverHelper!
    var messageHandler: MessageHandler!
    
    var turnCounter = Int()
    var gameDictionary = [MCPeerID : [Int : AnyObject]]()
    var arrayForOrder: Array<MCPeerID> = [MCPeerID]()
    var shiftingOrderArray: Array<MCPeerID> = [MCPeerID]()
    
    var exitDictionary = [MCPeerID : [Int : AnyObject]]()

    
    var dictionaryToDisplay = [Int : AnyObject]()
    var dictToDisplayReceivedFrom: MCPeerID?
    
    var keyForReceivedDictionary: MCPeerID?
    
    var countdownFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
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
                    
                    let message = messageHandler.createMessage(string: "viewDidLoad", object: dictionaryToSend as AnyObject?, keyForDictionary: currentPlayer, ready: nil)
                    messageHandler.sendMessage(messageDictionary: message, toPeers: [nextPlayer], appDelegate: appDelegate)
                    
                    if nextPlayer == appDelegate.mpcHandler.mcSession.myPeerID {
                        dictionaryToDisplay = dictionaryToSend!
                        dictToDisplayReceivedFrom = currentPlayer
                        
                        let caption = dictionaryToDisplay[turnCounter - 1] as? String
                        captionLabel.text = caption
                    }
                    
                }
            }
        }
        
        self.drawController = FreehandDrawController(canvas: self.drawView, view: self.drawView)
        self.drawController.width = 4.2
        self.drawView.isMultipleTouchEnabled = true
        
        
        seconds = secondsAllowed
        timerLabel.text = "\(seconds)"
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(subtractTime), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleReceivedData), name: NSNotification.Name(rawValue: "MPC_DataReceived"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(performSegueForServer), name: NSNotification.Name(rawValue: "Server_Ready"), object: nil)
        
        
        
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
                    let passImage = UIImage(cgImage: self.drawView.buffer!.cgImage!)
                    if serverStatus?.isServer == true {
                        gameDictionary[dictToDisplayReceivedFrom!]![turnCounter] = passImage
                    } else {
                       
                        let message = messageHandler.createMessage(string: "timer_up", object: passImage, keyForDictionary: keyForReceivedDictionary, ready: nil)
                        messageHandler.sendMessage(messageDictionary: message, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                        
                        serverStatus?.isReady()
                    }
                }}
            
        }
    }

    
    func handleReceivedData(_ notification: Notification){
        
        let message = messageHandler.unwrapReceivedMessage(notification: notification)
        
        if let serverStatus = serverStatus {
            if let message = message {
                
                if (message.object(forKey: "string") as AnyObject).isEqual("viewDidLoad") == true {
                    let messageDict = message.object(forKey: "object") as! [Int : AnyObject]
                    let receivedKey = message.object(forKey: "key") as! MCPeerID
                    keyForReceivedDictionary = receivedKey
                    
                    print("handleReceivedData: messageArray = \(messageDict) and receivedKey = \(receivedKey)")
                    
                    captionLabel.text = messageDict[turnCounter - 1] as? String
                    
                }
                
                if (message.object(forKey: "string") as AnyObject).isEqual("timer_up") == true {
                    if serverStatus.isServer == true {
                        let image = message.object(forKey: "object") as! UIImage
                        let receivedKey = message.object(forKey: "key") as! MCPeerID
                        
                        gameDictionary[receivedKey]![turnCounter] = image
                    }
                }
                
                if (message.object(forKey: "ready") as AnyObject).isEqual("ready") == true {
                    if serverStatus.isServer == true {
                        serverStatus.checkReady()
                    }
                }
                
                if (message.object(forKey: "string") as AnyObject).isEqual("ExitSegue") == true {
                    
                    let messageDict = message.object(forKey: "object") as! [MCPeerID : [Int : AnyObject]]
                    exitDictionary = messageDict
                    
                    self.performSegue(withIdentifier: "ExitSegue", sender: self)
                    
                } else if (message.object(forKey: "string") as AnyObject).isEqual("ToCaption") == true {
                    
                    self.performSegue(withIdentifier: "ToCaption", sender: self)
                    
                }
            }
        }
    }
    
    func performSegueForServer() {
        if let serverStatus = serverStatus {
            serverStatus.countForReadyCheck = 0
        }
        
        segueSwitch()
        
    }
    
    func segueSwitch() {
        
        if let serverStatus = serverStatus {
            
            let switchForSeque = serverStatus.gameOverCheck(turnCounter)
            
            if switchForSeque {
                
                let segueMessage = messageHandler.createMessage(string: "ExitSegue", object: gameDictionary as AnyObject?, keyForDictionary: nil, ready: nil)
                messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                
                self.performSegue(withIdentifier: "ExitSegue", sender: self)
            } else {
                
                let segueMessage = messageHandler.createMessage(string: "ToCaption", object: nil, keyForDictionary: nil, ready: nil)
                messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                
                self.performSegue(withIdentifier: "ToCaption", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        NotificationCenter.default.removeObserver(self)
        turnCounter = turnCounter + 1
        
        print("DrawVC - \(turnCounter) - \n \(gameDictionary) \n")
        print("arrayForOrder - \(arrayForOrder)")
        
        if segue.identifier == "ToCaption" {
            let dvc = segue.destination as! CaptionPhotoViewController
            dvc.serverStatus = serverStatus
            dvc.turnCounter = turnCounter
            dvc.gameDictionary = gameDictionary
            dvc.arrayForOrder = arrayForOrder
            
            if serverStatus?.isServer == true {
                 dvc.shiftingOrderArray = (serverStatus?.reorderArray(shiftingOrderArray))!
            }
            
        } else if segue.identifier == "ExitSegue" {
            // do something different
            let dvc = segue.destination as! DemoExitViewController
            dvc.exitDictionary = exitDictionary
        }
    }
    
    
    
}
