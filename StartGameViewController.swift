//
//  StartGameViewController.swift
//  Fictionary
//
//  Created by Caleb Talbot on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class StartGameViewController: UIViewController, MPCHandlerDelegate {
    
    let archiverHelper = ArchiverHelper()
    
    var appDelegate: AppDelegate!
    
    var userInfoToSend: NSData?
    
    var connectedUsers = [[String : AnyObject]]()
    var receivedImageData = [[String : AnyObject]]()
    
    @IBOutlet weak var connectedDevicesLabel: UILabel!
    
    @IBOutlet var peerImageView: [UIImageView]!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Get instance of the AppDelegate and the MPCHandler that was instantiated there for global use
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler = MPCHandler()
        appDelegate.mpcHandler?.mpcHandlerDelegate = self
        
        // Observe for notification of incoming data
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleReceivedData), name: "MPC_DataReceived", object: nil)
        
    }
    
    //    @IBAction func sendString(sender: AnyObject) {
    //
    //        let randomNumber = "\(arc4random())"
    //
    //        let stringData = randomNumber.dataUsingEncoding(NSUTF8StringEncoding)
    //
    //        let peers = appDelegate.mpcHandler?.session.connectedPeers
    //
    //        appDelegate.mpcHandler?.sendDataToDevice(data: stringData!, peerIDs: peers!)
    //
    //    }
    
    func handleReceivedData(notification: NSNotification) {
        let userInfo = notification.object as! Dictionary<String, AnyObject>
        let data = userInfo["data"] as? NSData
        let senderPeerID = userInfo["peerID"] as? String
        
        if let data = data {
            let unarchivedData = archiverHelper.unarchiveData(data: data) as? NSData
            
            if let unarchivedData = unarchivedData {
                let image = UIImage(data: unarchivedData)
                
                if let senderPeerID = senderPeerID {
                    if let image = image {
                        let imageData: [String : AnyObject] = ["peerID" : senderPeerID, "image" : image]
                        
                        receivedImageData.append(imageData)
                        
                    }
                    
                    displayConnectedUsers()
                    //                    print(senderPeerID)
                }
            }
        }
    }
    
    func sendDataToNewPeer(newPeer: MCPeerID, state: MCSessionState) {
        if state == MCSessionState.Connected {
            if let userInfoToSend = self.userInfoToSend {
                let data = self.archiverHelper.archiveData(data: userInfoToSend)
                if let data = data {
                    let peer = [newPeer]
                    appDelegate.mpcHandler.sendDataToDevice(data: data, peerIDs: peer)
                }
            }
        }
    }
    
    func connectedDevicesChanged(manager: MPCHandler, connectedDevices: [String], state: MCSessionState) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.connectedDevicesLabel.text = "Connected Devices: \(connectedDevices)"
            
//            let newPeers = connectedDevices
//            //            var peersToReceiveData = [String]()
//            
//            if state == MCSessionState.Connected {
//                for peer in newPeers {
//                    if !(connectedDevices.contains(peer)) {
//                        if let userInfoToSend = self.userInfoToSend {
//                            let data = self.archiverHelper.archiveData(data: userInfoToSend)
//                            if let mpcHandler = self.appDelegate.mpcHandler {
//                                let peers = mpcHandler.session.connectedPeers
//                                
//                                if let data = data {
//                                    self.appDelegate.mpcHandler?.sendDataToDevice(data: data, peerIDs: peer)
//                                    
//                                }
//                            }
//                        }
//                        
//                    }
//                }
//            }
//            
//            //            if state == MCSessionState.Connected {
//            //                                for image in self.receivedImageData {
//            //                    let peerID = image["peerID"] as? String
//            //                    if let peerID = peerID {
//            //                        if connectedDevices.contains(peerID) == false {
//            //                            self.connectedUsers.append(image)
//            //                        }
//            //                    }
//            //                }
//            //            }
//        }
    }
    }
    
    
    func displayConnectedUsers() {
        
        for index in 0 ..< connectedUsers.count {
            
            let user = connectedUsers[index]
            
            let image = user["image"] as? UIImage
            _ = user["peerID"] as? String
            
            peerImageView[index].hidden = false
            peerImageView[index].image = image
        }
        
    }
}




