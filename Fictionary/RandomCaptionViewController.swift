//
//  RandomCaptionViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 6/29/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class RandomCaptionViewController: UIViewController {

    @IBOutlet weak var captionLabel: UILabel!
    
    var captions = ["making a pizza",
                    "delivering mail",
                    "playing hopscotch",
                    "setting up a tent",
                    "the cow jumped over the moom",
                    "shopping at the mall",
                    "baking bread",
                    "decorating for a party",
                    "asking for an autograph",
                    "playing with play dough",
                    "flying a kite",
                    "being a flight attndant",
                    "walking with crutches",
                    "filming a movie",
                    "walking through a haunted house",
                    "milking a cow",
                    "operating a jackhammer"]
    
    @IBAction func dismissButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let randomIndex = Int(arc4random_uniform(UInt32(self.captions.count)))
        self.captionLabel.text = captions[randomIndex]

    }


    @IBAction func onShuffleButtonTapped(sender: AnyObject) {
        
        let randomIndex = Int(arc4random_uniform(UInt32(self.captions.count)))
        self.captionLabel.text = captions[randomIndex]
    }
}
