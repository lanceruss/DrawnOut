//
//  Player.swift
//  Fictionary
//
//  Created by Caleb Talbot on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class Player: NSObject {

    var profilePicture: UIImage!
    var userName: String!
    
    init(withPicture picture: UIImage, name: String) {
        
        profilePicture = picture
        userName = name
        
    }
    
}
