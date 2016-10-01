//
//  MPCHandler.swift
//  Fictionary
//
//  Created by Caleb Talbot on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import MultipeerConnectivity

@objc protocol MPCHandlerDelegate {
    
    // Currently unused, but this delegate method will allow you to monitor when connectedDevices changes in real time. You can use this to do things when devices are connecting (state.Connecting), become connected (state.Connected) or become disconnected (state.NotConnected).
    optional func connectedDevicesChanged(manager : MPCHandler, connectedDevices: [String], state: MCSessionState)
    
}

class MPCHandler: NSObject {

    var player: Player!
    
    // This message is used so that the MPCHandler can identify that advertisements are for our game and so that the browser knows to look for advertisements for our game
    let gameServiceType = "play-fictionary"
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var serviceBrowser: MCBrowserViewController!
    var serviceAdvertiser: MCAdvertiserAssistant? = nil
    
    var mpcHandlerDelegate: MPCHandlerDelegate?
    
    // Get an instance of the ArchiverHelper
    var archiveHelper = ArchiverHelper()
    
    override init() {
        super.init()
        
        // Initialize the mpcHandler with the current devices MCPeerID. This MUST be done before initializing an MCSession or the app will crash.
        setupPeerWithDisplayName(UIDevice.currentDevice().name)
        

    }
    
    func setupPeerWithDisplayName (displayName: String) {
        
            peerID = MCPeerID(displayName: displayName)

    }
    
    // Setup an MCSession that the device can invite other devices to join.
    func setupSession() {
        mcSession = MCSession(peer: peerID)
        mcSession.delegate = self
    }
    
    // Setup a service browser as an MCBrowserViewController that can be used to invite other devices to join the mcSession. The MCBrowserViewController is provided by Apple and is a standard interface for allowing devices to connect through MPC. You can use a different browser class (I forget the name) to create a custom invitation system.
    func setupBrowser() {
        
        serviceBrowser = MCBrowserViewController(serviceType: gameServiceType, session: mcSession)

    }
    
    // Start advertising that the device is available for connections when you pass in true and stop when we pass in false (we do not do this and it does not cause problems... but that functionality is there if we need it later). The advertiser takes in the serviceType to be sure to only advertise that its available for connections in our game.
    func startAdvertising(advertise: Bool) {
        if advertise {
            serviceAdvertiser = MCAdvertiserAssistant(serviceType: gameServiceType, discoveryInfo: nil, session: mcSession)
            serviceAdvertiser!.start()
        } else {
            serviceAdvertiser?.stop()
            serviceAdvertiser = nil
        }
    }
    
}

// An enum that returns a string for the devices MCSessionState. This is helpful for debugging purposes because you can print the status and such.
extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
            
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
            
        }
    }
}

// The MCSessionDelegate is used to handle changes in connection state and to handle sending/receiving data/resources. We are passing around NSData objects from device to device. However, you should note that it is better to pass around images as resources (which uses NSURL). For simplicity, we are not doing this and it hasn't caused problems. If the data becomes too big and connection issues result, we can look into using resources as an alternative.
extension MPCHandler: MCSessionDelegate {
    
    // Monitors MCSessionState and sends a notification when the state changes. We are not currently monitoring for these notifications, but we can if we need to do so. This function is also printing out the state of the devices so we can monitor it in the debugger.
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("peer: \(peerID) did changeState: \(state.stringValue())")
        
        let userInfo = ["peerID" : peerID, "state" : state.stringValue()]
        let notification = NSNotification(name: "MPC_NewPeerNotification", object: nil, userInfo: userInfo)
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationQueue.defaultQueue().enqueueNotification(notification, postingStyle: NSPostingStyle.PostASAP)
            //            NSNotificationCenter.defaultCenter().postNotificationName("MPC_NewPeerNotification", object: nil, userInfo: userInfo)
        }
    }
    
    // When any data is received, this function sends a notification regarding the same. The notification contains a dictionary called userInfo that has the data in NSData format and the peerID of the device from which the data was received. We monitor for the notification using an observer elsewhere in the app.
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
        let userInfo = ["data" : data, "peerID" : peerID]
        
        let notification = NSNotification(name: "MPC_DataReceived", object: nil, userInfo: userInfo)
        
        dispatch_async(dispatch_get_main_queue()) { 
//            NSNotificationCenter.defaultCenter().postNotificationName("MPC_DataReceived", object: nil, userInfo: userInfo)
            NSNotificationQueue.defaultQueue().enqueueNotification(notification, postingStyle: NSPostingStyle.PostASAP)

        }
    }
    
    // We do not use this, but this function can send a stream of data. From what I read, you can send streams of sensors (i.e., the camera, the accelerometer, etc.). Note that we MUST implement this function because it is a required MCSessionDelegate method even though we are not using it.
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceiveStream: \(streamName)")
    }
    
    // Notifies the device that a resource has been received. We are not currently using this, but I have a notification in place in case we decide to go this route. Note that we MUST implement this function even if we do not use it because it is a required MCSessionDelegate method.
    // There is maybe some potential with this? - L
    // Oh nvm don't be an idiot Lance - L
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
        let resource = ["name" : resourceName, "peerID" : peerID, "url" : localURL]
        
        dispatch_async(dispatch_get_main_queue()) { 
            NSNotificationCenter.defaultCenter().postNotificationName("MPC_ResourceReceived", object: resource)
        }
        print("didFinishReceivingResourceWithName: \(resourceName)")
    }
    
    // Can be used to notify the device that it has started receiving a resource. Resources are unique in that the device is notified when it starts receiving one and when it finishes receiving one. This allows the device to monitor progress. Contrast this with didReceiveData, which only notifies the device at the time that the data has actually been received (e.g., the receipt has finished). Note that we MUST implement this function because it is a required MCSessionDelegate method even though we are not using it.
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("didStartReceivingResourceWithName: \(resourceName)")
    }
    
}

