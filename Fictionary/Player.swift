//
//  Player.swift
//  Fictionary
//
//  Created by Ernie Barojas on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class Player: NSObject {
    
    var displayName: String?
    var email: String?
    var firebaseUID: String?
    var facebookUID: String?
    var photoURL: NSURL?
    
    init(displayName: String) {
        self.displayName = displayName
    }

}
