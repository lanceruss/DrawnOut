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

    func sendMessage(messageDictionary messageDictionary: [String : AnyObject], appDelegate: AppDelegate) {
        
            let message = messageDictionary
        
            do {
                let messageData = try NSJSONSerialization.dataWithJSONObject(message, options: NSJSONWritingOptions.PrettyPrinted)
                try appDelegate.mpcHandler.mcSession.sendData(messageData, toPeers: appDelegate.mpcHandler.mcSession.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch {
                print("error during MessageHandler.sendMessage(): \(error)")
            }
    }
    
    func unwrapReceivedMessage(notification notification: NSNotification) -> NSDictionary? {
        let userInfo = notification.userInfo!
        let receivedData: NSData = userInfo["data"] as! NSData
        
        var message: NSDictionary?
        
        do {
            message = try NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
        } catch {
            print("error during unwrapReceivedMessage: \(error)")
        }
        return message
    }
    
}
