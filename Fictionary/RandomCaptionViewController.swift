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
    
    @IBOutlet var timerLabel: UILabel!
    var secondsAllowed = 10
    var seconds = 0
    var timer = NSTimer()
    var passDictionary = [String : AnyObject]()
    
    var captions = ["making a pizza",
                    "delivering mail",
                    "playing hopscotch",
                    "setting up a tent",
                    "the cow jumped over the moon",
                    "shopping at the mall",
                    "baking bread",
                    "decorating for a party",
                    "asking for an autograph",
                    "playing with play dough",
                    "flying a kite",
                    "being a flight attendant",
                    "walking with crutches",
                    "filming a movie",
                    "walking through a haunted house",
                    "milking a cow",
                    "operating a jackhammer"]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let randomIndex = Int(arc4random_uniform(UInt32(self.captions.count)))
        self.captionLabel.text = captions[randomIndex]
        
        seconds = secondsAllowed
        timerLabel.text = "\(seconds)"
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(TimerViewController.subtractTime), userInfo: nil, repeats: true)
    }


    @IBAction func onShuffleButtonTapped(sender: AnyObject) {
        
        let randomIndex = Int(arc4random_uniform(UInt32(self.captions.count)))
        self.captionLabel.text = captions[randomIndex]
    }
    
    func subtractTime() {
        
        seconds-=1
        timerLabel.text = "\(seconds)"
        
        if seconds == 0 {
            timer.invalidate()
            performSegueWithIdentifier("ToDrawing", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToDrawing" {
            let dvc = segue.destinationViewController as! DrawViewController
            dvc.recievedCaption = captionLabel.text
        }
    }
    
}
