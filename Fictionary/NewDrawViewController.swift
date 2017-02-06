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
    @IBOutlet var timerActivityIndicator: UIActivityIndicatorView!
    
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
    var timer = Timer()

    
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
        
        timerActivityIndicator.isHidden = true

        headerView.backgroundColor = UIColor.pastelGreen()
        captionView.backgroundColor = UIColor.medAquamarine()
        
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOpacity = 0.25
        headerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headerView.layer.shadowRadius = 3.5

        self.drawingView.isMultipleTouchEnabled = true
        drawingView.drawingQueue = DispatchQueue(label: "drawingQueue", attributes: [])
        
        colorPaletteView.delegate = self

        colorTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        colorTableView.isScrollEnabled = false
        colorPaletteView.isUserInteractionEnabled = true
        self.drawingView.setupGestureRecognizersInView(self.drawingView)

        self.colorPaletteView.setupGestureRecognizersInView(colorPaletteView)
        self.colorTableView.isHidden = true
        self.colorPaletteView.backgroundColor = UIColor.black
        self.colorPaletteView.layer.cornerRadius = 5
        self.colorPaletteView.layer.masksToBounds = true
        
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
        
        seconds = secondsAllowed
        timerLabel.text = "\(seconds)"
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(subtractTime), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleReceivedData), name: NSNotification.Name(rawValue: "MPC_DataReceived"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(performSegue), name: NSNotification.Name(rawValue: "Server_Ready"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDroppedConnection), name: NSNotification.Name(rawValue: "MPC_NewPeerNotification"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        // Might actually need this.
    }
    
    override func viewDidLayoutSubviews() {
    
        drawingView.setNeedsLayout()
        
        if drawingView.incrementalImage == nil {
        UIGraphicsBeginImageContext(drawingView.bounds.size)
        drawingView.layer.render(in: UIGraphicsGetCurrentContext()!)
        drawingView.incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        }
    }
    
    // MARK: Color Palette methods

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = colorTableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if let colorPalette = ColorPalette(rawValue: indexPath.row) {
            cell.backgroundColor = colorPalette.color()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 22
    }
    
    func didTapView(_ view: ColorPaletteView) {
        //print("didTapView")
        if colorPaletteViewExpanded == false {
            
            let newHeight = drawingView.bounds.size.height - 16
            
            ColorPaletteView.animate(withDuration: 3.0, delay: 0.0, options: .curveEaseIn, animations: {
                
                self.colorPaletteViewHeight.constant = newHeight
                
                }, completion: { finished in
                    self.colorTableView.isScrollEnabled = true
                    self.colorPaletteView.tapRecognizer4!.numberOfTapsRequired = 8
                    self.colorTableView.isHidden = false
                    self.colorPaletteViewExpanded = true
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("didSelectRow")
        if colorPaletteViewExpanded == true {
            
            ColorPaletteView.animate(withDuration: 3.0, delay: 0.0, options: .curveEaseIn, animations: {
                
                self.colorPaletteViewHeight.constant = 40
                //                self.colorPaletteViewTop.constant = (self.colorPaletteViewTop.constant - 8) - newTop
                
                }, completion: { finished in
                    self.colorPaletteView.tapRecognizer4!.numberOfTapsRequired = 1
                    self.colorPaletteViewExpanded = false
                    self.colorTableView.isScrollEnabled = false
                    self.colorTableView.isHidden = true
                    if let colorPalette = ColorPalette(rawValue: indexPath.row) {
                        self.drawingView.color = colorPalette.color()
                        self.colorPaletteView.backgroundColor = colorPalette.color()
                    }
            })
        }
    }
    
    // MARK: MPC methods
    
    func subtractTime() {
        
        seconds -= 1
        timerLabel.text = "\(seconds)"
        
        if seconds == 0 {
            timer.invalidate()
            
            timerLabel.isHidden = true

            timerActivityIndicator.startAnimating()
            timerActivityIndicator.isHidden = false
            
            if !countdownFinished {
                
                countdownFinished = true
                
                
                if self.drawingView.incrementalImage != nil {
                    let passImage = UIImage(cgImage: self.drawingView.incrementalImage!.cgImage!)
                    if serverStatus?.isServer == true {
                        gameDictionary[dictToDisplayReceivedFrom!]![turnCounter] = passImage
                        
                    } else {
                        
                        let message = messageHandler.createMessage(string: "timer_up", object: passImage, keyForDictionary: keyForReceivedDictionary, ready: nil)
                        messageHandler.sendMessage(messageDictionary: message, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
                        //let passImage = UIImage(CGImage: self.drawingView.incrementalImage!.CGImage!)
                        print("time up non-server drawVC")
                        
                        serverStatus?.isReady()
                    }
                }
            }
        }
    }

    func handleReceivedData(_ notification: Notification){
        
        print("recieved data drawVC")
        
        let message = messageHandler.unwrapReceivedMessage(notification: notification)
        
        if let serverStatus = serverStatus {
            if let message = message {
                
                if (message.object(forKey: "string")? as AnyObject).isEqual("viewDidLoad") == true {
                    let messageDict = message.object(forKey: "object") as! [Int : AnyObject]
                    let receivedKey = message.object(forKey: "key") as! MCPeerID
                    keyForReceivedDictionary = receivedKey
                    
                    print("handleReceivedData: messageArray = \(messageDict) and receivedKey = \(receivedKey)")
                    
                    captionLabel.text = messageDict[turnCounter - 1] as? String
                }
                
                if (message.object(forKey: "string")? as AnyObject).isEqual("timer_up") == true {
                    if serverStatus.isServer == true {
                        let image = message.object(forKey: "object") as! UIImage
                        let receivedKey = message.object(forKey: "key") as! MCPeerID
                        
                        gameDictionary[receivedKey]![turnCounter] = image
                    }
                }
                
                if (message.object(forKey: "ready")? as AnyObject).isEqual("ready") == true {
                    if serverStatus.isServer == true {
                        serverStatus.checkReady()
                    }
                }
                
                if (message.object(forKey: "string")? as AnyObject).isEqual("ExitSegue") == true {
                    
                    print("DrawVC ExitSegue message received")
                    
                    let messageDict = message.object(forKey: "object") as! [MCPeerID : [Int : AnyObject]]
                    exitDictionary = messageDict
                    
                    self.performSegue(withIdentifier: "ExitSegue", sender: self)
                    
                } else if (message.object(forKey: "string")? as AnyObject).isEqual("ToCaption") == true {
                    
                    self.performSegue(withIdentifier: "ToCaption", sender: self)
                    
                } else if (message.object(forKey: "string")? as AnyObject).isEqual("Start Over") == true {
                    self.performSegue(withIdentifier: "RestartSegue", sender: self)
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
            
            // this sends messages for the segue
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
        print("arrayForOrder - \(arrayForOrder)\n")
        
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
