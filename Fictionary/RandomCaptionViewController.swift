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
    
    @IBOutlet var whiteActivityIndicator: UIActivityIndicatorView!
    
    var secondsAllowed = 20
    var seconds = 0
    var timer = Timer()
    
    var captions = ["beat around the bush", "burn the midnight oil", "cut the mustard", "elvis has left the building", "kill two birds with one stone", "piece of cake", "a ship lost in time", "new york minute", "a slap on the wrist", "a bird in the hand is worth two in the bush", "apple of my eye", "an arm and a leg", "back seat driver", "beating around the bush", "break a leg", "curiosity killed the cat", "don’t look a gift horse in the mouth", "everything but the kitchen sink", "flip the bird", "head over heels", "hocus pocus", "hit the books", "it’s a small world", "kick the bucket", "let the cat out of the bag", "nest egg", "out of the blue", "over my dead body", "put a sock in it", "saved by the bell", "son of a gun", "the best of both worlds", "water under the bridge", "bookworm", "kung fu", "milkshake", "funny bone", "mosquito bite", "pickpocket", "football field", "circus tent", "thunder and lightning", "ice breaker", "ace of spades", "pumpkin carving", "rudolph the red-nosed reindeer", "astronaut", "cowboy", "teacher", "fire fighter", "police officer", "school bus", "doctor", "ballet dancer", "scientist", "athlete", "space ship", "basketball", "baseball", "pop star", "answer the phone", "surf the internet", "drive a car", "go fishing", "fly a plane", "paper airplane", "read a book", "listen to music", "play guitar", "play piano", "scary clown", "haunted house", "filming a movie", "take a picture", "over the moon"]
    
    var serverStatus: Server?
    var appDelegate: AppDelegate!
    var archiveHelper: ArchiverHelper!
    var messageHandler: MessageHandler!
    
    var arrayForOrder: Array<MCPeerID> = [MCPeerID]()
    var gameDictionary = [MCPeerID : [Int : AnyObject]]()
    
    var turnCounter = 1
    
    @IBAction func dismissButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.pastelGreen()
        
        timerBackView.backgroundColor = UIColor.shamrock()
        timerBackView.layer.cornerRadius = 0.5 * timerBackView.bounds.size.height
        
        randomButton.backgroundColor = UIColor.shamrock()
        randomButton.layer.cornerRadius = 0.5 * randomButton.bounds.size.height
        
        // Set up the AppDelegate to reference the MPCHandler and references to the ArchiverHelper and the MessageHandler
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mpcHandler.mpcHandlerDelegate = self
        
        archiveHelper = ArchiverHelper()
        messageHandler = MessageHandler()
        
        whiteActivityIndicator.isHidden = true
        
        // Set up timer
        seconds = secondsAllowed
        timerLabel.text = "\(seconds)"
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TimerViewController.subtractTime), userInfo: nil, repeats: true)
        
        // Find the next player and store that player's PeerID
        if let serverStatus = serverStatus {
            if serverStatus.isServer == true {
                for (key, _) in gameDictionary {
                    arrayForOrder.append(key)
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleReceivedData), name: NSNotification.Name(rawValue: "MPC_DataReceived"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(performSegue), name: NSNotification.Name(rawValue: "Server_Ready"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDroppedConnection), name: NSNotification.Name(rawValue: "MPC_NewPeerNotification"), object: nil)
        
    }
    
    
    @IBAction func onShuffleButtonTapped(_ sender: AnyObject) {
        
        let randomIndex = Int(arc4random_uniform(UInt32(self.captions.count)))
        self.captionTextField.text = captions[randomIndex]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func subtractTime() {
        
        seconds-=1
        timerLabel.text = "\(seconds)"
        
        if seconds == 0 {
            timer.invalidate()
            
            timerLabel.isHidden = true
            
            whiteActivityIndicator.startAnimating()
            whiteActivityIndicator.isHidden = false
            
            captionTextField.isEnabled = false
            
            let caption = captionTextField.text
            if let serverStatus = serverStatus {
                
                if let caption = caption {
                    if serverStatus.isServer == true {
                        let myPeerID = appDelegate.mpcHandler.mcSession.myPeerID
                        gameDictionary[myPeerID]![turnCounter] = caption as AnyObject?
                    } else {
                        let message = messageHandler.createMessage(string: nil, object: caption as AnyObject?, keyForDictionary: nil, ready: nil)
                        messageHandler.sendMessage(messageDictionary: message, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                        serverStatus.isReady()
                    }
                }
            }
        }
    }
    
    func handleReceivedData(_ notification: Notification) {
        let message = messageHandler.unwrapReceivedMessage(notification: notification)
        let userID = notification.userInfo!["peerID"] as! MCPeerID
        
        if let serverStatus = serverStatus {
            if let message = message {
                if serverStatus.isServer == true {
                    if message.object(forKey: "object")?.isEqual("") != true {
                        let receivedCaption = message.object(forKey: "object")
                        if let receivedCaption = receivedCaption {
                        gameDictionary[userID]![turnCounter] = receivedCaption
                        }
                    }
                }
                
                if message.object(forKey: "ready")?.isEqual("ready") == true {
                    if serverStatus.isServer == true {
                        serverStatus.checkReady()
                    }
                }
                
                
                if message.object(forKey: "string")?.isEqual("segue") == true {
                    self.performSegue(withIdentifier: "ToDrawing", sender: self)
                    
                } else if message.object(forKey: "string")?.isEqual("Start Over") == true {
                    self.performSegue(withIdentifier: "RestartSegue", sender: self)
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
        
        self.performSegue(withIdentifier: "ToDrawing", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        NotificationCenter.default.removeObserver(self)
        turnCounter = turnCounter + 1
        
        print("Rando Caption - \(turnCounter) - \n \(gameDictionary) \n")
        print("arrayForOrder - \(arrayForOrder)")
        
        if segue.identifier == "ToDrawing" {
            let dvc = segue.destination as! NewDrawViewController
            dvc.serverStatus = serverStatus
            dvc.turnCounter = turnCounter
            dvc.gameDictionary = gameDictionary
            dvc.arrayForOrder = arrayForOrder
            dvc.shiftingOrderArray = arrayForOrder
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
