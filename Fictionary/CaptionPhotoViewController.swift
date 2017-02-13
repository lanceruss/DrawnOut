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
    @IBOutlet var behindImageView: UIView!
    @IBOutlet var backTimerView: UIView!
    @IBOutlet var headerView: UIView!
    
    var receivedArray: Array = [AnyObject]()
    
    @IBOutlet var timerActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var timerLabel: UILabel!
    var secondsAllowed = 20
    var seconds = 0
    var timer = Timer()
    var shadowIsSet: Bool = false
    
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
    
    var captionToSave = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.addSubview(behindImageView)
        //view.setNeedsLayout()
        behindImageView.layoutIfNeeded()
        
        
        headerView.backgroundColor = UIColor.pastelGreen()
        //view.setNeedsLayout()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mpcHandler.mpcHandlerDelegate = self
        
        archiveHelper = ArchiverHelper()
        messageHandler = MessageHandler()
        
        timerActivityIndicator.isHidden = true
        
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
                    
                    print("\n dictionaryToSend from \(currentPlayer.displayName) \(dictionaryToSend) \n")
                    
                    let message = messageHandler.createMessage(string: "viewDidLoad", object: dictionaryToSend as AnyObject?, keyForDictionary: currentPlayer, ready: nil)
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
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(subtractTime), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CaptionPhotoViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(CaptionPhotoViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleReceivedData), name: NSNotification.Name(rawValue: "MPC_DataReceived"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(performSegueSwitch), name: NSNotification.Name(rawValue: "Server_Ready"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDroppedConnection), name: NSNotification.Name(rawValue: "MPC_NewPeerNotification"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        
        behindImageView.layoutIfNeeded()
        backTimerView.layoutIfNeeded()
        headerView.layoutIfNeeded()
        
        backTimerView.backgroundColor = UIColor.medAquamarine()
        backTimerView.layer.cornerRadius = 0.5 * backTimerView.bounds.size.height
        
        if shadowIsSet == false {
            self.behindImageView.backgroundColor = UIColor.medAquamarine()
            self.view.backgroundColor = UIColor.pastelGreen()
            
            let shadowLayer = CAShapeLayer()
            shadowLayer.frame = behindImageView.bounds
            
            shadowLayer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            shadowLayer.shadowOpacity = 0.25
            shadowLayer.shadowRadius = 5
            
            shadowLayer.fillRule = kCAFillRuleEvenOdd
            
            let path = CGMutablePath();
            
            //let viewBounds = CGRect
            
            path.addRect(behindImageView.bounds.insetBy(dx: -42, dy: -42))
            //CGPathAddRect(path, nil, behindImageView.bounds.insetBy(dx: -42, dy: -42))
            
            let someInnerPath = UIBezierPath(roundedRect: behindImageView.bounds, cornerRadius:0.0).cgPath
            path.addPath(someInnerPath)
            //CGPathAddPath(path, nil, someInnerPath)
            path.closeSubpath()
            
            shadowLayer.path = path
            
            behindImageView.layer.addSublayer(shadowLayer)
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = someInnerPath
            shadowLayer.mask = maskLayer
            
            shadowIsSet = true
        }
    }
    
    func subtractTime() {
        
        seconds-=1
        timerLabel.text = "\(seconds)"
        timerLabel.textAlignment = NSTextAlignment.left
        
        if seconds == 0 {
            timer.invalidate()
            
            timerLabel.isHidden = true
            
            timerActivityIndicator.startAnimating()
            timerActivityIndicator.isHidden = false
            
            if !countdownFinished {
                
                countdownFinished = true
                
                
                captionTextField.isEnabled = false
                
                if captionTextField.text != nil {
                    captionToSave = captionTextField.text!
                } else {
                    captionToSave = ""
                }
                
                if let isServer = serverStatus?.isServer {
                    if isServer == false {
                        let message = messageHandler.createMessage(string: "timer_up", object: captionToSave as AnyObject?, keyForDictionary: keyForReceivedDictionary, ready: nil)
                        messageHandler.sendMessage(messageDictionary: message, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                        
                        print("non-server captionphoto turn over")
                        
                        serverStatus?.isReady()
                    }
                }
            }
        }
    }
    
    func handleReceivedData(_ notification: Notification){
        
        print("photocaption handle received data")
        
        let message = messageHandler.unwrapReceivedMessage(notification: notification)
        
        if let serverStatus = serverStatus {
            if let message = message {
                
                if (message.object(forKey: "string") as AnyObject).isEqual("viewDidLoad") == true {
                    let messageDict = message.object(forKey: "object") as! [Int : AnyObject]
                    let receivedKey = message.object(forKey: "key") as! MCPeerID
                    keyForReceivedDictionary = receivedKey
                    
                    print("handleReceivedData: messageArray = \(messageDict) and receivedKey = \(receivedKey)")
                    
                    imageView.image = messageDict[turnCounter - 1] as? UIImage
                    
                }
                
                if (message.object(forKey: "string") as AnyObject).isEqual("timer_up") == true {
                    if serverStatus.isServer == true {
                        let caption = message.object(forKey: "object") as! String
                        let receivedKey = message.object(forKey: "key") as! MCPeerID
                        
                        gameDictionary[receivedKey]![turnCounter] = caption as AnyObject?
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
                    
                } else if (message.object(forKey: "string") as AnyObject).isEqual("ToDraw") == true {
                    
                    self.performSegue(withIdentifier: "ToDraw", sender: self)
                } else if (message.object(forKey: "string") as AnyObject).isEqual("Start Over") == true {
                    self.performSegue(withIdentifier: "RestartSegue", sender: self)
                }
                
            }
        }
    }
    
    func performSegueSwitch() {
        if let serverStatus = serverStatus {
            serverStatus.countForReadyCheck = 0
        }
        
        segueSwitch()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.captionTextField.resignFirstResponder()
        return true
    }
    
    
    func keyboardWillHide(_ sender: Notification) {
        
        let userInfo: [AnyHashable: Any] = sender.userInfo!
        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
        self.view.frame.origin.y += keyboardSize.height
        self.backTimerView.frame.origin.y -= keyboardSize.height
        self.timerLabel.frame.origin.y -= keyboardSize.height
        self.headerView.frame.origin.y -= keyboardSize.height
    }
    
    func keyboardWillShow(_ sender: Notification) {
        
        let userInfo: [AnyHashable: Any] = sender.userInfo!
        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
        let offset: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
        
        if keyboardSize.height == offset.height {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y -= keyboardSize.height
                self.backTimerView.frame.origin.y += keyboardSize.height
                self.timerLabel.frame.origin.y += keyboardSize.height
                self.headerView.frame.origin.y += keyboardSize.height
            })
        } else {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
                self.backTimerView.frame.origin.x -= keyboardSize.height - offset.height
                self.timerLabel.frame.origin.x -= keyboardSize.height - offset.height
                self.headerView.frame.origin.x -= keyboardSize.height - offset.height
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    func segueSwitch() {
        
        if let serverStatus = serverStatus {
            let switchForSeque = serverStatus.gameOverCheck(turnCounter)
            
            if switchForSeque {
                
                if serverStatus.isServer == true {
                    if let dictToDisplayReceivedFrom = dictToDisplayReceivedFrom {
                        gameDictionary[dictToDisplayReceivedFrom]![turnCounter] = captionToSave as AnyObject?
                    }
                }
                
                let segueMessage = messageHandler.createMessage(string: "ExitSegue", object: gameDictionary as AnyObject?, keyForDictionary: nil, ready: nil)
                messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                self.performSegue(withIdentifier: "ExitSegue", sender: self)
                
            } else {
                
                let segueMessage = messageHandler.createMessage(string: "ToDraw", object: nil, keyForDictionary: nil, ready: nil)
                messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                self.performSegue(withIdentifier: "ToDraw", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NotificationCenter.default.removeObserver(self)
        turnCounter = turnCounter + 1
        
        
        if segue.identifier == "ToDraw" {
            let dvc = segue.destination as! NewDrawViewController
            dvc.serverStatus = serverStatus
            dvc.turnCounter = turnCounter
            dvc.gameDictionary = gameDictionary
            dvc.arrayForOrder = arrayForOrder
            
            if serverStatus?.isServer == true {
                dvc.shiftingOrderArray = (serverStatus?.reorderArray(shiftingOrderArray))!
            }
            
        } else if segue.identifier == "ExitSegue" {
            //do something different
            
            
            let dvc = segue.destination as! EndGameSwipeVC
            
            if serverStatus?.isServer == true {
                dvc.exitDictionary = gameDictionary
            } else {
                dvc.exitDictionary = exitDictionary
            }
        }
    }
    
    func handleDroppedConnection (_ notification: Notification) {
        let state = notification.userInfo!["state"] as? String
        let peerID = notification.userInfo!["peerID"] as? MCPeerID
        
        print("the dropped peer in handleDroppedConnection is \(peerID)")
        
        if state == MCSessionState.notConnected.stringValue() {
            let alert = UIAlertController(title: "Uh oh!", message: "It looks like someone left the game.", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Start a New Game", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                
                self.performSegue(withIdentifier: "RestartSegue", sender: self)
                
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
