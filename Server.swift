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
    var serverPeerID: MCPeerID?
    var playersInOrder: NSMutableDictionary?
    var nextPlayer: MCPeerID?
    
    // Init a Server object with a bool that declares whether the device is a server (true) or client (false) and the peerID in case we need that data later.
    init(serverStatus: Bool) {
        
        isServer = serverStatus
        
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
                let notification = NSNotification(name: "Server_Ready", object: nil)
                NSNotificationQueue.defaultQueue().enqueueNotification(notification, postingStyle: NSPostingStyle.PostASAP)
            }
    }
    
    // This could be modified to create more dynamic experiences
    func gameOverCheck(turn: Int) -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var isGameOver = false
        
        if turn == (appDelegate.mpcHandler.mcSession.connectedPeers.count + 2) {
            isGameOver = true
        }
        
        return isGameOver
    }
    
    func reorderArray(arrayToReorder: [MCPeerID]) -> [MCPeerID] {
        
        var reorderedArray = arrayToReorder
        
        let itemToMove = reorderedArray.first
        reorderedArray.removeFirst()
        reorderedArray.append(itemToMove!)
        return reorderedArray
    }
    
    func droppedConnection() {
        
    }
    
}