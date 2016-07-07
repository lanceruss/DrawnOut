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
    var drawnImage: UIImage?
    
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
        
        print("CVC - receivedArray.count at caption page did load: \(receivedArray.count)")
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.mpcHandlerDelegate = self
        
        archiveHelper = ArchiverHelper()
        messageHandler = MessageHandler()
        
        drawnImage = receivedArray.last as? UIImage
        imageView.image = drawnImage
        
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
                
                receivedArray.append(caption)
                print("CVC - receivedArray.count at append caption: \(receivedArray.count)")

                let message = messageHandler.createMessage(string: nil, object: receivedArray, ready: nil)
                if let nextPlayer = serverStatus?.nextPlayer {
                    messageHandler.sendMessage(messageDictionary: message, toPeers: [nextPlayer], appDelegate: appDelegate)
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
        
        print("CVC - receivedArray.count at caption segueSwitch: \(receivedArray.count)")
        
        if let serverStatus = serverStatus {
            let switchForSeque = serverStatus.gameOverCheck(receivedArray)
            print("CVC - receivedArray.count after gOC: \(receivedArray.count)")
            
            if switchForSeque {
                
                let segueMessage = messageHandler.createMessage(string: "ExitSegue", object: nil, ready: nil)
                messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                performSegueWithIdentifier("ExitSegue", sender: self)
            } else {
                
                let segueMessage = messageHandler.createMessage(string: "ToDraw", object: nil, ready: nil)
                messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                performSegueWithIdentifier("ToDraw", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        if segue.identifier == "ToDraw" {
            let dvc = segue.destinationViewController as! DrawViewController
            dvc.receivedArray = receivedArray
            dvc.serverStatus = serverStatus
            
            print("CVC - receivedArray.count at segue from caption: \(receivedArray.count)")
            print("CVC - \(receivedArray)")
            
        } else if segue.identifier == "ExitSegue" {
            //do something different
            
            print("DVC - receivedArray.count at exit segue: \(receivedArray.count)")
            print("DVC - \(receivedArray)")        }
    }
    
}
