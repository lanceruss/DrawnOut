//
//  EndGameViewImageVC.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/11/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class EndGameViewImageVC: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    
    var imagePassed: UIImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()


    
    
    
    }

    
    @IBAction func onCloseButtonTapped(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }

}
