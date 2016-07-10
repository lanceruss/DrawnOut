//
//  ViewStackViewController.swift
//  AlbumFlowTest
//
//  Created by Ernie Barojas on 7/6/16.
//  Copyright © 2016 Ernie Barojas. All rights reserved.
//

import UIKit

class ViewStackViewController: UIViewController {

    var stackID = Int()
    
    @IBOutlet weak var stackIDLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.stackIDLabel.text = "\(stackID)"
        

    }

    @IBAction func onDismissTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
