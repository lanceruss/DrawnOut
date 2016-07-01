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
    
    var isServer = Bool()
    var id: MCPeerID?
    
    var arrayForReadyCheck: Array<String>?
    
    let messageHandler = MessageHandler()
    
    init(serverStatus: Bool, peerID: MCPeerID) {
        
        isServer = serverStatus
        id = peerID
        
    }
    
    // Call this to have each client send a message to the server that says they are ready
    
    func isReady(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if isServer == false {
            
            let readyMessage = ["string" : "ready"]
            
            messageHandler.sendMessage(messageDictionary: readyMessage, appDelegate: appDelegate)
    }
    }
    
    func checkReady() -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var clientsReady = false
        
        if isServer == true {
            if let arrayForReadyCheck = arrayForReadyCheck {
                if arrayForReadyCheck.count == appDelegate.mpcHandler.mcSession.connectedPeers.count {
                    clientsReady = true
                }
            }
        }
        return clientsReady
    }
    
    // Call this to have the server send a given message once all the clients are ready 
    
    func serverSendOnReady(message: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if isServer == true {
            let message = ["string" : message]
            
            messageHandler.sendMessage(messageDictionary: message, appDelegate: appDelegate)

        }
}
    
}