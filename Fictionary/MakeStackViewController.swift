//
//  MakeStackViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/11/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class MakeStackViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let dictionary = ["<MCPeerID: 0x14590ff70 DisplayName = Ernie's iPhone>":
                            ["2": "<UIImage: 0x1447e53d0>, {640, 960}",
                             "3": "iPhone",
                             "1": "iPhone",
                             "4": "<UIImage: 0x1459083e0>, {640, 960}"]
        ]
        
        
        for (key,value) in dictionary {
            print("\(key) - \(value)")
        }

    
    
    
    }


    
}
