//
//  Server.swift
//  Fictionary
//
//  Created by Caleb Talbot on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class Server: NSObject {
    
    var countForReadyCheck = 0
    let messageHandler = MessageHandler()
    
    var isServer = Bool()
    var id: MCPeerID?
    var playersInOrder: NSMutableDictionary?
    var nextPlayer: MCPeerID?
    
    // Init a Server object with a bool that declares whether the device is a server (true) or client (false) and the peerID in case we need that data later.
    init(serverStatus: Bool, peerID: MCPeerID) {
        
        isServer = serverStatus
        id = peerID
        
    }
    
    
    // Call this to have each client send a message to the server that says they are ready
    
    func isReady(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if isServer == false {
            
            let readyMessage = messageHandler.createMessage(string: nil, object: nil, keyForDictionary: nil, ready: "ready")
            
            messageHandler.sendMessage(messageDictionary: readyMessage, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, appDelegate: appDelegate)
        }
    }
    
    func checkReady() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
            countForReadyCheck = countForReadyCheck + 1
            if countForReadyCheck == appDelegate.mpcHandler.mcSession.connectedPeers.count {
                NSNotificationCenter.defaultCenter().postNotificationName("Server_Ready", object: nil)
            }
    }
    
    func gameOverCheck(arrayToCheck: [AnyObject]) -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var isGameOver = false
        
        if arrayToCheck.count == (appDelegate.mpcHandler.mcSession.connectedPeers.count + 2) {
            isGameOver = true
        }
        
        return isGameOver
    }
    
}