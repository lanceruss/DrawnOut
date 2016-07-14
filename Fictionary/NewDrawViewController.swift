//
//  NewDrawViewController.swift
//  Fictionary
//
//  Created by Lance Russ on 7/10/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class NewDrawViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ColorPaletteViewDelegate, MPCHandlerDelegate {

    @IBOutlet var headerView: UIView!
    @IBOutlet var captionView: UIView!
    @IBOutlet weak var colorTableView: UITableView!
    @IBOutlet weak var colorPaletteView: ColorPaletteView!
    @IBOutlet weak var colorPaletteViewHeight: NSLayoutConstraint!
    @IBOutlet var drawingView: DrawingView!
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var captionLabel: UILabel!
    
    var colorPaletteViewExpanded: Bool = false
    
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
    
    var secondsAllowed = 45
    var seconds = 0
    var timer = NSTimer()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawingView.setNeedsLayout()
        
        if drawingView.incrementalImage == nil {
//        drawingView.incrementalImage = UIImage(named:"white")

//        UIGraphicsBeginImageContextWithOptions(drawingView.bounds.size, true, 0.0)
//        print("drawinView.bounds.size \(drawingView.bounds.size)")
//        print("drawinView.bounds \(drawingView.bounds)")
//
//        let rectpath: UIBezierPath = UIBezierPath(rect: drawingView.bounds)
//        UIColor.whiteColor().setFill()
//        rectpath.fill()
//        
//        drawingView.incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        }

        headerView.backgroundColor = UIColor.pastelGreen()
        captionView.backgroundColor = UIColor.medAquamarine()
        
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOpacity = 0.25
        headerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headerView.layer.shadowRadius = 3.5


        self.drawingView.multipleTouchEnabled = true
        drawingView.drawingQueue = dispatch_queue_create("drawingQueue", nil)
        
        colorPaletteView.delegate = self

        colorTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        colorTableView.scrollEnabled = false
        colorPaletteView.userInteractionEnabled = true
        self.drawingView.setupGestureRecognizersInView(self.drawingView)

        self.colorPaletteView.setupGestureRecognizersInView(colorPaletteView)
        self.colorTableView.hidden = true
        self.colorPaletteView.backgroundColor = UIColor.blackColor()
        self.colorPaletteView.layer.cornerRadius = 5
        self.colorPaletteView.layer.masksToBounds = true
        
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
                    
                    let message = messageHandler.createMessage(string: "viewDidLoad", object: dictionaryToSend, keyForDictionary: currentPlayer, ready: nil)
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
        
        seconds = secondsAllowed
        timerLabel.text = "\(seconds)"
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(subtractTime), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleReceivedData), name: "MPC_DataReceived", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(performSegue), name: "Server_Ready", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleDroppedConnection), name: "MPC_NewPeerNotification", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        // Might actually need this this time.
    }
    
    override func viewDidLayoutSubviews() {
    
        drawingView.setNeedsLayout()
        
        if drawingView.incrementalImage == nil {
        UIGraphicsBeginImageContext(drawingView.bounds.size)
        drawingView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        drawingView.incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = colorTableView.dequeueReusableCellWithIdentifier("cellid", forIndexPath: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if let colorPalette = ColorPalette(rawValue: indexPath.row) {
            cell.backgroundColor = colorPalette.color()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 22
    }
    
    func didTapView(view: ColorPaletteView) {
        //print("didTapView")
        if colorPaletteViewExpanded == false {
            
            let newHeight = drawingView.bounds.size.height - 16
            
            ColorPaletteView.animateWithDuration(3.0, delay: 0.0, options: .CurveEaseIn, animations: {
                
                self.colorPaletteViewHeight.constant = newHeight
                
                }, completion: { finished in
                    self.colorTableView.scrollEnabled = true
                    self.colorPaletteView.tapRecognizer4!.numberOfTapsRequired = 8
                    self.colorTableView.hidden = false
                    self.colorPaletteViewExpanded = true
            })
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print("didSelectRow")
        if colorPaletteViewExpanded == true {
            
            ColorPaletteView.animateWithDuration(3.0, delay: 0.0, options: .CurveEaseIn, animations: {
                
                self.colorPaletteViewHeight.constant = 40
                //                self.colorPaletteViewTop.constant = (self.colorPaletteViewTop.constant - 8) - newTop
                
                }, completion: { finished in
                    self.colorPaletteView.tapRecognizer4!.numberOfTapsRequired = 1
                    self.colorPaletteViewExpanded = false
                    self.colorTableView.scrollEnabled = false
                    self.colorTableView.hidden = true
                    if let colorPalette = ColorPalette(rawValue: indexPath.row) {
                        self.drawingView.color = colorPalette.color()
                        self.colorPaletteView.backgroundColor = colorPalette.color()
                    }
            })
        }
    }
    
    // MARK: MPC methods
    
    func subtractTime() {
        
        seconds-=1
        timerLabel.text = "\(seconds)"
        
        if seconds == 0 {
            timer.invalidate()
            
            if !countdownFinished {
                
                countdownFinished = true
                
                // We need to fix this so it will still transition if a person draws nothing.
                if self.drawingView.incrementalImage != nil {
                    let passImage = UIImage(CGImage: self.drawingView.incrementalImage!.CGImage!)
                    if serverStatus?.isServer == true {
                        gameDictionary[dictToDisplayReceivedFrom!]![turnCounter] = passImage
                    } else {
                        
                        let message = messageHandler.createMessage(string: "timer_up", object: passImage, keyForDictionary: keyForReceivedDictionary, ready: nil)
                        messageHandler.sendMessage(messageDictionary: message, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                        //let passImage = UIImage(CGImage: self.drawingView.incrementalImage!.CGImage!)

                        serverStatus?.isReady()
                    }
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
                    
                    captionLabel.text = messageDict[turnCounter - 1] as? String
                    
                }
                
                if message.objectForKey("string")?.isEqual("timer_up") == true {
                    if serverStatus.isServer == true {
                        let image = message.objectForKey("object") as! UIImage
                        let receivedKey = message.objectForKey("key") as! MCPeerID
                        
                        gameDictionary[receivedKey]![turnCounter] = image
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
                    
                } else if message.objectForKey("string")?.isEqual("ToCaption") == true {
                    
                    performSegueWithIdentifier("ToCaption", sender: self)
                    
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
        
        segueSwitch()
        
    }
    
    func segueSwitch() {
        
        if let serverStatus = serverStatus {
            
            let switchForSeque = serverStatus.gameOverCheck(turnCounter)
            
            if switchForSeque {
                
                let segueMessage = messageHandler.createMessage(string: "ExitSegue", object: gameDictionary, keyForDictionary: nil, ready: nil)
                messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                
                performSegueWithIdentifier("ExitSegue", sender: self)
            } else {
                
                let segueMessage = messageHandler.createMessage(string: "ToCaption", object: nil, keyForDictionary: nil, ready: nil)
                messageHandler.sendMessage(messageDictionary: segueMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                
                performSegueWithIdentifier("ToCaption", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        turnCounter = turnCounter + 1
        
        print("DrawVC - \(turnCounter) - \n \(gameDictionary) \n")
        print("arrayForOrder - \(arrayForOrder)")
        
        if segue.identifier == "ToCaption" {
            let dvc = segue.destinationViewController as! CaptionPhotoViewController
            dvc.serverStatus = serverStatus
            dvc.turnCounter = turnCounter
            dvc.gameDictionary = gameDictionary
            dvc.arrayForOrder = arrayForOrder
            
            if serverStatus?.isServer == true {
                dvc.shiftingOrderArray = (serverStatus?.reorderArray(shiftingOrderArray))!
            }
            
        } else if segue.identifier == "ExitSegue" {
            // do something different
            let dvc = segue.destinationViewController as! EndGameSwipeVC
            
            if serverStatus?.isServer == true {
                dvc.exitDictionary = gameDictionary
            } else {
                dvc.exitDictionary = exitDictionary
            }
        }
    }

    func handleDroppedConnection (notification: NSNotification) {
        let state = notification.userInfo!["state"] as? String
        let peerID = notification.userInfo!["peerID"] as? MCPeerID
        
        print("the dropped peer in handleDroppedConnection is \(peerID)")
        
        if state == MCSessionState.NotConnected.stringValue() {
            let alert = UIAlertController(title: "Start Over", message: "It looks like someone left the game. Unfortunately, that means you'll have to start over.", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
                
                self.performSegueWithIdentifier("RestartSegue", sender: self)

            })
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
