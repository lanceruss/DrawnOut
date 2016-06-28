//
//  MPCHandler.swift
//  Fictionary
//
//  Created by Caleb Talbot on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MPCHandler: NSObject, MCNearbyServiceAdvertiserDelegate {

    var gameServiceType = "play-game"
    
    var peerID: MCPeerID!
    var session: MCSession!
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    
    // Function to set up the PeerID and pass in a string which can be displayed to identify the user (this string can be anything)
    func setupPeerWithDisplayName(displayName displayName: String) {
        
        self.peerID = MCPeerID(displayName: displayName)
        
    }
    
    // Functions to begin Advertising and stop Advertising using the peerID that we set up above
    func beginAdvertising() {
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: gameServiceType)
        
        serviceAdvertiser.delegate = self
        
        serviceAdvertiser.startAdvertisingPeer()
        
    }
    
    func stopAdvertising() {
        
        serviceAdvertiser.stopAdvertisingPeer()
        
    }
    
    // MCNearbyServiceAdvertiserDelegate Functions
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        
        print("Advertiser did not start advertising: \(error)")
        
    }
}
