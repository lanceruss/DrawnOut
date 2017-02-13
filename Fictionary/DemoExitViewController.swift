//
//  DemoExitViewController.swift
//  Fictionary
//
//  Created by Caleb Talbot on 7/7/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class DemoExitViewController: UIViewController {

    var exitDictionary = [MCPeerID : [Int : AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.medAquamarine()
        
        let timer = RevisedCircleTimerView()
        
        timer.setUpTimer(45)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
