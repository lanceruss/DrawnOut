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

    func createMessage(string: String?, object: AnyObject?, keyForDictionary: MCPeerID?, ready: String?) -> [String : AnyObject] {
       
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var stringForMessage: String!
        var objectForMessage: AnyObject!
        var readyMessage: String!
        var key: MCPeerID!
        
        if object == nil {
            objectForMessage = "" as AnyObject!
        } else {
            objectForMessage = object
        }
        
        if keyForDictionary == nil {
            key = appDelegate.mpcHandler.mcSession.myPeerID
        } else {
            key = keyForDictionary
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
        
        let messageDictionary: [String : AnyObject] = ["string" : stringForMessage as AnyObject, "object" : objectForMessage, "key" : key, "ready" : readyMessage as AnyObject]
        
        return messageDictionary
    }
    
    // Takes an NSDictionary and an instance of the appDelegate as the parameters and sends that data to all of the connected peers. Remember that a device only sends the messages to everyone else, so any action you need to happen should ALSO be called on the device locally.
    func sendMessage(messageDictionary: [String : AnyObject], toPeers: [MCPeerID], appDelegate: AppDelegate) {
            let archiverHelper = ArchiverHelper()
        
            do {
                
                // Turn the NSDictionary that is passed in into an NSData object called messageData
                let messageData = archiverHelper.archiveData(data: messageDictionary as NSDictionary)

                if let messageData = messageData {
                
                    // Send the messageData object to all of the connected peers
                    try appDelegate.mpcHandler.mcSession.send(messageData as Data, toPeers: toPeers, with: MCSessionSendDataMode.reliable)
                }
            } catch {
                print("error during MessageHandler.sendMessage(): \(error)")
            }
    }
    
    // Takes in the NSNotification that is sent by the MPCHandler when data is received and returns an NSDictionary that can be checked to handle the message as appropriate.
    func unwrapReceivedMessage(notification: Notification) -> NSDictionary? {
        let archiverHelper = ArchiverHelper()
        var message: NSDictionary?

        
        // Get the userInfo object contained in the notification that is passed in. This contains an objectForKey("data") that is the NSData that is sent. It also contains an objectForKey("peerID") which contains the peerID of the device that sent the data if we ever need to access that information. Note that here we are not yet handling the peerID data.
        let userInfo = notification.userInfo!
        let receivedData: Data = userInfo["data"] as! Data
        
        // Use the archiverHelper to unwrap the NSData and return an NSDictionary option whch can be used to handle the data appropriately.
        message = archiverHelper.unarchiveData(data: receivedData)

        // Return the NSDictionary optional.
        return message
    }
    
}
