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
    
    optional func connectedDevicesChanged(manager : MPCHandler, connectedDevices: [String], state: MCSessionState)
    
    optional func sendDataToNewPeer(newPeer: MCPeerID, state: MCSessionState)
    
    optional func sendDataToDevice(data data: NSData, peerID: MCPeerID)
    
}

class MPCHandler: NSObject {

    let gameServiceType = "play-fictionary"
    
    let peerID: MCPeerID
    
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    
    var serviceBrowser: MCNearbyServiceBrowser
    
    var mcSession: MCSession
    
    var mpcHandlerDelegate: MPCHandlerDelegate?
    
    var archiveHelper = ArchiverHelper()
    
    // Function to set up the PeerID and pass in a string which can be displayed to identify the user (this string can be anything)
//    func setupPeerWithDisplayName(displayName displayName: String) {
//
//        
//    }

    // Functions to begin Advertising and stop Advertising using the peerID that we set up above and to set up a Browser
    override init() {
        
        peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: gameServiceType)
        
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: gameServiceType)
        
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        
        super.init()
        
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        
        mcSession.delegate = self
        
    }
    
    deinit {
        
        serviceAdvertiser.stopAdvertisingPeer()
        serviceAdvertiser.delegate = nil
        
        serviceBrowser.stopBrowsingForPeers()
        serviceBrowser.delegate = nil
        
    }
    
    func  sendImage(imageData: NSData, peerIDs: [MCPeerID]) {
        do {
            try self.mcSession.sendData(imageData, toPeers: peerIDs, withMode: MCSessionSendDataMode.Reliable)
        } catch {
            print("\(error)")
        }
    }
    
    func sendDataToDevice(data data: NSData, peerIDs: [MCPeerID]) {
        
        //archive the data to send
        
        do {
            try self.mcSession.sendData(data, toPeers: peerIDs, withMode: MCSessionSendDataMode.Reliable)
        } catch {
                print("\(error)")
            }
        }
}

extension MPCHandler : MCNearbyServiceAdvertiserDelegate {
    // MCNearbyServiceAdvertiserDelegate Functions
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        
        print("Advertiser did not start advertising: \(error)")
        
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("Invitation received from \(peerID)")
        let accept = self.mcSession.myPeerID.hashValue > peerID.hashValue
//        let start = NSDate()
//        let timeInterval = start.timeIntervalSinceNow
//        var peerRunningTime = NSTimeInterval()
//        peerRunningTime = archiveHelper.unarchiveData(data: context!) as! NSTimeInterval
//        let isPeerOlder = (peerRunningTime > timeInterval)
        invitationHandler(accept, self.mcSession)
        if accept {
            advertiser.stopAdvertisingPeer()
        }
    }
    
}

extension MPCHandler : MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("did not start browsing for peers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundPeer: \(peerID)")
        print("invitePeer: \(peerID)")
//        let start = NSDate()
//        let timeInterval = start.timeIntervalSinceNow
//        let context = archiveHelper.archiveData(data: timeInterval)
//        let size = sizeof(NSTimeInterval)
//        let context = NSData(bytes: &timeInterval, length: size)
        browser.invitePeer(peerID, toSession: self.mcSession, withContext: nil, timeout: 30)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer: \(peerID)")
    }
    
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
            
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
            
        default: return "Unknown"
        }
    }
}

extension MPCHandler: MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("peer: \(peerID) did changeState: \(state.stringValue())")
        
        let connectedDevices = mcSession.connectedPeers.connectedPeers.map({$0.displayName})
        self.mpcHandlerDelegate!.connectedDevicesChanged!(self, connectedDevices: mcSession.connectedPeers.map({$0.displayName}), state: state)
        
        self.mpcHandlerDelegate?.sendDataToNewPeer!(peerID, state: state)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
//        print("didReceiveData: \(data)")
        
        let userInfo = ["data" : data, "peerID" : peerID]
        
        dispatch_async(dispatch_get_main_queue()) { 
            NSNotificationCenter.defaultCenter().postNotificationName("MPC_DataReceived", object: userInfo)
        }
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        certificateHandler(true)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceiveStream: \(streamName)")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
        let resource = ["name" : resourceName, "peerID" : peerID, "url" : localURL]
        
        dispatch_async(dispatch_get_main_queue()) { 
            NSNotificationCenter.defaultCenter().postNotificationName("MPC_ResourceReceived", object: resource)
        }
        print("didFinishReceivingResourceWithName: \(resourceName)")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("didStartReceivingResourceWithName: \(resourceName)")
    }
    
}

