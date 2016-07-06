//
//  MessageHandler.swift
//  Fictionary
//
//  Created by Caleb Talbot on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MessageHandler: NSObject {

    func createMessage(string string: String?, object: AnyObject?, ready: String?) -> [String : AnyObject] {
       
        var stringForMessage: String!
        var objectForMessage: AnyObject!
        var readyMessage: String!
        
        if object == nil {
            objectForMessage = ""
        } else {
            objectForMessage = object
        }
        
        if string == nil {
            stringForMessage = ""
        } else {
            stringForMessage = string
        }
        
        if ready == nil {
            readyMessage = ""
        } else {
            readyMessage = ready
        }
        
        let messageDictionary: [String : AnyObject] = ["string" : stringForMessage, "object" : objectForMessage, "ready" : readyMessage]
        
        return messageDictionary
    }
    
    // Takes an NSDictionary and an instance of the appDelegate as the parameters and sends that data to all of the connected peers. Remember that a device only sends the messages to everyone else, so any action you need to happen should ALSO be called on the device locally.
    func sendMessage(messageDictionary messageDictionary: [String : AnyObject], toPeers: [MCPeerID], appDelegate: AppDelegate) {
            let archiverHelper = ArchiverHelper()
        
            do {
                
                // Turn the NSDictionary that is passed in into an NSData object called messageData
                let messageData = archiverHelper.archiveData(data: messageDictionary)

                if let messageData = messageData {
                
                    // Send the messageData object to all of the connected peers
                    try appDelegate.mpcHandler.mcSession.sendData(messageData, toPeers: toPeers, withMode: MCSessionSendDataMode.Reliable)
                }
            } catch {
                print("error during MessageHandler.sendMessage(): \(error)")
            }
    }
    
    // Takes in the NSNotification that is sent by the MPCHandler when data is received and returns an NSDictionary that can be checked to handle the message as appropriate.
    func unwrapReceivedMessage(notification notification: NSNotification) -> NSDictionary? {
        let archiverHelper = ArchiverHelper()
        var message: NSDictionary?

        
        // Get the userInfo object contained in the notification that is passed in. This contains an objectForKey("data") that is the NSData that is sent. It also contains an objectForKey("peerID") which contains the peerID of the device that sent the data if we ever need to access that information. Note that here we are not yet handling the peerID data.
        let userInfo = notification.userInfo!
        let receivedData: NSData = userInfo["data"] as! NSData
        
        // Use the archiverHelper to unwrap the NSData and return an NSDictionary option whch can be used to handle the data appropriately.
        message = archiverHelper.unarchiveData(data: receivedData)

        // Return the NSDictionary optional.
        return message
    }
    
}
